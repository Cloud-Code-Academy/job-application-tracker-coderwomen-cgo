/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
//

@isTest
public class StaleJobAppScheduleTest{
    @isTest 
    static void testScheduledJobRunsBatch() {
        List<Job_Application__c> apps = new List<Job_Application__c>{
            // stale & eligible (older than 30 days, status ≠ Closed/Accepted)
            new Job_Application__c(
                Name='App-Stale'
            ),
            // not stale (only 10 days old)
            new Job_Application__c(
                Name='App-Fresh'
            ),
            // stale but already Closed (should be skipped)
            new Job_Application__c(
                Name='App-AlreadyClosed'
            )
        };
        insert apps;
       
        job_Application__C ja1 = [SELECT Id,Name,Status__c,Notes__c FROM Job_Application__c WHERE Name = 'App-Stale' LIMIT 1];
        ja1.Status__c = 'Applying';
        update ja1;
        ja1.Follow_up_Date__c = Date.today().addDays(-31);
        update ja1;
        job_Application__C ja2 = [SELECT Id,Name,Status__c,Notes__c FROM Job_Application__c WHERE Name = 'App-AlreadyClosed' LIMIT 1];
        ja2.Status__c = 'Closed';
        update ja2;
        
        Test.startTest();
        StaleJobAppSchedule stalejobs = new StaleJobAppSchedule(); 
            String jobId = System.schedule(
                'Test StaleJobAppSchedule',
                 '0 0 12 * * ?',
                stalejobs
            );
            stalejobs.execute(null);
        Test.stopTest();
          //stalejobs.execute(null);
         Job_Application__c staleApp       = [SELECT Status__c, Notes__c FROM Job_Application__c WHERE Name='App-Stale'];
        Job_Application__c freshApp       = [SELECT Status__c, Notes__c FROM Job_Application__c WHERE Name='App-Fresh'];
        Job_Application__c alreadyClosed  = [SELECT Status__c, Notes__c FROM Job_Application__c WHERE Name='App-AlreadyClosed'];
        
        System.assertNotEquals(null, jobId, 'Scheduled job should return a job ID.');
        System.assertEquals('CLOSED', staleApp.Status__c, 'status should be set to closed');
        System.assert(staleApp.Notes__c.contains('Closed by automated process on'),
            'Expected automated close note'
        );
        System.assertEquals(null, alreadyClosed.Notes__c, 'automated process should not append note');
    }
}
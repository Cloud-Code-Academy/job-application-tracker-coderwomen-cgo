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
//no Follow_Up_Date__c history records older than 30 days
//follow-up was “reset” to 31 days ago (stale → should close)
//recent follow-up (not stale → should stay Open)
//Application already Accepted (even if stale → should stay Accepted)
@isTest
public class StaleJobAppScheduleTest{

    @isTest
    static void testNoHistoryToClose() {
       Job_Application__c ja = new Job_Application__c(
            Salary__c = 100000     
        );
        insert ja;

        Test.startTest();
         new StaleJobAppSchedule().execute(null);
        Test.stopTest();

        ja = [SELECT Status__c FROM Job_Application__c WHERE Id = :ja.Id];
        System.assertEquals(
            'SAVED',
            ja.Status__c,
            'With no old history entries, nothing should close.'
        );
    }

    @isTest
    static void testRecentStaleJobApp() {
        Job_Application__c ja = new Job_Application__c(
            Salary__c = 100000     
        );
        insert ja;
        ja.Status__c = 'Applying';
        update ja;

        Test.startTest();
         new StaleJobAppSchedule().execute(null);
        Test.stopTest();

        ja = [SELECT Status__c FROM Job_Application__c WHERE Id = :ja.Id];
        System.assertEquals(
            'APPLYING',
            ja.Status__c,
            'With just a recent history entry, application should not  close.'
        );
    }

    @isTest
    static void testStaleJobApp() {
        Job_Application__c ja = new Job_Application__c(
            Salary__c = 100000  
        );
        insert ja;
      ja.Status__c = 'Applying';
      ja.Follow_Up_Date__c = Date.today().addDays(2);
        update ja;
      ja.Salary__c = 120000;
       ja.Follow_Up_Date__c = Date.today().addDays(4);
       update ja; 
    
      Job_Application__History staleJobs = [
    SELECT ParentId, CreatedDate
      FROM Job_Application__History
     WHERE ParentId = :ja.Id
        AND  Field = 'Follow_Up_Date__c'
         ORDER BY CreatedDate DESC
        LIMIT 1
];
    //    Job_Application__History hist = [
    //         SELECT CreatedDate
    //           FROM Job_Application__History
    //          WHERE ParentId = :ja.Id
    //            AND Field    = 'Follow_Up_Date__c'
    //          ORDER BY CreatedDate DESC
    //          LIMIT 1
    //     ];
        Datetime oldDate = staleJobs.CreatedDate.addDays(31);
        StaleJobAppSchedule.overrideNow = oldDate;
        Test.startTest();
         new StaleJobAppSchedule().execute(null);
        Test.stopTest();

        ja = [SELECT Status__c FROM Job_Application__c WHERE Id = :ja.Id];
        System.assertEquals(
            'CLOSED',
            ja.Status__c,
            'FOLLOW UP ATE OLDER THAN 30 DAYS, application should close.');
    }

        
}
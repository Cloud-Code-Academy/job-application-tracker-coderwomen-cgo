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
@isTest
public class FollowupFieldUpdateTest {

    /** 
     * When new job applications are create, status is set to 'saved' so
     * follow-up date should be null.
     */
    @isTest 
    static void testNewJobApplication() {
        List <Job_Application__c> newJobApps = new List<Job_Application__c>();
        for(integer i = 0; i < 3; i++){
            newJobApps.add(new Job_Application__c());
        }
        insert newJobApps;

        Test.startTest();
        FollowupFieldUpdate.updateFollowupField(newJobApps,null);
        Test.stopTest();

        system.Assert.areEqual(null, newJobApps[0].Follow_up_Date__c);

    }

    //when job application is changed to Applied, follow up date should populate
    @isTest
    static void testAppliedJobApplication() {
        // Date preDate = Date.today().addDays(4);
        List <Job_Application__c> newJobApps = new List<Job_Application__c>();
        for(integer i = 0; i < 2; i++){
            newJobApps.add(new Job_Application__c());
        }
        insert newJobApps;
        Map<Id, Job_Application__c> oldJobApps = new Map<Id, Job_Application__c>(newJobApps);
    
        newjobApps[0].Status__c = 'Applied';
        newJobApps[1].Status__c = 'Interviewing';

        Test.startTest();
        update newJobApps[0];
        update newJobApps[1];
        Test.stopTest();
         List<Job_Application__c> updated = [SELECT Status__c, Follow_up_Date__c FROM Job_Application__c WHERE Id IN :newJobApps];

            system.Assert.areEqual(Date.today().addDays(4), updated[0].Follow_up_Date__c);
            system.Assert.areEqual(Date.today().addDays(4), updated[1].Follow_up_Date__c);
    }

    @isTest
    static void testUpdatedJobAppWithSavedStatus(){
         List <Job_Application__c> newJobApps = new List<Job_Application__c>();
        for(integer i = 0; i < 2; i++){
            newJobApps.add(new Job_Application__c());
        }
        insert newJobApps;
        Map<Id, Job_Application__c> oldJobApps = new Map<Id, Job_Application__c>(newJobApps);

        newJobApps[0].notes__c = 'Test';
        update newJobApps[0];

        Test.startTest();
        FollowupFieldUpdate.updateFollowupField(newJobApps,oldJobApps);
        Test.stopTest();

        system.Assert.areEqual(null, newJobApps[0].Follow_up_Date__c);

    }
}
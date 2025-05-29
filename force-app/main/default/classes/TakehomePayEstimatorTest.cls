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

 * New App with salary
 * New App without Salary
 * Update App with no salary to have Salary
 * Update Salary of already existing Job App
 * Empty List
 */
@isTest
public class TakehomePayEstimatorTest {
    @TestSetup
    static void jobAppTestData(){
        List<Job_Application__c> testJobAppsSetup = new List<Job_Application__c>{
            new Job_Application__c(Name = 'Test App 1', Salary__c = 100000),
            new Job_Application__c(Name = 'Test App 2')
        };
        insert testJobAppsSetup ;

    }

    @isTest
    static void testJobAppsWithSalary() {
        List<Job_Application__c> testJobApps = [SELECT Id,Salary__c,Federal_Income_Tax__c,Social_Security__c,Medicare_Withholding__c,Yearly_Take_home_Pay__c,Monthly_Take_home_Pay__c,
        Bi_annual_Pay__c,Bi_weekly_Pay__c FROM Job_Application__c WHERE Name = 'Test App 1' LIMIT 1];
        
        Test.startTest();
        TakehomePayEstimatorHandler.calcTakehomePay(testJobApps,null);
        Test.stopTest();


        Job_Application__c withSal = testJobApps[0];
        system.assertNotEquals(null, withSal.Federal_Income_Tax__c, 'Field must have a value');
        system.assertNotEquals(null, withSal.Social_Security__c,'Field must have a value');
        system.assertNotEquals(null, withSal.Medicare_Withholding__c, 'Field must have a value');
        system.assertNotEquals(null, withSal.Yearly_Take_home_Pay__c, 'Field must have a value');
        system.assertNotEquals(null, withSal.Monthly_Take_home_Pay__c, 'Field must have a value');
        system.assertNotEquals(null, withSal.Bi_annual_Pay__c, 'Field must have a value');
        system.assertNotEquals(null, withSal.Bi_weekly_Pay__c, 'Field must have a value');
    }
    
    @isTest
    static void testJobAppsWithNoSalary() {
        List<Job_Application__c> testJobApps = [SELECT Id,Salary__c,Federal_Income_Tax__c,Social_Security__c,Medicare_Withholding__c,Yearly_Take_home_Pay__c,Monthly_Take_home_Pay__c,
        Bi_annual_Pay__c,Bi_weekly_Pay__c FROM Job_Application__c WHERE Name = 'Test App 2' LIMIT 1];
        
        Test.startTest();
        TakehomePayEstimatorHandler.calcTakehomePay(testJobApps,null);
        Test.stopTest();


        Job_Application__c withSal = testJobApps[0];
        system.assertEquals(null, withSal.Federal_Income_Tax__c, 'Field must have a value');
        system.assertEquals(null, withSal.Social_Security__c, 'Field must have a value');
        system.assertEquals(null, withSal.Medicare_Withholding__c, 'Field must have a value');
        system.assertEquals(null, withSal.Yearly_Take_home_Pay__c, 'Field must have a value');
        system.assertEquals(null, withSal.Monthly_Take_home_Pay__c, 'Field must have a value');
        system.assertEquals(null, withSal.Bi_annual_Pay__c, 'Field must have a value');
        system.assertEquals(null, withSal.Bi_weekly_Pay__c, 'Field must have a value');
    }

    @isTest
    static void testNoSalaryToSalary() {
        List<Job_Application__c> testJobApps = [SELECT Id,Salary__c,Federal_Income_Tax__c,Social_Security__c,Medicare_Withholding__c,Yearly_Take_home_Pay__c,Monthly_Take_home_Pay__c,
        Bi_annual_Pay__c,Bi_weekly_Pay__c FROM Job_Application__c WHERE Name = 'Test App 2' LIMIT 1];

        Map<Id,Job_Application__c> oldMap = new Map<Id,Job_Application__c>{testJobApps[0].Id => testJobApps[0]};
        
        testJobApps[0].Salary__c = 90000;
        update testJobApps[0];

        List<Job_Application__c> updatedJobApp = [SELECT Id,Salary__c,Federal_Income_Tax__c,Social_Security__c,Medicare_Withholding__c,Yearly_Take_home_Pay__c,Monthly_Take_home_Pay__c,
        Bi_annual_Pay__c,Bi_weekly_Pay__c FROM Job_Application__c WHERE Id = :testJobApps[0].Id];
        
        Test.startTest();
        TakehomePayEstimatorHandler.calcTakehomePay(updatedJobApp,oldMap);
        Test.stopTest();

        Job_Application__c withSalary = updatedJobApp[0];
        system.assertNotEquals(null, withSalary.Federal_Income_Tax__c, 'Field must have a value');
        system.assertNotEquals(null, withSalary.Social_Security__c, 'Field must have a value');
        system.assertNotEquals(null, withSalary.Medicare_Withholding__c, 'Field must have a value');
        system.assertNotEquals(null, withSalary.Yearly_Take_home_Pay__c, 'Field must have a value');
        system.assertNotEquals(null, withSalary.Monthly_Take_home_Pay__c, 'Field must have a value');
        system.assertNotEquals(null, withSalary.Bi_annual_Pay__c, 'Field must have a value');
        system.assertNotEquals(null, withSalary.Bi_weekly_Pay__c, 'Field must have a value');
    }

    @isTest
    static void testOldSalaryToNewSalary() {
        List<Job_Application__c> testJobApps = [SELECT Id,Salary__c,Federal_Income_Tax__c,Social_Security__c,Medicare_Withholding__c,Yearly_Take_home_Pay__c,Monthly_Take_home_Pay__c,
        Bi_annual_Pay__c,Bi_weekly_Pay__c FROM Job_Application__c WHERE Name = 'Test App 1' LIMIT 1];

        Map<Id,Job_Application__c> oldMap = new Map<Id,Job_Application__c>{testJobApps[0].Id => testJobApps[0]};
        
        testJobApps[0].Salary__c = 120000;
        update testJobApps[0];

        List<Job_Application__c> updatedSalaryApp = [SELECT Id,Salary__c,Federal_Income_Tax__c,Social_Security__c,Medicare_Withholding__c,Yearly_Take_home_Pay__c,Monthly_Take_home_Pay__c,
        Bi_annual_Pay__c,Bi_weekly_Pay__c FROM Job_Application__c WHERE Id = :testJobApps[0].Id];
        
        Test.startTest();
        TakehomePayEstimatorHandler.calcTakehomePay(updatedSalaryApp,oldMap);
        Test.stopTest();

        Job_Application__c withSalary = updatedSalaryApp[0];
        
        system.assertNotEquals(testJobApps[0].Federal_Income_Tax__c, withSalary.Federal_Income_Tax__c, 'Federal Tax Amount should be updated');
        system.assertNotEquals(testJobApps[0].Social_Security__c, withSalary.Federal_Income_Tax__c, 'Federal Tax Amount should be updated');
        system.assertNotEquals(testJobApps[0].Medicare_Withholding__c, withSalary.Federal_Income_Tax__c, 'Federal Tax Amount should be updated');
        system.assertNotEquals(testJobApps[0].Bi_annual_Pay__c, withSalary.Federal_Income_Tax__c, 'Federal Tax Amount should be updated');
        system.assertNotEquals(testJobApps[0].Yearly_Take_home_Pay__c, withSalary.Federal_Income_Tax__c, 'Federal Tax Amount should be updated');
        system.assertNotEquals(testJobApps[0].Bi_weekly_Pay__c, withSalary.Federal_Income_Tax__c, 'Federal Tax Amount should be updated');
        system.assertNotEquals(testJobApps[0].Monthly_Take_home_Pay__c, withSalary.Federal_Income_Tax__c, 'Federal Tax Amount should be updated');
        
    }

     @isTest
    static void testEmptyJobApplicationList() {
        // Create an empty list of Job_Application__c records
        List<Job_Application__c> jobApps = new List<Job_Application__c>();

        // Start test context
        Test.startTest();
        TakehomePayEstimatorHandler.calcTakehomePay(jobApps,null);
        Test.stopTest();

        // Query for any tasks that might have been created
        List<job_Application__C> savedApps = [SELECT Id FROM job_Application__C WHERE Id IN :jobApps];

        // Assert that no tasks are created
        System.assertEquals(0, savedApps.size(), 'Expected no job application to be created for an empty job application list');
    }
}
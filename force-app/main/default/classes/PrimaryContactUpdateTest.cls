@isTest
public with sharing class PrimaryContactUpdateTest {
  //test for no contacts
  //test for account with contacts and no direct contact
  //testfor directcontact and no account contact
  //test for account with contacts and direct contact
    @isTest
    static void testNoContacts() {
        List<Job_Application__c> jobApps = new List<Job_Application__c>();
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        for (Integer i = 0; i < 5; i++) {
            jobApps.add(new Job_Application__c(CompanyName__c = acc.Id));
        }
        insert jobApps;

        Test.startTest();
        PrimaryContactUpdate.PrimaryContactFieldUpdate(jobApps);
        Test.stopTest();

        jobApps = [SELECT Id, Primary_Contact__c FROM Job_Application__c WHERE Id IN :jobApps];
        for (Job_Application__c jobApp : jobApps) {
            System.assertEquals(null, jobApp.Primary_Contact__c, 'Primary contact should be null');
        }
    }

    @isTest
    static void testJobAppContacts(){
     List<Job_Application__c> jobApps = new List<Job_Application__c>();
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        for (Integer i = 0; i < 5; i++) {
          jobApps.add(new Job_Application__c(CompanyName__c = acc.Id));
      }
      insert jobApps;

        List<Contact> contacts = new List<Contact>();
        for (integer i = 0; i < jobApps.size(); i++) {
             for (Job_Application__c jobApp : jobApps) {
            contacts.add(new Contact(
                FirstName = 'Test' + i,
                LastName = 'Contact',
                Job_Application__c = jobApp.Id
            ));
        }
        }
        insert contacts;
        
        List<Job_Application__c> updateJobAppsWithContact = [SELECT Id, description__c, Primary_Contact__c FROM Job_Application__c WHERE Id IN :jobApps];
        for (Job_Application__c jobApp : updateJobAppsWithContact) {
            jobApp.description__c ='Test';
        }
        update updateJobAppsWithContact;

        Test.startTest();
        PrimaryContactUpdate.PrimaryContactFieldUpdate(updateJobAppsWithContact);
        Test.stopTest();


        jobApps = [SELECT Id, Primary_Contact__c FROM Job_Application__c WHERE Id IN :updateJobAppsWithContact];
        for (Integer i = 0; i < updateJobAppsWithContact.size(); i++) {
            System.assertEquals(contacts[i].Id, updateJobAppsWithContact[i].Primary_Contact__c, 'Primary contact should be updated');
        }
   }

    @isTest
    static void testAccountContact(){
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        List<Job_Application__c> jobApps = new List<Job_Application__c>();
         for (Integer i = 0; i < 2; i++) {
            jobApps.add(new Job_Application__c(CompanyName__c = acc.Id));
         }
        insert jobApps; 
        List<Contact> accContacts = new List<Contact>();
        accContacts.add(new Contact(FirstName = 'Account', LastName = 'Contact', AccountId = acc.Id));
        insert accContacts;
        
        List<Job_Application__c> JobAppsWithAccountContact = [SELECT Id, Salary__c, Primary_Contact__c FROM Job_Application__c WHERE Id IN :jobApps];
        for (Job_Application__c jobApp : JobAppsWithAccountContact ) {
            jobApp.description__c ='Test';
        }
        update JobAppsWithAccountContact ;

        Test.startTest();
        PrimaryContactUpdate.PrimaryContactFieldUpdate(JobAppsWithAccountContact);
        Test.stopTest();


        jobApps = [SELECT Id, Primary_Contact__c FROM Job_Application__c WHERE Id IN :JobAppsWithAccountContact ];
        for (Integer i = 0; i < JobAppsWithAccountContact.size(); i++) {
            System.assertEquals(accContacts[0].Id, JobAppsWithAccountContact[i].Primary_Contact__c, 'Primary contact should be updated');
        }

    }
 
    
    @isTest
    static void testAccountContactAndDirectContacts(){
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact c = new Contact(FirstName = 'Account', LastName = 'Contact', AccountId = acc.Id);
        insert c;
        List<Job_Application__c> jobApps = new List<Job_Application__c>();
         for (Integer i = 0; i < 2; i++) {
            jobApps.add(new Job_Application__c(CompanyName__c = acc.Id));
         }
        insert jobApps;
        Contact contact = new Contact(FirstName = 'Direct', LastName = 'Contact', Job_Application__c = jobApps[0].Id);
        insert contact;
        Id jaId = JobApps[0].Id;

        List<Job_Application__c> JobAppsWithBothContact = [SELECT Id, Salary__c, Primary_Contact__c FROM Job_Application__c WHERE Id = :jaId];
        for (Job_Application__c jobApp : JobAppsWithBothContact ) {
            jobApp.Salary__c = 100000;
        }
        update JobAppsWithBothContact;

        Test.startTest();
        PrimaryContactUpdate.PrimaryContactFieldUpdate(JobAppsWithBothContact);
        Test.stopTest();

        jobApps = [SELECT Id, Primary_Contact__c FROM Job_Application__c WHERE Id IN :JobAppsWithBothContact];
         System.assertEquals(contact.Id, JobAppsWithBothContact[0].Primary_Contact__c, 'Primary contact should be updated to Direct Contact');
        

    }

}

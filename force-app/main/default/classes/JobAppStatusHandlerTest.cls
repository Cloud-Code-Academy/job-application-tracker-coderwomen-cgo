@isTest
public with sharing class JobAppStatusHandlerTest {

@isTest
    static void testCreateSavedTaskRecords() {
        List<Job_Application__c> jobApps = new List<Job_Application__c>();
        for (Integer i = 0; i < 4; i++) {
            jobApps.add(new Job_Application__c());  
        }
        
        
        Test.startTest();
        insert jobApps;
        Test.stopTest();

        List<Task> savedTasks = [SELECT Id, Status, WhatId, ActivityDate, Subject FROM Task WHERE WhatId IN :jobApps];
        
        System.assertEquals(12, savedTasks.size(), 'Expected 12 tasks to be created');
    }

   
@isTest
    static void testCreateTaskRecords() {
        List<Job_Application__c> newJobs = new List<Job_Application__c>();
        for (Integer i = 0; i < 2; i++) {
           newJobs.add(new Job_Application__c());
        }
        insert newJobs;
        
        Map<Id, Job_Application__c> oldJobApps = new Map<Id, Job_Application__c>(newJobs);

        Test.startTest();
        for(Job_Application__c  ja: newJobs){
            ja.Status__c = 'Applying';
        }
        update NewJobs;
        Test.stopTest();
        
        List<Task> tasks = [SELECT Id, WhatId FROM Task WHERE WhatId IN :newJobs];
        System.assertEquals(16, tasks.size(), 'Expected 16 task Records');
    }


    @isTest
    static void testEmptyJobApplicationList() {
        List<Job_Application__c> jobApps = new List<Job_Application__c>();
        insert jobApps;
        Test.startTest();
       JobAppStatusHandler.createTasksForStatus(jobApps,null);
        Test.stopTest();

        List<Task> savedTasks = [SELECT Id FROM Task WHERE WhatId IN :jobApps];

        System.assertEquals(0, savedTasks.size(), 'Expected no tasks to be created for an empty job application list');
    }

    @isTest
    static void testCreateTasksForStatusNoStatusChange() {
        List<Job_Application__c> jobApps =  new List<Job_Application__c>();
        for (Integer i = 0; i < 2; i++) {
           jobApps.add(new Job_Application__c());
        }
        insert jobApps;
        jobApps[0].Description__c = 'Updated description';  

        Test.startTest();
        update jobApps; // No tasks should be created.
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId IN :jobApps];
        System.assertEquals(6, tasks.size(), 'There should be only 6 tasks');
    }
 

}

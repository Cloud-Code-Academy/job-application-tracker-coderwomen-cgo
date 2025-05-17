public with sharing class  JobAppStatusHandler {

     public static void createSavedTaskRecords(List<Job_Application__c> newJobAppList){
        List<Task> savedTasks = new List<Task>();
        for (Job_Application__c jobApplication : newJobAppList) {
            if (jobApplication.Status__c == 'Saved') {
               savedTasks.add(new Task(
            		Status= 'Not Started', WhatId = jobApplication.Id, ActivityDate = date.today() + 1, Subject = 'Check if the job description aligns with your interests and values')); 
                    savedTasks.add(new Task(
            		Status= 'Not Started', WhatId = jobApplication.Id, ActivityDate = date.today() + 1, Subject = 'Review the highlighted skills to see if the role is a good fit'));
                    savedTasks.add(new Task(
            		Status= 'Not Started', WhatId = jobApplication.Id, ActivityDate = date.today() + 1, Subject = 'Research the company or role and mark your excitement level'));    
        }
    }
        if (!savedTasks.isEmpty()) {
            insert savedTasks;
        }
     }
   
    // Define Task templates per status
    public static void createTaskRecords(List<Job_Application__c> jobAppList) {
        List<Task> taskList = new List<Task>();
        for (Job_Application__c jobApp : jobAppList) {
            if (jobApp.Status__c == 'Applying') {
                 taskList.add(new Task(
            		Status= 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 2, Subject = 'Find and research someone who works at the company and add them as a contact'));
                    taskList.add(new Task(
            		Status= 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 2, Subject = 'Set up an informational interview to learn more about the role/company'));
                     taskList.add(new Task(
            		Status= 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 2, Subject = 'Identify potential referrals to help get your application on the top of the pile'));
                     taskList.add(new Task(
            		Status= 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 2, Subject = 'Customize your work achievements using the job description keywords'));
                     taskList.add(new Task(
            		Status= 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 2, Subject = 'Submit your application on the company website if possible'));
            } else if (jobApp.Status__c == 'Applied') {
                 taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 4, Subject = 'Reach out to the hiring manager or recruiter'));
                    taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 4, Subject = 'Follow up on your application via email weekly'));
                     taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 4, Subject = 'Continue identifying and saving similar job opportunities'));
                     taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 7, Subject = 'Set up weekly networking calls to explore similar companies/roles'));
            } else if (jobApp.Status__c == 'Interviewing') {
                 taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 1, Subject = 'Prepare your blurb or “tell me about yourself” response'));
                     taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 2, Subject = 'Practice answering behavioral interview questions'));
                     taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 2, Subject = 'Research the company and your interviewers'));
                     taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 1, Subject = 'Set up your virtual interview space and test your tech'));
                     taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 1, Subject = 'Send thank you emails within 24 hours'));
            } else if (jobApp.Status__c == 'Negotiating') {
                 taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 3, Subject = 'Research your market value and know your numbers'));
                     taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 4, Subject = 'Prepare your negotiation scripts'));
                     taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 4, Subject = 'Evaluate your offer and decline or accept'));
            } else if (jobApp.Status__c == 'Accepted') {
                 taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 2, Subject = 'Plan your resignation if applicable'));
                     taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 4, Subject = 'Take some time to relax and recharge'));
                     taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 4, Subject = 'Prepare for your first day of onboarding'));
            } else {
                taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 1, Subject = 'Send a follow-up email thanking the interviewer and asking for feedback'));
                     taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 4, Subject = 'Review your notes and reflect on areas of improvement'));
            }
        }
        if (!taskList.isEmpty()) {
        insert taskList;
    }
    }

   
}
public class JobAppStatusHandler {
    // Define Task templates per status
    public static void createTaskRecords(List<Job_Application__c> jobAppList) {
        List<Task> taskList = new List<Task>();
        for (Job_Application__c jobApp : jobAppList) {
            if (jobApp.Status__c == 'Saved') {
                    taskList.add(new Task(
            		Status= 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 1, Subject = 'Check if the job description aligns with your interests and values'));
            } else if (jobApp.Status__c == 'Applying') {
                 taskList.add(new Task(
            		Status= 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 2, Subject = 'Find and research someone who works at the company and add them as a contact'));
            } else if (jobApp.Status__c == 'Applied') {
                 taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 4, Subject = 'Follow up on your application via email weekly'));
            } else if (jobApp.Status__c == 'Interviewing') {
                 taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 1, Subject = 'Prepare your blurb or “tell me about yourself” response'));
            } else if (jobApp.Status__c == 'Negotiating') {
                 taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 3, Subject = 'Evaluate your offer and decline or accept'));
            } else if (jobApp.Status__c == 'Accepted') {
                 taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 2, Subject = 'Plan your resignation if applicable'));
            } else {
                taskList.add(new Task(
            		Status = 'Not Started', WhatId = jobApp.Id, ActivityDate = date.today() + 1, Subject = 'Send a follow-up email thanking the interviewer and asking for feedback'));
            }
        }
        if (!taskList.isEmpty()) {
        insert taskList;
    }
    }
}
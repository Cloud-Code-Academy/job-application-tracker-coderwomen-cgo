public with sharing class JobAppStatusHandler{
    public static void createTasksForStatus(List<Job_Application__c> jobApps){

        List<Task> tasksToInsert = new List<Task>();
        for(Job_Application__c ja: jobApps){
            string status = ja.Status__c;
            if(status =='Saved'){
                 tasksToInsert.addAll(new List<Task>{
            		new Task(Status= 'Not Started', WhatId = ja.Id, ActivityDate = date.today() + 1, Subject = 'Check if the job description aligns with your interests and values'), 
                   new Task(Status= 'Not Started', WhatId = ja.Id, ActivityDate = date.today() + 1, Subject = 'Review the highlighted skills to see if the role is a good fit'),
                   new Task(Status= 'Not Started', WhatId = ja.Id, ActivityDate = date.today() + 1, Subject = 'Research the company or role and mark your excitement level')});
                } else if(status == 'Applying'){
                    tasksToInsert.addAll(new List<Task>{
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 2,
                             Subject='Find and research someone who works at the company and add them as a contact'),
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 2,
                             Subject='Set up an informational interview to learn more about the role/company'),
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 2,
                             Subject='Identify potential referrals to help get your application on the top of the pile'),
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 2,
                             Subject='Customize your work achievements using the job description keywords'),
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 2,
                             Subject='Submit your application on the company website if possible')
                });
                } else if (Status == 'Applied'){
                    tasksToInsert.addAll(new List<Task>{
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 3,
                             Subject='Reach out to the hiring manager or recruiter'),
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 3,
                             Subject='Follow up on your application via email weekly'),
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 3,
                             Subject='Continue identifying and saving similar job opportunities'),
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 3,
                             Subject='Set up weekly networking calls to explore similar companies/roles')
                });
                }  else if (Status == 'Interviewing') {
                Integer dayOffset = 4;
                tasksToInsert.addAll(new List<Task>{
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 4,
                             Subject='Prepare your blurb or “tell me about yourself” response'),
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 4,
                             Subject='Practice answering behavioral interview questions'),
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 4,
                             Subject='Research the company and your interviewers'),
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 4,
                             Subject='Set up your virtual interview space and test your tech'),
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 4,
                             Subject='Send thank you emails within 24 hours')
                });
            }
            else if (Status == 'Negotiating') {
                Integer dayOffset = 5;
                tasksToInsert.addAll(new List<Task>{
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 5,
                             Subject='Research your market value and know your numbers'),
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 5,
                             Subject='Prepare your negotiation scripts'),
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 5,
                             Subject='Evaluate your offer and decline or accept')
                });
            }
            else if (Status == 'Accepted') {
                Integer dayOffset = 6;
                tasksToInsert.addAll(new List<Task>{
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 6,
                             Subject='Plan your resignation if applicable'),
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 6,
                             Subject='Take some time to relax and recharge'),
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 6,
                             Subject='Prepare for your first day of onboarding')
                });
            }
            else if (Status == 'Closed') {
                Integer dayOffset = 1;
                tasksToInsert.addAll(new List<Task>{
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 1,
                             Subject='Send a follow-up email thanking the interviewer and asking for feedback'),
                    new Task(Status='Not Started', WhatId=ja.Id, ActivityDate=date.today() + 1,
                             Subject='Review your notes and reflect on areas of improvement')
                });
    }
}

    if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
    }
}
}
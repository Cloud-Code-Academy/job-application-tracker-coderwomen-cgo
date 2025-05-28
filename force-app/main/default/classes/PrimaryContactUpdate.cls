public with sharing class PrimaryContactUpdate {
     public static void primaryContactFieldUpdate(List<Job_Application__c> jobApplications) {
            List<Job_Application__c> jobAppsNoPc = new List<Job_Application__c>();
        for (Job_Application__c jobApp : jobApplications) {
            if (jobApp.Primary_Contact__c == null ) {
                jobAppsNoPc.add(jobApp);
            }
        }

        if (jobAppsNoPc.isEmpty()) {
            return;
        }

        //Check if there are contacts related to the job application
        List<Contact> contacts = [SELECT Id, FirstName,LastName,Job_Application__c FROM Contact WHERE Job_Application__c IN :jobAppsNoPc];
       Map<Id, Contact> jobAppToContactMap = new Map<Id, Contact>();
       if (contacts != null && !contacts.isEmpty()) {
        for (Contact c : contacts) {
            if (c.job_Application__C != null && !jobAppToContactMap.containsKey(c.Job_Application__c)) {
                jobAppToContactMap.put(c.Job_Application__c, c);
            }
        }
       }
       
    // Check if there are Contacts related to the Account of the Job Application
    List<Job_Application__c> apps = [SELECT Id, CompanyName__c FROM Job_Application__c WHERE Id IN :jobAppsNoPc];   
    Map<Id, Account> jobAppToAccountMap = new Map<Id, Account>([SELECT Id, Name, (SELECT FirstName, LastName FROM Contacts LIMIT 1)  FROM Account WHERE Id IN (SELECT CompanyName__c FROM Job_Application__c WHERE Id IN :apps)]);
    Map<Id, Contact> jobAppToContact = new Map<Id, Contact>();
    for (Job_Application__c ja : apps) {
        Account acc = jobAppToAccountMap.get(ja.CompanyName__c );
         if (acc != null && !acc.Contacts.isEmpty()) {
          jobAppToContact.put(ja.Id, acc.Contacts[0]);
  }
}  


        for (Job_Application__c jobs : jobAppsNoPc) {
            if (jobAppToContactMap.containsKey(jobs.Id)) {
                jobs.Primary_Contact__c = jobAppToContactMap.get(jobs.Id).Id;
            } else {
                 if (jobAppToContact.containsKey(jobs.Id)) {
                  jobs.Primary_Contact__c = jobAppToContact.get(jobs.Id).Id;
                }
        
    }
}
}
}
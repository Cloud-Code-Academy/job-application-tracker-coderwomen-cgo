public class ReminderEmailBatch implements Database.Batchable<SObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext context) {
        // Define time window: Events starting in 24 hours ± 30 minutes
        Datetime now = Datetime.now();
        Datetime startTime = now.addHours(24);
        Datetime endTime = startTime.addMinutes(30);

        System.debug('Running ReminderEmailBatch start() at: ' + now);
        System.debug('StartTime: ' + startTime + ', EndTime: ' + endTime);

        String query = 'SELECT Id, StartDateTime, Job_Application__c, Job_Application__r.Name, Subject, EndDateTime, OwnerId, WhatId, ' +
                    'WhoId, Interviewer__c, Interview_Date_Time__c ' +
                    'FROM Event ' +
                    'WHERE StartDateTime >= :startTime ' + 
                    'AND StartDateTime <= :endTime ' + 
                    'AND Subject LIKE \'%Interview%\'';
        System.debug('SOQL Query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Event> scope) {
        List<Event> events = (List<Event>) scope;
        System.debug('----ReminderEmailBatch Execute() ---');
        System.debug('Number of Events in Scope: ' + events.size());

        Set<Id> ownerIds = new Set<Id>();
        for (Event ev : events) {
            if (ev.OwnerId != null && ev.OwnerId.getSObjectType() == User.SObjectType) {
                ownerIds.add(ev.OwnerId);
            }
        }

        Map<Id, User> users = new Map<Id, User>();
        if (!ownerIds.isEmpty()) {
            users = new Map<Id, User>([
                SELECT Id, Email 
                FROM User 
                WHERE Id IN :ownerIds AND Email != null
            ]);
            System.debug('Resolved User Emails: ' + users.keySet());
        }

        List<Messaging.SingleEmailMessage> batch = new List<Messaging.SingleEmailMessage>();

        for (Event event : events) {
            if (users.containsKey(event.OwnerId)) {
                String jobName = '';
                if (event.Job_Application__r != null) {
                    jobName = event.Job_Application__r.Name;
                }           
                
                String body = 'Get your dress shoes on and practice your speaking skills!<br/>' +
                            '<strong>For the job:</strong> ' + jobName + '<br/>' +
                            '<strong>At: </strong> ' +  ((DateTime)event.get('StartDateTime')).format();

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { users.get(event.OwnerId).Email });
                mail.setSubject('Interview Reminder');
                mail.setHtmlBody(body);
                mail.setSaveAsActivity(false);
                batch.add(mail);

                System.debug('Queued email for: ' + users.get(event.OwnerId).Email);

                if (batch.size() == 10) {
                    Messaging.sendEmail(batch);
                    batch.clear();
                }
            }
        }

        // Send any remaining emails
        if (!batch.isEmpty()) {
            Messaging.sendEmail(batch);
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug('ReminderEmailBatch completed successfully.');
    }
}

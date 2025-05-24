public class ReminderEmailBatch implements Database.Batchable<SObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext context) {
        // Define time window: Events starting in 24 hours ± 30 minutes
        Datetime now = Datetime.now();
        Datetime startTime = now.addHours(24);
        Datetime endTime = startTime.addMinutes(30);

    System.debug('Running ReminderEmailBatch start() at: ' + now);
    System.debug('StartTime: ' + startTime + ', EndTime: ' + endTime);

        
        String query = 'SELECT Id, StartDateTime, Subject, EndDateTime, OwnerId ' +
                    'FROM Event ' +
                    'WHERE StartDateTime >= :startTime ' + 
                    'AND StartDateTime <= :endTime' + 
                    ' AND Subject LIKE \'%Interview%\'';
        System.debug('SOQL Query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        List<Event> events = (List<Event>) scope;
        System.debug('----RemindeEmailBatch Execute() ---');
        System.debug('Number of Events in Scope ' + events.size() );
        
        for (Event ev : events) {
        System.debug('Event: ' + ev.Subject + ' | Start: ' + ev.StartDateTime + ' | OwnerId: ' + ev.OwnerId);
        }

        Set<Id> ownerIds = new Set<Id>();

        for (Event ev : events) {
            if (ev.OwnerId != null && ev.OwnerId.getSObjectType() == User.SObjectType) {
                ownerIds.add(ev.OwnerId);
            }
        }

        Map<Id, User> users = new Map<Id, User>();
        
        if (!ownerIds.isEmpty()){
                users = new Map<Id, User> ([SELECT Id, Email FROM User WHERE Id IN :ownerIds AND Email != null]
            );
            System.debug('which users? ' +users);
        }
            Id templateId;
            try {
                templateId = [
                    SELECT Id 
                    FROM EmailTemplate 
                    WHERE DeveloperName = 'Interview_Day_Before_Reminder' 
                    LIMIT 1
                ].Id;
                System.debug('Using Email Template ID: ' + templateId);

            } catch (Exception e) {
                System.debug('Email template not found: ' + e.getMessage());
                return;
            }

        List<Messaging.SingleEmailMessage> batch = new List<Messaging.SingleEmailMessage>();

        for (Event event : events) {
            System.debug('OwnerId: ' + event.OwnerId);
            System.debug('User map keys: ' + users.keySet());

            if (users.containsKey(event.OwnerId)) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(users.get(event.OwnerId).Id);
                mail.setTemplateId(templateId);
                mail.setSaveAsActivity(false);
                batch.add(mail);
                System.debug('Queued email for: ' + users.get(event.OwnerId).Email);


                if (batch.size() == 10) {
                    Messaging.sendEmail(batch);
                    batch.clear();
                }
            }
        }
            // Send any remaining emails (<10)
            if (!batch.isEmpty()) {
                Messaging.sendEmail(batch);
            }
        }    
        public void finish(Database.BatchableContext context) {
            System.debug('ReminderEmailBatch completed successfully.');
        }
    }


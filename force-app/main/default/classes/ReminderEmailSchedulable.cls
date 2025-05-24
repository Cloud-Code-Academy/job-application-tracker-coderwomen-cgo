public with sharing class ReminderEmailSchedulable implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch( new ReminderEmailBatch(), 200);
    }
}




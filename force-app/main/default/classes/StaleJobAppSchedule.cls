public with sharing class StaleJobAppSchedule implements Schedulable {
    public void execute(SchedulableContext sc) {
        StaleJobAppBatch batch = new StaleJobAppBatch(); 
       Database.executeBatch(batch, 200);
    }
}

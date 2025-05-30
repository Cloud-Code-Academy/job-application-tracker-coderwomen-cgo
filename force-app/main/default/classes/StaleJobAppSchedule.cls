public with sharing class StaleJobAppSchedule implements Schedulable {
    public static void execute(SchedulableContext sc) {
       Database.executeBatch(new StaleJobAppBatch(), 200);
    }
}

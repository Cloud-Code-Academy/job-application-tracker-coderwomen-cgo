trigger JobAppStatusTrigger on Job_Application__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        JobAppStatusHandler.createTaskRecords(Trigger.new);
    }
}

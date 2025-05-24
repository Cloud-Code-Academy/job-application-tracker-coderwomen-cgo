trigger JobAppStatusTrigger on Job_Application__c (before insert,before update,after insert, after update) {
     
    if (Trigger.isbefore && (Trigger.isInsert || Trigger.isUpdate)) {
       PrimaryContactUpdate.PrimaryContactFieldUpdate(Trigger.new);
    }
    
    if (Trigger.isAfter && Trigger.isInsert) {
         JobAppStatusHandler.createSavedTaskRecords(Trigger.new);
          
         
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        JobAppStatusHandler.createTaskRecords(Trigger.new);
       
    }
}

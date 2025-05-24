trigger JobAppStatusTrigger on Job_Application__c (before insert,before update,after insert, after update) {
     
    if (Trigger.isbefore &&  Trigger.isUpdate) {
       PrimaryContactUpdate.primaryContactFieldUpdate(Trigger.new);
       FollowupFieldUpdate.updateFollowupField(Trigger.new);
    }
    
    if (Trigger.isAfter) {
         JobAppStatusHandler.createTasksForStatus(Trigger.new);
         }
}

trigger InterviewEventTrigger on Event (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            EventValidatorHandler.validateInterviewTimeConflicts(Trigger.new);
        }
    }
}

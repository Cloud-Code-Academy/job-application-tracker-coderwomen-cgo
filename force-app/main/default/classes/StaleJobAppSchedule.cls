global class StaleJobAppSchedule implements Schedulable {
     @TestVisible
    private static DateTime overrideNow;
    global void execute(SchedulableContext sc) {
         DateTime nowDT = (overrideNow != null) 
                         ? overrideNow 
                         : DateTime.now();
        Date cutoffDate = nowDT.date().addDays(-30);
        DateTime cutoff = DateTime.newInstance(cutoffDate, Time.NewInstance(0,0,0,0));

        List<Job_Application__History> hists = [
            SELECT ParentId
              FROM Job_Application__History
             WHERE Field       = 'Follow_Up_Date__c'
               AND CreatedDate <= :cutoff
        ];

        if (hists.isEmpty()) return;

        Set<Id> staleIds = new Set<Id>();
        for (Job_Application__History h : hists) {
            staleIds.add(h.ParentId);
        }

        List<Job_Application__c> toClose = [
          SELECT Id, Notes__c, Status__c 
            FROM Job_Application__c
           WHERE Id IN :staleIds
             AND Status__c NOT IN ('Closed','Accepted')
        ];

        if (toClose.isEmpty()) return;

        
        for (Job_Application__c ja : toClose) {
            ja.Status__c = 'Closed';
            ja.Notes__c  = 'Closed by automated process on ' +  Date.today();      
        }

        update toClose;
    }
}

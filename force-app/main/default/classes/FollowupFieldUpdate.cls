public with sharing class FollowupFieldUpdate {
    public static void updateFollowupField(List<Job_Application__c> jobApplicationList, Map<Id, Job_Application__c> oldJobApps) {
        //Set<String> skipStatuses = new Set<String>{ 'Accepted', 'Closed','Saved' };
        for (Job_Application__c ja: jobApplicationList) {
             String st = ja.Status__c;
            if ( String.isBlank(st) || st.contains('SAVED') || st.contains('Saved') || ja.Status__c == oldJobApps.get(ja.Id).Status__c ) {
                continue;
            } ja.Follow_Up_Date__c = Date.today().addDays(4);
            
        }
    }
}
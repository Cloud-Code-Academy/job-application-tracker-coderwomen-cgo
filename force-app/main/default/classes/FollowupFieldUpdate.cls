public with sharing class FollowupFieldUpdate {
    public static void updateFollowupField(List<Job_Application__c> jobApplicationList) {
        //Set<String> skipStatuses = new Set<String>{ 'Accepted', 'Closed','Saved' };
        for (Job_Application__c ja: jobApplicationList) {
             String st = ja.Status__c;
            if ( String.isBlank(st) || st.contains('SAVED') ) {
                continue;
            } ja.Follow_Up_Date__c = Date.today().addDays(4);
            
        }
    }
}
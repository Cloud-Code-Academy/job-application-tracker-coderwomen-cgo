public with sharing class StaleJobAppBatch implements Database.Batchable<sObject> {
    private Date cutoff = Date.today().addDays(-30);

    public Database.QueryLocator start(Database.BatchableContext bc){
        return database.getQueryLocator([SELECT Id, Status__c, Follow_up_Date__c, Notes__c 
        FROM Job_Application__c 
        WHERE Status__c NOT IN('Closed','Accepted') 
        AND Follow_up_Date__c <= :cutoff]);
    }

    public void execute(Database.BatchableContext bc, List<Job_Application__c> scope){
        List<Job_Application__c> toUpdate = new List<Job_Application__c>();

        for (Job_Application__c ja : scope) {
            ja.Status__c = 'Closed';
            ja.Notes__c = 'Closed by automated process on ' +  Date.today();
            toUpdate.add(ja);
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    public void finish(Database.BatchableContext bc){}


}
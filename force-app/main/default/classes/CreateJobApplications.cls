public with sharing class CreateJobApplications {

    public static List<Job_Application__c> createEveryApplication(Map<String, Object> jsonJoobleResponseMap) {

        if (jsonJoobleResponseMap == null || jsonJoobleResponseMap.isEmpty()) {
            throw new IllegalArgumentException('jsonJoobleResponseMap must not be null');
        }

        List<Object> jobs = (List<Object>) jsonJoobleResponseMap.get('jobs');
        Set<String> companyNames = new Set<String>();
        List<Map<String, Object>> parsedJobs = new List<Map<String, Object>>();

        for (Object jobObj : jobs) {
            Map<String, Object> job = (Map<String, Object>) jobObj;
            String companyName = (String) job.get('company');

            if (companyName != null) {
                companyNames.add(companyName);
                parsedJobs.add(job);
            }
        }

        Map<String, Account> companyToAccountMap = AccountCreationHelper.getOrCreateAccounts(companyNames);

        List<Job_Application__c> jobAppsInsertList = new List<Job_Application__c>();
        for (Map<String, Object> job : parsedJobs) {
            String companyName = (String) job.get('company'); 
            String jobTitleFull = (String) job.get('title');
            String jobTitle; 
            if (jobTitleFull != null && jobTitleFull.length() > 80) {
                jobTitle = jobTitleFull.substring(0, 77) + '...';
            } else {
                jobTitle = jobTitleFull;
            }

            String jobLocation = (String) job.get('location');
            String description = (String) job.get('snippet');
            String jobLink = (String) job.get('link');

            Job_Application__c jobApp = new Job_Application__c();
            jobApp.Name = jobTitle;
            jobApp.Title__c = jobTitleFull;
            jobApp.Location__c = jobLocation;
            jobApp.Description__c = JobApplicationUtils.cleanDescription(description);
            jobApp.CompanyName__c = companyToAccountMap.get(companyName).Id;

            JobApplicationUtils.SalaryParseResult salary = JobApplicationUtils.parseSalaryFromJob(job);
            jobApp.Salary__c = salary.numeric;
            jobApp.Salary_Display__c = salary.display;   
            if (job.containsKey('salary_val1') && job.containsKey('salary_val2')){
                try{
                    jobApp.Minimum_Salary__c = Decimal.valueOf(String.valueOf(job.get('salary_val1')));
                    jobApp.Maximum_Salary__c = Decimal.valueOf(String.valueOf(job.get('salary_val2')));
                } catch (Exception e){
                    System.debug('Failed to assign Min/Max salary:' +e.getMessage());
                }
            }

            jobApp.URL__c = jobLink;
            jobAppsInsertList.add(jobApp);
        }

        return jobAppsInsertList;
    }
}




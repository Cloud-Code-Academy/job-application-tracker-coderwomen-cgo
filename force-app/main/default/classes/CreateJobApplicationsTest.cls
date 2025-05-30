@isTest
private class CreateJobApplicationsTest {

    @isTest
    static void testJobApplicationCreationAndCompanyLookup() {
        String companyName = 'QualityCo';

        // Jooble API responseBody
        Map<String, Object> fakeJob = new Map<String, Object>{
            'title' => 'QA Analyst',
            'location' => 'Boston, MA',
            'snippet' => 'We need a detail-oriented QA. $70,000/year',
            'salary' => '70,000 USD',
            'company' => companyName
        };

        Map<String, Object> fakeJson = new Map<String, Object>{
            'jobs' => new List<Object>{ fakeJob }
        };

        Test.startTest();
        List<Job_Application__c> jobApps = CreateJobApplications.createEveryApplication(fakeJson);
        Test.stopTest();

        System.assertEquals(1, jobApps.size(), 'One job application should be returned');

        Job_Application__c job = jobApps[0];

        System.assertEquals('QA Analyst', job.Name, 'Job title populated correctly');
        System.assertEquals('Boston, MA', job.Location__c, 'Job location populated correctly');
        System.assertEquals(70000, job.Salary__c, 'Parsed numeric salary stored correctly');
        System.assertEquals('70,000 USD', job.Salary_Display__c, 'Salary display value stored correctly');
        System.assertNotEquals(null, job.CompanyName__c, 'CompanyName__c lookup should be populated');

        List<Account> accs = [SELECT Id, Name FROM Account WHERE Name = :companyName];
        System.assertEquals(1, accs.size(), 'One Account should be created or matched');
        System.assertEquals(accs[0].Id, job.CompanyName__c, 'Job application should link to correct Account');
    }
	
    @isTest
    static void testJobAppjobTitle80() {
        String companyName = 'QualityCo';

        // Jooble API responseBody
        Map<String, Object> longTitleJob = new Map<String, Object>{
            'title' => 'QA Analyst and Programmer and Writer and Tester, who knows a lot of things because we are ridiculous',
            'location' => 'Boston, MA',
            'snippet' => 'We need a detail-oriented QA. $70,000/year',
            'salary' => '',
            'company' => companyName
        };

        Map<String, Object> fakeJson = new Map<String, Object>{
            'jobs' => new List<Object>{longTitleJob}
        };

        Test.startTest();
        List<Job_Application__c> jobApps = CreateJobApplications.createEveryApplication(fakeJson);
        Test.stopTest();

        System.assertEquals(1, jobApps.size(), 'One job application should be returned');

        Job_Application__c job = jobApps[0];

        System.assertNotEquals('QA Analyst and Programmer and Writer and Tester, who knows a lot of ...', job.Name, 'Name was\t cut to 77');
    }
    
    
    @isTest
    static void testJsonJoobleResponseMapIsNull() {
        try {
            CreateJobApplications.createEveryApplication(null);
            System.assert(false, 'Expected exception not thrown for null input');
        } catch (IllegalArgumentException e) {
            System.assertEquals('jsonJoobleResponseMap must not be null', e.getMessage(), 'Correct error message for null input');
        }
    }

    @isTest
    static void testJsonJoobleResponseMapIsEmpty() {
    try {
        Map<String, Object> emptyMap = new Map<String, Object>();
        CreateJobApplications.createEveryApplication(emptyMap);
        System.assert(false, 'Expected exception not thrown for empty input');
    } catch (IllegalArgumentException e) {
        System.assertEquals('jsonJoobleResponseMap must not be null', e.getMessage(), 'Correct error message for empty input');
    }
    }

@isTest
static void testMinMaxSalaryFieldsAreAssigned() {
    String companyName = 'HighSalaryCo';

    Map<String, Object> fakeJob = new Map<String, Object>{
        'title' => 'Senior Consultant',
        'location' => 'Remote',
        'snippet' => 'Earn up to $200k!',
        'salary' => '200,000 USD',
        'salary_val1' => 150000,
        'salary_val2' => 200000,
        'company' => companyName
    };

    Map<String, Object> fakeJson = new Map<String, Object>{
        'jobs' => new List<Object>{ fakeJob }
    };

    Test.startTest();
    List<Job_Application__c> apps = CreateJobApplications.createEveryApplication(fakeJson);
    Test.stopTest();

    System.assertEquals(1, apps.size(), 'Should return one job application');

    Job_Application__c job = apps[0];
    System.assertEquals(150000, job.Minimum_Salary__c, 'Minimum salary assigned correctly');
    System.assertEquals(200000, job.Maximum_Salary__c, 'Maximum salary assigned correctly');
}

    @isTest
    static void testMinMaxSalaryFieldsInvalidCatchBlock() {
        String companyName = 'BrokenSalaryCo';

        Map<String, Object> fakeJob = new Map<String, Object>{
            'title' => 'Buggy Salary Job',
            'location' => 'Nowhere',
            'snippet' => 'This has bad salary data.',
            'salary' => 'invalid!',
            'salary_val1' => 'abc', 
            'salary_val2' => 'def',
            'company' => companyName
        };

        Map<String, Object> fakeJson = new Map<String, Object>{
            'jobs' => new List<Object>{ fakeJob }
        };

        Test.startTest();
        List<Job_Application__c> apps = CreateJobApplications.createEveryApplication(fakeJson);
        Test.stopTest();

        System.assertEquals(1, apps.size(), 'Should return one job application even if salary is malformed');

        Job_Application__c job = apps[0];
        System.assertEquals(null, job.Minimum_Salary__c, 'Invalid salary_val1 should not be assigned');
        System.assertEquals(null, job.Maximum_Salary__c, 'Invalid salary_val2 should not be assigned');
    }

}


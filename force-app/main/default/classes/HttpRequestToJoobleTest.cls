@isTest
private class HttpRequestToJoobleTest {

    //Mock class to simulate callout
    private class MockGetJoobleResponse implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            //Sample JSON mimicking actual API structure
            String mockResponse =  
            '{' +
            '  "totalCount": 1,' +
            '  "jobs": [' +
            '    {' +
            '      "title": "Sales Manager",' +
            '      "location": "San Francisco",' +
            '      "snippet": "This is a great opportunity to join our team...",' +
            '      "salary": "17,600 UAH",' +
            '      "source": "jooble",' +
            '      "type": "Full-time",' +
            '      "link": "https://ua.jooble.org/jdp/12345",' +
            '      "company": "ABC Corp",' +
            '      "updated": "2023-09-15T12:55:35.3870000",' +
            '      "id": 1234567890' +
            '    }' +
            '  ]' +
            '}';
        res.setBody(mockResponse);
        return res;
        }
    }

    @isTest
    public static void testHttpRequestToJooble() {    
    
        Test.setMock(HttpCalloutMock.class, new MockGetJoobleResponse());

        //Setting up the invocable input
        HttpRequestToJooble.JobInputs input = new HttpRequestToJooble.JobInputs();
        input.keywordInput = 'Sales';
        input.locationInput = 'San Francisco';

        List<HttpRequestToJooble.JobInputs> inputs = new List<HttpRequestToJooble.JobInputs>{input};


        Test.startTest();
        HttpRequestToJooble.sendJoobleRequest(inputs);
        Test.stopTest();

        List<Job_Application__c> jobsReturned = [SELECT Name, Id, Description__c, Location__c, CompanyName__c FROM Job_Application__c WHERE Location__c = 'San Francisco' AND Name LIKE '%Sales%'];

        System.assertEquals(1, jobsReturned.size(), 'One job application should be inserted');
        
        Job_Application__c insertedJob = jobsReturned[0];
        System.assertEquals('Sales Manager', insertedJob.Name, 'Proper Name returned');
        System.assert(insertedJob.Description__c.toLowerCase().contains('join our team'), 'Description as expected');
		System.assertEquals('San Francisco', insertedJob.Location__c, 'correct location ' );

    }

    private class MockThrowingCallout implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Simulate an unexpected failure
        throw new CalloutException('Simulated callout failure');
    }
}
@isTest
public static void testHttpRequestToJooble_ExceptionPath() {
    Test.setMock(HttpCalloutMock.class, new MockThrowingCallout());

    HttpRequestToJooble.JobInputs input = new HttpRequestToJooble.JobInputs();
    input.keywordInput = 'FailTest';
    input.locationInput = 'Nowhere';

    List<HttpRequestToJooble.JobInputs> inputs = new List<HttpRequestToJooble.JobInputs>{input};

    Test.startTest();
    HttpRequestToJooble.sendJoobleRequest(inputs);
    Test.stopTest();
    System.assert(true, 'Confirmed method did not throw an exception.');
    }
}
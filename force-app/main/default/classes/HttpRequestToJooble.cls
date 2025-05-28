public with sharing class HttpRequestToJooble {
    
    public class JobInputs{
    @InvocableVariable(label='keyword')
    public String keywordInput;
    
    @InvocableVariable(label='location')
    public String locationInput;
}

    @invocableMethod(label='Get Jooble Jobs' description='Input keyword + location to get relevant jobs')
    
    public static void sendJoobleRequest(List<JobInputs> inputs) {
        if(inputs == null || inputs.isEmpty()) {return;
        }    

        JobInputs input = inputs[0];

        String url = 'https://jooble.org/api/';
        String key = '21eb451a-81e6-478c-b219-9691fe4b4636';
        
        String requestBody = JSON.serialize(new Map<String, String>{
                'keywords' => input.keywordInput,
                'location' => input.locationInput 
        });

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url + key);        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');        
        request.setBody(requestBody);

        String responseBody;

        try {
            HttpResponse response = http.send(request);
            responseBody = response.getBody();
            if(response.getStatusCode() ==200) {
                System.debug('Response Body: ' + responseBody);
                Map<String, Object> jsonJoobleResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                
                List<Job_Application__c> jobAppsInsertList = CreateJobApplications.createEveryApplication(jsonJoobleResponseMap);

                if(jobAppsInsertList.size() > 0) {
                    database.insert(jobAppsInsertList, AccessLevel.USER_MODE);
                }
            } else {
                System.debug('Failed with status code: ' +response.getStatusCode());
            }    
        }catch (Exception e){
            System.debug('Failed callout: ' + e.getMessage());
        }
    }

}
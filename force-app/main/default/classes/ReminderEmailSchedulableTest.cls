
@isTest
private class ReminderEmailSchedulableTest {

    @IsTest
static void testInterviewAtCorrectTime(){

	Datetime now = Datetime.now();
    Datetime eventTime = now.addHours(24).addMinutes(1);

    Contact conIntvwr = new Contact(FirstName = 'Jane', LastName = 'Doe', Email = 'janedoe@company.com');
    insert conIntvwr;

    Event newEv = new Event(Subject = 'Interview tomorrow', WhoId = conIntvwr.Id, StartDateTime = eventTime, DurationInMinutes = 60, OwnerId = UserInfo.getUserId()); 
    
    Event newEv2 = new Event(Subject = 'Interview tomorrow', WhoId = conIntvwr.Id, StartDateTime = eventTime.addMinutes(75), DurationInMinutes = 60, OwnerId = UserInfo.getUserId()
    ); 
    insert new List<Event> {newEv, newEv2};

Test.startTest();
    String jobId = System.schedule(
        'Test Reminder Email Job',
        '0 0 12 * * ?', 
        new ReminderEmailSchedulable()
        );
Test.stopTest();

	System.assertNotEquals(null, jobId, 'Scheduled job should return a job ID.');
	}
}

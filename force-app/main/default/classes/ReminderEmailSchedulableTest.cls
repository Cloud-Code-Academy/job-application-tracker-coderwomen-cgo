
@isTest(SeeAllData=true)
private class ReminderEmailSchedulableTest {

    @IsTest
static void testInterviewAtCorrectTime(){

	Datetime now = Datetime.now();
    Datetime eventTime = now.addHours(24).addMinutes(1);

    Contact conIntvwr = new Contact(FirstName = 'Jane', LastName = 'Doe', Email = 'janedoe@company.com');
    insert conIntvwr;

    Event newEv = new Event(Subject = 'Interview tomorrow', WhoId = conIntvwr.Id, StartDateTime = eventTime, DurationInMinutes = 60, OwnerId = UserInfo.getUserId()); 
    
    Event newEv2 = new Event(Subject = 'Interview tomorrow', WhoId = conIntvwr.Id, StartDateTime = eventTime.addMinutes(15), DurationInMinutes = 60, OwnerId = UserInfo.getUserId()
    ); 
    insert new List<Event> {newEv, newEv2};

    Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Interview_Day_Before_Reminder' LIMIT 1].Id;

Test.startTest();
ReminderEmailHelper.sendReminders(now);
Test.stopTest();

	System.assertEquals(2, Limits.getEmailInvocations(), 'Should have sent 2 emails for the two Events.');
	}
}

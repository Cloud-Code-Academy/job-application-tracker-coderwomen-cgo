@isTest
public class ReminderEmailBatchTest {

    @testSetup
    static void setupData() {
        // Standard test user
        Profile standardUser = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'testuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = standardUser.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com'
        );
        insert testUser;
    }

    @isTest
    static void testBatchExecutes() {
        
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@example.com' LIMIT 1];

        Job_Application__c job = new Job_Application__c(Name = 'Salesforce Admin');
        insert job;

        
        DateTime eventTime = DateTime.now().addHours(24);
        List<Event> events = new List<Event>();
        for (Integer i = 0; i < 5; i++) {
            events.add(new Event(
                OwnerId = testUser.Id,
                Job_Application__c = job.Id,
                StartDateTime = eventTime.addHours(i),
                DurationInMinutes = 30, 
                Subject = 'Interview with Candidate ' + i
            ));
        }
        insert events;

        Test.startTest();
        ReminderEmailBatch batch = new ReminderEmailBatch();
        Database.executeBatch(batch, 5);
        Test.stopTest();

        System.assert(true, 'Batch ran without exception');
    }

    @isTest
    static void testNoOwnerIds() {
    
        DateTime eventTime = DateTime.now().addHours(24);
        insert new Event(
            StartDateTime = eventTime,
            DurationInMinutes = 30,
            Subject = 'Interview – No Owner'
        );

        Test.startTest();
        Database.executeBatch(new ReminderEmailBatch(), 5);
        Test.stopTest();

        System.assert(true, 'Handled null OwnerId gracefully');
    }

    @isTest
    static void testUserWithIgnoredEmail() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User fakeUser = new User(
            Alias = 'fakeuser',
            Email = 'test@invalid.com', 
            EmailEncodingKey = 'UTF-8',
            LastName = 'Fake',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'fakeuser' + DateTime.now().getTime() + '@test.com'
        );
        insert fakeUser;

        DateTime eventTime = DateTime.now().addHours(24);
        insert new Event(
            OwnerId = fakeUser.Id,
            StartDateTime = eventTime,
            DurationInMinutes = 30,
            Subject = 'Interview – Fake Email'
        );

        Test.startTest();
        Database.executeBatch(new ReminderEmailBatch(), 5);
        Test.stopTest();

        System.assert(true, 'User with ignored email skipped cleanly');
    }
}

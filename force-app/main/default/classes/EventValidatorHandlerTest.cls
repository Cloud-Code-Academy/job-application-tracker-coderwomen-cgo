@isTest
public class EventValidatorHandlerTest {

    static User createTestUser() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User user = new User(
            Alias = 'tuser',
            Email = 'tuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'EventTester',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'tuser' + DateTime.now().getTime() + '@example.com'
        );
        insert user;
        return user;
    }

    @isTest
    static void testNoOverlapBetweenNewEvents() {
        User user = createTestUser();
        DateTime base = DateTime.now().addDays(1);

        Event ev1 = new Event(
            Subject = 'Interview with Candidate A',
            OwnerId = user.Id,
            StartDateTime = base,
            DurationInMinutes = 30
        );

        Event ev2 = new Event(
            Subject = 'Interview with Candidate B',
            OwnerId = user.Id,
            StartDateTime = base.addMinutes(45),
            DurationInMinutes = 30
        );

        Test.startTest();
        EventValidatorHandler.validateInterviewTimeConflicts(new List<Event>{ev1, ev2});
        Test.stopTest();

        System.assert(true, 'No overlapping errors should be thrown.');
    }

    @isTest
static void testOverlapWithinSameBatch() {
    User u = createTestUser();
    DateTime base = DateTime.now().addDays(1);

    Event e1 = new Event(
        Subject = 'Interview with Candidate A',
        OwnerId = u.Id,
        StartDateTime = base,
        DurationInMinutes = 60
    );

    Event e2 = new Event(
        Subject = 'Interview with Candidate B',
        OwnerId = u.Id,
        StartDateTime = base.addMinutes(30),
        DurationInMinutes = 30
    );

    Test.startTest();
    try {
        EventValidatorHandler.validateInterviewTimeConflicts(new List<Event>{e1, e2});
        insert new List<Event>{e1, e2}; 
        System.assert(false, 'Expected DML exception due to overlapping events');
    } catch (DmlException ex) {
        System.assert(ex.getMessage().contains('scheduled during this time'), 'Expected overlap error');
    }
    Test.stopTest();
}

        @isTest
        static void testOverlapWithExistingEvents() {
            User u = createTestUser();
            DateTime base = DateTime.now().addDays(1);


            Event existing = new Event(
                Subject = 'Interview with Client X',
                OwnerId = u.Id,
                StartDateTime = base,
                DurationInMinutes = 60
            );
            insert existing;

        
            Event incoming = new Event(
                Subject = 'Interview with Client Y',
                OwnerId = u.Id,
                StartDateTime = base.addMinutes(30),
                DurationInMinutes = 30
            );

            Test.startTest();
            try {
                EventValidatorHandler.validateInterviewTimeConflicts(new List<Event>{incoming});
                insert incoming;
                System.assert(false, 'Expected DML exception due to validation error');
            } catch (DmlException ex) {
                System.assert(ex.getMessage().contains('existing events'), 'Expected error for overlap with existing');
            }
            Test.stopTest();
        }

        @isTest
        static void testDurationFallbackWhenEndDateTimeNull() {
            User user = createTestUser();
            DateTime start = DateTime.now().addDays(2);

            Event e = new Event(
                Subject = 'Interview with Candidate Z',
                OwnerId = user.Id,
                StartDateTime = start,
                DurationInMinutes = 30,
                EndDateTime = null 
            );

            Test.startTest();
            EventValidatorHandler.validateInterviewTimeConflicts(new List<Event>{ e });
            Test.stopTest();

            System.assertNotEquals(null, e.EndDateTime, 'EndDateTime should be derived from DurationInMinutes');
    }
    @isTest
    static void testEventSkippedDueToMissingFields() {
        Event e = new Event(
            Subject = null, 
            OwnerId = null, 
            StartDateTime = null,
            EndDateTime = null
        );

        Test.startTest();
        EventValidatorHandler.validateInterviewTimeConflicts(new List<Event>{ e });
        Test.stopTest();

        System.assertEquals(0, e.getErrors().size(), 'Skipped event should not throw errors');
    }
}

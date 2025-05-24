public with sharing class EventValidatorHandler {

    public static void validateInterviewTimeConflicts(List<Event> newEvents) {
        System.debug('New Event Records: ' + newEvents);

        // Collect all interview events from the input list that have valid fields
        List<Event> newInterviewEvents = new List<Event>();
        Set<Id> userIdsWithNewEvents = new Set<Id>();

        for (Event event : newEvents) {
            if (event.EndDateTime == null && event.DurationInMinutes != null) {
                event.EndDateTime = event.StartDateTime.addMinutes(event.DurationInMinutes);
            }
            
            if(
                event.Subject != null &&
                event.Subject.toLowerCase().contains('interview') &&
                event.OwnerId != null &&
                event.StartDateTime != null &&
                event.EndDateTime != null
            ) {   
                newInterviewEvents.add(event);
                userIdsWithNewEvents.add(event.OwnerId);
            }
        }

        System.debug('Qualified Interview Events for Validation: ' + newInterviewEvents);

        // Query existing interview events in the org (excluding the ones being inserted or updated)
        Map<Id, List<Event>> existingInterviewEventsByUser = new Map<Id, List<Event>>();

        if (!userIdsWithNewEvents.isEmpty()) {
            List<Event> existingEvents = [
                SELECT Id, StartDateTime, EndDateTime, OwnerId, Subject
                FROM Event
                WHERE OwnerId IN :userIdsWithNewEvents
                AND Subject LIKE '%Interview%'
            ];

            for (Event existing : existingEvents) {
                if (!existingInterviewEventsByUser.containsKey(existing.OwnerId)) {
                    existingInterviewEventsByUser.put(existing.OwnerId, new List<Event>());
                }
                existingInterviewEventsByUser.get(existing.OwnerId).add(existing);
            }

            System.debug('Grouped Existing Events by User: ' + existingInterviewEventsByUser);
        }

        // Overlap between new and existing?
        for (Event newEvent : newInterviewEvents) {
            List<Event> existingEventsForUser = existingInterviewEventsByUser.get(newEvent.OwnerId);

            if (existingEventsForUser != null) {
                for (Event existingEvent : existingEventsForUser) {
                    System.debug('Existing Event/s start time: ' + existingEvent.StartDateTime);
                    System.debug('Existing Event/s End time: ' + existingEvent.EndDateTime);
                    System.debug('New Event/s start time: ' + newEvent.StartDateTime);
                    System.debug('New Event/s End time: ' + newEvent.EndDateTime);
                    Boolean isOverlapping =
                        newEvent.StartDateTime < existingEvent.EndDateTime &&
                        newEvent.EndDateTime > existingEvent.StartDateTime;

                    if (isOverlapping) {
                        newEvent.addError('This user already has an Interview event at this time (from existing events).');
                        break;
                    }
                }
            }
        }

        // new interview events in the same batch
        for (Integer i = 0; i < newInterviewEvents.size(); i++) {
            Event firstEvent = newInterviewEvents[i];

            for (Integer j = i + 1; j < newInterviewEvents.size(); j++) {
                Event secondEvent = newInterviewEvents[j];

                if (firstEvent.OwnerId == secondEvent.OwnerId) {
                    Boolean isOverlapping =
                        firstEvent.StartDateTime < secondEvent.EndDateTime &&
                        firstEvent.EndDateTime > secondEvent.StartDateTime;

                    if (isOverlapping) {
                        firstEvent.addError('Another interview event for this user is also scheduled during this time (within this batch).');
                        secondEvent.addError('Another interview event for this user is also scheduled during this time (within this batch).');
                    }
                }
            }
        }
    }
}

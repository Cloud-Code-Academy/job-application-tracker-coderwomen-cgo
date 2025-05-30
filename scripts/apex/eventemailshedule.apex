// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

List<Integer> minutes = new List<Integer>{0, 15, 30, 45};
for (Integer min : minutes) {
    String cron = '0 ' + String.valueOf(min) + ' * * * ?';
    System.schedule('ReminderEmailBatch_' + min, cron, new ReminderEmailSchedulable());
}

List<Integer> minutes = new List<Integer>{0, 15, 30, 45};
for (Integer min : minutes) {
    String cron = '0 ' + String.valueOf(min) + ' * * * ?';
    System.schedule('StaleJobAppBatch_' + min, cron, new StaleJobAppSchedule());
}
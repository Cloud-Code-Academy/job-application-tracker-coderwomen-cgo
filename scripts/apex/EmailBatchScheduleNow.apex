String cron = '0 ' + String.valueOf(Datetime.now().minute() + 1) + ' ' + 
              String.valueOf(Datetime.now().hour()) + ' * * ?';
System.schedule('Test_Immediate_ReminderRun', cron, new ReminderEmailSchedulable());
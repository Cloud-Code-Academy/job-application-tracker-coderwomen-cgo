@isTest
private class AccountCreationHelperTest {

    @isTest
    static void testGetOrCreateAccounts_existingAccount() {
        Account acc = new Account(Name = 'ExistCo');
        insert acc;

        Set<String> companyNames = new Set<String>{ 'ExistCo' };

        Test.startTest();
        Map<String, Account> result = AccountCreationHelper.getOrCreateAccounts(companyNames);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Right count of Accts created.');
        System.assertEquals(acc.Id, result.get('ExistCo').Id, 'Correct Id returned.');
        
        // Ensure no duplicate accounts
        Integer count = [SELECT COUNT() FROM Account WHERE Name = 'ExistCo'];
        System.assertEquals(1, count, 'Should not create a duplicate');
    }

    @isTest
    static void testGetOrCreateAccounts_createsAccount() {
        String name = 'NewCo';
        Set<String> companyNames = new Set<String>{ name };

        Test.startTest();
        Map<String, Account> result = AccountCreationHelper.getOrCreateAccounts(companyNames);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Correct count returned.');
        System.assertEquals(name, result.get(name).Name, 'Correct Account Name.');

        List<Account> created = [SELECT Id FROM Account WHERE Name = :name];
        System.assertEquals(1, created.size(), 'Should create a new Account');
    }
}

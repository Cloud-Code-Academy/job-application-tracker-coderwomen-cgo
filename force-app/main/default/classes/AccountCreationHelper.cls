public with sharing class AccountCreationHelper {
        public static Map<String, Account> getOrCreateAccounts(Set<String> companyNames) {
            Map<String, Account> companyToAccountMap = new Map<String, Account>();
    
            for (Account acc : [SELECT Id, Name FROM Account WHERE Name IN :companyNames]) {
                companyToAccountMap.put(acc.Name, acc);
            }

            List<Account> accountsToInsert = new List<Account>();
            for (String name : companyNames) {
                if (!companyToAccountMap.containsKey(name)) {
                    Account acc = new Account(Name = name);
                    accountsToInsert.add(acc);
                }
            }
            if (!accountsToInsert.isEmpty()) {
                database.insert(accountsToInsert, AccessLevel.USER_MODE);
                for (Account acc : accountsToInsert) {
                    companyToAccountMap.put(acc.Name, acc);
                }
            }
            return companyToAccountMap;
        }
    }
    
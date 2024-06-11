/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Benjamin Pierre
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        Account newAccount = new Account();     
        newAccount.Name = '1804 Capital';      

        insert as user newAccount;
        
        return newAccount.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        Account newAccount = new Account();   
        newAccount.Name = name;
        newAccount.Industry = industry;
        insert as user newAccount;                                  
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        Contact newCon = new Contact();
        String lastName = 'George';
        String firstName = 'Jefferson';
        newCon.FirstName = firstName;
        newCon.LastName = lastName;
        newCon.AccountId = accountId;

        insert as user newCon;

        return newCon.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        Contact contactRecord = [SELECT Id, LastName FROM Contact WHERE Id = :contactId WITH USER_MODE];
        contactRecord.Lastname = newLastName;
        
        update as user contactRecord;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :oppId WITH USER_MODE];
        opp.StageName = newStage;

        update as user opp;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        Account acc = [SELECT Id FROM Account WHERE Id = :accountId WITH USER_Mode];
        acc.Name = newName;
        acc.Industry = newIndustry;
        update as user acc;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        for (Opportunity opp :  opportunities) {
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.today().addMonths(3);
            opp.Amount = 50000;
        }
        upsert as user opportunities; 
    }

    /**
     * Question 8
     * Insert or updates opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        List<Account> accList = [SELECT Id FROM Account WHERE Name = :accountName WITH USER_MODE];
        Account acc;
    
        if (!accList.isEmpty() && accList.size() == 1) {
            acc = accList.get(0);
        } else {
            acc = new Account(Name = accountName);
            insert as user acc;  
        }
        Map<String, Opportunity> existingOppsMap = new Map<String, Opportunity>();
        for (Opportunity opp : [SELECT Id, Name FROM Opportunity WHERE AccountId = :acc.Id WITH USER_MODE]) {
            existingOppsMap.put(opp.Name, opp);
        }
    
        List<Opportunity> oppList = new List<Opportunity>();
    
        for (String oppName : oppNames) {
            Opportunity opp;
            if (existingOppsMap.containsKey(oppName)) {
                opp = existingOppsMap.get(oppName);
            } else {
                opp = new Opportunity(Name = oppName, AccountId = acc.Id);
            }
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.today().addMonths(3);
            opp.Amount = 50000;
    
            oppList.add(opp);
        }
        upsert as user oppList;
    }
    

    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName WITH USER_MODE];
        Account acc;
        if (!accounts.isEmpty() && accounts.size() == 1) {
            acc = accounts.get(0);
            acc.Description = 'Updated Account';
        } else {
            acc = new Account(Name = accountName);
            acc.Description = 'New Account';
        }
        upsert as user acc;
		return acc;
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */

        public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
            Map<String, Account> accountMap = new Map<String, Account>();
            List<Account> accountsToInsert = new List<Account>();
            Set<String> accountNames = new Set<String>();
    
            for (Contact contact : contactsToUpsert) {
                String accountName = contact.LastName;
                if (String.isNotBlank(accountName)) {
                    accountNames.add(accountName);
                }
            }
    
            List<Account> existingAccounts = [SELECT Id, Name FROM Account WHERE Name IN :accountNames WITH USER_MODE];
            for (Account acc : existingAccounts) {
                accountMap.put(acc.Name, acc);
            }
    
            for (Contact contact : contactsToUpsert) {
                String accountName = contact.LastName;
                if (String.isNotBlank(accountName) && !accountMap.containsKey(accountName)) {
                    Account newAcc = new Account(Name = accountName);
                    accountsToInsert.add(newAcc);
                    accountMap.put(accountName, newAcc);
                }
            }
    
            if (!accountsToInsert.isEmpty()) {
                insert as user accountsToInsert;
            }
    
            for (Contact contact : contactsToUpsert) {
                String accountName = contact.LastName;
                if (String.isNotBlank(accountName) && accountMap.containsKey(accountName)) {
                    contact.AccountId = accountMap.get(accountName).Id;
                }
            }
            upsert as user contactsToUpsert;
        }
    
    

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */

        public static void insertAndDeleteLeads(List<String> leadNames) {
            List<Lead> newLeads = new List<Lead>();
            
            Set<String> leadNameSet = new Set<String>(leadNames);
            
            List<Lead> existingLeadsList = [SELECT Id, LastName FROM Lead WHERE LastName IN :leadNameSet WITH USER_MODE];
            
            Map<String, Lead> mapOfExistingLeads = new Map<String, Lead>();
            for (Lead lead : existingLeadsList) {
                mapOfExistingLeads.put(lead.LastName, lead);
            }
            
            for (String leadName : leadNames) {
                if (!mapOfExistingLeads.containsKey(leadName)) {
                    Lead newLead = new Lead(LastName = leadName, Company = 'Salesforce', Status = 'Working - Contacted');
                    newLeads.add(newLead);
                }
            }
            
            if (!newLeads.isEmpty()) {
                insert as user newLeads;
            }
            
            List<Lead> leadsToDelete = [SELECT Id FROM Lead WHERE LastName IN :leadNameSet WITH USER_MODE];
            
            if (!leadsToDelete.isEmpty()) {
                delete as user leadsToDelete;
            }
            
            List<Lead> deletedLeads = [SELECT Id FROM Lead WHERE LastName IN :leadNameSet WITH USER_MODE];
        }
    
    
    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        List<Case> casesToCreate = new List<Case>();

        for (Integer i = 0; i < numOfCases; i++){
            Case newCase = new Case(AccountId = accountId);
            casesToCreate.add(newCase);
        }
        insert as user casesToCreate;
        List<Case> insertedCases = [SELECT Id, AccountId, Subject FROM Case WHERE AccountId = :accountId WITH USER_MODE];
                
        delete as user insertedCases;
    }
}
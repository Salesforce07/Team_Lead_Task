@IsTest
public class LeadControllerTest {

    // Method to create a test Account with a specific country
    private static Account createTestAccount(String country) {
        Account acc = new Account(
            Name = 'Test Account',
            Email__c = 'testaccount@example.com',
            Country__c = country
        );
        insert acc;
        return acc;
    }

    // Method to create a test Lead with a specific country
    private static Lead createTestLead(String firstName, String lastName, String email, String country) {
        Lead lead = new Lead(
            FirstName = firstName,
            LastName = lastName,
            Company = 'Test Company',
            Email = email,
            Country = country,
            Status = 'New'
        );
        return lead;
    }

    @IsTest
    static void testSaveLeadWithMatchingAccount() {
        // Create a test Account with a specific country
        String country = 'USA';
        Account testAccount = createTestAccount(country);
        
        // Create a test Lead with the same country as the test Account
        Lead testLead = createTestLead('John', 'Doe', 'johndoe@example.com', country);

        // Start the test by using Test.startTest() to capture governor limits
        Test.startTest();
        // Save the Lead using the saveLead method from the LeadController class
        Lead insertedLead = LeadController.saveLead(testLead);
        Test.stopTest();

        // Verify the Lead was inserted and has an Account__c field populated with the testAccount Id
        Lead insertedLeadResult = [SELECT Id, Account__c FROM Lead WHERE Id = :insertedLead.Id];
        System.assertNotEquals(null, insertedLeadResult.Account__c, 'Account__c should not be null');
        System.assertEquals(testAccount.Id, insertedLeadResult.Account__c, 'Account__c should be linked to the correct Account');
    }

    @IsTest
    static void testSaveLeadWithoutMatchingAccount() {
        // Create a test Lead with a country that doesn't match any Account
        String country = 'Canada';
        Lead testLead = createTestLead('Jane', 'Smith', 'janesmith@example.com', country);

        // Start the test
        Test.startTest();
        Lead insertedLead = LeadController.saveLead(testLead);
        Test.stopTest();

        // Verify the Lead was inserted and the Account__c field is not populated
        Lead insertedLeadResult = [SELECT Id, Account__c FROM Lead WHERE Id = :insertedLead.Id];
        System.assertEquals(null, insertedLeadResult.Account__c, 'Account__c should be null for a lead without matching Account');
    }

    @IsTest
    static void testSaveLeadException() {
        // Create a Lead without required fields to trigger an exception
        Lead invalidLead = new Lead(
            FirstName = null, // FirstName is required, so this will cause an exception
            LastName = 'Doe',
            Company = 'Test Company',
            Email = 'johndoe@example.com',
            Country = 'USA',
            Status = 'New'
        );

        // Start the test and expect an exception to be thrown
        Test.startTest();
        try {
            LeadController.saveLead(invalidLead);
            System.assert(false, 'Expected an exception to be thrown, but none was thrown.');
        } catch (AuraHandledException e) {
            System.assertEquals('Error saving lead: Required fields are missing.', e.getMessage(), 'The exception message should match.');
        }
        Test.stopTest();
    }

    @IsTest
    static void testSendEmail() {
        // Call the sendEmail method and verify email sending logic
        Test.startTest();
        LeadController.sendEmail('test@example.com', 'Test Subject', 'Test Body');
        Test.stopTest();

        // Verify the email was sent using the email sent count
        System.assertEquals(1, Limits.getEmailInvocations(), 'One email should have been sent');
    }

    @IsTest
    static void testSendEmailWithInvalidEmail() {
        // Call the sendEmail method with an invalid email and verify no email is sent
        Test.startTest();
        LeadController.sendEmail('', 'Test Subject', 'Test Body');  // Invalid email
        Test.stopTest();

        // Verify no email was sent
        System.assertEquals(0, Limits.getEmailInvocations(), 'No email should have been sent for an invalid email');
    }
}

@isTest
public class ContactLeadApexTest {

    @testSetup
    static void setupTestData() {
        // Create test Contacts
        Contact contact1 = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com', Country__c = 'USA');
        Contact contact2 = new Contact(FirstName = 'Jane', LastName = 'Smith', Email = 'jane.smith@example.com', Country__c = 'Canada');
        insert new List<Contact>{contact1, contact2};
    }

    @isTest
    static void testCreateLeadWithMatchingContact() {
        // Create a test Lead with a matching country to the Contact
        Lead testLead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Company', Email = 'test.lead@example.com', Country = 'USA', Status = 'Open-Not Contacted', LeadSource = 'Web');
        
        // Call the createLead method
        Test.startTest();
        Lead resultLead = ContactLeadApex.createLead(testLead);
        Test.stopTest();
        
        // Verify the Lead was created and assigned the correct Contact
        Lead createdLead = [SELECT Id, Contact__c FROM Lead WHERE Id = :resultLead.Id];
        System.assertNotEquals(null, createdLead.Contact__c, 'The Lead should be assigned a Contact.');
        
        // Verify that the Contact ID matches the correct one for the USA
        Contact assignedContact = [SELECT Id, Email FROM Contact WHERE Id = :createdLead.Contact__c];
        System.assertEquals('john.doe@example.com', assignedContact.Email, 'The assigned Contact should have the correct email.');
    }

    @isTest
    static void testCreateLeadWithNoMatchingContact() {
        // Create a test Lead with no matching country to any Contact
        Lead testLead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Company', Email = 'test.lead@example.com', Country = 'Australia', Status = 'Open-Not Contacted', LeadSource = 'Web');
        
        // Call the createLead method
        Test.startTest();
        Lead resultLead = ContactLeadApex.createLead(testLead);
        Test.stopTest();
        
        // Verify the Lead was created but no Contact was assigned
        Lead createdLead = [SELECT Id, Contact__c FROM Lead WHERE Id = :resultLead.Id];
        System.assertEquals(null, createdLead.Contact__c, 'The Lead should not be assigned a Contact since no matching country was found.');
    }

    @isTest
    static void testEmailNotification() {
        // Create a test Lead with a matching country to trigger the email
        Lead testLead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Company', Email = 'test.lead@example.com', Country = 'Canada', Status = 'Open-Not Contacted', LeadSource = 'Web');
        
        // Set up email tracking
        Test.startTest();
        Lead resultLead = ContactLeadApex.createLead(testLead);
        Test.stopTest();
        
        // Verify that the email was sent
        List<Messaging.SingleEmailMessage> emails = [SELECT Id, ToAddress, Subject, Body FROM EmailMessage WHERE ToAddress = 'jane.smith@example.com'];
        System.assertEquals(1, emails.size(), 'One email should have been sent.');
        System.assertEquals('Lead Successfully Created', emails[0].Subject, 'The email subject should match.');
    }
    
    @isTest
    static void testGetLeadSourcePicklistValues() {
        Test.startTest();
        List<String> leadSources = ContactLeadApex.getLeadSourcePicklistValues();
        Test.stopTest();
        
        // Verify that the lead source picklist values are returned
        System.assertEquals(5, leadSources.size(), 'There should be 5 lead source picklist values.');
        System.assert(leadSources.contains('Web'), 'The list should contain "Web" as a picklist value.');
    }

    @isTest
    static void testGetLeadStatusPicklistValues() {
        Test.startTest();
        List<String> leadStatuses = ContactLeadApex.getLeadStatusPicklistValues();
        Test.stopTest();
        
        // Verify that the lead status picklist values are returned
        System.assertEquals(4, leadStatuses.size(), 'There should be 4 lead status picklist values.');
        System.assert(leadStatuses.contains('Open-Not Contacted'), 'The list should contain "Open-Not Contacted" as a picklist value.');
    }
}

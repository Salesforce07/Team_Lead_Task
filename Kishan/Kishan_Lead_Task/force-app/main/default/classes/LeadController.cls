/*
*********************************************************
Apex Class Name    : LeadController
Purpose           : Used to create a Lead, populate Account name if there's a matching country and send an email notification.
*********************************************************
Created Date       : Sept. 11, 2024
@description       : This class is Used to create a Lead, populate Account name if there's a matching country and send an email notification.
@author            : Kishan Aminani
Modification Log:
Ver   Date         Author                               Modification
1.0   12-09-2024   Kishan Aminani                      Initial Version
*********************************************************
*/
public class LeadController {
    
    /**
     * AuraEnabled method to save a Lead record.
     * This method is invoked by the Lightning Web Component (LWC).
     *
     * @param lead - Lead object passed from the LWC.
     * @return Lead - The inserted Lead object after being saved.
     */


     /*
*********************************************************
@Method Name    : saveLead
@Purpose       : Method is used to save a Lead record.
@author         : KishanAminani
@param          :Lead lead
@return         : lead
********************************************************
*/
    
    @AuraEnabled
public static Lead saveLead(Lead lead) {
    try {
        // Call method to update lead with matching account by country
        populateAccountName(lead);

        // Insert the lead record into the database
        insert lead;
        
        return lead; 
    } catch (DmlException e) {
        // Handle duplicate exception
        if (e.getDmlType(0) == StatusCode.DUPLICATES_DETECTED) {
            // Return a more specific error message or take action (e.g., merge leads)
            throw new AuraHandledException('Duplicate lead detected. Please review existing records.');
        }
        
        // Throw a generic exception for other errors
        throw new AuraHandledException('Error saving lead: ' + e.getMessage());
    }
}


    /**
     * Method to populate the Lead's Account__c field if there's an Account with a matching country.
     *
     * @param lead - The inserted Lead object
     */

     /*
*********************************************************
@Method Name    : populateAccountName
@author         : KishanAminani
@description    : method is used for populating the Account__c field if there's an Account with a matching country
@param          :Lead lead
@return         : void
********************************************************
*/
    public static void populateAccountName(Lead lead) {
        // Set to store the countries of the lead(s)
        Set<String> leadCountries = new Set<String>();
        
        // Add the lead's country to the set if it's not null
        Lead l = lead;
        String keyy;
        if (l.Country != null) { 
            keyy=l.Country.toLowerCase();
            leadCountries.add(keyy);
            System.debug('keyy >> '+keyy);
        }
        
        // Map to store the matching Account records by their Country
        Map<String, Account> countryToAccountMap = new Map<String, Account>();
        
        // Query Accounts where the country matches the Lead's country
        for (Account acc : [SELECT Id, Email__c, Country__c FROM Account WHERE Country__c !=null]) {
            String key =acc.Country__c.toLowerCase();
            countryToAccountMap.put(key, acc); // Map Account by Country__c field
        }
        System.debug(countryToAccountMap);

        
        // If the Lead's country exists and matches an Account's country
        if (l.Country != null && countryToAccountMap.containsKey(keyy)) {
            // Assign the Account's Id to the Lead's Account__c field
            System.debug('map value'+countryToAccountMap.get(keyy));
            System.debug('map value Id'+countryToAccountMap.get(keyy).Id);
            l.Account__c = countryToAccountMap.get(keyy).Id;
            
            // Prepare the subject and body for the notification email
            String subject = 'New Lead Assigned to Account';
            String body = 'Dear User, \n\nA new lead with the country ' + l.Country + ' has been assigned to the Account with the same country.\n\nThank you.';
            
             //Send an email to the account owner, using the Account's Email__c field
             sendEmail(countryToAccountMap.get(keyy).Email__c, subject, body);
        }
    }
       
    /**
     * Method to send an email notification.
     *
     * @param recipientEmail - The email address of the recipient
     * @param subject - The subject of the email
     * @param body - The body content of the email
     */
    public static void sendEmail(String recipientEmail, String subject, String body) {
        // Check if the recipient's email is valid (not null or empty)
        if (recipientEmail != null && recipientEmail != '') {
            // Create a new email message
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { recipientEmail }); // Set recipient's email
            mail.setSubject(subject); // Set email subject
            mail.setPlainTextBody(body); // Set email body as plain text
            
            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}



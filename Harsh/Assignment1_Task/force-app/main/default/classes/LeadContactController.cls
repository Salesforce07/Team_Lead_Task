/*
*********************************************************
Apex Class Name    : LeadContactController
Created Date       : September 12, 2024
@description       : This is class is used for....
@author            : Harsh Sharma
Modification Log:
Ver   Date         Author                               Modification
1.0   12-09-2024   Harsh Sharma                    Initial Version
*********************************************************
*/

public with sharing class LeadContactController {
    /**
     * Processes a list of leads by assigning a contact to each lead based on matching country.
     * For each lead, if the country of the lead matches the country of a contact,
     * the lead's Contact__c field is set to that contact's Id.
     * An email notification is sent to the contact if a match is found.
     *
     * @param leadList List of leads to be processed
     */
    public static void processLeads(List<Lead> leadList) {
        String contactEmail;
        Set<String> leadCountries = new Set<String>();

        // Collect unique countries from the lead list
        for (Lead l : leadList) {
            if (l.Country != null) {
                leadCountries.add(l.Country.toLowerCase());
            }
        }

        // Query contacts whose countries match the lead countries
        Map<String, Contact> countryToContactMap = new Map<String, Contact>();
        for (Contact con : [SELECT Id, Contry__c, Email FROM Contact WHERE Contry__c != null]) {
            con.Contry__c=con.Contry__c.toLowerCase();
            countryToContactMap.put(con.Contry__c, con);
            contactEmail = con.Email;
        }

        // Assign contacts to leads based on matching countries
        for (Lead l : leadList) {
            if (l.Country != null && countryToContactMap.containsKey(l.Country)) {
                l.Contact__c = countryToContactMap.get(l.Country).Id;

                // Send email notification to the contact
                sendEmailNotification(contactEmail);
            }
        }
    }

    /**
     * Sends an email notification to the contact informing them that a lead has been successfully created
     * and assigned to them.
     *
     * @param contactEmail The email address of the contact to whom the notification will be sent
     */
    private static void sendEmailNotification(String contactEmail) {
        if (String.isNotBlank(contactEmail)) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[]{contactEmail});
            mail.setSubject('Lead Successfully Created');
            mail.setPlainTextBody('Your lead has been successfully created and assigned.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }
    }
}

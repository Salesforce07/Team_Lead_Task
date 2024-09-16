
/*******************************************************************************************
* @Name         MitaliGehlot
* @Author       mitali gehlot <mitaligehlot.metadologie.com>
* @Date          12/09/2024

* @Description  This class contains all service methods related to caching data in Salesforce.  
*				It is segregated as a service to make changing cache partition easy.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0                Mitali            12/09/2024        Initial Creation                                                      
*******************************************************************************************/


//create the apex class for the contactLead 
public with sharing class  ContactLeadApex {


   // picklist value assign to leadsource 
@AuraEnabled(cacheable=true)
    public static List<String> getLeadSourcePicklistValues() {
        // Return static LeadSource picklist values
        return new List<String>{'Web', 'Phone Inquiry', 'Partner Referral', 'Purchased List', 'Other'};
    }
    
    // picklist value assign to leadstatus
    @AuraEnabled(cacheable=true)
    public static List<String> getLeadStatusPicklistValues() {
        // Return static LeadStatus picklist values
        return new List<String>{'Open-Not Contacted', 'Working -Contacted', 'Closed - Converted', 'Closed -Not Converted'};
    }
        
    @AuraEnabled
    public static Lead createLead(Lead lead) {
        // Insert the Lead record
        insert lead;
        
        // Assign the contact based on country
        assignContactToLead(lead);
        
        return lead;
    }
    
    private static void assignContactToLead(Lead lead) {
        // Create a map to hold country to Contact mappings
        Map<String, Contact> countryToContactMap = new Map<String, Contact>();
        
        // Collect countries from Leads in the trigger context
        Set<String> leadCountries = new Set<String>();
        if (lead.Country != null) { 
            leadCountries.add(lead.Country.toLowerCase());         // to add here lowe case 
        }
        
        // Fetch Contacts whose Country__c matches the countries from the Leads
        if (!leadCountries.isEmpty()) {
            List<Contact> contacts = [SELECT Id, Email,Country__c FROM Contact WHERE Country__c IN :leadCountries];
            for (Contact contact : contacts) {
               contact.Country__c = contact.Country__c.toLowerCase();
                countryToContactMap.put(contact.Country__c, contact);
            }
        }
        
        // Update the Lead with the matched Contact
        if (lead.Country!= null && countryToContactMap.containsKey(lead.Country)) {
            lead.Contact__c= countryToContactMap.get(lead.Country).Id;
            // Update the Lead record to reflect the Contact assignment
            update lead;
            sendEmailNotification(countryToContactMap.get(lead.Country).Email);
        }
    }

        // sending mail to assign contact 
    
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
    



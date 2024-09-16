
/*
*********************************************************
Apex Class Name    : LeadController
Created Date       : September 12, 2024
@description       : This is class is used for....
@author            : Harsh Sharma
Modification Log:
Ver   Date         Author                               Modification
1.0   12-09-2024   Harsh Sharma                      Initial Version
*********************************************************
*/

//Lead controller to save lead that is created
public with sharing class LeadController {
    @AuraEnabled
    //function that is getting data from javascript and adding it to lead object
    public static Id createLead(String firstName, String lastName, String email, String countryName, String companyName, Decimal orgSize, String leadStatus, String leadSource) {
        Lead newLead = new Lead(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            Country = countryName,
            Company = companyName,
            OrgSize__c = orgSize,
            Status = leadStatus,
            LeadSource = leadSource
        );
        
        try {
            // Insert the new Lead record
            insert newLead;
            return newLead.Id;  // Return the Lead Id
        } catch (DmlException e) {
            // Handle any DML exceptions that occur
            throw new AuraHandledException('Error creating lead: ' + e.getMessage());
        }
    }
}

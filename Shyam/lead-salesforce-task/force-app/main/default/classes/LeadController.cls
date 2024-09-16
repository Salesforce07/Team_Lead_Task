/*
*********************************************************
Apex Class Name    : LeadController
Test Class Name    : LeadControllerTest
Test Coverage      : 100%
Created Date       : Sept. 11
@description       : This is class is used for creating Lead record, and automatically populating lookup opportunity field where opportunity's country and Lead country is same.
@author            : Shyam Upadhyay
Modification Log:
Ver   Date         Author                               Modification
1.0   11-09-2024   Shyam Upadhyay                     Initial Version
*********************************************************
*/

public with sharing class LeadController {

    /*
*********************************************************
@Method Name    : createLeadRecord
@author         : Shyam Upadhyay
@description    : method is used to create Lead record and automatically populate opportunity lookup field where opportunity's country and Lead country is same.
@param          : Lead Object
@return         : Lead Object
********************************************************
*/
    @AuraEnabled
    public static Lead createLeadRecord(Lead lead){
        try {
            List<Opportunity> relatedOpportunity= [SELECT Id, Name, Country__c FROM Opportunity WHERE Country__c =: lead.Country];
            if(relatedOpportunity.size()>0){
                lead.Opportunity__c= relatedOpportunity[0].Id;
            }
            insert lead;
            return lead;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
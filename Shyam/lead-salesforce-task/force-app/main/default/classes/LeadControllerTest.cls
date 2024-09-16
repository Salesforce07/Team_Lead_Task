@isTest
private class LeadControllerTest {
    @isTest
    static void createLeadRecordTest() {
        //Creating Opportunity record
        Opportunity opp = new Opportunity(Name='Test Opportunity',CloseDate=Date.newInstance(2022,11,11),StageName='Prospecting',Country__c='India');
        insert opp;

        Lead lead = new Lead(FirstName='Test',LastName='Lead',Company='Test Company',Status='Open - Not Contacted',Country='India');
        Test.startTest();
        Lead result= LeadController.createLeadRecord(lead);
        Test.stopTest();
              
    }
    
    @isTest
    static void createLeadRecordExceTest(){
         //Creating Opportunity record
        Opportunity opp = new Opportunity(Name='Test Opportunity',CloseDate=Date.newInstance(2022,11,11),StageName='Prospecting',Country__c='India');
        insert opp;

        Lead lead = new Lead();
        Test.startTest();
        Lead result= LeadController.createLeadRecord(lead);
        Test.stopTest();
    }
}
public with sharing class SearchBoxController {
    @AuraEnabled(cacheable=true)
   public static List<Contact> getContacts(String accName){
      try{
        List<Contact> conList = new List<Contact>();
            conList = [SELECT FirstName, LastName, Email, AccountId 
                       FROM Contact 
                       WHERE Account.Name=:accName];
      
       if (conList.isEmpty()) {
        throw new AuraHandledException('No contacts found for the given account name.');
      
    }
    return conList;
      }catch(Exception e){
        throw new AuraHandledException(e.getMessage());
      }
      
   }
}
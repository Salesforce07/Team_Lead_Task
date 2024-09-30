/*
*********************************************************
Apex Class Name    : ProductController
Created Date       : Sept. 23
@description       : This class is used for getting product and product informatons and save account.
@author            : Shyam Upadhyay
Modification Log:
Ver   Date         Author                               Modification
1.0   23-09-2024   Shyam Upadhyay                     Initial Version
*********************************************************
*/
public with sharing class ProductController {
/*
*********************************************************
@Method Name    : getProducts
@author         : Shyam Upadhyay
@description    : method to get products info(id, name, types, quantity, versionDataUrl) with help of wrapper class.
@param          : No Parameters
@return         : List<InfoProduct> 
********************************************************
*/
    @AuraEnabled(cacheable=true)
    public static List<InfoProduct> getProducts(){
          // Query to get product records
          Map<id, Product2> products = new Map<id, Product2>([SELECT Id, Name, Types__c, Quantity__c FROM Product2]);

          // map to hold id of product as key and price as value
          Map<Id, Decimal> mapPrice = new Map<Id, Decimal>();

         //Query to get price record, map with key product id and value price 
         for(Price__c price: [SELECT Product__r.Id, Unit_Price__c FROM Price__c where Product__r.Id IN :products.keySet()]){
                   mapPrice.put(price.Product__r.id, price.Unit_Price__c);
         }

          // Query to get content versions associated with products
          List<ContentDocumentLink> contentLinks = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :products.keySet()];
  
          // Query to get ContentDocumentIds
          Set<Id> contentDocumentIds = new Set<Id>(); 
          Map<Id,Id> productIdToContentDocumentId= new Map<Id, Id>();         
          for (ContentDocumentLink link : contentLinks) {
              contentDocumentIds.add(link.ContentDocumentId);
              productIdToContentDocumentId.put(link.LinkedEntityId, link.ContentDocumentId);
          }
  
          Map<Id,String> contentDocumentIdWithUrl= new Map<Id, String>(); 

          // Query to get the VersionDataUrl for each ContentDocument
          List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId, VersionDataUrl FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];

          for (ContentVersion link : contentVersions) {
            contentDocumentIdWithUrl.put(link.ContentDocumentId, link.VersionDataUrl);
        }

          // create instance of wrapper class
          List<InfoProduct> infoProduct = new List<InfoProduct>();
          
          // populate the wrapper class
          for(Product2 product : products.values()) {
               Id contentDocumentId = productIdToContentDocumentId.get(product.Id);
               String contentDownloadUrl = contentDocumentIdWithUrl.get(contentDocumentId);
               Decimal price = mapPrice.get(product.Id);
               InfoProduct productToAdd= new InfoProduct();
               productToAdd.id = product.Id;
               productToAdd.name = product.Name;
               productToAdd.price= price;
               productToAdd.type = product.Types__c;
               productToAdd.quantity= 0;
               productToAdd.photoUrl = contentDownloadUrl;
               infoProduct.add(productToAdd);
            }

            return infoProduct;
        
    }


/*
*********************************************************
Apex Class Name    : InfoProduct
Created Date       : Sept. 23
@description       : This class is used as wrapper class to hold product information.
@author            : Shyam Upadhyay
Modification Log:
Ver   Date         Author                               Modification
1.0   23-09-2024   Shyam Upadhyay                     Initial Version
*********************************************************
*/
    public class InfoProduct{
       @AuraEnabled public String id {get; set;}
       @AuraEnabled public String name {get; set;}
       @AuraEnabled  public String type {get; set;}
       @AuraEnabled public Decimal price {get; set;}
       @AuraEnabled public Decimal quantity {get; set;}
       @AuraEnabled  public String photoUrl {get; set;}
    }

/*
*********************************************************
@Method Name    : saveAccount
@author         : Shyam Upadhyay
@description    : method is used to create Account record or return account if it's only present.
@param          : Account account.
@return         : List<Account>
********************************************************
*/
    @AuraEnabled
    public static List<Account> saveAccount(Account account){
        try {
            List<Account> savedAccounts= [Select Name, Phone from account where Name=:account.Name and Phone=:account.Phone];
            if(savedAccounts.size()>0){
                return savedAccounts;
            }else{
                insert account;
                savedAccounts.add(account);
                return savedAccounts;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}
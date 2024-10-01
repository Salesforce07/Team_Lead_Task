/*
*********************************************************
Apex Class Name    : FoodController
Created Date       :  27/09/2024
@description       : Control the database and control the images and fetch the records 
@author            : MitaliGehlot
Modification Log:
Ver   Date         Author                               Modification
1.0   27-09-2024   MitaliGehlot                       Initial Version
*********************************************************
*/
public with sharing class FoodorderController {

    @AuraEnabled
    public static Account createAccount(String customerName, String customerNumber) {
        // Create new Account record
        Account newAccount = new Account();
        newAccount.Name = customerName;
        newAccount.Phone = customerNumber;

        insert newAccount; 
        return newAccount;  
    }

    // Method to get product details with images
    @AuraEnabled(cacheable=true)
    public static List<InfoProduct> getProducts() {
        // Get Product records
        Map<Id, Product2> products = new Map<Id, Product2>([SELECT Id, Name, Choice__c, Quantity__c FROM Product2]);

        // Get the Price associated with the product 
        Map<Id, Decimal> mapPrice = new Map<Id, Decimal>();
        for (Price__c price : [SELECT Product__r.Id, Unit__c FROM Price__c]) {
            mapPrice.put(price.Product__r.Id, price.Unit__c);
        }

        // Query ContentDocumentLink to get the document ids
        List<ContentDocumentLink> contentLinks = [
            SELECT ContentDocumentId, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :products.keySet()
        ];

        // Collect ContentDocumentIds
        Set<Id> contentDocumentIds = new Set<Id>();
        Map<Id, Id> productIdToContentDocumentId = new Map<Id, Id>();
        
        for (ContentDocumentLink link : contentLinks) {
            contentDocumentIds.add(link.ContentDocumentId);
            productIdToContentDocumentId.put(link.LinkedEntityId, link.ContentDocumentId);
        }

        // Query to get the VersionDataUrl for each ContentDocument
        Map<Id, String> contentDocumentIdWithUrl = new Map<Id, String>();
        List<ContentVersion> contentVersions = [
            SELECT ContentDocumentId, VersionDataUrl 
            FROM ContentVersion 
            WHERE ContentDocumentId IN :contentDocumentIds
        ];
        
        for (ContentVersion version : contentVersions) {
            if (contentDocumentIdWithUrl.get(version.ContentDocumentId) == null) {
                contentDocumentIdWithUrl.put(version.ContentDocumentId, version.VersionDataUrl);
            }
        }

        // Create list of wrapper class instances
        List<InfoProduct> infoProductList = new List<InfoProduct>();

        // Populate the wrapper class
        for (Product2 product : products.values()) {
            Id contentDocumentId = productIdToContentDocumentId.get(product.Id);
            String contentDownloadUrl = contentDocumentIdWithUrl.get(contentDocumentId);
            
            if (contentDownloadUrl != null && contentDownloadUrl != ' ') {
                // Create instance of wrapper class
                InfoProduct productToAdd = new InfoProduct();
                productToAdd.id = product.Id;
                productToAdd.name = product.Name;
                productToAdd.Choice = product.Choice__c;
                productToAdd.quantity = product.Quantity__c;
                productToAdd.price = mapPrice.get(product.Id);
                productToAdd.ImageUrl = contentDownloadUrl; // URL to the image

                infoProductList.add(productToAdd);
            }
        }
        return infoProductList;
    }

    // Create Order and Order Items
    @AuraEnabled
    public static Id createOrder(Id accountId, List<OrderItemWrapper> orderItems) {
        // Insert Contract
        Contract cont = new Contract();
        cont.AccountId = accountId;
        cont.Status = 'Draft';
        cont.ContractTerm = 3;
        cont.StartDate = System.today();
        insert cont;

        // Create Order
        Order newOrder = new Order();
        newOrder.AccountId = accountId;
        newOrder.Status = 'Draft';
        newOrder.EffectiveDate = System.today();
        newOrder.ContractId = cont.Id;
        insert newOrder;

        // Insert Order Items
        List<orderitem__c> orderItemsToInsert = new List<orderitem__c>();
        
        for (OrderItemWrapper item : orderItems) {
            orderitem__c newItem = new orderitem__c();
            
            // Associate with the created Order
            newItem.Order__c = newOrder.Id;
            
            // Set the product ID for lookup
            newItem.Product__c = item.productId;

            // Set the custom Name field with the product name
            newItem.Name = item.productName;  // Assign product name to the custom Name field
            
            // Set the quantity and price
            newItem.quantity__c = item.quantity;
            newItem.UnitPrice__c = item.price;

            // Add to the list for bulk insert
            orderItemsToInsert.add(newItem);
        }
        
        // Bulk insert of order items
        insert orderItemsToInsert;
        
        // Return the created Order ID
        return newOrder.Id;
    }

    // Wrapper class for product info
    public class InfoProduct {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String Choice { get; set; }
        @AuraEnabled public String ImageUrl { get; set; }
        @AuraEnabled public Decimal price { get; set; }
        @AuraEnabled public Decimal quantity { get; set; }
    }

    // Wrapper class for Order Items
    public class OrderItemWrapper {
        @AuraEnabled public Id productId { get; set; }       // Product ID
        @AuraEnabled public String productName { get; set; } // Product Name
        @AuraEnabled public Decimal quantity { get; set; }   // Quantity
        @AuraEnabled public Decimal price { get; set; }      // Price
    }
}
























































































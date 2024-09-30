/*
*********************************************************
Apex Class Name    : OrderItemController
Created Date       : Sept. 26
@description       : This class is used for Saving Order record and Order Item record.
@author            : Shyam Upadhyay
Modification Log:
Ver   Date         Author                               Modification
1.0   26-09-2024   Shyam Upadhyay                     Initial Version
*********************************************************
*/

public with sharing class OrderItemController {

/*
*********************************************************
@Method Name    : saveOrder
@author         : Shyam Upadhyay
@description    : method is used to save Order Record.
@param          : Order object.
@return         : Order object
********************************************************
*/
    @AuraEnabled
    public static Order saveOrder(Order order){
        try {
            if(order!=null){
                insert order;
            }
            return order;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

/*
*********************************************************
@Method Name    : saveOrderItem
@author         : Shyam Upadhyay
@description    : method is used to saveOrderItem and call saveOrder method to save order.
@param          : List<Map<String, String>> orderItemList, Order order
@return         : List<Order_Item__c>
********************************************************
*/

    @AuraEnabled
    public static List<Order_Item__c> saveOrderItem(List<Map<String, String>> orderItemList, Order order){
        try {
            Order createdOrder= saveOrder(order);
            List<Order_Item__c> orderList = new List<Order_Item__c>();
          
            for(Map<String, String> orderItemMap: orderItemList){
                Order_Item__c orderItem = new Order_Item__c();
                orderItem.Name = orderItemMap.get('name');
                orderItem.Product__c = orderItemMap.get('id');
                orderItem.Quantity__c = Integer.valueof(orderItemMap.get('quantity'));
                orderItem.Unit_Price__c = Integer.valueof(orderItemMap.get('price'));
                orderItem.Order__c = createdOrder.Id;
                orderList.add(orderItem);
            }
            if(orderList.size()>0){
                insert orderList;
            }           
            return orderList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
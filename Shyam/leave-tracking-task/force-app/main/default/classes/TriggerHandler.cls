public with sharing class TriggerHandler {
   public static void beforInsert(List<Leave_Request__c> leaverequest){} 
   public static void afterInsert(List<Leave_Request__c> leaverequest){}
   public static void afterUpdate(Map<Id, Leave_Request__c> leaverequestold, List<Leave_Request__c> leaverequestnew){
      changeLeaveBalance(leaverequestold, leaverequestnew);
   }
   public static void beforeDelete(List<Leave_Request__c> leaverequest){}
   public static void afterDelete(List<Leave_Request__c> leaverequest){}
  

   // Method to update Leave Balance of Employee
   public static void changeLeaveBalance(Map<Id, Leave_Request__c> leaverequestold, List<Leave_Request__c> leaverequestnew) {
      // Get Employees Id from leave request records
      Set<Id> empIds = new Set<Id>();
      for (Leave_Request__c leavereq : leaverequestnew) {
          empIds.add(leavereq.Employee__c);
      }

      // Get Emloyee records with associated Id from Set
      List<Employee__c> empList = [SELECT Id, Leave_Balance__c FROM Employee__c Where Id In :empIds]; 
      
      // Create a Map for Employee Id and employee
      Map<Id, Employee__c> empMap = new Map<Id, Employee__c>();
      for (Employee__c emp : empList) {
          empMap.put(emp.Id, emp);
      }
      
      List<Employee__c> empToUpdate = new List<Employee__c>();
      for (Leave_Request__c record : leaverequestnew) {
          Leave_Request__c oldRecord = leaverequestold.get(record.Id);
          
          // Check if leave request record status changed to approved
          if (oldRecord.Status__c != record.Status__c && record.Status__c == 'Approved') {
              Employee__c employee = empMap.get(record.Employee__c);
              if (employee != null) {
                  employee.Leave_Balance__c -= LeaveRequestController.getLeaveCounts(record.Start_Date__c, record.End_Date__c);
                  empToUpdate.add(employee);
              }
          }
      }
      
      if (!empToUpdate.isEmpty()) {
          update empToUpdate;
      }
  }
  
   }
  
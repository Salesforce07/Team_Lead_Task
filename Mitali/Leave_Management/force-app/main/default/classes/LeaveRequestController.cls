
/*
*********************************************************
Apex Class Name    : LeaveRquestController
Created Date       : spet 18, 2024
@description       : creating for the Leave Reuqest 
@author            : Mitali gehlot 
Modification Log:
Ver   Date         Author                               Modification
1.0   18-09-2024   mitali gehlot                     Initial Version
********************************************************
*/

 public with sharing class LeaveRequestController {

// create leave Request and fetch the data from the component 
    @AuraEnabled
    public static Id createLeaveRequest(String employeeId, Date startDate, Date endDate, String leaveType) {

    if (String.isBlank(employeeId)) {

             throw new AuraHandledException('Employee ID cannot be blank.');
         }
    if (startDate == null || endDate == null) {
          throw new AuraHandledException('Start Date and End Date cannot be blank.');
    }
    if (String.isBlank(leaveType)) {
           throw new AuraHandledException('Leave Type cannot be blank.');
    }
    if (startDate > endDate) {
            throw new AuraHandledException('Start Date cannot be after End Date.');
    }
    
    try {
    // Create Leave Request record
    LeaveRequest__c leaveRequest = new LeaveRequest__c();
    leaveRequest.Employee__c = employeeId; 
    leaveRequest.StartDate__c = startDate;
    leaveRequest.EndDate__c = endDate;
    leaveRequest.LeaveType__c = leaveType;
    
    insert leaveRequest;
    
    return leaveRequest.Id;
    
    }catch (Exception ex) {

         throw new AuraHandledException('Error creating leave request: ' + ex.getMessage());
    }
    }
    

   
   }
    
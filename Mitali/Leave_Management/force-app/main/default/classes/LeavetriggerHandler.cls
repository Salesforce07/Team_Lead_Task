/*
*********************************************************
Apex Class Name    : LeavetriggerHandler
Created Date       : sept 18, 2024
@description       : creating for the trigger handler 
@author            : Mitali gehlot 
Modification Log:
Ver   Date         Author                               Modification
1.0   18-09-2024   mitali gehlot                     Initial Version
*********************************************************
*/


public with sharing class LeavetriggerHandler {
  // checked leave 
    @AuraEnabled
    public static Map<Id, String> checkLeavesBulk(List<LeaveRequest__c> leaveRequests) {
        Set<Id> employeeIds = new Set<Id>();
        for (LeaveRequest__c leaveRequest : leaveRequests) {
            if (leaveRequest.Employee__c != null) {
                employeeIds.add(leaveRequest.Employee__c);
            }
    }
  
    Map<Id, Employee__c> employeeMap = new Map<Id, Employee__c>(
    [SELECT Id, Leave_Balance__c
    FROM Employee__c
    WHERE Id IN :employeeIds]
    );
    
    Map<Id, String> errorMap = new Map<Id, String>();
    
    for (LeaveRequest__c leaveRequest : leaveRequests) {
    Id employeeId = leaveRequest.Employee__c;
    
    if (employeeMap.containsKey(employeeId)) {
    Employee__c employee = employeeMap.get(employeeId);
    Decimal leaveBalance = employee.Leave_Balance__c;
    // get the total Leave days 
    Integer totalLeaveDays = getLeaveDaysExcludingWeekends(leaveRequest.StartDate__c, leaveRequest.EndDate__c);
    
    if (totalLeaveDays > leaveBalance) {
    errorMap.put(leaveRequest.Id, 'Insufficient leave balance. You only have ' + leaveBalance + ' leave days available.');
    }
    } else {
    errorMap.put(leaveRequest.Id, 'Employee not found for ID: ' + employeeId);
    }
    }
    
    return errorMap;
    }
    
 // update the leave balanace 
    @AuraEnabled
    public static void updateLeaveBalanceBulk(List<LeaveRequest__c> leaveRequests) {
    Set<Id> employeeIds = new Set<Id>();
    for (LeaveRequest__c leaveRequest : leaveRequests) {
    if (leaveRequest.Employee__c != null) {
    employeeIds.add(leaveRequest.Employee__c);
    }
    }
    
    Map<Id, Employee__c> employeeMap = new Map<Id, Employee__c>(
    [SELECT Id, Leave_Balance__c
    FROM Employee__c
    WHERE Id IN :employeeIds
    FOR UPDATE]
    );
    
    List<Employee__c> employeesToUpdate = new List<Employee__c>();
    
    for (LeaveRequest__c leaveRequest : leaveRequests) {
    Employee__c employee = employeeMap.get(leaveRequest.Employee__c);
    if (employee != null) {
    Integer totalLeaveDays = getLeaveDaysExcludingWeekends(leaveRequest.StartDate__c, leaveRequest.EndDate__c);
    employee.Leave_Balance__c -= totalLeaveDays;
    
    employeesToUpdate.add(employee);
    }
    }
    System.debug(employeesToUpdate);
    if (!employeesToUpdate.isEmpty()) {
    update employeesToUpdate;
    }
    }
    
    // Helper method to calculate the number of leave days, excluding weekends
    public static Integer getLeaveDaysExcludingWeekends(Date startDate, Date endDate) {
    Integer leaveDays = 0;
    
    for (Date currentDate = startDate; currentDate <= endDate; currentDate = currentDate.addDays(1)) {
    Integer dayOfWeek = Integer.valueOf(DateTime.newInstance(currentDate, Time.newInstance(0, 0, 0, 0)).format('u'));
    
    // Exclude weekends (Saturday = 6, Sunday = 7)
    if (dayOfWeek != 6 && dayOfWeek != 7) {
    leaveDays++;
    }
    }
    
    return leaveDays;
    }
}
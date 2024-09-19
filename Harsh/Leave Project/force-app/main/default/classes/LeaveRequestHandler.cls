// public with sharing class LeaveRequestHandler {
//     @AuraEnabled
//     public static Id createLeaveRequest(String employeeId, Date startDate, Date endDate, String leaveType) {
//         if (startDate == null || endDate == null) {
//             throw new AuraHandledException('Start Date and End Date cannot be blank.');
//         }
//         if (String.isBlank(leaveType)) {
//             throw new AuraHandledException('Leave Type cannot be blank.');
//         }
//         if (startDate > endDate) {
//             throw new AuraHandledException('Start Date cannot be after End Date.');
//         }

//         try {
//             // Create Leave Request record
//             Leave_Req__c leaveRequest = new Leave_Req__c();
//             leaveRequest.Employee__c = employeeId;  // Assuming Employee__c is a lookup to Employee
//             leaveRequest.Start_Date__c = startDate;
//             leaveRequest.End_Date__c = endDate;
//             leaveRequest.Leave_Type__c = leaveType;

//             insert leaveRequest;
//             // Return the ID of the new Leave Request
//             return leaveRequest.Id;

//         } catch (Exception ex) {
//             throw new AuraHandledException('Error creating leave request: ' + ex.getMessage());
//         }
//     }
// }
public with sharing class LeaveRequestHandler {
 
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
                        Leave_Req__c leaveRequest = new Leave_Req__c();
                        leaveRequest.Employee__c = employeeId;  // Assuming Employee__c is a lookup to Employee
                        leaveRequest.Start_Date__c = startDate;
                        leaveRequest.End_Date__c = endDate;
                        leaveRequest.Leave_Type__c = leaveType;
            
                        insert leaveRequest;
                        // Return the ID of the new Leave Request
                        return leaveRequest.Id;
            
                    } catch (Exception ex) {
                        throw new AuraHandledException('Error creating leave request: ' + ex.getMessage());
                    }
    }
    // Check leave balances in bulk
    @AuraEnabled
    public static Map<Id, String> checkLeavesBulk(List<Leave_Req__c> leaveRequests) {
        Set<Id> employeeIds = new Set<Id>();
        for (Leave_Req__c leaveRequest : leaveRequests) {
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
 
        for (Leave_Req__c leaveRequest : leaveRequests) {
            Id employeeId = leaveRequest.Employee__c;
 
            if (employeeMap.containsKey(employeeId)) {
                Employee__c employee = employeeMap.get(employeeId);
                Decimal leaveBalance = employee.Leave_Balance__c;
 
                Integer totalLeaveDays = getLeaveDaysExcludingWeekends(leaveRequest.Start_Date__c, leaveRequest.End_Date__c);
 
                if (totalLeaveDays > leaveBalance) {
                    errorMap.put(leaveRequest.Id, 'Insufficient leave balance. You only have ' + leaveBalance + ' leave days available.');
                }
            } else {
                errorMap.put(leaveRequest.Id, 'Employee not found for ID: ' + employeeId);
            }
        }
 
        return errorMap;
    }
 
    // Bulk update leave balances when leave requests are approved
    @AuraEnabled
    public static void updateLeaveBalanceBulk(List<Leave_Req__c> leaveRequests) {
        Set<Id> employeeIds = new Set<Id>();
        for (Leave_Req__c leaveRequest : leaveRequests) {
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
 
        for (Leave_Req__c leaveRequest : leaveRequests) {
            Employee__c employee = employeeMap.get(leaveRequest.Employee__c);
            if (employee != null) {
                Integer totalLeaveDays = getLeaveDaysExcludingWeekends(leaveRequest.Start_Date__c, leaveRequest.End_Date__c);
                employee.Leave_Balance__c -= totalLeaveDays;
 
                employeesToUpdate.add(employee);
            }
        }
 
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
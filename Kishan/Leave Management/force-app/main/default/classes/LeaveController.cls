
public with sharing class LeaveController {

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
            Leave_Request__c leaveRequest = new Leave_Request__c();
            leaveRequest.Employee__c = employeeId;  
            leaveRequest.Start_Date__c = startDate;
            leaveRequest.End_Date__c = endDate;
            leaveRequest.Leave_Type__c = leaveType;

            insert leaveRequest;

            return leaveRequest.Id;

        } catch (Exception ex) {
            throw new AuraHandledException('Error creating leave request: ' + ex.getMessage());
        }
    }

}

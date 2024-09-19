trigger LeaveRquest on LeaveRequest__c (before insert, before update, after update, after insert) {
 
    if (Trigger.isBefore && Trigger.isInsert) {
    List<LeaveRequest__c> leaveRequests = new List<LeaveRequest__c>();
     
    for (LeaveRequest__c leaveRequest : Trigger.new) {
    if (leaveRequest.Employee__c != null && leaveRequest.StartDate__c != null && leaveRequest.EndDate__c != null) {
    leaveRequests.add(leaveRequest);
    }
    System.debug(leaveRequest);
    }
     
    if (!leaveRequests.isEmpty()) {
    // Call checkLeavesBulk with a list instead of a map
    Map<Id, String> errorMap = LeavetriggerHandler.checkLeavesBulk(leaveRequests);
     
    for (Id leaveRequestId : errorMap.keySet()) {
    // Match error messages to their corresponding leave request
    for (LeaveRequest__c leaveRequest : leaveRequests) {
    if (leaveRequest.Id == leaveRequestId) {
    leaveRequest.addError(errorMap.get(leaveRequestId));
    break;
    }
    }
    }
    }
    }
     
    if (Trigger.isAfter && Trigger.isUpdate) {
    Map<Id, LeaveRequest__c> approvedLeaveRequests = new Map<Id, LeaveRequest__c>();
     
    for (LeaveRequest__c leaveRequest : Trigger.new) {
    if (leaveRequest.Status__c == 'Approve' && Trigger.oldMap.get(leaveRequest.Id).Status__c != 'Approve') {
    approvedLeaveRequests.put(leaveRequest.Id, leaveRequest);
    }
    }
     
    if (!approvedLeaveRequests.isEmpty()) {
    LeavetriggerHandler.updateLeaveBalanceBulk(approvedLeaveRequests.values());
    }
    }
    }
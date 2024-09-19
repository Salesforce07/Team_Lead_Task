trigger LeaveRequestTrigger on Leave_Req__c (before insert, before update, after update, after insert) {
   
    if (Trigger.isBefore && Trigger.isInsert) {
        List<Leave_Req__c> leaveRequests = new List<Leave_Req__c>();
 
        for (Leave_Req__c leaveRequest : Trigger.new) {
            if (leaveRequest.Employee__c != null && leaveRequest.Start_Date__c != null && leaveRequest.End_Date__c != null) {
                leaveRequests.add(leaveRequest);
            }
        }
 
        if (!leaveRequests.isEmpty()) {
            // Call checkLeavesBulk with a list instead of a map
            Map<Id, String> errorMap = LeaveRequestHandler.checkLeavesBulk(leaveRequests);
 
            for (Id leaveRequestId : errorMap.keySet()) {
                // Match error messages to their corresponding leave request
                for (Leave_Req__c leaveRequest : leaveRequests) {
                    if (leaveRequest.Id == leaveRequestId) {
                        leaveRequest.addError(errorMap.get(leaveRequestId));
                        break;
                    }
                }
            }
        }
    }
 
    if (Trigger.isAfter && Trigger.isUpdate) {
        Map<Id, Leave_Req__c> approvedLeaveRequests = new Map<Id, Leave_Req__c>();
 
        for (Leave_Req__c leaveRequest : Trigger.new) {
            if (leaveRequest.Status__c == 'Approved' && Trigger.oldMap.get(leaveRequest.Id).Status__c != 'Approved') {
                approvedLeaveRequests.put(leaveRequest.Id, leaveRequest);
            }
        }
 
        if (!approvedLeaveRequests.isEmpty()) {
            LeaveRequestHandler.updateLeaveBalanceBulk(approvedLeaveRequests.values());
        }
    }
}
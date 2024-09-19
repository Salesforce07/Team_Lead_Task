trigger LeaveRequestTrigger on Leave_Request__c (after update) {
    if(trigger.isAfter && trigger.isUpdate){
        TriggerHandler.afterUpdate(trigger.oldMap, trigger.new);
    }
} 
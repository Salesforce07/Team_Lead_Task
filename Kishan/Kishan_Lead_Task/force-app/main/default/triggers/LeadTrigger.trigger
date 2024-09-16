trigger LeadTrigger on Lead (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

    if (Trigger.isBefore && Trigger.isInsert) {
        LeadTriggerHandler.populateAccountName(Trigger.new);
    }
    if(trigger.isAfter && trigger.isInsert){

    }
    if( )
   
}

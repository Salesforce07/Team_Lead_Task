/*
*********************************************************
Apex Class Name    : LeaveRequestController
Test Class Name    : LeaveRequestControllerTest
Test Coverage      : 100%
Created Date       : Sept. 18
@description       : This is class is used for creating Leave Request record
*********************************************************
@author            : Shyam Upadhyay
Modification Log:
Ver   Date         Author                               Modification
1.0   18-09-2024   Shyam Upadhyay                     Initial Version
*********************************************************
*/
public with sharing class LeaveRequestController {
   /*
*********************************************************
@Method Name    : createLeaveRequest
@description    : Method is used for creating Leave Request record
@param          : Leave_Request__c leaverequest
@return         : Leave_Request__c leaverequest
@author         : Shyam Upadhyay
*********************************************************   
*/
    @AuraEnabled
   public static Leave_Request__c createLeaveRequest(Leave_Request__c leaverequest){
      try {
        Id employeeId= leaverequest.Employee__c;
        Employee__c employee = [select id, Leave_Balance__c from Employee__c where id= :employeeId];
        Integer totalLeaves= getLeaveCounts(leaverequest.Start_Date__c, leaverequest.End_Date__c);
        if(employee.Leave_Balance__c<totalLeaves){
             throw new AuraHandledException('No enough leave balance');
        }
        else{
          insert leaverequest;
        }
        return leaverequest;
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
   }

    /*
********************************************************
@Method Name    : getLeaveCounts
@description    : Method is used to getLeaveCounts excluding weekends
@param          : Date startDate, Date endDate
@return         : Integer total
@author         : Shyam Upadhyay
*********************************************************   
*/
   public static Integer getLeaveCounts(Date startDate, Date endDate) {
    Integer total = 0;
    for (Date currentDate = startDate; currentDate <= endDate; currentDate = currentDate.addDays(1)) {
        DateTime currentDateTime = DateTime.newInstance(currentDate, Time.newInstance(0, 0, 0, 0));
        Integer dayOfWeek = Integer.valueOf(currentDateTime.format('u')); 
        
        // Check if it's not Saturday (6) or Sunday (7)
        if (dayOfWeek != 6 && dayOfWeek != 7) {
            total++;
        }
    }
    return total;
}
}
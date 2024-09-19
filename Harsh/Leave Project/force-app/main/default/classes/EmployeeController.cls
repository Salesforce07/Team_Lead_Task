public with sharing class EmployeeController {
    @AuraEnabled(cacheable=true)
    public static Employee__c getEmployee(String employeeId) {
        return [SELECT Name FROM Employee__c WHERE Id = :employeeId LIMIT 1];
    }
}

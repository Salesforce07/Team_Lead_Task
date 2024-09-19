@isTest
public class LeaveRequestHandlerTest {

    // Test method for checking leave balances in bulk
    @isTest
    static void testCheckLeavesBulk() {
        // Create test Employee records
        Employee__c employee1 = new Employee__c(Name = 'John Doe', Leave_Balance__c = 5);
        insert employee1;

        Employee__c employee2 = new Employee__c(Name = 'Jane Doe', Leave_Balance__c = 10);
        insert employee2;

        // Create test Leave_Request__c records
        Leave_Request__c leaveRequest1 = new Leave_Request__c(Employee__c = employee1.Id, Start_Date__c = Date.today(), End_Date__c = Date.today().addDays(3), Leave_Type__c = 'Sick');
        Leave_Request__c leaveRequest2 = new Leave_Request__c(Employee__c = employee2.Id, Start_Date__c = Date.today(), End_Date__c = Date.today().addDays(12), Leave_Type__c = 'Vacation');
        
        List<Leave_Request__c> leaveRequests = new List<Leave_Request__c>{leaveRequest1, leaveRequest2};
        insert leaveRequests;

        // Call the method and assert results
        Map<Id, String> errorMap = LeaveRequestHandler.checkLeavesBulk(leaveRequests);
        
        // Assert that leaveRequest1 doesn't have any errors as the balance is sufficient
        System.assertEquals(null, errorMap.get(leaveRequest1.Id));

        // Assert that leaveRequest2 has insufficient leave balance
        System.assertEquals('Insufficient leave balance. You only have 10 leave days available.', errorMap.get(leaveRequest2.Id));
    }

    // Test method for updating leave balances in bulk
    @isTest
    static void testUpdateLeaveBalanceBulk() {
        // Create test Employee records
        Employee__c employee1 = new Employee__c(Name = 'John Doe', Leave_Balance__c = 5);
        insert employee1;

        Employee__c employee2 = new Employee__c(Name = 'Jane Doe', Leave_Balance__c = 10);
        insert employee2;

        // Create test Leave_Request__c records
        Leave_Request__c leaveRequest1 = new Leave_Request__c(Employee__c = employee1.Id, Start_Date__c = Date.today(), End_Date__c = Date.today().addDays(3), Leave_Type__c = 'Sick');
        Leave_Request__c leaveRequest2 = new Leave_Request__c(Employee__c = employee2.Id, Start_Date__c = Date.today(), End_Date__c = Date.today().addDays(5), Leave_Type__c = 'Vacation');
        
        List<Leave_Request__c> leaveRequests = new List<Leave_Request__c>{leaveRequest1, leaveRequest2};
        insert leaveRequests;

        // Call the updateLeaveBalanceBulk method
        LeaveRequestHandler.updateLeaveBalanceBulk(leaveRequests);

        // Re-query employee records to check leave balance update
        employee1 = [SELECT Leave_Balance__c FROM Employee__c WHERE Id = :employee1.Id];
        employee2 = [SELECT Leave_Balance__c FROM Employee__c WHERE Id = :employee2.Id];

        // Assert that the leave balance has been correctly reduced
        System.assertEquals(2, employee1.Leave_Balance__c); // 5 - 3 = 2 days left
        System.assertEquals(5, employee2.Leave_Balance__c); // 10 - 5 = 5 days left
    }

    // Test helper method getLeaveDaysExcludingWeekends
    @isTest
    static void testGetLeaveDaysExcludingWeekends() {
        Date startDate = Date.newInstance(2024, 9, 19);  // Thursday
        Date endDate = Date.newInstance(2024, 9, 26);    // Thursday (includes a weekend)

        Integer totalLeaveDays = LeaveRequestHandler.getLeaveDaysExcludingWeekends(startDate, endDate);
        
        // Assert that weekends are excluded (7 total days - 2 weekend days)
        System.assertEquals(5, totalLeaveDays);
    }

    // Negative test case for checkLeavesBulk (employee not found)
    @isTest
    static void testCheckLeavesBulkEmployeeNotFound() {
        // Create a test Leave_Request__c without a valid employee
        Leave_Request__c leaveRequest = new Leave_Request__c(Employee__c = null, Start_Date__c = Date.today(), End_Date__c = Date.today().addDays(3), Leave_Type__c = 'Sick');
        
        List<Leave_Request__c> leaveRequests = new List<Leave_Request__c>{leaveRequest};
        
        // Call the method and assert results
        Map<Id, String> errorMap = LeaveRequestHandler.checkLeavesBulk(leaveRequests);
        
        // Assert that the error message for employee not found is returned
        System.assertNotEquals(null, errorMap.get(leaveRequest.Id));
    }
}

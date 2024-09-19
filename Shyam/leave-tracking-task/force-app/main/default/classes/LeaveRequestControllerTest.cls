@isTest
private class LeaveRequestControllerTest {
    @isTest
    static void createLeaveRequestTest() {
        // creating employee
        Employee__c employee = new Employee__c(
            Name__c= 'Vishal',
            Email__c= 'vishal@gmail.com',
            Department__c= 'Sales',
            Leave_Balance__c= 10
        );
        insert employee;
        // creating leaveRequest record
        Leave_Request__c leaveRequest = new Leave_Request__c(
       Start_Date__c = Date.newInstance(2024, 9, 18),
       End_Date__c = Date.newInstance(2024, 9, 20),
        Leave_Type__c = 'Sick Leave',
        Status__c= 'Draft',
        Employee__c = employee.Id
        );
    
        // start test
        Test.startTest();
        LeaveRequestController.createLeaveRequest(leaveRequest);
        // stop test
        Test.stopTest();   
        System.Assert([SELECT Id FROM Leave_Request__c].size()  > 0,'Leave Request record is not created');
    }
    
     @isTest
    static void createLeaveRequestLowBalanceTest() {
        // creating employee
        Employee__c employee = new Employee__c(
            Name__c= 'Vishal',
            Email__c= 'vishal@gmail.com',
            Department__c= 'Sales',
            Leave_Balance__c= 0
        );
        insert employee;
        // creating leaveRequest record
        Leave_Request__c leaveRequest = new Leave_Request__c(
       Start_Date__c = Date.newInstance(2024, 9, 18),
       End_Date__c = Date.newInstance(2024, 9, 20),
        Leave_Type__c = 'Sick Leave',
        Status__c= 'Draft',
        Employee__c = employee.Id
        );
    
        // start test
        Test.startTest();
        LeaveRequestController.createLeaveRequest(leaveRequest);
        // end test
        Test.stopTest();

        System.Assert([SELECT Id FROM Leave_Request__c].size()  == 0,'Leave Request record is not created');
        
    }
        
        @isTest
        static void testLeaveRequestApprovalUpdatesLeaveBalance() {
            // Create employee
            Employee__c emp = new Employee__c(
                Name__c= 'Vishal',
                Email__c= 'vishal@gmail.com',
                Department__c= 'Sales',
                Leave_Balance__c = 10);
            insert emp;
    
            // Create a leave request 
            Leave_Request__c leaveRequest = new Leave_Request__c(
                Employee__c = emp.Id,
                Start_Date__c = Date.newInstance(2024, 9, 18),
                End_Date__c = Date.newInstance(2024, 9, 20),
                Status__c = 'Pending'
            );
            insert leaveRequest;
    
            // Start test 
            Test.startTest();
            leaveRequest.Status__c = 'Approved';
            update leaveRequest;
    
            // Stop test 
            Test.stopTest();
    
            // Retrieve the updated employee record
            emp = [SELECT Leave_Balance__c FROM Employee__c WHERE Id = :emp.Id];
    
            // Calculate the expected leave count to deduct
            Integer leaveCount = LeaveRequestController.getLeaveCounts(leaveRequest.Start_Date__c, leaveRequest.End_Date__c);
            Integer expectedLeaveBalance = 10 - leaveCount;
    
            System.assertEquals(expectedLeaveBalance, emp.Leave_Balance__c, 'Leave balance should be updated correctly on approval');
        }
        
    
}
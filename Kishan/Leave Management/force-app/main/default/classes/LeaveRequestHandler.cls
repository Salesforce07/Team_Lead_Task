public with sharing class LeaveRequestHandler {

    /**
     * This method checks leave balances in bulk for a list of leave requests.
     * It returns a map of leave request IDs to error messages if any employee has insufficient leave balance.
     *
     * @param leaveRequests List of Leave_Request__c records to check for sufficient leave balance.
     * @return A Map where the key is the leave request ID, and the value is an error message if applicable.
     */
    @AuraEnabled
    public static Map<Id, String> checkLeavesBulk(List<Leave_Request__c> leaveRequests) {
        // Collect the IDs of all employees from the leave requests
        Set<Id> employeeIds = new Set<Id>();
        for (Leave_Request__c leaveRequest : leaveRequests) {
            if (leaveRequest.Employee__c != null) {
                employeeIds.add(leaveRequest.Employee__c);
            }
        }

        // Query employee records to get their leave balances
        Map<Id, Employee__c> employeeMap = new Map<Id, Employee__c>(
            [SELECT Id, Leave_Balance__c 
             FROM Employee__c 
             WHERE Id IN :employeeIds]
        );

        // Map to hold any errors associated with the leave requests
        Map<Id, String> errorMap = new Map<Id, String>();

        // Iterate through the leave requests and validate leave balance
        for (Leave_Request__c leaveRequest : leaveRequests) {
            Id employeeId = leaveRequest.Employee__c;

            // Check if the employee exists in the queried employee map
            if (employeeMap.containsKey(employeeId)) {
                Employee__c employee = employeeMap.get(employeeId);
                Decimal leaveBalance = employee.Leave_Balance__c;

                // Calculate the total leave days requested excluding weekends
                Integer totalLeaveDays = getLeaveDaysExcludingWeekends(leaveRequest.Start_Date__c, leaveRequest.End_Date__c);

                // If the requested days exceed the available leave balance, add an error to the map
                if (totalLeaveDays > leaveBalance) {
                    errorMap.put(leaveRequest.Id, 'Insufficient leave balance. You only have ' + leaveBalance + ' leave days available.');
                }
            } else {
                // If employee record is not found, add an error message
                errorMap.put(leaveRequest.Id, 'Employee not found for ID: ' + employeeId);
            }
        }

        // Return any errors encountered during validation
        return errorMap;
    }

    /**
     * This method updates the leave balances of employees in bulk when their leave requests are approved.
     *
     * @param leaveRequests List of Leave_Request__c records that are approved.
     */
    @AuraEnabled
    public static void updateLeaveBalanceBulk(List<Leave_Request__c> leaveRequests) {
        // Collect the IDs of employees for whom leave requests have been approved
        Set<Id> employeeIds = new Set<Id>();
        for (Leave_Request__c leaveRequest : leaveRequests) {
            if (leaveRequest.Employee__c != null) {
                employeeIds.add(leaveRequest.Employee__c);
            }
        }

        // Lock employee records to prevent changes while updating leave balances
        Map<Id, Employee__c> employeeMap = new Map<Id, Employee__c>(
            [SELECT Id, Leave_Balance__c 
             FROM Employee__c 
             WHERE Id IN :employeeIds 
             FOR UPDATE]
        );

        // List to hold employees whose leave balances need to be updated
        List<Employee__c> employeesToUpdate = new List<Employee__c>();

        // Iterate through the leave requests and update leave balances
        for (Leave_Request__c leaveRequest : leaveRequests) {
            Employee__c employee = employeeMap.get(leaveRequest.Employee__c);
            if (employee != null) {
                // Calculate the total leave days excluding weekends
                Integer totalLeaveDays = getLeaveDaysExcludingWeekends(leaveRequest.Start_Date__c, leaveRequest.End_Date__c);

                // Deduct the leave days from the employee's leave balance
                employee.Leave_Balance__c -= totalLeaveDays;

                // Add the employee to the list for updating
                employeesToUpdate.add(employee);
            }
        }

        // If there are any employees to update, perform the update operation
        if (!employeesToUpdate.isEmpty()) {
            update employeesToUpdate;
        }
    }

    /**
     * This helper method calculates the total number of leave days excluding weekends (Saturday and Sunday).
     *
     * @param startDate The start date of the leave request.
     * @param endDate The end date of the leave request.
     * @return The total number of leave days excluding weekends.
     */
    public static Integer getLeaveDaysExcludingWeekends(Date startDate, Date endDate) {
        Integer leaveDays = 0;

        // Iterate through each date from the start date to the end date
        for (Date currentDate = startDate; currentDate <= endDate; currentDate = currentDate.addDays(1)) {
            // Get the day of the week (1 = Monday, 7 = Sunday)
            Integer dayOfWeek = Integer.valueOf(DateTime.newInstance(currentDate, Time.newInstance(0, 0, 0, 0)).format('u'));

            // Exclude weekends (Saturday = 6, Sunday = 7)
            if (dayOfWeek != 6 && dayOfWeek != 7) {
                leaveDays++;
            }
        }

        // Return the total number of leave days excluding weekends
        return leaveDays;
    }
}

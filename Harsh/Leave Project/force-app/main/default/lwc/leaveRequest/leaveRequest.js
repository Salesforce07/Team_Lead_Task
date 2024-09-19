import { LightningElement, api, track, wire } from 'lwc';
import createLeaveRequest from '@salesforce/apex/LeaveRequestHandler.createLeaveRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

// Define fields to fetch
const EMPLOYEE_FIELDS = ['Employee__c.Name'];

export default class LeaveRequestForm extends NavigationMixin(LightningElement) {
    @api recordId; // This is the ID of the employee record
    @track startDate = '';
    @track endDate = '';
    @track leaveType = '';
    @track employeeId;
    @track employeeName = '';
    @track errorMessage = '';

    leaveTypeOptions = [
        { label: 'Sick Leave', value: 'Sick Leave' },
        { label: 'Casual Leave', value: 'Casual Leave' }
    ];

    renderedCallback(){
        this.employeeId=this.recordId;
        // console.log('Display Info:', JSON.stringify(this.displayInfo));
    }

    displayInfo = {
        primaryField: 'Emp_Name__c',
        additionalFields: ['Name'],
    };
    
    matchingInfo = {
        primaryField: { fieldPath: 'Emp_Name__c' },
        additionalFields: [{ fieldPath: 'Name' }],
    };

    handleStartDateChange(event) {
        this.startDate = event.target.value;
        this.testStartDate();
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
        this.testEndDate();
    }

    handleLeaveTypeChange(event) {
        this.leaveType = event.target.value;
    }

    testStartDate() {
        let stDate = this.template.querySelector(".Stdate");
        let stDateVal = stDate.value;
    
        // Get today's date in IST
        const today = new Date();
        const istOffset = 5.5 * 60 * 60 * 1000; // Offset in milliseconds (5.5 hours)
        const todayInIST = new Date(today.getTime() + istOffset);
        
        todayInIST.setHours(0, 0, 0, 0); // Set time to midnight for accurate comparison
        const formattedToday = todayInIST.toISOString().split('T')[0]; // Format to YYYY-MM-DD
    
        if (!stDateVal) {
            stDate.setCustomValidity("Date value is required");
        } else if (stDateVal <= formattedToday) {
            stDate.setCustomValidity("Start date cannot be before today.");
        } else {
            const selectedDate = new Date(stDateVal);
            const selectedDateInIST = new Date(selectedDate.getTime() + istOffset);
            const dayOfWeek = selectedDateInIST.getDay();
            if (dayOfWeek === 0 || dayOfWeek === 6) { // 0 = Sunday, 6 = Saturday
                stDate.setCustomValidity("Start date cannot be on a weekend.");
            } else {
                stDate.setCustomValidity(""); // Clear previous validity messages
            }
        }
        
        stDate.reportValidity();
    }
    
    closeModal() {
        // Logic to close the modal, e.g., setting a boolean property to false
        this.isModalOpen = false; // Adjust according to your modal visibility logic
    }
    
    testEndDate() {
        let endDate = this.template.querySelector(".Enddate");
        let endDateVal = endDate.value;
        let startDateVal = this.template.querySelector(".Stdate").value; // Get the value of the start date
    
        // Get today's date in IST
        const today = new Date();
        const istOffset = 5.5 * 60 * 60 * 1000; // Offset in milliseconds (5.5 hours)
        const todayInIST = new Date(today.getTime() + istOffset);
        todayInIST.setHours(0, 0, 0, 0); // Set time to midnight for accurate comparison
        const formattedToday = todayInIST.toISOString().split('T')[0]; // Format to YYYY-MM-DD
    
        if (!endDateVal) {
            endDate.setCustomValidity("Date value is required");
        } else if (endDateVal < formattedToday) {
            endDate.setCustomValidity("End date cannot be before today.");
        } else if (startDateVal && endDateVal < startDateVal) {
            endDate.setCustomValidity("End date cannot be earlier than start date.");
        } 
        else {
            const endedDate = new Date(endDateVal);
            const endedDateInIST = new Date(endedDate.getTime() + istOffset);
            const dayOfWeek = endedDateInIST.getDay();
            if (dayOfWeek === 0 || dayOfWeek === 6) { // 0 = Sunday, 6 = Saturday
                endDate.setCustomValidity("end date cannot be on a weekend.");
            } else {
                endDate.setCustomValidity(""); // Clear previous validity messages
            }
        }
        
        endDate.reportValidity();
    }
    
    async handleSubmit() {
        this.errorMessage = '';

        // Validation
        // if (!this.startDate || !this.endDate || !this.leaveType || !this.employeeId) {
        //     this.errorMessage = 'Error: All fields are required.';
        //     return;
        // }

        try {
            const leaveRequestId = await createLeaveRequest({
                employeeId: this.employeeId,
                startDate: this.startDate,
                endDate: this.endDate,
                leaveType: this.leaveType
            });

            // Show success toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Leave request created successfully!',
                    variant: 'success'
                })
            );

            // Navigate to the newly created leave request record detail page
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: leaveRequestId,
                    actionName: 'view'
                }
            });
        } catch (error) {
            this.errorMessage = error.body.message;
            // Show error toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.errorMessage,
                    variant: 'error'
                })
            );
        }
    }
}

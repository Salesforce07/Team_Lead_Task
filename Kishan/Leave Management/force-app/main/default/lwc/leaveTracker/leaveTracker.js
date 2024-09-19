import { LightningElement, api, track, wire } from 'lwc';
import createLeaveRequest from '@salesforce/apex/LeaveController.createLeaveRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class LeaveRequestForm extends NavigationMixin(LightningElement) {
    @api recordId; // Employee ID if provided
    @track employeeId; // The selected employee Id
    @track startDate = '';
    @track endDate = '';
    @track leaveType = '';
    @track errorMessage = '';

    leaveTypeOptions = [
        { label: 'Sick Leave', value: 'Sick Leave' },
        { label: 'Casual Leave', value: 'Casual Leave' }
    ];

    handleEmployeeChange(event) {
        this.employeeId = event.detail.value;
    }

    handleStartDateChange(event) {
        this.startDate = event.target.value;
        this.validateDates();
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
        this.validateDates();
    }

    handleLeaveTypeChange(event) {
        this.leaveType = event.target.value;
    }
    renderedCallback(){
                 this.employeeId = this.recordId;
    }


    validateDates() {
        const today = new Date();
        const startDate = new Date(this.startDate);
        const endDate = new Date(this.endDate);
    
        const startDateInput = this.template.querySelector('[data-id="startDate"]');
        const endDateInput = this.template.querySelector('[data-id="endDate"]');
    
        // Ensure start date is not before today
        if (startDate.getTime() < today.setHours(0, 0, 0, 0)) {
            startDateInput.setCustomValidity('Start Date cannot be earlier than today.');
        } else {
            startDateInput.setCustomValidity(''); // Clear custom validity
        }
    
        // Ensure end date is not earlier than start date
        if (this.endDate && endDate.getTime() < startDate.getTime()) {
            endDateInput.setCustomValidity('End Date cannot be earlier than Start Date.');
        } else {
            endDateInput.setCustomValidity(''); // Clear custom validity
        }
    
        // Ensure start and end dates are not weekends
        const startDay = startDate.getDay();
        const endDay = endDate.getDay();
        if (startDay === 6 || startDay === 0) {
            startDateInput.setCustomValidity('Start Date cannot be on a weekend.');
        }
        if (endDay === 6 || endDay === 0) {
            endDateInput.setCustomValidity('End Date cannot be on a weekend.');
        }
    
        // Report validity for both inputs
        startDateInput.reportValidity();
        endDateInput.reportValidity();
    
        // Return true if both fields are valid
        return startDateInput.checkValidity() && endDateInput.checkValidity();
    }
    

    async handleSave() {
        this.errorMessage = '';
        if (!this.validateDates()) {
            return;
        }

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

    async handleSaveAndNew() {
        this.errorMessage = '';
        if (!this.validateDates()) {
            return;
        }

        try {
            await createLeaveRequest({
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

            // Clear form fields for a new record
            this.startDate = '';
            this.endDate = '';
            this.leaveType = '';
            this.employeeId = '';

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

    handleCancel() {
        // Navigate back or close the form
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Employee__c' // Navigate to the custom tab or home page
            }
        });
    }
}
//this is working

// import { LightningElement, api, track, wire } from 'lwc';
// import createLeaveRequest from '@salesforce/apex/LeaveTracker.createLeaveRequest';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import { NavigationMixin } from 'lightning/navigation';

// export default class LeaveRequestForm extends NavigationMixin(LightningElement) {
//     @api recordId; // Employee ID if provided
//     @track employeeId; // The selected employee Id
//     @track startDate = '';
//     @track endDate = '';
//     @track leaveType = '';
//     @track errorMessage = '';

//     leaveTypeOptions = [
//         { label: 'Sick Leave', value: 'Sick Leave' },
//         { label: 'Casual Leave', value: 'Casual Leave' }
//     ];

//     handleEmployeeChange(event) {
//         this.employeeId = event.detail.value;
//     }

//     handleStartDateChange(event) {
//         this.startDate = event.target.value;
//         this.validateDates();
//     }

//     handleEndDateChange(event) {
//         this.endDate = event.target.value;
//         this.validateDates();
//     }

//     handleLeaveTypeChange(event) {
//         this.leaveType = event.target.value;
//     }

//     renderedCallback(){
//         this.employeeId = this.recordId;
//     }

//     validateDates() {
//         const today = new Date().toISOString().split('T')[0]; // Current date in YYYY-MM-DD format
//         const startDate = this.startDate;
//         const endDate = this.endDate;
        
//         const startDateInput = this.template.querySelector('[data-id="startDate"]');
//         const endDateInput = this.template.querySelector('[data-id="endDate"]');
        
//         // Ensure start date is not before today
//         if (startDate < today) {
//             startDateInput.setCustomValidity('Start Date cannot be earlier than today.');
//         } else {
//             startDateInput.setCustomValidity(''); // Clear custom validity
//         }
        
//         // Ensure end date is not earlier than start date
//         if (endDate && endDate < startDate) {
//             endDateInput.setCustomValidity('End Date cannot be earlier than Start Date.');
//         } else {
//             endDateInput.setCustomValidity(''); // Clear custom validity
//         }
        
//         // Ensure start and end dates are not weekends
//         const startDay = new Date(startDate).getDay();
//         const endDay = new Date(endDate).getDay();
//         if (startDay === 6 || startDay === 0) {
//             startDateInput.setCustomValidity('Start Date cannot be on a weekend.');
//         } else {
//             startDateInput.setCustomValidity(''); // Clear custom validity
//         }
//         if (endDay === 6 || endDay === 0) {
//             endDateInput.setCustomValidity('End Date cannot be on a weekend.');
//         } else {
//             endDateInput.setCustomValidity(''); // Clear custom validity
//         }

//         // Finally, trigger the validity check and show the error message on the form
//         startDateInput.reportValidity();
//         endDateInput.reportValidity();
//         return true;
//     }

//     async handleSubmit() {
//         this.errorMessage = '';
//         if (!this.validateDates()) {
//             return;
//         }

//         try {
//             const leaveRequestId = await createLeaveRequest({
//                 employeeId: this.employeeId,
//                 startDate: this.startDate,
//                 endDate: this.endDate,
//                 leaveType: this.leaveType
//             });

//             // Show success toast
//             this.dispatchEvent(
//                 new ShowToastEvent({
//                     title: 'Success',
//                     message: 'Leave request created successfully!',
//                     variant: 'success'
//                 })
//             );

//             // Navigate to the newly created leave request record detail page
//             this[NavigationMixin.Navigate]({
//                 type: 'standard__recordPage',
//                 attributes: {
//                     recordId: leaveRequestId,
//                     actionName: 'view'
//                 }
//             });

//         } catch (error) {
//             this.errorMessage = error.body.message;
//             // Show error toast
//             this.dispatchEvent(
//                 new ShowToastEvent({
//                     title: 'Error',
//                     message: this.errorMessage,
//                     variant: 'error'
//                 })
//             );
//         }
//     }
// }



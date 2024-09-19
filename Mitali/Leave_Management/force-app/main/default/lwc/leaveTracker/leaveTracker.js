

import { api, LightningElement, track } from 'lwc';
import createLeaveRequest from '@salesforce/apex/LeaveRequestController.createLeaveRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';


export default class LeaveTracker extends NavigationMixin(LightningElement) {
  
    @api recordId;
    @track employeeId;
    @track startDate;
    @track endDate;
    @track leaveType = 'Sick Leave'; // default value
    @track status = 'Draft'; // default value
    @track startDateError = ''; // Error message for Start Date
    @track endDateError = ''; // Error message for End Date

    get leaveTypeOptions() {
        return [
            { label: 'Sick Leave', value: 'Sick Leave' },
            { label: 'Casual Leave', value: 'Casual Leave' }
        ];
    }
 
    renderedCallback(){
        this.employeeId=this.recordId;
    } 


    handleStartDateChange(event) {
        this.startDate = event.target.value;
        this.validateStartDate();
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
        this.validateEndDate();
    }

    handleLeaveTypeChange(event) {
        this.leaveType = event.target.value;
    }

    // Utility function to strip time from a Date object
    removeTime(date) {
        return new Date(date.getFullYear(), date.getMonth(), date.getDate());
    }

    // Validation for Start Date: Should not be in the past and no weekends
    validateStartDate() {
        const today = this.removeTime(new Date()); // Today’s date without time
        const startDateObj = this.removeTime(new Date(this.startDate)); // Start date without time
        const dayOfWeek = startDateObj.getDay();

        if (startDateObj < today) {
            this.startDateError = 'Start Date should be today or a future date';
        } else if (dayOfWeek === 6 || dayOfWeek === 0) {
            this.startDateError = 'Start Date cannot be on a weekend';
        } else {
            this.startDateError = '';
        }
    }

    // Validation for End Date: Should be equal to or greater than Start Date, and no weekends
    validateEndDate() {
        const startDateObj = this.removeTime(new Date(this.startDate));
        const endDateObj = this.removeTime(new Date(this.endDate));
        const dayOfWeek = endDateObj.getDay();

        if (endDateObj < startDateObj) {
            this.endDateError = 'End Date should be equal to or greater than Start Date';
        } else if (dayOfWeek === 6 || dayOfWeek === 0) {
            this.endDateError = 'End Date cannot be on a weekend';
        } else {
            this.endDateError = '';
        }
    }

    // Dynamic class for Start Date input
    get startDateClass() {
        return this.startDateError ? 'slds-input-margin slds-has-error' : 'slds-input-margin';
    }

    // Dynamic class for End Date input
    get endDateClass() {
        return this.endDateError ? 'slds-input-margin slds-has-error' : 'slds-input-margin';
    }

    handleSubmit() {
        // Validate before submission
        this.validateStartDate();
        this.validateEndDate();

        if (this.startDateError || this.endDateError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please correct the errors before submitting',
                    variant: 'error',
                })
            );
            return;
        }

        // Automatically update status to 'Pending' before submission
        this.status = 'Pending';

        // Call Apex method to create leaveRequest record
        createLeaveRequest({ 
            employeeId : this.employeeId,
            startDate: this.startDate, 
            endDate: this.endDate, 
            leaveType: this.leaveType, 
            status: this.status // Submit with status 'Pending'
        })
        .then(result => {
            // Show success message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Leave request created successfully with status Pending',
                    variant: 'success',
                })
            );

            // Redirect to the leaveRequest record page
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: result,
                    objectApiName: 'LeaveRequest__c',
                    actionName: 'view'
                }
            });
        })
        .catch(error => {
            console.log('Error', error);
            // Show error message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'error',
                })
            );
        });
    }
}

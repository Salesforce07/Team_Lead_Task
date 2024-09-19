import { api, LightningElement } from 'lwc';
import createLeaveRequest from '@salesforce/apex/LeaveRequestController.createLeaveRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';

export default class LeaveRequest extends NavigationMixin(LightningElement) {
  @api recordId;
  employeeId = '';
  startDate;
  recordPageId;
  endDate;
  leaveType;
  leaveTypeOptions = [
    { label: 'Sick Leave', value: 'Sick Leave' },
    { label: 'Casual Leave', value: 'Casual Leave' }
  ];

  displayInfo = {
    primaryField: 'Employee__c.Name__c',
    additionalField: 'Employee__c.Name__c'
  };

  // Navigate to record page
  navigateToRecordViewPage() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recordPageId,
        objectApiName: "Leave_Request__c",
        actionName: "view",
      },
    });
  }

  renderedCallback() {
    this.employeeId = this.recordId;
  }


  handleChange(e) {
    switch (e.target.name) {
      case 'Employee':
        this.employeeId = e.detail.recordId;
        break;
      case 'Start Date':
        ((this.validateToday(e.target.value, 'StartDate')) && (this.validateWeekend(e.target.value, 'StartDate'))) ? this.startDate = e.target.value : this.startDate = '';
        break;
      case 'End Date':
        ((this.validateToday(e.target.value, 'EndDate')) && (this.validateWeekend(e.target.value, 'EndDate'))) ? this.endDate = e.target.value : this.endDate = '';
        break;
      case 'Leave Type':
        this.leaveType = e.target.value;
        break;
    }
  }



  validateRequired(val, name) {
    let comp = this.template.querySelector('.' + name);
    if (val == '' || val == undefined) {
      comp.setCustomValidity('This field is required');
      comp.reportValidity();
      return false;
    }
    else {
      comp.setCustomValidity('');
      comp.reportValidity();
      return true;
    }

  }


  validateToday(val, name) {
    let comp = this.template.querySelector('.' + name);
    const date = new Date();
    let day = date.getDate();
    let month = date.getMonth() + 1;
    if (month < 10) {
      month = '0' + month;
    }
    let year = date.getFullYear();
    let currentDate = `${year}-${month}-${day}`;
    if (val < currentDate) {
      comp.setCustomValidity('This date is smaller than today');
      comp.reportValidity();
      return false;
    }
    else {
      comp.setCustomValidity('');
      comp.reportValidity();
      return true;
    }
  }

  validateWeekend(val, name) {
    let comp = this.template.querySelector('.' + name);
    let date = new Date(val);
    let day = date.getDay();
    if (day == 0 || day == 6) {
      comp.setCustomValidity('Weekend is not allowed');
      comp.reportValidity();
      return false;
    }
    else {
      comp.setCustomValidity('');
      comp.reportValidity();
      return true;
    }
  }

  validateEndDate(valStart, valEnd, name) {
    let comp = this.template.querySelector('.' + name);
    if (valEnd < valStart) {
      comp.setCustomValidity('End Date Should be greater than Start Date');
      comp.reportValidity();
      return false;
    }
    else {
      comp.setCustomValidity('');
      comp.reportValidity();
      return true;
    }
  }


  closeQuickAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  handleSubmit() {
    const isStartDateValid = this.validateRequired(this.startDate, 'StartDate');
    const isEndDateValid = this.validateRequired(this.endDate, 'EndDate');
    const isLeaveTypeValid = this.validateRequired(this.leaveType, 'LeaveType');
    const isEmployeeIdValid = this.validateRequired(this.employeeId, 'Employee');
    const isEndDateAfterStartDate = this.validateEndDate(this.startDate, this.endDate, 'EndDate');

    if (isStartDateValid && isEndDateValid && isLeaveTypeValid && isEmployeeIdValid && isEndDateAfterStartDate) {
      console.log("Submit");
      const leaveRequest = {
        Start_Date__c: this.startDate,
        End_Date__c: this.endDate,
        Leave_Type__c: this.leaveType,
        Employee__c: this.employeeId
        // Status: 'Draft'
      };
      console.log('This is leave send.......', { leaveRequest })
      createLeaveRequest({ leaverequest: leaveRequest })
        .then((result) => {
          console.log("this is what returnss........ ", result)
          this.recordPageId = result.Id;
          this.navigateToRecordViewPage();
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Success',
              message: 'Leave request created successfully',
              variant: 'success'
            })
          );
          this.closeQuickAction();
        })
        .catch((error) => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error creating leave request',
              message: error.body.message,
              variant: 'error'
            })
          );
        });

    }
    else {
      console.log(this.startDate, this.endDate, this.leaveType, this.employeeId, this.endDateAfterStartDate)
      console.log("Not Valid")
    }
  }
}

import { LightningElement, track, wire } from 'lwc';
import createLead from '@salesforce/apex/ContactLeadApex.createLead';
import getLeadSourcePicklistValues from '@salesforce/apex/ContactLeadApex.getLeadSourcePicklistValues';
import getLeadStatusPicklistValues from '@salesforce/apex/ContactLeadApex.getLeadStatusPicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
 

export default class NewLeadCon extends NavigationMixin(LightningElement) {
    @track isFormVisible = false;
    @track leadSourceOptions = [];
    @track leadStatusOptions = [];

    @track firstName = '';
    @track lastName = '';
    @track email = '';
    @track country = '';
    @track company = '';
    @track leadSource = '';
    @track leadStatus = '';

    // Error messages
    @track firstNameError = '';
    @track lastNameError = '';
    @track emailError = '';
    @track countryError = '';
    @track companyError = '';
    @track leadSourceError = '';
    @track leadStatusError = '';

  
    @wire(getLeadSourcePicklistValues)
    wiredLeadSourcePicklist({ data, error }) {
        if (data) {
            this.leadSourceOptions = data.map(value => ({ label: value, value }));
        }
    }

    @wire(getLeadStatusPicklistValues)
    wiredLeadStatusPicklist({ data, error }) {
        if (data) {
            this.leadStatusOptions = data.map(value => ({ label: value, value }));
        }
    }

    showForm() {
        this.isFormVisible = !this.isFormVisible;
    }

    handleInputChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;

       
        if (field === 'firstName') {
            this.firstNameError = this.validateAlphabetic(this.firstName) ? '' : 'First Name must only contain letters';
        } else if (field === 'lastName') {
            this.lastNameError = this.validateAlphabetic(this.lastName) ? '' : 'Last Name must only contain letters';
        } else if (field === 'email') {
            this.emailError = this.validateEmail(this.email) ? '' : 'Please enter a valid Email address';
        } else if (field === 'country') {
            this.countryError = this.validateAlphabetic(this.country) ? '' : 'Country must only contain letters';
        } else if (field === 'company') {
            this.companyError = this.company ? '' : 'Company is required';
        }
    }

    handleLeadSourceChange(event) {
        this.leadSource = event.detail.value;
        this.leadSourceError = this.leadSource ? '' : 'Lead Source is required';
    }

    handleLeadStatusChange(event) {
        this.leadStatus = event.detail.value;
        this.leadStatusError = this.leadStatus ? '' : 'Lead Status is required';
    }

    handleSaveLead() {
        if (!this.validateForm()) {
            return; 
        }

        const lead = {
            FirstName: this.firstName,
            LastName: this.lastName,
            Email: this.email,
            Company: this.company,
            Country: this.country,
            LeadSource: this.leadSource,
            Status: this.leadStatus
        };

        createLead({ lead })
            .then(result => {
                this.showSuccessToast('Lead created successfully!');
                this.navigateToRecordPage(result.Id);
            })
            .catch(error => {
                console.error('Error creating lead: ', error.body.message);
            });
    }

    validateForm() {
        this.handleInputChange({ target: { name: 'firstName', value: this.firstName } });
        this.handleInputChange({ target: { name: 'lastName', value: this.lastName } });
        this.handleInputChange({ target: { name: 'email', value: this.email } });
        this.handleInputChange({ target: { name: 'country', value: this.country } });
        this.handleInputChange({ target: { name: 'company', value: this.company } });

        this.handleLeadSourceChange({ detail: { value: this.leadSource } });
        this.handleLeadStatusChange({ detail: { value: this.leadStatus } });

        return !this.firstNameError && !this.lastNameError && !this.emailError && !this.countryError &&
               !this.companyError && !this.leadSourceError && !this.leadStatusError;
    }

    validateEmail(email) {
        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailPattern.test(email);
    }

    validateAlphabetic(value) {
        const alphabeticPattern = /^[A-Za-z\s]+$/;
        return alphabeticPattern.test(value);
    }

    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success'
        });
        this.dispatchEvent(event);
    }
     
    showErrorToast(message) {
        const event = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(event);
    }


    navigateToRecordPage(leadId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: leadId,
                actionName: 'view',
            },
        });
    }
}

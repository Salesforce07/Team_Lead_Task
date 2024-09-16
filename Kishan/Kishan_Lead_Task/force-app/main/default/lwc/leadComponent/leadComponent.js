import { LightningElement, track } from 'lwc';
import saveLead from '@salesforce/apex/LeadController.saveLead'; 
import { NavigationMixin } from 'lightning/navigation'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LeadFormComponent extends NavigationMixin(LightningElement) {
    @track isModalOpen = false;
    @track firstName = '';
    @track lastName = '';
    @track email = '';
    @track orgSize = '';
    @track leadStatus = '';
    @track company = '';
    @track leadSource = '';
    @track country = '';
    @track errorMessage = '';
    @track errors = {
        firstName: '',
        lastName: '',
        email: '',
        orgSize: '',
        leadStatus: '',
        country: ''
    };

    leadStatusOptions = [
        { label: 'New', value: 'New' },
        { label: 'Working', value: 'Working' },
        { label: 'Closed', value: 'Closed' }
    ];

    leadSourceOptions = [
        { label: 'Web', value: 'Web' },
        { label: 'Phone Inquiry', value: 'Phone Inquiry' },
        { label: 'Partner Referral', value: 'Partner Referral' },
        { label: 'Purchased List', value: 'Purchased List' },
        { label: 'Other', value: 'Other' }
    ];

    // Regex for validation
    nameRegex = /^[A-Za-z]+([-'][A-Za-z]+)*$/;  // Allows alphabets, hyphens, apostrophes
    emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[A-Z]{2,}$/i;  // Basic email validation
    numberRegex = /^[0-9]+$/;  // Ensures org size is numeric
    leadStatusRegex = /^.+$/; 

    // Method to handle opening the modal and showing the form
    handleOpenModal() {
        this.isModalOpen = true;  // Set modal open to true to show the form
    }

    // Method to handle closing the modal and clearing the form
    handleCloseModal() {
        this.isModalOpen = false;  // Set modal open to false to hide the form
        this.clearForm();  // Clear the form fields when modal is closed
    }

    // Method to handle input changes and validate the fields
    handleInputChange(event) {
        const field = event.target.dataset.id;
        const value = event.target.value;
        this[field] = value;
        this.validateField(field, value);
    }

    // Field validation logic based on field type
    validateField(field, value) {
        let error = '';
        switch (field) {
            case 'firstName':
            case 'lastName':
                if (!this.nameRegex.test(value)) {
                    
                    error = 'Name must contain only alphabetic characters.';
                }
                break;
            case 'email':
                if (value && !this.emailRegex.test(value)) {
                    error = 'Please enter a valid email address.';
                }
                break;
            case 'orgSize':
                if (value && !this.numberRegex.test(value)) {
                    error = 'Org Size must be a number.';
                }
                break;
            default:
                break;
        }
        this.errors = { ...this.errors, [field]: error };
    }

    // Save lead record when form is submitted
    handleSave() {
        this.errorMessage = '';

        // Validate required fields
        if (!this.validateRequiredFields()) {
            return;  // If validation fails, stop execution
        }

        // Validate other fields (like Org Size and Email format)
        if (!this.validateOtherFields()) {
            return;  // If validation fails, stop execution
        }

        // Prepare lead data
        const leadData = {
            FirstName: this.firstName,
            LastName: this.lastName,
            Email: this.email,
            OrgSize: this.orgSize,
            LeadStatus: this.leadStatus,
            Company: this.company,
            LeadSource: this.leadSource,
            Country: this.country
        };

        // Save Lead via Apex
        saveLead({ lead: leadData })
            .then(result => {
                this.showSuccessToast('Lead Created successfully!');
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result.Id,
                        objectApiName: 'Lead',
                        actionName: 'view'
                    }
                });
                this.handleCloseModal();  // Close modal after successful save
            })
            .catch(error => {
                this.errorMessage = `Error saving lead: ${error.body.message}`;
            });
    }

    // Method to validate required fields
    validateRequiredFields() {
        if (!this.firstName) {
            this.errors.firstName = 'First Name is required.';
            return false;
        }
        if (!this.lastName) {
            this.errors.lastName = 'Last Name is required.';
            return false;
        }
        if (!this.email) {
            this.errors.email = 'Email is required.';
            return false;
        }
        if (!this.leadStatus) {
            this.errors.leadStatus = 'Lead Status is required.';
            return false;
        }
        if (!this.country) {
            this.errors.country = 'Country is required.';
            return false;
        }

        return true;  // If all required fields are valid, return true
    }

    // Method to validate other fields (like email format and org size)
    validateOtherFields() {
        if (this.errors.firstName || this.errors.lastName || this.errors.email || this.errors.orgSize) {
            return false;
        }
        return true;
    }

    // Method to clear the form after submission or cancel
    clearForm() {
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.orgSize = '';
        this.leadStatus = '';
        this.company = '';
        this.leadSource = '';
        this.country = '';
        this.errors = {};  // Reset errors
        this.errorMessage = '';  // Clear any previous error messages
    }

    // Method to show a success toast message after lead creation
    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success',
        });
        this.dispatchEvent(event);
    }
}

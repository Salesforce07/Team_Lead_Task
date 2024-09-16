import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation'; // Import NavigationMixin
import createLead from '@salesforce/apex/LeadController.createLead';

export default class LeadForm extends NavigationMixin(LightningElement) { // Extend NavigationMixin
    @track firstName = '';
    @track lastName = '';
    @track email = '';
    @track countryName = '';
    @track companyName = '';
    @track orgSize = '';
    @track leadStatus = '';
    @track leadSource = '';
    @track hasError = false;
    @track errorMessage = '';
    @track emailError = '';
    @track firstNameError = '';
    @track lastNameError = '';
    @track companyNameError = '';
    @track countryNameError = '';
    @track isModalOpen=false;

    // Options for comboboxes
    get leadStatusOptions() {
        return [
            { label: 'New', value: 'New' },
            { label: 'Working', value: 'Working' },
            { label: 'Closed - Converted', value: 'Closed - Converted' },
            { label: 'Closed - Not Converted', value: 'Closed - Not Converted' }
        ];
    }

    get leadSourceOptions() {
        return [
            { label: 'Web', value: 'Web' },
            { label: 'Phone Inquiry', value: 'Phone Inquiry' },
            { label: 'Partner Referral', value: 'Partner Referral' },
            { label: 'Purchased List', value: 'Purchased List' }
        ];
    }


    handleInputChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;
        // Validate field based on the data-id
        this[`validate${field.charAt(0).toUpperCase() + field.slice(1)}`]();
    }

    handleLeadAndOrg(event){
      const field = event.target.dataset.id;
      this[field] = event.target.value;
    }

    handleOpenModal() {
      this.isModalOpen = !this.isModalOpen;  // Set modal open to true to show the form
    }

  // Method to handle closing the modal and clearing the form
    // handleCloseModal() {
    //   this.isModalOpen = false;  // Set modal open to false to hide the form
    //   this.clearForm();  // Clear the form fields when modal is closed
    // }

    validateFirstName() {
        const nameRegex = /^[A-Za-z\s]+$/;
        if (this.firstName && !nameRegex.test(this.firstName)) {
            this.firstNameError = 'First name can only contain letters and spaces';
            return true;
        } else {
            this.firstNameError = '';
        }
    }

    validateCountryName() {
      const nameRegex = /^[A-Za-z\s]+$/; // No numbers allowed
      if (this.countryName && !nameRegex.test(this.countryName)) {
          this.countryNameError = 'Country name can only contain letters and spaces';
          return true;
      } else {
          this.countryNameError = '';
      }
  }

    validateLastName() {
        const nameRegex = /^[A-Za-z\s]+$/;
        if (this.lastName && !nameRegex.test(this.lastName)) {
            this.lastNameError = 'Last name can only contain letters and spaces';
            return true;
        } else {
            this.lastNameError = '';
        }
    }

    validateCompanyName() {
        const nameRegex = /^[A-Za-z\s]+$/;
        if (this.companyName && !nameRegex.test(this.companyName)) {
            this.companyNameError = 'Company name can only contain letters and spaces';
            return true;
        } else {
            this.companyNameError = '';
        }
    }

    validateEmail() {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/; // Simple email regex
        if (this.email && !emailRegex.test(this.email)) {
            this.emailError = 'The email format is not correct';
            return true;
        } else {
            this.emailError = '';
        }
    }

    validateForm() {
        if (!this.lastName || !this.companyName || !this.leadStatus || !this.countryName) {
            this.hasError = true;
            this.errorMessage = 'Required fields are missing.';
            return false;
        } else if (this.emailError || this.firstNameError || this.lastNameError || this.companyNameError || this.countryNameError) {
            this.hasError = true;
            this.errorMessage = 'Please fix the errors above.';
            return false;
        }
        this.hasError = false;
        this.errorMessage = '';
        return true;
    }

    handleSubmit() {
        if (this.validateForm()) {
            createLead({
                firstName: this.firstName,
                lastName: this.lastName,
                email: this.email,
                countryName: this.countryName,
                companyName: this.companyName,
                orgSize: parseFloat(this.orgSize),
                leadStatus: this.leadStatus,
                leadSource: this.leadSource
            })
                .then(leadId => {
                    console.log('Lead created with ID:', leadId);
                    // Navigate to the newly created Lead record page
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: leadId,
                            objectApiName: 'Lead',
                            actionName: 'view'
                        }
                    });
                    this.handleCloseModal();
                })
                .catch(error => {
                    console.error('Error creating lead:', error);
                    this.hasError = true;
                    this.errorMessage = 'Error creating lead.';
                });
        }
    }

    resetForm() {
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.countryName = '';
        this.companyName = '';
        this.orgSize = '';
        this.leadStatus = '';
        this.leadSource = '';
        this.firstNameError = '';
        this.lastNameError = '';
        this.companyNameError = '';
        this.countryNameError = '';
        this.emailError = '';
    }
}
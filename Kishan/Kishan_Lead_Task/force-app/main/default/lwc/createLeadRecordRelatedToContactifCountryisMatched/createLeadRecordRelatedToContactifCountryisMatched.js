import { LightningElement, track } from 'lwc';
import createLead from '@salesforce/apex/LeadController.createLead'; // Import the Apex method

export default class LeadFormComponent extends LightningElement {
    @track firstName = '';
    @track lastName = '';
    @track company = '';
    @track email = '';
    @track phone = '';
    @track errorMessage = '';

    handleInputChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;
    }

    handleSubmit() {
        // Clear previous error message
        this.errorMessage = '';

        // Validate form fields
        if (!this.firstName || !this.lastName || !this.company || !this.email || !this.phone) {
            this.errorMessage = 'All fields are required';
            return;
        }

        
        const leadData = {
            FirstName: this.firstName,
            LastName: this.lastName,
            Company: this.company,
            Email: this.email,
            Phone: this.phone
        };

        // Call Apex method to create lead
        createLead({ lead: leadData })
            .then(() => {
                // Clear fields on success
                this.firstName = '';
                this.lastName = '';
                this.company = '';
                this.email = '';
                this.phone = '';
                // Optional: Show success message or redirect
            })
            .catch(error => {
                this.errorMessage = `Error creating lead: ${error.body.message}`;
            });
    }
}

import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createLeadRecord from '@salesforce/apex/LeadController.createLeadRecord';
import {NavigationMixin} from 'lightning/navigation';

export default class CreateLead extends NavigationMixin(LightningElement) {
   isModalOpen= false;
   recordPageUrl;
   recordPageId;
   recordId;
   FirstName;
   LastName;
   Email;
   Company;
   LeadSource;
   LeadStatus;
   Country;
   leadSourceOptions= [
    { label: 'Web', value: 'Web' },
    { label: 'Phone Inquiry', value: 'Phone Inquiry' },
    { label: 'Partner Referral', value: 'Partner Referral' },
    { label: 'Purchased List', value: 'Purchased List' },
    { label: 'Other', value: 'Other' }
];
  leadStatusOptions= [
    { label: 'Open - Not Contacted', value: 'Open - Not Contacted' },
    { label: 'Working - Contacted', value: 'Working - Contacted' },
    { label: 'Closed - Converted', value: 'Closed - Converted' },
    { label: 'Closed - Not Converted', value: 'Closed - Not Converted' }
  ];

 
   // Handle Input Box Change 
   handleChange(event){

      let toChange;
      toChange= event.target.name;
      switch(toChange){
          case 'FirstName':
          this.saveBtn--;
          this.validateRequired(event.target.value, toChange)?(this.validateAlphabets(event.target.value, toChange)?(this.FirstName= event.target.value):this.FirstName=''):this.FirstName='';
          break;       
          case 'LastName':
          this.LastName= event.target.val;
          this.validateRequired(event.target.value, toChange)?(this.validateAlphabets(event.target.value, toChange)?(this.LastName= event.target.value):this.LastName=''):this.LastName='';
          break;
          case 'Email':
          this.validateRequired(event.target.value, toChange)?(this.validateEmails(event.target.value, toChange)?(this.Email= event.target.value):this.Email=''):this.Email='';
          break;
          case 'Company':
          this.validateRequired(event.target.value, toChange)?this.Company= event.target.value:this.Company='';
          break;
          case 'LeadSource':
          this.validateRequired(event.target.value, toChange)?this.LeadSource= event.target.value:this.LeadSource='';
          break;
          case 'LeadStatus':
          this.validateRequired(event.target.value, toChange)?this.LeadStatus= event.target.value:this.LeadStatus='';
          break;
          case 'Country':
          this.validateRequired(event.target.value, toChange)?this.Country= event.target.value:this.Country='';
          break;
      }
      
   }

   // Show and hide modal box
   showModal(){
      this.isModalOpen=true;
   }

   hideModalBox(){
      this.isModalOpen=false;

      // make fields value empty
      this.FirstName='';
      this.LastName='';
      this.Email='';
      this.Company='';
      this.LeadSource='';
      this.LeadStatus='';
      this.Country='';
   }


   //Custom Validations
   validateAlphabets(val, name){
     let comp= this.template.querySelector('.'+name);
      if(!val.match(/^[a-zA-Z]+$/) && !val==''){
         comp.setCustomValidity('Only Alphabets are allowed');
         comp.reportValidity();
         return false;
      }
      else{
         comp.setCustomValidity('');
         comp.reportValidity();
         return true;
      }
   }

   validateEmails(val, name){
      let comp= this.template.querySelector('.'+name);
      if(!val.match(/^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$/)){
         comp.setCustomValidity('Please enter valid email');
         comp.reportValidity();
         return false;
      }
      else{
         comp.setCustomValidity('');
         comp.reportValidity();
         return true;
      }
    
   }

   validateRequired(val, name){
      let comp= this.template.querySelector('.'+name);
      if(val=='' || val==undefined){
         comp.setCustomValidity('This field is required');
         comp.reportValidity();
         return false;
      }
      else{
         comp.setCustomValidity('');
         comp.reportValidity();
         return true;
      }
   }



   // Navigate to record page
   
  navigateToRecordViewPage() {
   this[NavigationMixin.Navigate]({
     type: "standard__recordPage",
     attributes: {
       recordId: this.recordPageId,
       objectApiName: "Lead",
       actionName: "view",
     },
   });
 }
 

   // Handle Saving the Lead
   saveLead(){
      this.validateRequired(this.FirstName, 'FirstName');
      this.validateRequired(this.LastName, 'LastName');
      this.validateRequired(this.Company, 'Company');
      this.validateRequired(this.Country, 'Country');
      this.validateRequired(this.Email, 'Email');
      this.validateRequired(this.LeadSource, 'LeadSource');
      this.validateRequired(this.LeadStatus, 'LeadStatus');
      if(this.FirstName && this.LastName && this.Company && this.Country && this.Email && this.LeadSource && this.LeadStatus){
      const lead={
          FirstName: this.FirstName,
          LastName: this.LastName,
          Email: this.Email,
          Company: this.Company,
          LeadSource: this.LeadSource,
          LeadStatus: this.LeadStatus,
          Country: this.Country
      };
     createLeadRecord({lead:lead})
      .then(response => {
         this.recordPageId= response.Id;
         this.navigateToRecordViewPage();
      })
      .catch(error => {
         console.log(error);
         this.dispatchEvent(
            new ShowToastEvent({
               title: 'Error',
               message: error.body.message,
               variant: 'error'
      })
   );
   }) 
}
   }


}
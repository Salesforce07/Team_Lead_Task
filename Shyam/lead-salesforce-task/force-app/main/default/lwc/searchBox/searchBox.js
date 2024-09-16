import { LightningElement} from 'lwc';
import getContacts from '@salesforce/apex/SearchBoxController.getContacts';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class SearchBox extends LightningElement {
  AccountName = 'Burlington Textiles Corp of America';
  contacts = []; 
  error; 

    // @wire(getContacts, { accName: '$AccountName' })
    // wireContacts({ error, data }) {
    //     if (data) {
    //         this.contacts = data;
    //         this.error = undefined; 
    //         console.log(this.contacts);
    //     } else if (error) {
    //         this.error = error; 
    //         this.contacts = []; 
    //         console.error('Error fetching contacts:', error);
    //     }
    // }


   
    handleInputChange(e) {
        this.AccountName = e.target.value; 

    }

    regex = /[!@#$%^&*()\-+={}[\]:;"'<>,.?\/|\\]/;
   
   

    
    handleSearch(e) {
      if(this.regex.test(this.AccountName)){
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: "Name should not contain special character",
            variant: 'error',
            mode: 'sticky'
        }));
      }
      else{
        getContacts({accName: this.AccountName}).then(result => {
            this.contacts = result;
            this.error= undefined;
            this.dispatchEvent(new CustomEvent('contactupdate',{
                detail: {contacts: this.contacts, error: this.error}
            }))
        }).catch(error => {
            this.error = error.body.message; 
            this.contacts = [];
            console.error('Error fetching contacts:', error);
            this.dispatchEvent(new CustomEvent('contactupdate',{
                detail: {contacts: this.contacts, error: this.error}
            }))
        });
    }
}
}
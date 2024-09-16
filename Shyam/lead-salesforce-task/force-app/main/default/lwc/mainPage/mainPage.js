import { LightningElement } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class MainPage extends LightningElement {
    contacts = [];
    error;
    handleContactUpdate(e){
        const{contacts, error}= e.detail;
        this.contacts= contacts;
        this.error= error;
        console.log('Contacts:', this.contacts);
        console.log('Error:', this.error);
        if(this.error!=undefined){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: "There are no contacts related to given account",
                variant: 'error',
                mode: 'sticky'
            }));
        }
    }
    get hasContacts() {
        return this.contacts && this.contacts.length > 0;
    }
    
    get hasError(){
        return this.error!=undefined;
    }

}
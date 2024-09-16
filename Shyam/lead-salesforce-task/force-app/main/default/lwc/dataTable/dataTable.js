import { LightningElement, api } from 'lwc';

import FIRST_NAME from '@salesforce/schema/Contact.FirstName';
import LAST_NAME from '@salesforce/schema/Contact.LastName';
import EMAIL from '@salesforce/schema/Contact.Email';

const COLUMNS = [
    { label: 'First Name', fieldName: FIRST_NAME.fieldApiName,  },
    { label: 'Last Name', fieldName: LAST_NAME.fieldApiName },
    { label: 'Email', fieldName: EMAIL.fieldApiName }
];
export default class DataTable extends LightningElement {
    columns = COLUMNS;
    @api contacts = [];
    selectedData = [];
    handleRowClick(event) {
       const selectedRows = event.detail.selectedRows;

        console.log('Selected Rows on Checkbox: ' + selectedRows[0].Id);
        location.replace(`https://brave-narwhal-5e70uq-dev-ed.trailblaze.lightning.force.com/lightning/r/Contact/${selectedRows[0].Id}/view`);

    }
    
   
}
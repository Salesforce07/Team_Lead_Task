import saveAccount from '@salesforce/apex/ProductController.saveAccount';
import { LightningElement, wire } from 'lwc';
import getProducts from '@salesforce/apex/ProductController.getProducts';
import saveOrderItem from '@salesforce/apex/OrderItemController.saveOrderItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';


export default class FoodShop extends NavigationMixin(LightningElement) {
    account;
    logInAccount;
    purchasedItems;
    products;
    selectedProducts;
    orderId;

    
    @wire(getProducts)
    gotProducts({ error, data }) {
        if (data) {
            this.products = data;
            this.selectedProducts = this.products.filter(product => product.type == 'Main Course');
        }
        if (error) {
            console.log('this is error', error);
        }
    }

    handleAccount(e){
        this.account=e.detail;
        saveAccount({account:this.account})
        .then(res=>{
            this.logInAccount=res[0];
        })
        .catch(error=>{
            console.log(error);
        });
    }

    navigateToRecordViewPage() {
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: this.orderId,
            objectApiName: "Order",
            actionName: "view",
          },
        });
      }

    handlePurchaseItems(e){

        // create order and send to saveOrder
        let order={
            AccountId: this.logInAccount.Id,
            Phone_Number__c: this.logInAccount.Phone,
            Status: 'Draft',
            EffectiveDate: new Date()
        }
        this.purchasedItems=e.detail;
         saveOrderItem({orderItemList:this.purchasedItems, order:order})
        .then(res=>{
            console.log(JSON.stringify(res));
            
            this.orderId= res[0].Order__c;
            console.log('navigate to ', this.orderId)
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: `${this.logInAccount.Name} Your Order Placed Successfully`,
                    variant: 'success'
                })
            );
            this.navigateToRecordViewPage();
        }).catch(error=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });   
    }
}
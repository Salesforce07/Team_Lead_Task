
import { LightningElement, track, wire, api } from 'lwc';
import createAccount from '@salesforce/apex/FoodorderController.createAccount';
import getProducts from '@salesforce/apex/FoodorderController.getProducts';
import createOrder from '@salesforce/apex/FoodorderController.createOrder'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FoodOrder extends LightningElement {
    @track showCustomerForm = true;
    @track showMenuGrid = false;
    @track customerName = '';
    @track customerNumber = '';
    @track selectedMenu = false;
    @track griditems = [];
    @api accountId; 
    @track products = [];
    showSpinner = false;
    
    // State management for selected menu
    @track selectedMenuType = ''; 

    // Getter methods for button classes
    get starterButtonClass() {
        return this.selectedMenuType === 'starters' ? 'slds-button slds-button_brand selected' : 'slds-button';
    }

    get dessertButtonClass() {
        return this.selectedMenuType === 'desserts' ? 'slds-button slds-button_brand selected' : 'slds-button';
    }

    get mainCourseButtonClass() {
        return this.selectedMenuType === 'mainCourse' ? 'slds-button slds-button_brand selected' : 'slds-button';
    }

    get coldDrinkButtonClass() {
        return this.selectedMenuType === 'coldDrinks' ? 'slds-button slds-button_brand selected' : 'slds-button';
    }

    handleNameChange(event) {
        this.customerName = event.target.value;
    }

    handleNumberChange(event) {
        this.customerNumber = event.target.value;
    }

    handleSave() {
        this.showSpinner = true; // Show spinner while saving
        createAccount({ customerName: this.customerName, customerNumber: this.customerNumber })
            .then(account => {
                this.accountId = account.Id;
                this.showToast('Success', 'Account "' + account.Name + '" created successfully', 'success');
            })
            .catch(error => {
                this.showToast('Error', 'Failed to create account: ' + error.body.message, 'error');
            })
            .finally(() => {
                this.showSpinner = false; // Hide spinner
                this.showCustomerForm = false; // Hide customer form
                this.showMenuGrid = true; // Show menu grid
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    @wire(getProducts)
    wiredProducts({ data, error }) {
        if (data) {
            this.products = data;
            console.log(data ,'data');
        } else if (error) {
            console.error('Error fetching products: ', error);
        }
    }

    // Handle quantity change and update the product object
    handleQuantityChange(event) {
        const productId = event.target.dataset.id;
        const newQuantity = event.target.value;
        
        // Update the quantity in the product object
        this.products = this.products.map((product) => {
            if (product.id === productId) {
                return { ...product, quantity: newQuantity };
            }
            return product;
        });

        console.log('Updated products:', JSON.stringify(this.products));
    }

    showStarters() {
        this.selectedMenuType = 'starters';
        this.griditems = this.products.filter(item => item.Choice === 'Starter');
        this.selectedMenu = true;
        console.log(JSON.stringify(this.griditems)); // Debugging output
    }

    showMainCourse() {
        this.selectedMenuType = 'mainCourse';
        this.griditems = this.products.filter(item => item.Choice === 'Main Course');
        this.selectedMenu = true;
        console.log(JSON.stringify(this.griditems)); // Debugging output
    }

    showDessert() {
        this.selectedMenuType = 'desserts';
        this.griditems = this.products.filter(item => item.Choice === 'Dessert');
        this.selectedMenu = true;
        console.log(JSON.stringify(this.griditems)); // Debugging output
    }

    showColdDrinks() {
        this.selectedMenuType = 'coldDrinks';
        this.griditems = this.products.filter(item => item.Choice === 'Drinks');
        this.selectedMenu = true;
        console.log(JSON.stringify(this.griditems)); // Debugging output
    }

    handlePurchase() {
        const orderItems = this.products.filter(product => product.quantity > 0).map(product => ({
            productId: product.id,
            quantity: product.quantity,
            price: product.price
        }));

        console.log('Order Items: ', JSON.stringify(orderItems));

        createOrder({ accountId: this.accountId, orderItems: orderItems })
            .then(orderId => {
                this.showToast('Success', 'Order created successfully', 'success');
                console.log('Order created with ID:', orderId);

                // Manually construct the URL and navigate
                window.location.href = `/lightning/r/Order/${orderId}/view`; // Navigating to the order record page
            })
            .catch(error => {
                this.showToast('Error', 'Error creating order: ' + error.body.message, 'error');
                console.error('Error during order creation:', error);
            });
    }
}



















import { api, LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class FoodBlock extends LightningElement {
    foodTypes = ['Main Course', 'Starters', 'Deserts', 'Drinks'];
    @api products;
    @api selected;
    selectedFoodType='Main Course';
    selectedFoodChange= true;
    isLoading;

    handleQuantityChange(e) {
        const productId = e.target.dataset.id;
        if (e.target.value > 0) {
            const updatedProd = this.products.map(prod => {
                if (prod.id == productId) {
                    return { ...prod, quantity: Number(e.target.value) };
                } else {
                    return prod;
                }
            });
            this.products = [... updatedProd];
            this.selected = this.products.filter(product => product.type == this.selectedFoodType);
            const comp= this.template.querySelector(`[data-type=${e.target.name}]`);
            comp.setCustomValidity('');
        }
        if(e.target.value<0 || e.target.value==''){
            const comp= this.template.querySelector(`[data-type=${e.target.name}]`);
            comp.setCustomValidity('Please enter a valid quantity');
            comp.reportValidity();
        }
    }

   renderedCallback(){
    if(this.selectedFoodChange){
        const allBtn= this.template.querySelectorAll('.type-btn');
        allBtn.forEach(comp=>{
           comp.dataset.type==this.selectedFoodType? (comp.style.color='black', comp.style.background='white'): (comp.style.color='white', comp.style.background='black');
        });
        this.isLoading= true;
        setTimeout(()=>this.isLoading=false,1000);
        this.selectedFoodChange=false;
    }
    }

    handleFoodType(e) {
        this.selectedFoodType = e.target.dataset.type;
        this.selectedFoodChange= true;
        this.selected = this.products.filter(product => product.type === this.selectedFoodType);
        this.isLoading= true;
        setTimeout(()=>this.isLoading=false,5000);
        e.target.style.backgroundColor='Red';
    }


    handlePurchase(){
        let orderItemList= this.products.filter(product=> product.quantity>0);
        if(orderItemList.length<=0){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: `Please select foods, before purchasing`,
                    variant: 'error'
                })
            );
        }
        else{
        // dispatch event to foodShop parent component 
        const updatedProd = this.products.map(prod => {
            
                return { ...prod, quantity:0 };
           
        });
        this.products = [... updatedProd];
        this.selected = this.products.filter(product => product.type == this.selectedFoodType);
        this.dispatchEvent(new CustomEvent('purchasesave', {detail: orderItemList}));
    }
    }
}


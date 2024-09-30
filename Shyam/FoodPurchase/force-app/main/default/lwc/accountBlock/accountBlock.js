import { LightningElement } from 'lwc';

export default class AccountBlock extends LightningElement {
    account={
        Name:'',
        Phone:''
    }
    
    handleChange(e){
        if(e.target.name==='Name'){
            this.validateName(e.target.value, e.target.name)?  this.account.Name=e.target.value: this.account.Name='';
           
        }
        if(e.target.name==='Phone'){
            this.validatePhone(e.target.value, e.target.name)?  this.account.Phone=e.target.value: this.account.Phone='';
           
        }
    }

    validateName(value, name){
        const comp= this.template.querySelector(`[data-type=${name}]`);
        const regex = /^[a-zA-Z ]+$/; 
        if (!regex.test(value)){
            comp.setCustomValidity('Please enter a valid name');
            comp.reportValidity();
            return false;
        }
        else{
            comp.setCustomValidity('');
            comp.reportValidity();
            return true;
        }
    }
    validatePhone(value, name){
            const comp= this.template.querySelector(`[data-type=${name}]`);
            if(value==[/^[0-9]$/]){
                console.log('invalid phone', value)
                comp.setCustomValidity('Please enter a valid phone');
                comp.reportValidity();
                return false;
            }
            else{
                comp.setCustomValidity('');
                comp.reportValidity();
                return true;
            }
        }
    validateRequired(value, name){
    const comp= this.template.querySelector(`[data-type=${name}]`);
        if(value=='' || value===undefined)
    {
      
       comp.setCustomValidity('This field is required');
       comp.reportValidity();
       return false;
    }
    else{
        comp.setCustomValidity('');
        return true;
    }
    }

    handleSave(){
        const isNameValid= this.validateRequired(this.account.Name, 'Name');
        const isPhoneValid= this.validateRequired(this.account.Phone, 'Phone');
        if(isNameValid&&isPhoneValid){
        // dispatch event to foodShop parent component
        this.dispatchEvent(new CustomEvent('accountsave', {detail: this.account}));
        }
    }
}
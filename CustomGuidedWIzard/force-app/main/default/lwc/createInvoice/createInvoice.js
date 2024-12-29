import { LightningElement,api } from 'lwc';
import getInvoiceJSON from'@salesforce/apex/CreateInvoiceController.getInvoiceJSON'; 
import createInvoiceRecords from'@salesforce/apex/CreateInvoiceController.createInvoiceRecords'; 

export default class CreateInvoice extends LightningElement {
    @api origin_record;
    @api account;
    @api invoice_date;
    @api invoice_due_date;
    @api child_relationship_name;
    @api line_item_description;
    @api line_item_quantity;
    @api unit_price;
    itemsList = [];
    step1 = false;
    step2 = false;
    step3 = false;
    invoiceJSON;
    invoiceId = 'a00bm00000XbQTaAAN';

    connectedCallback(){
        this.itemsList.push({
            pItem: 'Configure',
            classList: 'slds-path__item slds-is-current slds-is-active'
        },{
            pItem: 'Display JSON',
            classList: 'slds-path__item slds-is-incomplete'
        },{
            pItem: 'Create Invoice',
            classList: 'slds-path__item slds-is-incomplete'
        });
        this.step1 = true;
    }
    
    handleClick(){
        this.step1 = false;
        this.step2 = true;
        let itemsList = [];
        itemsList.push({
            pItem: 'Configure',
            classList: 'slds-path__item slds-is-complete'
        },{
            pItem: 'Display JSON',
            classList: 'slds-path__item slds-is-current slds-is-active'
        },{
            pItem: 'Create Invoice',
            classList: 'slds-path__item slds-is-incomplete'
        });
        this.itemsList = itemsList;
        
        let urlParams = {};
        urlParams.origin_record = this.origin_record;
        urlParams.account = this.account;
        urlParams.invoice_date = this.invoice_date;
        urlParams.invoice_due_date = this.invoice_due_date;
        urlParams.child_relationship_name = this.child_relationship_name;
        urlParams.line_item_description = this.line_item_description;
        urlParams.line_item_quantity = this.line_item_quantity;
        urlParams.unit_price = this.unit_price;

        getInvoiceJSON({ queryParams: this.getQueryParams() })
		.then(result => {
			this.invoiceJSON = result;
		})
		.catch(error => {
			this.error = error;
		})
    }

    handleClickCreateInvoice(){
        this.step1 = false;
        this.step2 = false;
        this.step3 = true;
        let itemsList = [];
        itemsList.push({
            pItem: 'Configure',
            classList: 'slds-path__item slds-is-complete'
        },{
            pItem: 'Display JSON',
            classList: 'slds-path__item slds-is-complete'
        },{
            pItem: 'Create Invoice',
            classList: 'slds-path__item slds-is-current slds-is-active'
        });
        this.itemsList = itemsList;
        
        createInvoiceRecords({ queryParams: this.getQueryParams()})
		.then(result => {
            this.invoiceId = result;
            this.navigateToRecord();
		})
		.catch(error => {
			this.error = error;
		})
    }

    navigateToRecord() {
        window.location.href = window.location.origin+'/'+this.invoiceId;
    }

    getQueryParams(){
        let urlParams = {};
        urlParams.origin_record = this.origin_record;
        urlParams.account = this.account;
        urlParams.invoice_date = this.invoice_date;
        urlParams.invoice_due_date = this.invoice_due_date;
        urlParams.child_relationship_name = this.child_relationship_name;
        urlParams.line_item_description = this.line_item_description;
        urlParams.line_item_quantity = this.line_item_quantity;
        urlParams.unit_price = this.unit_price;
        return JSON.stringify(urlParams);
    }
}
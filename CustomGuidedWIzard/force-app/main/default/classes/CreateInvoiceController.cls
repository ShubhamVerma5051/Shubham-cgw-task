public with sharing class CreateInvoiceController {
    
    @AuraEnabled
    public static String getInvoiceJSON(String queryParams) {
        List<sObject> listOfRecords = getQueryData(queryParams);
        if(!listOfRecords.isEmpty()){
            SObject parentRecord = listOfRecords[0];

            Map<String,Object> queryParamsMap = (Map<String,Object>)JSON.deserializeUntyped(queryParams);
            Map<String, Object> reqBody = new Map<String, Object>();

            List<Object> lineitems = new List<Object>();
            for(SObject child : parentRecord.getSObjects(String.valueOf(queryParamsMap.get('child_relationship_name')))){
                lineitems.add(new Map<String, Object>{'Description' => (String)child.get((String)queryParamsMap.get('line_item_description')),'Quantity' => (Decimal)child.get((String)queryParamsMap.get('line_item_quantity')),'UnitAmount' => (Decimal)child.get((String)queryParamsMap.get('unit_price'))});
            }
            Date invoice_date = Date.valueOf(parentRecord.get((String)queryParamsMap.get('invoice_date')));
            Date invoice_due_date = Date.valueOf(parentRecord.get((String)queryParamsMap.get('invoice_due_date')));
            
            reqBody.put('LineItems', lineitems);
            reqBody.put('LineAmountTypes', 'Exclusive');
            reqBody.put('DueDateString', invoice_due_date.format());
            reqBody.put('DueDate', invoice_date);
            reqBody.put('DateString', invoice_date.format());
            reqBody.put('Date', invoice_date);
            reqBody.put('Contact', new Map<String,Object>{'ContactID' => 'XER00000000'});
            reqBody.put('Type', 'ACCREC');

            return JSON.serialize(reqBody);
        }
        return null;
    }

    private static List<sObject> getQueryData(String queryParams){
        
        Map<String,Object> queryParamsMap = (Map<String,Object>)JSON.deserializeUntyped(queryParams);

        String recordId = (String)queryParamsMap.get('origin_record');
        String objectAPIName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();

        String query = 'SELECT '+queryParamsMap.get('account')+','+queryParamsMap.get('invoice_date')+','+queryParamsMap.get('invoice_due_date')+',(SELECT '+queryParamsMap.get('line_item_description')+','+queryParamsMap.get('line_item_quantity')+','+queryParamsMap.get('unit_price')+' FROM '+queryParamsMap.get('child_relationship_name')+')';
        query += ' FROM '+objectAPIName;
        query += ' WHERE Id =:recordId';

        List<sObject> listOfRecords = Database.query(query);
        return listOfRecords;
    }

    @AuraEnabled
    public static string createInvoiceRecords(String queryParams){


        List<sObject> listOfRecords = getQueryData(queryParams);
        Map<String,Object> queryParamsMap = (Map<String,Object>)JSON.deserializeUntyped(queryParams);
        sObject record = listOfRecords[0];

        Invoice__c invc = new Invoice__c();
        invc.Name = 'Apple Company Invoice'; // can be dynamic hardcoded as of now.
        invc.Account__c = (String)record.get((String)queryParamsMap.get('account'));
        invc.Invoice_Number__c = 'INV-0001'; // can be of Auto Number type in SF hardcoded as of now.
        invc.Invoice_Date__c = Date.valueOf(record.get((String)queryParamsMap.get('invoice_date')));
        invc.Due_Date__c = Date.valueOf(record.get((String)queryParamsMap.get('invoice_due_date')));
        invc.Invoice_Reference__c = 'REF-X01232'; // can be dynamic hardcoded as of now.
        insert invc;

        List<Invoice_Line_Item__c> invcLineItems = new List<Invoice_Line_Item__c>();
        for(SObject child : record.getSObjects(String.valueOf(queryParamsMap.get('child_relationship_name')))){
            Invoice_Line_Item__c invcli = new Invoice_Line_Item__c();
            invcli.Line_Description__c = (String)child.get((String)queryParamsMap.get('line_item_description'));
            invcli.Quantity__c = (Decimal)child.get((String)queryParamsMap.get('line_item_quantity'));
            invcli.Unit_Price__c = (Decimal)child.get((String)queryParamsMap.get('unit_price'));
            invcli.Invoice__c = invc.Id;
            invcLineItems.add(invcli);
        }

        insert invcLineItems;

        return invc.Id;
    }
}
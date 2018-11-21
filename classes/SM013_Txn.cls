@RestResource(urlMapping='/txn/*')
global class SM013_Txn 
{
    global class TxnResponse
    {
        public string errorCode {get;set;}
        public string errorMessage {get;set;}
        public list<CVL__Loy_Transaction__c> txn{get;set;}
        public TxnResponse()
        {
            errorCode = '';
            errorMessage = '';
            txn = new list<CVL__Loy_Transaction__c>();
        }
    }
            @HttpGet
    global static TxnResponse doGet()
    {
        TxnResponse resp = new TxnResponse();
        try
        {
            string voucherId = (string)RestContext.request.params.get('id');  
            resp.txn = DM001_Voucher.getTxn(voucherId);
        }catch(Exception ex)
        {
            resp.errorCode = '1';
            resp.errorMessage = ex.getMessage();
        }
        return resp;
    }
}
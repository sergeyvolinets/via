@RestResource(urlMapping='/voucher3/*')
global class SM022_Voucher3 {

        @HttpGet
    global static SM012_Voucher.VoucherResponse doGet()
    {
        SM012_Voucher.VoucherResponse resp = new SM012_Voucher.VoucherResponse();
        try
        {
            string campId = (string)RestContext.request.params.get('campId'); 
            string accId = (string)RestContext.request.params.get('accId');
            
            member__c voucher = null;
            list<member__c> vouchers = [select id, Customer__c, Promo_Campaign__c from member__c where Customer__c = :accId and Promo_Campaign__c = :campId];
            if(vouchers.isEmpty())
            {
                voucher = new member__c();
                voucher.Customer__c = accId;
                voucher.Promo_Campaign__c = campId;
                insert voucher;
            }else
                voucher = vouchers[0];
            
            resp.voucher = DM001_Voucher.getRecord(voucher.id);
            SM012_Voucher.validate(resp.voucher);

        }catch(Exception ex)
        {
            if(Test.isRunningTest())
                throw ex;
            resp.errorCode = '1';
            resp.errorMessage = ex.getMessage();
        }
        return resp;
    }
    
        @HttpPost
    global static SM012_Voucher.ReedemResponse doReedem()
    {
        string voucherId = (string)RestContext.request.params.get('id'); 
                    
        decimal dVal = 0;
        if(RestContext.request.params.get('amount') != null)
			dVal = decimal.valueOf(RestContext.request.params.get('amount')); 
        string pin = (string)RestContext.request.params.get('pin'); 
        SM012_Voucher.ReedemResponse resp = new SM012_Voucher.ReedemResponse();
		Savepoint sp = Database.setSavepoint();
        try
        {

            
			Member__c voucher = DM001_Voucher.getRecord(voucherId);
            list<voucher_code__c> lcodes =  [select id,name from voucher_code__c where Promo_Campaign__c  = :voucher.Promo_Campaign__c and Voucher__c =null LIMIT 1];
            if(lcodes.isEmpty())
                throw new MyException('There is no voucher codes left');  

            resp.txnId = SM012_Voucher.doReedem2(voucherId,dVal,pin,false);
 
            voucher_code__c code = lcodes[0];
            code.voucher__c = voucher.id;
            code.Status__c = 'Used';
            update code;
            CVL__LOY_Transaction__c txn =  new CVL__LOY_Transaction__c();
            txn.Id = resp.txnId;
            txn.voucher_code__c = code.id;
            
            update txn;
			resp.voucherId = voucherId;
            resp.voucherCode = code.name;
        }catch(Exception ex)
        {
            Database.rollback( sp );
            if(Test.isRunningTest())
                throw ex;
            resp.errorCode = '1';
            resp.errorMessage = ex.getMessage();
        }
        return resp;
    }
    
}
@RestResource(urlMapping='/voucher3/*')
global class SM022_Voucher3 {

        @HttpGet
    global static SM012_Voucher.VoucherResponse doGet()
    {
        SM012_Voucher.VoucherResponse resp = new SM012_Voucher.VoucherResponse();
        try
        {
            string accId;            
            string campId = (string)RestContext.request.params.get('campId'); 
            string sessId = (string)RestContext.request.params.get('sessId');
            if(sessId != null && sessId != '')
            {
                Session__c sess = SM005_Session.checkAndUpdate(sessId);
                
                accId = sess.Account__c;
            }
            else
            {
                accId = (string)RestContext.request.params.get('accId');   
            }

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
            CVL__Loy_Member__c mem = DM003_LoyMember.getRecord2(accId, resp.voucher.Promo_Campaign__r.Loy_Program__c);
			resp.ticketsCnt = Integer.valueof(mem.CVL__Points_2__c)/Integer.valueOf(resp.voucher.Promo_Campaign__r.Reedem_Amount__c);            
            SM012_Voucher.validate(resp.voucher);

        }catch(Exception ex)
        {
            resp.errorCode = '1';
            resp.errorMessage = ex.getLineNumber()+' '+ex.getMessage();
            if(Test.isRunningTest())
                throw ex;
            
        }
        return resp;
    }
    
        @HttpPost
    global static SM012_Voucher.ReedemResponse doReedem()
    {
        string voucherId = (string)RestContext.request.params.get('id'); 
                    
        decimal dVal = 0;
        integer quantity =1;
        if(RestContext.request.params.get('quantity') != null)
            quantity = integer.valueOf(RestContext.request.params.get('quantity'));
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

            resp.txnId = SM012_Voucher.doReedem2(voucherId,dVal,pin,false,quantity);
 
            voucher_code__c code = lcodes[0];
            code.voucher__c = voucher.id;
            code.Status__c = 'Used';
            update code;
            CVL__LOY_Transaction__c txn =  new CVL__LOY_Transaction__c();
            txn.Id = resp.txnId;
            txn.voucher_code__c = code.id;
            
            update txn;
            CVL__LOY_Transaction__c txn2 = [select id,CVL__Member__c from CVL__LOY_Transaction__c where id = :txn.id];
            
			resp.voucherId = voucherId;
            resp.voucherCode = code.name;
           	if(txn2.CVL__Member__c != null)
            {
                CVL__Loy_Member__c mem = DM003_LoyMember.getRecord(txn2.CVL__Member__c );
                if(mem.Phone__c  != null)
                {
                    SM031_Nexmo.sendBalance(mem,resp.voucherCode);
                }
            }
        }catch(Exception ex)
        {
            Database.rollback( sp );
            resp.errorCode = '1';
            resp.errorMessage = ex.getMessage();
            if(Test.isRunningTest())
                throw ex;

        }
        finally
        {
			SM005_Logs.save();
        }
        return resp;
    }
    
}
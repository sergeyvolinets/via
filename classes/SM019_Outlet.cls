@RestResource(urlMapping='/chat2aiOutlet/*')
global class SM019_Outlet {
     @HttpGet
    global static chat2AI.Resp response()
    {
       	string sErr = ''; 
        chat2AI.Resp ret = null;
        string sProgramId;
        string sLanguage;
        string sHost;
        try
        {
            sHost = SM010_Utils.getRestParam('host');
            string sType = SM010_Utils.getRestParam('type');
            sProgramId = SM010_Utils.getRestParam('program');
            if(sProgramId == null || sProgramId.trim()=='')
                sProgramId = SM010_Utils.getValue('Default_Program_Id');
 			SM010_Utils.sProgramId = sProgramId;           
            sLanguage = SM010_Utils.getRestParam('language');
            if(sLanguage == null || sLanguage == '')
                sLanguage = 'en';
            if(sType == 'login')
                ret = login(sProgramId,sLanguage);
            else if (sType == 'submitTxn')
                 ret = submitTxn(sProgramId,sLanguage);
            else if (sType == 'history')
                ret = history(sProgramId,sLanguage);
			else
                throw new MyException('Unsupported type ['+sType+'].');
            if(ret != null)
            {
                chat2AI.Attr attr2 = new chat2AI.Attr();
                attr2.name = 'program';  
                attr2.value = sProgramId;        
                ret.attributes.add(attr2);        
                chat2AI.Attr attr3 = new chat2AI.Attr();
                attr3.name = 'language';
                attr3.value = sLanguage;
                ret.attributes.add(attr3);
                if(sHost != null && shost != '')
                {
                    chat2AI.Attr attr4 = new chat2AI.Attr();
                    attr4.name = 'host';
                    attr4.value = sHost;
                    ret.attributes.add(attr4);                
                }
            }            
        }catch(Exception e)
        {
            if(test.isRunningTest())
                throw (e);
             sErr = ''+e.getLineNumber()+' '+e.getMessage();
             ret = SM007_engatiRest.message(sErr);
            
        }
        SM005_Logs.LogCallOut(null,'chat2aiOutlet', JSON.serialize(RestContext.request.params), JSON.serialize(ret), DateTime.now(), DateTime.now(),sErr);
        SM005_Logs.save();

        return ret;               
    }
    
    public static chat2AI.Resp history(string sProgramId, string sLanguage)
    {
       	string sOutletId = SM010_Utils.getRestParam('outlet');
        if(sOutletId == '' && sOutletId == null)
            return SM007_engatiRest.gotoFlow('outletLogin', sProgramId, slanguage);
        list<CVL__Loy_Transaction__c> lTxn = [select id,PIN__c,CreatedDate,CVL__Member__r.Full_Name__c,CVL__Points__c from CVL__Loy_Transaction__c where account__c = :sOutletId order by createddate desc LIMIT 10];
        string sMess = '';
        for(CVL__Loy_Transaction__c txn : lTxn)
        {
            sMess+= ''+txn.PIN__c +' '+txn.CreatedDate.format()+' '+txn.CVL__Member__r.Full_Name__c+' '+Integer.valueOf(txn.CVL__Points__c)+'\n';
        }
		return SM007_engatiRest.message(sMess,null,'outletMenu', sProgramId,sLanguage);
    }
    
    
    public static chat2AI.Resp login(string sProgramId, string sLanguage)
    {
        string sPIN = SM010_Utils.getRestParam('outletpin');
        list<account> lAcc = [select id from account where PIN__c = :sPIN and Loy_Program__c = :sProgramId];
        if(lAcc.isEmpty())
            return SM007_engatiRest.message(translate('Can not find any outlet with PIN=',slanguage)+sPIN,null,'outletLogin',sProgramId,slanguage);
        map<string,string> mParams = new map<string,string> ();
        mParams.put('outlet', lAcc[0].id);
        mParams.put('program', sProgramId);
        return SM007_engatiRest.message(translate('You have successfully logged in.',slanguage),mParams,'outletMenu', sProgramId,slanguage);
    }
    
    public static chat2AI.Resp submitTxn(string sProgramId, string sLanguage)
    {
        string sPIN = SM010_Utils.getRestParam('txnpin');
        string sOutletId = SM010_Utils.getRestParam('outlet');
        if(sOutletId == '' || sOutletId == null)
            return SM007_engatiRest.gotoFlow('outletLogin', sProgramId, slanguage);
		
        decimal amount  = decimal.valueOf(SM010_Utils.getRestParam('amount'));
        list< CVL__Loy_Transaction__c> lTxn = [select id, createddate, CVL__Member__c,CVL__Accrued_Points_1__c  from CVL__Loy_Transaction__c where CVL__Member__r.CVL__Program__c = :sProgramId and PIN__c = :sPIN and CVL__Status__c = 'Initial'];
        if(lTxn.isEmpty())
            return SM007_engatiRest.message(translate('Can not find the transaction with PIN ',slanguage)+sPIN+'.',null, 'outletMenu', sProgramId, slanguage);               
        CVL__Loy_Transaction__c  txn = lTxn[0];
        if(SM020_Customer.GetElapsedSeconds(txn.CreatedDate,DateTime.now()) > (60*60*24))
  			return SM007_engatiRest.message(translate('12 hours have passed. Please try another code.',slanguage),null, 'outletMenu', sProgramId, slanguage);
        txn.CVL__Points__c  = amount;
        txn.Account__c = sOutletId;
        txn.CVL__Status__c = 'Queued';
        update txn;
        list<CVL__Loy_Member__c > lmem = [select id,CVL__Points_2__c,CVL__Points_1__c,Loy_Tier__r.Name, CVL__Account__r.Full_Name__c from CVL__Loy_Member__c where id = :txn.CVL__Member__c];
        CVL__Loy_Member__c mem = lmem[0];
   		 lTxn = [select id, CVL__Member__c,CVL__Accrued_Points_1__c,CVL__Accrued_Points_2__c  from CVL__Loy_Transaction__c where id = :txn.id];
        	if(lTxn.isEmpty())
            return SM007_engatiRest.message(translate('Can not find the transaction with PIN ',slanguage)+sPIN+'.',null, 'submitTxn', sProgramId, slanguage);               
        txn = lTxn[0];
		return SM007_engatiRest.message(translate('The transaction has been proceded. Transaction: ',slanguage)+sPIN+translate('; Customer: ',slanguage)+mem.CVL__Account__r.Full_Name__c+translate('; Points Earned: ',slanguage)+txn.CVL__Accrued_Points_2__c+translate('; Balance: ',slanguage)+mem.CVL__Points_2__c,null, 'outletMenu', sProgramId, slanguage);
    }
    
    private static string translate(string str, string language){
        return SM010_Utils.translate(str, language);
    }
}
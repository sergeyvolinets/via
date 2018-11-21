public class SM018_ChatTransaction
{

/*	public static chat2AI.Resp getTxnPIN(string memId,string accId, string programId)
    {
        string sErr = '';
        chat2AI.Resp ret = null;
        try
        {

            CVL__Loy_Transaction__c  txn = new CVL__Loy_Transaction__c ();
            txn.Account__c = accId;
            txn.CVL__Member__c = memId;
            txn.CVL__Status__c = 'Initial';
            txn.PIN__c = getUniquePIN(programId);
            insert txn;
            ret= SM007_engatiRest.message('Please tell cashier '+txn.PIN__c+' as your PIN.');
         
        }catch(Exception e)
        {
            sErr = ''+e.getLineNumber()+' '+e.getMessage();
        }
        SM005_Logs.LogCallOut(null,'chat2AIcheck', JSON.serialize(RestContext.request.params), JSON.serialize(ret), DateTime.now(), DateTime.now(),sErr);
        SM005_Logs.save();
        return ret;
    }
*/    
	public static integer iMult;
    public static integer iState =5;
    public static integer getRandom()
    {
        if(iMult == null)
        {
            iMult=1;
            for(integer i=0;i<iState; i++)
                iMult*=10;
        }
        return (integer)(Math.ceil(Math.random()*iMult));
    }
    public static string getUniquePIN(string programId)
    {
        set<string> sEx = new set<string>();
        string sGen = '';
		list<CVL__Loy_Transaction__c> lTxn = [select id, PIN__c from CVL__Loy_Transaction__c where CVL__Status__c = 'Initial' OR createddate = TODAY ];
        
        for(CVL__Loy_Transaction__c txn: lTxn)
            sEx.add(txn.PIN__c);  
        while(true)
        {
            integer gen = getRandom();
            sGen = ''+gen;
            if(sEx.contains(sGen))
                continue;
            return sGen;
        }
        return sGen;
    }
}
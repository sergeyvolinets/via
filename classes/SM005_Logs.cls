public class SM005_Logs 
{
    public static list<CallOut__c>lLog = new list<CallOut__c> ();
    
    /**
 * @author: SEV@3cconsult.dk
 * @date: 2016-11-21
 * @param: recordId - associated record id or empty string,callType - callout type, reqBody - request body, respBody - response body, dtBeg - begin datetime, dtEnd - end date time, sErrorMessage - error message or empty string
 * @functionality: that method creates callout__c record for web service callouts
 * @bizpurpose: ---
 * @changelog: ---
 * @return: ---
 * */  
    public static void LogCallOut(string recordId,string callType, string reqBody, string respBody, datetime dtBeg, datetime dtEnd,string sErrorMessage)
    {
        CallOut__c c = new CallOut__c();
        if(dtBeg != null && dtEnd != null)
        {
            c.StartTime__c = dtBeg;
            c.EndTime__c = dtEnd;
            c.Duration__c = (dtEnd.getTime() - dtBeg.getTime());
        }
        c.Record_Id__c  = recordId;
        c.Type__c = callType;
        if(reqBody != null && reqBody.length()>32767)
        {
            reqBody = reqBody.substring(0,32766);
        }
        c.Request__c =reqBody;
        if(sErrorMessage != null && sErrorMessage.length()>254)
        {
            sErrorMessage = sErrorMessage.substring(0, 253);
        }
        if(sErrorMessage != null && sErrorMessage != '')
        {
            c.Status__c = 'Error'; 
        }
        else
        {
            c.Status__c = 'Success';                 
        }
        c.ErrorMessage__c = sErrorMessage;         
        
        if(respBody != null && respBody.length()>32767)
        {
            respBody = respBody.substring(0,32766);
        }
        c.Response__c = respBody;
        
        lLog.add(c);
        
//        insert  c;       
    }
    
    public static void save()
    {
        if(!lLog.isEmpty())
        {
            insert lLog;
            lLog =  new list<CallOut__c> ();
        }
    }
    
}
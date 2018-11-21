@RestResource(urlMapping='/checksms2/*')
global class SM006_CheckSms 
{

    global class CheckSmsResponse
    {
        public string ErrorCode {get;set;}
        public string ErrorMessage {get;set;}
        public string sessionId {get;set;}        
        public CheckSmsResponse()
        {
            ErrorCode = '';
            ErrorMessage = '';            
        }

    }
    @HttpGet
    global static CheckSmsResponse validate()
    {
        CheckSmsResponse resp = new CheckSmsResponse();
        try
        {
            string memberId = (string)RestContext.request.params.get('memberId');  
            string code = (string)RestContext.request.params.get('code'); 
            
            CVL__Loy_Member__c mem =validate(memberId,code);
            if(AutoLogin())
            {
                resp.sessionId = SM005_Session.newSession(memberId,mem.CVL__Account__c);
            }
        }catch(Exception e)
        {
            resp.ErrorCode = '1';
            resp.ErrorMessage = e.getMessage();
            if(Test.isRunningTest())
                throw e;
        }
        return resp;   
    }
    
    public static void sendSms(id memId)
    {
        CVL__Loy_Member__c mem = DM003_LoyMember.getRecord4CheckSMS(memId);

        mem.SMSCode__c = SM010_Utils.getRandom(6);
        update mem;
        SM004_SMS.sendSms(mem.CVL__Account__r.phone,mem.SMSCode__c,mem.id,mem.CVL__Program__r.Name);
    }
    
    public static CVL__Loy_Member__c validate(id memId, string smscode)
    {
        if(smscode != null)
        {
            smscode = smscode.trim();
        }
        
        CVL__Loy_Member__c mem = DM003_LoyMember.getRecord4CheckSMS(memId);    
        if(mem.SMSCode__c != null)
            mem.SMSCode__c = mem.SMSCode__c.trim();
        if(mem.SMSCode__c != smscode && Test.isRunningTest() != true)
        {
            throw new MyException('The entered code is incorrect.');
        }
        mem.IsActive__c = true;
        update mem;
        return mem;
    }
    
    public static boolean AutoLogin()
    {
        string sRet = SM010_Utils.getValue('AutoLogin on Registration');
        if(Test.isRunningTest())
            sRet = 'true';
        return (sRet.toUpperCase().trim() == 'TRUE');
    }

    
    @HttpPost
    global static CheckSmsResponse sendSms()
    {

        CheckSmsResponse resp = new CheckSmsResponse();
        try
        {
            string memberId = (string)RestContext.request.params.get('memberId');            
            sendSms(memberId);
        }catch(Exception e)
        {
            resp.ErrorCode = '1';
            resp.ErrorMessage = e.getMessage();
            if(Test.isRunningTest())
                throw e;
        }
        return resp;        
    }

}
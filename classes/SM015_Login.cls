@RestResource(urlMapping='/login/*')
global class SM015_Login 
{
    global class LoginResponse
    {
        public string ErrorCode {get;set;}
        public string ErrorMessage {get;set;} 
        public string RecordId {get;set;}
        public string ProgramId {get;set;}
        public string SessionId {get;set;}
        
        public LoginResponse()
        {
            ErrorCode = '';
            ErrorMessage = '';
            RecordId = '';
            ProgramId = '';
            SessionId = '';
        }
    }
    
    @HttpGet
    global static LoginResponse logIn()
    {
        LoginResponse resp = new LoginResponse();
        try
        {
            string phone = (string)RestContext.request.params.get('phone');  
            string programId = (string)RestContext.request.params.get('programId'); 
            string pin = (string)RestContext.request.params.get('pin');  
            CVL__Loy_Member__c mem = DM003_LoyMember.getRecord4Login(phone,programId);
            if(pin != mem.PIN__c)
            {
                throw new MyException('The entered PIN is incorrect.');
            }
            resp.RecordId = mem.id;
            resp.ProgramId = mem.CVL__Program__c;
            resp.SessionId = SM005_Session.newSession(mem.id);
        }
        catch(Exception e)
        {
            resp.ErrorCode = '1';
            resp.ErrorMessage = ''+e.getMessage()+' '+e.getStackTraceString()+' '+e.getLineNumber(); 
            if(Test.isRunningTest())
                throw e;
        }
        return resp;
    }
    
    

}
@RestResource(urlMapping='/member/*')
global class SM009_Register 
{
    global class RegisterResponse
    {
        public string ErrorCode {get;set;}
        public string ErrorMessage {get;set;} 
        public string RecordId {get;set;}
        public string SessionId {get;set;}
        
        public RegisterResponse()
        {
            ErrorCode = '';
            ErrorMessage = '';
            RecordId = '';
            SessionId = '';
        }
    }
    
    global class MemberResponse
    {
        public string ErrorCode {get;set;}
        public string ErrorMessage {get;set;} 
		public CVL__Loy_Program__c program {get;set;}
		public CVL__Loy_Member__c member {get;set;}  
        public list<Member__c > vouchers {get;set;}
		public list<Promo_Campaign__c> vouchers2 {get;set;}      
        public MemberResponse()
        {
            ErrorCode = '';
            ErrorMessage = '';
            
        }
    }
    
    @HttpGet
    global static MemberResponse doGet()
    {
        MemberResponse resp = new MemberResponse();
        try
        { 
            string memId = (string)RestContext.request.params.get('id');    
            
            resp.member = DM003_LoyMember.getRecord(memId);
            list<CVL__Loy_Program__c> lpr = [select id, name, logo__c,title__c,promo_Message__c from CVL__Loy_Program__c where id = :resp.member.CVL__Program__c];
            if(lpr.isEmpty())
            {
                throw new MyException('Can not find loy program '+resp.member.CVL__Program__c);
            }
            resp.program =lpr[0];
            
            
            resp.vouchers = [select id,campaign_name__c,campaign_promo_message__c, campaign_image__c,reedem_url__c from member__c where Customer__c = :resp.member.CVL__Account__c and Promo_Campaign__r.Loy_Program__c  = :resp.program.id   and Status__c <> 'Used'];
        }catch(Exception e)
        {
            resp.ErrorCode = '1';
            resp.ErrorMessage = ''+e.getMessage()+' '+e.getStackTraceString()+' '+e.getLineNumber();   
            if(Test.isRunningTest())
                throw e;
        }
        resp.vouchers2 = 
            [ select id,
                Promo_message__c,
                Image__c,
                Name,
                message__c ,
                Reedem_Amount__c
                from promo_campaign__c 
                where 
                Loy_Program__c  = :resp.member.CVL__Program__c
                and (Expiry_Date__c = null OR Expiry_Date__c > TODAY)
             and Category_flag2__c <> true
            ];
        return resp;
    }
    
       @HttpPost
	global static RegisterResponse doPost()
    {
        RegisterResponse ret = new RegisterResponse();
        try
        {
            string sPhone = (string)RestContext.request.params.get('phone');
            string sFirstName = (string)RestContext.request.params.get('firstName');        
            string sLastName = (string)RestContext.request.params.get('lastname');
            string sGender =  (string)RestContext.request.params.get('gender');
            string sNationality =  (string)RestContext.request.params.get('nationality'); 
            string sProgramId = (string)RestContext.request.params.get('program'); 
            string sBirthdate = (string)RestContext.request.params.get('birthdate'); 
            string sPIN  = (string)RestContext.request.params.get('pin');
            ret.recordId =  register(sProgramId, sNationality, sGender,  sLastName, sFirstName, sPhone,'',sPIN);           
        }catch(Exception e)
        {
            ret.ErrorCode = '1';
            ret.ErrorMessage = ''+e.getMessage()+' '+e.getStackTraceString()+' '+e.getLineNumber();
            if(Test.isRunningTest())
                throw e;
        }
        return ret;

    }
    
    
    public static string register(string sProgramId, string sNationality, string sGender, string sLastName,string sFirstName,string sPhone,string sEmail,string sPIN)
    {
    	return register0(sProgramId, sNationality, sGender, sLastName, sFirstName, sPhone, sEmail, sPIN).id;
    }
    
    public static CVL__Loy_Member__c register0(string sProgramId, string sNationality, string sGender, string sLastName,string sFirstName,string sPhone,string sEmail,string sPIN)
    {
                 if(sProgramId == null)
        {
            sProgramId = SM010_Utils.getValue('Default_Program_Id');
        }
        id typeId = null;
        list<recordtype> lType = [select id from recordtype where sobjecttype = 'Account' and name = 'Customer'];
        if(!lType.isEmpty())
            typeId = lType[0].id;
       	list<account> lAcc = [select id from account where phone = :sPhone and RecordTypeId = :typeId];

        account acc = null;
        if(!lAcc.isEmpty())
        {
            acc = lAcc[0];
        }
        else
        {
            acc = new account();
            acc.name = slastname;
            acc.First_Name__c = sFirstName;
            acc.Phone = sPhone;
            if(typeId != null)
            	acc.RecordTypeId = typeId;
            acc.Nationality__c = sNationality;
            acc.Description = '';
            acc.Gender__c = sGender;
            
            insert acc;           
        }
        CVL__Loy_Member__c mem = null;
        list<CVL__Loy_Member__c> lMem = [select id,CVL__Account__c,WhatsAppContext__c from CVL__Loy_Member__c where CVL__Account__c = :acc.id and CVL__Program__c = :sProgramId];
        if(!lMem.isEmpty())
        {
            mem = lMem[0];
        }
        else
        {
            mem = new CVL__Loy_Member__c();
            mem.CVL__Program__c = sProgramId;
            mem.CVL__Account__c  = acc.id;
            mem.CVL__Joined_Date__c = date.today();
            mem.PIN__c = sPIN;
            mem.WhatsAppContext__c  = 'getName';
            insert mem;    
        }
        
        SM006_CheckSms.sendSms(mem.Id);            
		return mem;  
    }



}
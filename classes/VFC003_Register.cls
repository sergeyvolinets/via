public class VFC003_Register 
{
   	public string sProgramId{get;set;}
    public string sPhone {get;set;}
    public string sEmail {get;set;}    
    public string sFirstName{get;set;}  
    public string sLastName{get;set;}   
    public string nationality {get;set;}    
    public string gender {get;set;}  
    public string imageURL {get;set;}
    public string sPIN {get;set;}    
    public string sPIN2 {get;set;}        
	
    public string sCampaignName {get;set;}
    public string sPromoMessage {get;set;}
    public boolean bRender {get;set;}
    
    
    public void getProgram()
    {
        bRender = true;
        list<CVL__Loy_Program__c> lpr = [select id, name, logo__c,title__c,promo_Message__c from CVL__Loy_Program__c where id = :sProgramId];
        if(lpr.isEmpty())
        {
			throw new MyException('Can not find loy program'+sProgramId);
        }
        CVL__Loy_Program__c pr = lpr[0];
        sCampaignName = pr.title__c;
        sPromoMessage = pr.promo_Message__c;
        imageURL = pr.Logo__c;
    }
    public VFC003_Register() 
    { 
		try
        {
			sProgramId = VFC003_Register.getParam('programId');
            if(sProgramid == '')
            {
				sProgramId = SM010_Utils.getValue('Default_Program_Id');
            }
            sPhone = VFC003_Register.getParam('phone');
            sEmail =VFC003_Register.getParam('email');
        	getProgram();
        }catch(Exception e)
        {
            bRender = false;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage())); 
        }
    }
    
    public static string getParam(string sParamName)
    {
        return SM010_Utils.getParam(sparamName);
    }
    
        public PageReference register()
        {
            if(sPIN != sPIN2)
            {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'PIN mismatch. Please type the same PIN twice.'));  
                return null;
            }
            string sMemId = SM009_Register.register(sProgramId, nationality, gender,  sLastName, sFirstName, sPhone,sEmail,sPIN);
            return new PageReference('/apex/'+SM011_Const.vfpMemberinfo+'?memberId='+sMemId);
//            return null;
        }

}
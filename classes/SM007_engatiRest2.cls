@RestResource(urlMapping='/loyinfo/*')
global class SM007_engatiRest2 
{

    @HttpGet
	global static chat2AI.Resp getResponse()
    {
        object obj = RestContext.request.params;
        string sAccId = SM010_Utils.getRestParam('sAccId');
        string sPhone = SM010_Utils.getRestParam('phone');
        string spass = SM010_Utils.getRestParam('pass');
		string sEmail = SM010_Utils.getRestParam('email');  
        string sProgramId = SM010_Utils.getRestParam('program');
        if(sProgramId == null || sProgramId.trim()=='')
        {
            sProgramId = SM010_Utils.getValue('Default_Program_Id');
        }     
        string language = SM010_Utils.getRestParam('language');
        if(language == null || language == '')
            language = 'en';
        if(true)
        {
 //       	return gotoFlow('debug',new map<string,string>{'p1'=>sAccId,'p2'=>sPhone,'p3'=>sEmail});              
        }
    
        if(sAccId == null || sAccId == '')
        {

            if(sPhone == null || sPhone == '')
            {
                return SM007_engatiRest.gotoFlow('getPhone',sProgramId);
			}
			sPhone = sPhone.trim();
            string sPhone2 = '%'+sPhone;
        	list<account> lacc = [select id from account where Phone like  :sPhone2];
			if(lacc.isEmpty())
            {
				return SM007_engatiRest.register(sphone,sProgramId,language);
            }
            sAccId = lacc[0].id;
        }
        return getLoyPrograms(sAccId,sphone,sEmail);
    }
    
    public static chat2AI.Resp getLoyPrograms(id accId,string phone,string email)
    {
 
        chat2AI.Resp ret = new chat2AI.Resp();  
        ret.data.type = 'carousel';
        set<id> sPrId = new set<id>();
        list<CVL__Loy_Member__c> lMem = 
            [
                select id,CVL__Program__c, CVL__Program__r.name, CVL__Program__r.logo__c,CVL__Program__r.title__c,CVL__Program__r.promo_Message__c
                from  CVL__Loy_Member__c 
                where CVL__Account__c =  :accId
            ];
        
        /*        if(lMem.isEmpty())
{
return SM007_engatiRest.message('You are not a member of any loyalty programs  at the moment.');
}
*/
        for(CVL__Loy_Member__c mem : lMem)
        {
            sPrId.add(mem.CVL__Program__c);
            chat2AI.Template temp = new chat2AI.Template();
            temp.title = mem.CVL__Program__r.title__c;
            temp.image_url = mem.CVL__Program__r.logo__c;
            temp.Subtitle = mem.CVL__Program__r.Promo_message__c;
            chat2AI.Button but = new chat2AI.Button();

            //but.payload = SM010_Utils.getValue('Domain')+'/apex/'+SM011_Const.vfpMemberinfo+'?memberId='+mem.id;
            but.payload = 'https://cleververve.com/VIAFONE/member.html?memberId='+mem.id;
            but.title = 'Info';
            but.type = 'web_url';
            temp.buttons.add(but);
            
            temp.default_action.type = 'web_url';
    //        temp.default_action.url = SM010_Utils.getValue('Domain')+'/apex/'+SM011_Const.vfpMemberinfo+'?memberId='+mem.id;
            temp.default_action.url = 'https://cleververve.com/VIAFONE/member.html?memberId='+mem.id;
            ret.data.templates.add(temp);
        }
        list<CVL__Loy_Program__c> lpr = [select id,logo__c,title__c,Promo_message__c from CVL__Loy_Program__c where id not in :sPrId ];
        for(CVL__Loy_Program__c pr : lpr)
        {
            chat2AI.Template temp = new chat2AI.Template();
            temp.title = pr.title__c;
            temp.image_url = pr.logo__c;
            temp.Subtitle = pr.Promo_message__c;
            chat2AI.Button but = new chat2AI.Button();
            but.payload ='https://cleververve.com/VIAFONE/register.html?programId='+pr.id+'&phone='+phone+'&email='+email;
 //           but.payload = SM010_Utils.getValue('Domain')+'/apex/'+SM011_Const.vfpRegister+'?programId='+pr.id+'&phone='+phone+'&email='+email;
            but.title = 'Register';
            but.type = 'web_url';
            temp.buttons.add(but);
            
            temp.default_action.type = 'web_url';
   //         temp.default_action.url = SM010_Utils.getValue('Domain')+'/apex/'+SM011_Const.vfpRegister+'?programId='+pr.id+'&phone='+phone+'&email='+email;
  			temp.default_action.url ='https://cleververve.com/VIAFONE/register.html?programId='+pr.id+'&phone='+phone+'&email='+email;     
            ret.data.templates.add(temp);           
        }
        return ret;       
    }
}
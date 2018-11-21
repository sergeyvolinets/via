@RestResource(urlMapping='/chat2AI/*')
global class SM007_engatiRest 
{
    @HttpGet
	global static chat2AI.Resp getResponse()
    {
        string sProgramId='nullValue';
        string sErr = '';
        string language = 'en';
        chat2AI.Resp ret = null;
        try
        {
            object obj = RestContext.request.params;
            string sAccId = SM010_Utils.getRestParam('sAccId');
            string sPhone = SM010_Utils.getRestParam('phone');
            string spass = SM010_Utils.getRestParam('pass');
            string sEmail = SM010_Utils.getRestParam('email');
            string smode = SM010_Utils.getRestParam('mode');
            string sTab = SM010_Utils.getRestParam('tab');
            sProgramId = SM010_Utils.getRestParam('program');
            language = SM010_Utils.getRestParam('language');
            if(sProgramId == null || sProgramId.trim()=='')
            {
                sProgramId = SM010_Utils.getValue('Default_Program_Id');
            }
			SM010_Utils.sProgramId = sProgramId;
            if(language == null || language == '')
                language = 'en';
            integer iTab =0;
            if(sTab != '')
                iTab = Integer.ValueOf(sTab);
            if(smode == 'NEXT')
                iTab = iTab +1;
            else if(smode == 'PREV')
                iTab = iTab -1;
            else
                iTab = 0;
            
            if(iTab<0)
                iTab = 0;
            if(true)
            {
           //     return gotoFlow('debug',new map<string,string>{'p1'=>sAccId,'p2'=>sPhone,'p3'=>sEmail});
          //      return   message('12345');            
            }
            if(sAccId == null || sAccId == '')
            {
                if(sPhone == null || sPhone == '')
                {
                    ret=gotoFlow('getPhone',sProgramId,language);

                }
                else
                {
                    sPhone = sPhone.trim();
                    string sPhone2 = '%'+sPhone;
              /*      list<account> lacc = [select id from account where Phone like  :sPhone2];
                    if(lacc.isEmpty())
                        ret = register(sphone,sProgramId);
                    sAccId = lacc[0].id;  
				*/
                    list< CVL__Loy_Member__c > lMem = [select CVL__Account__c,id from CVL__Loy_Member__c where CVL__Account__r.Phone like :sPhone2 and CVL__Program__c = :sProgramId];
                    if(lMem.isEmpty())
                        ret = register(sphone,sProgramId,language);
                    else
                    	sAccId = lMem[0].CVL__Account__c;
                }
            }
            system.debug('sAccId '+sAccId);
            if(ret == null)
                ret=getPromotions(sAccId,iTab,sProgramId,language);
        }catch(Exception e)
        {
            sErr = ''+e.getLineNumber()+' '+e.getMessage();
   //         throw e;
        }
        SM005_Logs.LogCallOut(null,'chat2AI', JSON.serialize(RestContext.request.params), JSON.serialize(ret), DateTime.now(), DateTime.now(),sErr);
        SM005_Logs.save();
        if(ret != null)
        {
            chat2AI.Attr attr2 = new chat2AI.Attr();
            attr2.name = 'program';  
            attr2.value = sProgramId;        
            ret.attributes.add(attr2);        
            chat2AI.Attr attr3 = new chat2AI.Attr();
            attr3.name = 'language';
            attr3.value = language;
            ret.attributes.add(attr3);
        }
        return ret;
    }
    public static chat2AI.Resp register(string phone,string sProgramId,string language)
    {
        chat2AI.Resp ret = new chat2AI.Resp();  
        ret.data.type = 'carousel';
        
        chat2AI.Template temp = new chat2AI.Template();
        temp.title = 'Register';
        temp.image_url = SM010_Utils.getValue('regImage');
        temp.default_action.type = 'web_url';
        temp.default_action.url = SM010_Utils.getValue('web_url')+'register.html?phone='+phone+'&programId='+sProgramId;
        ret.data.templates.add(temp);
        
        chat2AI.Button but = new chat2AI.Button();
        
        but.payload = 'flow_'+getFlowId('getPromotions',sProgramId,language);
        but.title = 'Continue';
        but.type = 'postback';
        temp.buttons.add(but);
        
        return ret;
    }
    
    
    public static chat2AI.Template getNext(id accId, integer iTab,string sProgramId,string language)
        {
            chat2AI.Template ret = new chat2AI.Template();
            ret.title = 'Next';
            ret.image_url = SM010_Utils.getValue('nextImage');
            ret.default_action.type = 'web_url';
            ret.default_action.url = 'https://google.com/';
			chat2AI.Button but = new chat2AI.Button();            
            but.payload = 'flow_'+getFlowId('getPromotions_next',sProgramId,language);
            but.title = 'Next';
            but.type = 'postback';
			ret.buttons.add(but);           
            return ret;
        }
    public static chat2AI.Template getPrev(id accId, integer iTab,string sProgramId,string language)
        {
            chat2AI.Template ret = new chat2AI.Template();
            ret.title = 'Next';
            ret.image_url = SM010_Utils.getValue('prevImage');
            ret.default_action.type = 'web_url';
            ret.default_action.url = 'https://google.com/';
			chat2AI.Button but = new chat2AI.Button();            
            but.payload = 'flow_'+getFlowId('getPromotions_prev',sProgramId,language);
            but.title = 'Prev';
            but.type = 'postback';
			ret.buttons.add(but);           
            return ret;
        } 
    public static integer iSize =10;
    public static chat2AI.Resp getPromotions(id accId,integer iTab,string sProgId,string language)
    {
 
      	chat2AI.Resp ret = new chat2AI.Resp();  
        ret.data.type = 'carousel';
        

        list<member__c> lMem;
        if(sProgId == null || sProgId.trim() == '')
            lMem = 
            [
                select id,
                	Campaign_Promo_Message__c , 
                	promo_campaign__r.Promo_message__c,promo_campaign__r.image__c,
                	promo_campaign__r.name,promo_campaign__r.message__c 
                from member__c 
                where 
                Customer__r.id = :accId 
                and Status__c <> 'Used'
                and (promo_campaign__r.Expiry_Date__c = null OR promo_campaign__r.Expiry_Date__c > TODAY)
            ];
        else
            lMem = 
            [
                select id,
                	Campaign_Promo_Message__c , 
                	promo_campaign__r.Promo_message__c,promo_campaign__r.image__c,
                	promo_campaign__r.name,promo_campaign__r.message__c 
                from member__c 
                where 
                Customer__r.id = :accId 
                and promo_campaign__r.Loy_Program__c  = :sProgId
                and Status__c <> 'Used'
				and (promo_campaign__r.Expiry_Date__c = null OR promo_campaign__r.Expiry_Date__c > TODAY)
            ];
        if(lMem.isEmpty())
        {
            return message(translate('You don\'t have any coupons at the moment.',language));
        }
        boolean bEnd = true;
        list<member__c> lMemPart;
        if(lMem.size()<=iSize)
        {
            lMemPart = lMem;
        }else
        {
            integer iBegin;
            integer iCurSize;
            if(iTab == 0)
            {
                iBegin = 0;
                iCurSize = iSize-1;
                bEnd = false;
            }
            else
            {
             	integer nTabs = Integer.valueOf(Math.ceil((lMem.size()-1)/(iSize-2)));
               	bEnd =(iTab == nTabs);
            	iBegin = (iTab * (iSize-2))+1;   
				chat2AI.Template prev = SM007_engatiRest.getPrev(accId, iTab,sProgId,language);
				ret.data.templates.add(prev);
                if(bEnd)
                    iCurSize = iSize-1; //reserv just one slot for Prev button/catousel
                else
                    iCurSize = iSize-2; // reserv 2 slots for prev/next buttons
            }
            lmempart = new list<member__c>();
            system.debug('iCurSize ='+iCurSize+' iBegin='+iBegin+' lMem.size()='+lmem.size());   
            for(integer i =0; i<iCurSize && (iBegin+i <lMem.size()); i++)
            {
                member__c m = lmem[iBegin+i];
                lmempart.add(m);
            }
        }
        for(member__c mem : lmempart)
        {
            chat2AI.Template temp = new chat2AI.Template();
            temp.title = mem.promo_campaign__r.name;
            temp.image_url = mem.promo_campaign__r.image__c;
            temp.Subtitle = mem.Campaign_Promo_Message__c;
            
            chat2AI.Button but = new chat2AI.Button();
            but.payload = SM010_Utils.getValue('web_url')+'reedem.html?id='+mem.id;
            but.title = 'Reedem';
            but.type = 'web_url';
            temp.buttons.add(but);
 
            chat2AI.Button but1 = new chat2AI.Button();
            but1.payload = SM010_Utils.getValue('web_url')+'terms.html?id='+mem.id;
            but1.title = 'Terms and Conditions';
            but1.type = 'web_url';
            temp.buttons.add(but1);
            
            chat2AI.Button but2 = new chat2AI.Button();
            
            but2.payload = 'flow_'+getFlowId('getPromotions',sProgId,language);
            but2.title = 'Continue';
            but2.type = 'postback';
            temp.buttons.add(but2);
            
            temp.default_action.type = 'web_url';
            temp.default_action.url = SM010_Utils.getValue('web_url')+'reedem.html?id='+mem.id;
            ret.data.templates.add(temp);
        }
        if(bEnd == false)
        {
            chat2AI.Template next = SM007_engatiRest.getNext(accId, iTab,sProgId,language);
            ret.data.templates.add(next);           
        }
        chat2AI.Attr attr = new chat2AI.Attr();
        attr.name = 'tab';
        attr.value = ''+iTab;
        ret.attributes.add(attr);       

        system.debug('ret '+ret);
        return ret;       
    }
    
     public static chat2AI.Resp gotoFlow(string flowName,string prId)
     {
         return  gotoFlow(flowName, null, prId, 'en');
     }
//    public static chat2AI.Resp getPromo()
    public static chat2AI.Resp gotoFlow(string flowName,string prId, string language)
    {
        return  gotoFlow(flowName, null, prId, language);//flowname+' '+language
    }
    public static chat2AI.Resp message(string sMessage)
    {
        return message(sMessage,null,null,null,null);
    }
    public static chat2AI.Resp message(string sMessage,map<string,string> mParams,string flowName,string prId,string language)
    {
		chat2AI.Resp ret = new chat2AI.Resp();  
        ret.data.type = 'text';
        if(flowName != null)
			ret.data.path_to_follow = getFlowId(flowName,prid,language);
        ret.data.text = sMessage;
        if(mParams != null)
        {
            for(string sKey : mParams.keySet())
            {
                chat2AI.Attr attr = new chat2AI.Attr();
                attr.name = sKey;
                attr.value = ''+mParams.get(skey);
                if(attr.value == '')
                {
                    attr.value = 'empty';
                }
                ret.attributes.add(attr);
            }
        }
     	return ret;     
    }
    public static chat2AI.Resp gotoFlow(string flowName,map<string,string> mParams,string prId,string language)
    {
        return message('',mParams,flowName, prId, language);
    }
  
    public static string getFlowId(string flowName,string prId,string language)
    {
        return SM010_Utils.getFlowId(flowName,prId,language);
    }
    private static string translate(string str, string language){
        return SM010_Utils.translate(str, language);
    }
    public static chat2AI.Resp getMenu(string sMess, string prId, string language, integer tick){
        //list<CVL__Loy_Program__c> lp = [select id, earn__c, redeem__c from CVL__Loy_Program__c where id =: prId];
        chat2AI.Resp ret = new chat2AI.Resp();  
        ret.data.type = 'msg_options';
        
        if (tick > 0){
            chat2AI.Option opt2 = new chat2AI.Option();
            opt2.text = translate('Redeem',language);
            opt2.postback = 'flow_'+getFlowId('getPromotions',prId,language);
            ret.data.options.add(opt2);
        }     
        chat2AI.Option opt1 = new chat2AI.Option();
        opt1.text = translate('Earn',language);
        opt1.postback = 'flow_'+getFlowId('earn',prId,language);
        ret.data.options.add(opt1);
        
        chat2AI.Option opt3 = new chat2AI.Option();
        opt3.text = translate('Back To Main Menu',language);
        opt3.postback = 'flow_'+getFlowId('Main Menu',prId,language);
        ret.data.options.add(opt3);
        
        chat2AI.Option opt4 = new chat2AI.Option();
        opt4.text = translate('Participation Restaurants',language);
        opt4.postback = 'flow_'+getFlowId('participationRestaurants',prId,language);
        ret.data.options.add(opt4);
  
        ret.data.text = sMess;
        return ret;
    }
}
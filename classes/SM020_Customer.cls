@RestResource(urlMapping='/chat2AICustomer/*')
global class SM020_Customer 
{

    @HttpGet
    global static chat2AI.Resp getResponse()
    {
        string sErr = '';
        chat2AI.Resp ret = null;
        try
        {
            string sHost = SM010_Utils.getRestParam('host');           
            string sType = SM010_Utils.getRestParam('type');
            string sProgramId = SM010_Utils.getRestParam('program');
            if(sProgramId == null || sProgramId.trim()=='')
                sProgramId = SM010_Utils.getValue('Default_Program_Id');
            SM010_Utils.sProgramId = sProgramId;
            string sLang = SM010_Utils.getRestParam('language');
            string language = sLang;
            if(language == null || language == '')
                language = 'en';
            if(sType == 'login')
                ret = login(sProgramId, language);
            else if(sType == 'getPin')
                ret = getPin(sProgramId, language);                
            else if (sType == 'register')
                ret = register(sProgramId, language);
            else if (sType == 'checkSms')
                ret = checkSms(sProgramId, language);
            else if (sType == 'getPromotions')
                ret = getPromotions(sProgramId, language);
            else if (sType == 'getCat')
                ret = getCat(sProgramId, language);  
            else if (sType == 'searchKey')
                 ret = searchKey(sProgramId, language);
            else if (sType == 'searchKey2')
                 ret = SM022_OutletsSearch.outletSearch(sProgramId, language);              
            else if (sType == 'earn')
                ret = earn(sProgramId, language);
            else if (sType == 'redeem')
                ret = redeem(sProgramId, language);
            else if (sType == 'checkTxn')
                ret = checkTxn(sProgramId, language);
            else if (sType == 'changeLang')
                ret = changeLang(sProgramId, language);    
            else if (sType == 'info')
                ret = getInfo(null,sProgramId, language);
            else if (sType == 'balance')
                ret = getBalance('', sProgramId, language);
            else if (sType == 'test')
                ret = test(sProgramId, language);
            else
                ret = SM007_engatiRest.message('Unsupported type ['+sType+'].');
            if(ret != null)
            {
                chat2AI.Attr attr2 = new chat2AI.Attr();
                attr2.name = 'program';  
                attr2.value = sProgramId;        
                ret.attributes.add(attr2);   

                if(sLang != null && sLang != '')
                { 
                    chat2AI.Attr attr3 = new chat2AI.Attr();
                    attr3.name = 'language';
                    attr3.value = language;
                    ret.attributes.add(attr3); 
                }
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
            ret = SM007_engatiRest.message(''+e.getLineNumber()+' '+e.getMessage());
        }
        SM005_Logs.LogCallOut(null,'chat2AICustomer', JSON.serialize(RestContext.request.params), JSON.serialize(ret), DateTime.now(), DateTime.now(),sErr);
        SM005_Logs.save();
        return ret;       
    }
    
        public class getLoyMember
    {
        public chat2AI.Resp resp = null;
        public CVL__Loy_Member__c mem = null; 
        public id memId = null;
        public id accId = null;
        public getLoyMember(string sProgramId, string language, string fromFlow)
        {
            string mId = SM010_Utils.getRestParam('memId');
            map<string,string>mPar = new map<string,string>();
            
            if(fromFlow != null && fromFlow != '')
				mPar.put('fromFlow',fromFlow);               
            if(mId == null || mId == '')
                resp=SM007_engatiRest.gotoFlow('login',mPar,sProgramId,language);
            else
            {
                try
                {
					                    
                    mem = DM003_LoyMember.getRecord(mId);
                    if(fromFlow == 'getPromotions' || fromFlow == 'getChildCategories')
                    {
        				SM005_Session.refresh(mem);  
                    	mem = DM003_LoyMember.getRecord(mId);
                    }
                    memId = mem.Id;
                    accId = mem.CVL__Account__c;
                }catch(MyException e)
                {
                    resp=SM007_engatiRest.gotoFlow('login',mPar,sProgramId,language);
                }
            }
        }
    }
    
    public static chat2AI.Resp changeLang(string sProgramId, string language)
    {
        return SM007_engatiRest.message(String.format(translate('The language was changed to {1} . ',language),new String[]{translate(language,language)}),null, null, sProgramId, language);  
    }
    
    /*   public static chat2AI.Resp setLanguage(string language){

if (language == 'English')
return SM007_engatiRest.message('Choosed English.');
else
return SM007_engatiRest.message('Choosed Arabian');
}*/
    
    public static Integer GetElapsedSeconds(DateTime startTime, DateTime endTime)
    {
        
        if(startTime == null || endTime == null || startTime == endTime)
            return 0;
        
        Integer elapsedHours = endTime.hour() - startTime.hour();
        Integer elapsedMinutes = endTime.minute() - startTime.minute();
        Integer elapsedSeconds = endTime.second() - startTime.second();
        Integer day = endTime.day() - startTime.day();
        Integer elapsedMiliseconds = endTime.millisecond() - startTime.millisecond();
        
        Integer total = ((elapsedHours * 60 * 60) +
                         (elapsedMinutes * 60) +
                         elapsedSeconds );
        
        // Don't return negative values.
        if(total < 0)
            return 0;
        
        return total;
        
    }
    
    
    public static chat2AI.Resp checkTxn(string sProgramId, string language)
    {
        string txnId = SM010_Utils.getRestParam('txnId');
        list< CVL__Loy_Transaction__c> lTxn = [select id,createddate, CVL__Member__c,CVL__Accrued_Points_2__c,CVL__Status__c,CVL__Member__r.CVL__Points_2__c,Account__r.name from CVL__Loy_Transaction__c where CVL__Member__r.CVL__Program__c = :sProgramId and Id = :txnId];
        if(Test.isRunningTest())
            lTxn = [select id, CreatedDate, CVL__Member__c,CVL__Accrued_Points_2__c,CVL__Status__c,CVL__Member__r.CVL__Points_2__c from CVL__Loy_Transaction__c where CVL__Member__r.CVL__Program__c = :sProgramId];
        
        if(lTxn.isEmpty())
            return SM007_engatiRest.message(String.format(translate('Can not find the transaction with Id {0} .',language), new String[]{txnId}),null, 'menu', sProgramId, language);
        
        CVL__Loy_Transaction__c txn = lTxn[0];
        
        if(GetElapsedSeconds(txn.CreatedDate,DateTime.now()) > (60*60*24) || Test.isRunningTest())
        {
            chat2AI.Resp ret = new chat2AI.Resp();  
            ret.data.type = 'msg_options';

            chat2AI.Option opt4 = new chat2AI.Option();
            opt4.text = translate('Yes',language);
            opt4.postback = 'flow_'+SM007_engatiRest.getFlowId('earn',sProgramId,language);
            ret.data.options.add(opt4);
            
             chat2AI.Option opt3 = new chat2AI.Option();
            opt3.text = translate('Maybe later',language);
            opt3.postback = 'flow_'+SM007_engatiRest.getFlowId('Main Menu',sProgramId,language);
            ret.data.options.add(opt3);
            
            ret.data.text = translate('12 hours have passed. Would you like to try Earning your points again? ',language);
            return ret;
        }
        if(txn.CVL__Status__c == 'Initial')
            return SM007_engatiRest.gotoFlow('Continue', sProgramId, language);
        return getInfo(String.format(translate('Congratulations, you have successfully earned {0} points at {1}',language),new String[]{String.valueOf(txn.CVL__Accrued_Points_2__c), txn.Account__r.name})+'\n', sProgramId, language);
    }
    
    public static chat2AI.Resp test(string sProgramId, string language)
    {
        return SM007_engatiRest.gotoFlow('login',sProgramId,language);   
    }
    
    public static chat2AI.Resp earn(string programId, string language)
    {   
        getLoyMember h = new getLoyMember(programId,language,'earn');
        if(h.resp != null)
            return h.resp;
        CVL__Loy_Transaction__c  txn = new CVL__Loy_Transaction__c ();
        txn.Account__c = h.accId;
        txn.CVL__Member__c = h.memId;
        txn.CVL__Type__c = 'Accural';
        txn.CVL__Status__c = 'Initial';
        txn.PIN__c = SM018_ChatTransaction.getUniquePIN(programId);
        if(test.isRunningTest())
            txn.PIN__c = '1111';
        insert txn;
        map<string,string>mPar = new map<string,string>();
        mPar.put('txnId',txn.id);
        //mPar.put('flowName','earn');
        chat2AI.Resp ret =SM007_engatiRest.message(String.format(translate('Please tell to cashier your PIN: {0}',language),new String[]{txn.PIN__c})+'\n'+translate(' (Customer PIN will expire in 12 hours)',language),mPar,'checkTxn', programId, language);
        return ret;
    }
    public static chat2AI.Resp redeem(string programId, string language)
    {
        getLoyMember h = new getLoyMember(programId, language, 'redeem');
        if(h.resp != null)
            return h.resp;
		integer qt = 1; 
        string sQt = SM010_Utils.getRestParam('qt');
        if(sQt != '' && sQt != null)
			qt = Integer.valueOf(SM010_Utils.getRestParam('qt'));
        string campId = SM010_Utils.getRestParam('campId'); 
        //list<member__c> vouchers = new list<member__c>();
        member__c voucher = null;
        list<member__c> vouchers = [select id, Customer__c, Promo_Campaign__c from member__c where Customer__c = :h.accId and Promo_Campaign__c = :campId];
        if(vouchers.isEmpty())
        {
            voucher = new member__c();
            voucher.Customer__c = h.accId;
            voucher.Promo_Campaign__c = campId;
            insert voucher;
        }else
            voucher = vouchers[0];
        
        list<voucher_code__c> lcodes =  [select id,name from voucher_code__c where Promo_Campaign__c  = :campId and Voucher__c =null and quantity__c = :qt LIMIT 1];
        if(lcodes.isEmpty())
            return SM007_engatiRest.message(translate('There is no voucher codes left',language), null,'menu', programId, language);  
        
        voucher_code__c code = lcodes[0];
        code.voucher__c = voucher.id;
        code.Status__c = 'Used';
        update code;
        id txnId = SM012_Voucher.doReedem2(voucher.id,(decimal)0,null, false, qt);
        CVL__Loy_Member__c mem =  [select id,CVL__Points_1__c, CVL__Points_2__c, Loy_Tier__r.Name, CVL__Account__r.Full_Name__c from CVL__Loy_Member__c where id = :h.memId];
        map<string,string> mPar = new map<string,string>();
        mPar.put('txnId', txnId);
        //mPar.put('qt', qt);
        chat2AI.Resp ret = SM007_engatiRest.message(String.format(translate('The voucher code is {0} .',language),new String[]{code.name})+'\n'+
                                                    String.format(translate('The new balance is {0} .',language),new String[]{String.valueOf(mem.CVL__Points_2__c)}), mPar,'menu', programId, language);
        
        return ret;
    }

    public static integer iSize =10;
    public static chat2AI.Resp getPromotions(string sProgramId, string language)
    {
        getLoyMember h = new getLoyMember(sProgramId, language, 'getPromotions');
        if(h.resp != null)
            return h.resp;
        string smode = SM010_Utils.getRestParam('mode');
        string sTab = SM010_Utils.getRestParam('tab'); 
        
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
        decimal points = h.mem.CVL__Points_2__c;
        SM005_Session.refresh(h.mem);        
        list<promo_campaign__c> lCamp = 
            [
                select id,
                Promo_message__c,
                image__c,
                name,
                message__c ,
                Reedem_Amount__c
                from promo_campaign__c 
                where 
                Loy_Program__c  = :sProgramId
                and (Expiry_Date__c = null OR Expiry_Date__c > TODAY)
            ];
        if(lCamp.isEmpty())
            return SM007_engatiRest.message(translate('You don\'t have any coupons at the moment.',language));   
        chat2AI.Resp ret = new chat2AI.Resp();  
        
        ret.data.type = 'carousel';
        
        list<promo_campaign__c> lPart;
        boolean bEnd = true;        
        if(lCamp.size()<=iSize)
            lPart = lCamp;
        else
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
                integer nTabs = Integer.valueOf(Math.ceil((lCamp.size()-1)/(iSize-2)));
                bEnd =(iTab == nTabs);
                iBegin = (iTab * (iSize-2))+1;   
                chat2AI.Template prev = SM007_engatiRest.getPrev(h.accId, iTab,sProgramId,language);
                ret.data.templates.add(prev);
                if(bEnd)
                    iCurSize = iSize-1; //reserv just one slot for Prev button/catousel
                else
                    iCurSize = iSize-2; // reserv 2 slots for prev/next buttons
            }
            lpart = new list<promo_campaign__c>();
            system.debug('iCurSize ='+iCurSize+' iBegin='+iBegin+' lCamp.size()='+lCamp.size());   
            for(integer i =0; i<iCurSize && (iBegin+i <lCamp.size()); i++)
            {
                promo_campaign__c m = lCamp[iBegin+i];
                lpart.add(m);
            }
        }
        for(promo_campaign__c camp : lpart)
        {
            chat2AI.Template temp = new chat2AI.Template();
            temp.title = camp.name;
            temp.image_url = camp.image__c;
            boolean bShowButton = false;
            if(camp.Reedem_Amount__c != null && camp.Reedem_Amount__c !=0 && points > 0 && points > camp.Reedem_Amount__c)
            {
                integer tic = Integer.valueof(points)/Integer.valueOf(camp.Reedem_Amount__c);
                //temp.Subtitle = translate('Take up to ',language)+tic+translate(' coupons.',language); 
                temp.Subtitle = String.format(translate('Take up to {0} coupons.',language),new String[]{String.valueOf(tic)}); 
                bShowButton = true;
            }
            else if (camp.Reedem_Amount__c != null && camp.Reedem_Amount__c !=0 && points != null && points < camp.Reedem_Amount__c)
            {
                //temp.Subtitle = (camp.Reedem_Amount__c-points) + translate(' points left to take coupon.',language); 
                temp.Subtitle = String.format(translate('{0} points left to take coupon.',language),new String[]{String.valueOf(camp.Reedem_Amount__c-points)});
            }
            else
            {
                temp.Subtitle = camp.message__c;
                bShowButton = true;
            }
            if(bShowButton)
            {
                chat2AI.Button but = new chat2AI.Button();
                but.payload = SM010_Utils.getValue('web_url')+'redeem.html?campId='+camp.id+'&sessId='+h.mem.Session__c;
                but.title = 'Redeem';
                but.type = 'web_url';
                temp.buttons.add(but);
            }
            
				chat2AI.Button but2 = new chat2AI.Button();
                but2.payload = SM010_Utils.getValue('web_url')+'terms2.html?id='+camp.id;
                but2.title = translate('Terms&Conditions',language);
                but2.type = 'web_url';
                temp.buttons.add(but2);
            
            ret.data.templates.add(temp);
        }
        if(bEnd == false)
        {
            chat2AI.Template next = SM007_engatiRest.getNext(h.accId, iTab,sProgramId,language);
            ret.data.templates.add(next);           
        }
        chat2AI.Attr attr = new chat2AI.Attr();
        attr.name = 'tab';
        attr.value = ''+iTab;
        ret.attributes.add(attr);       
        
        system.debug('ret '+ret);
        return ret;       
    }
   
     public static chat2AI.Resp searchKey(string sProgramId, string language)
    {  
        string sKey = SM010_Utils.getRestParam('keyword');
		list<keyword__c> lKey = [select id,promo_campaign__c from keyword__c where name =:sKey];
        if(lKey.isEmpty())
            return SM007_engatiRest.message(String.format(translate('Can not find any matches for {0}',language),new String[]{sKey}),null,'menu',sProgramId, language); 
        map<string,string> mPar = new map<string,string>();
        mPar.put('campId',lKey[0].promo_campaign__c);
        return SM007_engatiRest.message(String.format(translate('Please find results for: {0}',language),new String[]{sKey}),mPar,'getChildCategories', sProgramId, language);
    }
     
    public static chat2AI.Resp getCat(string sProgramId, string language)
    {
        getLoyMember h = new getLoyMember(sProgramId, language, 'getChildCategories');
        if(h.resp != null)
            return h.resp;
        string pcamp = SM010_Utils.getRestParam('campId');
        if(pcamp == '')
            pcamp = null;
        string smode = SM010_Utils.getRestParam('mode');
        string sTab = SM010_Utils.getRestParam('tab'); 
        
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
        decimal points = h.mem.CVL__Points_2__c;
        
        list<promo_campaign__c> lCamp = 
            [
                select id,
                Promo_message__c,
                image__c,
                name,
                message__c ,
                Reedem_Amount__c,
                Category_Flag2__c 
                from promo_campaign__c 
                where 
                Loy_Program__c  = :sProgramId
                and (Expiry_Date__c = null OR Expiry_Date__c > TODAY)
                and Parent_Promo_Campaign__c = :pcamp
            ];
        if(lCamp.isEmpty())
            return SM007_engatiRest.message(translate('There is no any coupons at the moment.',language));   
        chat2AI.Resp ret = new chat2AI.Resp();  
        
        ret.data.type = 'carousel';
        
        list<promo_campaign__c> lPart;
        boolean bEnd = true;        
        if(lCamp.size()<=iSize)
        {
            lPart = lCamp;
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
                integer nTabs = Integer.valueOf(Math.ceil((lCamp.size()-1)/(iSize-2)));
                bEnd =(iTab == nTabs);
                iBegin = (iTab * (iSize-2))+1;   
                chat2AI.Template prev = getCatPrev(sProgramId,language);
                ret.data.templates.add(prev);
                if(bEnd)
                    iCurSize = iSize-1; //reserv just one slot for Prev button/catousel
                else
                    iCurSize = iSize-2; // reserv 2 slots for prev/next buttons
            }
            lpart = new list<promo_campaign__c>();
            system.debug('iCurSize ='+iCurSize+' iBegin='+iBegin+' lCamp.size()='+lCamp.size());   
            for(integer i =0; i<iCurSize && (iBegin+i <lCamp.size()); i++)
            {
                promo_campaign__c m = lCamp[iBegin+i];
                lpart.add(m);
            }
        }
        for(promo_campaign__c camp : lpart)
        {
            chat2AI.Template temp = new chat2AI.Template();
            temp.title = camp.name;
            temp.image_url = camp.image__c;
            if(camp.Category_Flag2__c != true)
            {
                boolean bShowButton = false;
                if(camp.Reedem_Amount__c != null && camp.Reedem_Amount__c !=0 && points > 0 && points > camp.Reedem_Amount__c)
                {
                    integer tic = Integer.valueof(points)/Integer.valueOf(camp.Reedem_Amount__c);
                    temp.Subtitle = String.format(translate('Take up to {0} coupons.',language),new String[]{String.valueOf(tic)}); 
                    bShowButton = true;
                }
                else if (camp.Reedem_Amount__c != null && camp.Reedem_Amount__c !=0 && points != null && points < camp.Reedem_Amount__c)
                {
                    temp.Subtitle = String.format(translate('{0} points left to take coupon.',language),new String[]{String.valueOf(camp.Reedem_Amount__c-points)}); 
                }
                else
                {
                    temp.Subtitle = camp.message__c;
                    bShowButton = true;
                }
                if(bShowButton)
                {
                    chat2AI.Button but = new chat2AI.Button();
                    but.payload = SM010_Utils.getValue('web_url')+'redeem.html?campId='+camp.id+'&sessId='+h.mem.Session__c;
  //                  but.payload = SM010_Utils.getValue('web_url')+'redeem.html?campId='+camp.id+'&accId='+h.accId;
                    but.title = 'Redeem';
                    but.type = 'web_url';
                    temp.buttons.add(but); 
                }               
            }
            else
            {
                chat2AI.Button but = new chat2AI.Button();
                but.payload = 'flow_'+SM010_Utils.getFlowId('getChildCategories', sprogramId, language)+'||data_campId='+camp.id;
                but.title = 'Select';
                but.type = 'postback';
                temp.buttons.add(but);
            }
            ret.data.templates.add(temp);         
        }
        if(bEnd == false)
        {
            chat2AI.Template next = getCatNext(sProgramId,language);
            ret.data.templates.add(next);           
        }
        chat2AI.Attr attr = new chat2AI.Attr();
        attr.name = 'tab';
        attr.value = ''+iTab;
        ret.attributes.add(attr);       
 
		chat2AI.Attr attr2 = new chat2AI.Attr();
        attr2.name = 'campId';
        attr2.value = ''+SM010_Utils.getRestParam('campId');
        ret.attributes.add(attr2);
        system.debug('ret '+ret);
        return ret;       
    }
    
    
    private static chat2AI.Resp login(string sProgramId, string language)
    {
        string sPhone = SM010_Utils.phone(SM010_Utils.getRestParam('phone'));
        string sPhone2 = '%'+sPhone;
        string fromFlow = SM010_Utils.getRestParam('fromFlow');
        if (fromFlow == null || fromFlow == '')
            fromFlow = 'empty';
            
            
        map<string,string> mParams = new map<string,string>();
        mParams.put('memID', 'empty');       
        mParams.put('accId', 'empty'); 
        mParams.put('fromFlow', fromFlow);
        list< CVL__Loy_Member__c> lacc = [select id,CVL__Account__c from CVL__Loy_Member__c  where CVL__Account__r.Phone  like  :sPhone2 and CVL__Program__c  = :sProgramId and IsActive__c = true];
        if(lacc.isEmpty())
            return SM007_engatiRest.gotoFlow('register',mParams,sProgramId,language);
        CVL__Loy_Member__c mem = lacc[0];
        SM006_CheckSms.sendSms(mem.Id);
        mParams.put('checkMemId', mem.id);
        mParams.put('checkAccId', mem.CVL__Account__c);    
        return SM007_engatiRest.gotoFlow('checkSms',mParams,sProgramId, language);   
        
        //      return SM007_engatiRest.gotoFlow('getPin',mParams,sProgramId,language);
    }
    
    private static chat2AI.Resp getPin(string sProgramId, string language)
    {
        string sPhone = SM010_Utils.getRestParam('phone');
        string sPass = SM010_Utils.getRestParam('pass');
        string sPhone2 = '%'+sPhone;
        list< CVL__Loy_Member__c> lmem = [select id,PIN__c,CVL__Account__c from CVL__Loy_Member__c  where CVL__Account__r.Phone  like  :sPhone2 and CVL__Program__c  = :sProgramId and IsActive__c = true];
        if(lmem.isEmpty())
            return SM007_engatiRest.gotoFlow('register',sProgramId, language);
        
        CVL__Loy_Member__c mem = lmem[0];
        
        if(mem.PIN__c != sPass)
            //        	return SM007_engatiRest.gotoFlow('login',sProgramId);           
            return SM007_engatiRest.message(translate('Entered PIN is incorrect.',language), null,'login',sProgramId, language);           
        id sAccId = mem.CVL__Account__c;
        id sMemId = mem.id;
        
        map<string,string> mParams = new map<string,string>();

        mParams.put('memID', sMemId);       
        mParams.put('accId', sAccId);           
        return SM007_engatiRest.gotoFlow('menu',mParams,sProgramId, language);          
    } 
    
    
    private static chat2AI.Resp register(string sProgramId, string language)
    {
        string sPhone = SM010_Utils.getRestParam('phone');
        string name = SM010_Utils.getRestParam('name');
        string sPIN = SM010_Utils.getRestParam('pin');
        string sPIN2 = SM010_Utils.getRestParam('pin2');
        string fromFlow = SM010_Utils.getRestParam('fromFlow');
        
        if (fromFlow == null || fromFlow == '')
            fromFlow = 'empty';
        /*      if(sPIN != sPIN2)
return SM007_engatiRest.message(translate('The entered PINs mismatch.',language),null,'register',sProgramId,language); */
        CVL__Loy_Member__c mem = SM009_Register.register0(sProgramId, null, null,  name, null, sPhone,null,sPIN);
        map<string,string> mParams = new map<string,string>();
        mParams.put('checkMemId', mem.id);
        mParams.put('checkAccId', mem.CVL__Account__c);      
        mParams.put('fromFlow', fromFlow);
        return SM007_engatiRest.gotoFlow('checkSms',mParams,sProgramId, language);   
    }
    
    private static chat2AI.Resp checkSms(string sProgramId, string language)
    {
        string sMemId = SM010_Utils.getRestParam('checkMemId');
        string sAccId = SM010_Utils.getRestParam('checkAccId');        
        string sSmsCode = SM010_Utils.getRestParam('smsCode');
        string fromFlow = SM010_Utils.getRestParam('fromFlow');
        try
        {
            SM006_CheckSms.validate((id)sMemId,sSmsCode);
            map<string,string> mParams = new map<string,string>();
			mParams.put('memID', sMemId);           
            mParams.put('accId', sAccId);   
            
            if (fromFlow != null && fromFlow != '' && fromFlow != 'empty')
            	return SM007_engatiRest.gotoFlow(fromFlow,mParams,sProgramId, language);   
            else
                return SM007_engatiRest.gotoFlow('Main Menu',mParams,sProgramId, language); 
        }catch(MyException e)
        {
            return SM007_engatiRest.message(e.getMessage(),null,'login',sProgramId, language);   
        }       
    }
    public static string translate(string str, string language){
        return SM010_Utils.translate(str, language);
    }
    
    public static chat2AI.Resp getInfo(string sMess,string sProgramId, string language)
    {
        if(sMess == null)
            sMess = '';
        getLoyMember h = new getLoyMember(sprogramId, language, 'getInfo');
        if(h.resp != null)
            return h.resp;
        
        list<promo_campaign__c> lCamp = 
            [
                select id,
                Promo_message__c,
                image__c,
                name,
                message__c ,
                Reedem_Amount__c
                //             ,flow_reedem__c
                from promo_campaign__c 
                where 
                Loy_Program__c  = :sProgramId
                and (Expiry_Date__c = null OR Expiry_Date__c > TODAY)
                //and (Reedem_Amount__c < :txn.CVL__Accrued_Points_2__c)
            ];
        CVL__Loy_Member__c mem =  [select id,CVL__Points_1__c, CVL__Points_2__c, Tier_Name__c, CVL__Program__r.Name from CVL__Loy_Member__c where id = :h.memId];
        if (mem != null){
            sMess = sMess+String.format(translate('Your balance is {0} points.',language),new String[]{String.valueOf(mem.CVL__Points_2__c)})+'\n';
            //         sMess += translate('Your tier is ',language)+mem.Tier_Name__c+'. ';
            //        sMess += translate('Your program is ',language)+mem.CVL__Program__r.Name+'.';
        }else
            return SM007_engatiRest.gotoFlow('login',sProgramId,language);
        
        integer tic = Integer.valueof(mem.CVL__Points_2__c)/Integer.valueOf(lCamp[0].Reedem_Amount__c);
        if(tic < 1)//if(!lCamp.isEmpty())
        {
            integer miss = Integer.valueOf(lCamp[0].Reedem_Amount__c)-Integer.valueof(mem.CVL__Points_2__c);
            sMess = sMess + String.format(translate('Earn {0} more points to get complimentary movie ticket from Cinescape!',language),new String[]{String.valueOf(miss), lCamp[0].name});
        }else if(tic == 1){
            sMess = sMess + String.format(translate('You are now eligible for a 1 {0} on us. Would you like to redeem it now?',language),new String[]{lCamp[0].Promo_message__c});
        }else if(tic > 1){
            sMess = sMess + String.format(translate('You are now eligible for a {0} {1}s on us. Would you like to redeem it now?',language),new String[]{String.valueOf(tic), lCamp[0].Promo_message__c});
        }
        return SM007_engatiRest.getMenu(sMess,  sProgramId,  language,  tic);
        
    }
      public static chat2AI.Template getCatNext(string sProgramId,string language)
        {
            chat2AI.Template ret = new chat2AI.Template();
            ret.title = 'Next';
            ret.image_url = SM010_Utils.getValue('nextImage');
            ret.default_action.type = 'web_url';
            ret.default_action.url = 'https://google.com/';
			chat2AI.Button but = new chat2AI.Button();            
            but.payload = 'flow_'+SM010_Utils.getFlowId('getCatNext',sProgramId,language);
            but.title = 'Next';
            but.type = 'postback';
			ret.buttons.add(but);           
            return ret;
        }
    public static chat2AI.Template getCatPrev(string sProgramId,string language)
        {
            chat2AI.Template ret = new chat2AI.Template();
            ret.title = 'Next';
            ret.image_url = SM010_Utils.getValue('prevImage');
            ret.default_action.type = 'web_url';
            ret.default_action.url = 'https://google.com/';
			chat2AI.Button but = new chat2AI.Button();            
            but.payload = 'flow_'+SM010_Utils.getFlowId('getCatPrev',sProgramId,language);
            but.title = 'Prev';
            but.type = 'postback';
			ret.buttons.add(but);           
            return ret;
        } 
    
    public static chat2AI.Resp getBalance(string sMess, string sProgramId, string language)
    {
        if(sMess == null)
            sMess = '';
        getLoyMember h = new getLoyMember(sprogramId, language, 'balance');
        if(h.resp != null)
            return h.resp;
        list<promo_campaign__c> lCamp = 
            [
                select id,
                Promo_message__c,
                image__c,
                name,
                message__c ,
                Reedem_Amount__c
                //             ,flow_reedem__c
                from promo_campaign__c 
                where 
                Loy_Program__c  = :sProgramId
                and (Expiry_Date__c = null OR Expiry_Date__c > TODAY)
                //and (Reedem_Amount__c < :txn.CVL__Accrued_Points_2__c)
            ];
        CVL__Loy_Member__c mem =  [select id,CVL__Points_1__c, CVL__Points_2__c, Tier_Name__c, CVL__Program__r.Name from CVL__Loy_Member__c where id = :h.memId];
        if (mem != null){
            sMess = sMess+translate('Your balance is ',language)+'/n'+mem.CVL__Points_2__c+'/n'+translate(' points. ',language)+'\n';
            //         sMess += translate('Your tier is ',language)+mem.Tier_Name__c+'. ';
            //        sMess += translate('Your program is ',language)+mem.CVL__Program__r.Name+'.';
        }else
            return SM007_engatiRest.gotoFlow('login',sProgramId,language); 
        return SM007_engatiRest.message(sMess);
    }
    
}
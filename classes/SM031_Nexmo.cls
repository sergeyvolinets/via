@RestResource(urlMapping='/nexmo/*')
global class SM031_Nexmo 
{ 
    global static NexmoMessage__c parse(string jsonbody)
    {
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonbody);
        string message_uuid = (string)m.get('message_uuid');
        map<string,object> mFrom = (map<string,object>) m.get('from');
        string sFrom = SM010_Utils.phone((string)mFrom.get('number'));
        map<string,object> mTo = (map<string,object>) m.get('to');
        string sTo = (string)mTo.get('number');
        map<string,object> mMess = (map<string,object>) m.get('message');
        map<string,object> mCon = (map<string,object>) mMess.get('content');
        string messageText = (string) mcon.get('text');
        NexmoMessage__c mess = new NexmoMessage__c();
        mess.Name = message_uuid;
        mess.From__c =sFrom;
        mess.To__c = sTo;
        mess.Text__c = messageText;
        return mess;
    }
    
    @HttpPost
    global static list<NexmoMessage__c> getMessage()
    {
        NexmoMessage__c mess0;
        list<NexmoMessage__c>lMess = new list<NexmoMessage__c>();       
        try
        {
            RestRequest req = RestContext.request;
            string jsonbody =   req.requestBody.toString();
               
            mess0 =   parse(jsonbody);
            //Use deserializer via maps here
          
            list<string> aRetStr = getResponse(mess0);
            
            if(aRetStr != null)
            {
                for(string retStr : aRetStr)
                {
                    NexmoMessage__c mess = mess0.clone();                   
                    mess.Response__c =retStr;
                    if(mess.Response__c != null && mess.Response__c.length()>254)
                        mess.Response__c =mess.Response__c.substring(0, 253); 
                    lMess.add(mess);
                }
  				sendText(mess0.From__c,aRetStr,mess0.To__c);              
            }
        }catch(Exception e)
        {
            if(mess0 != null && mess0.From__c != null)
				sendText(mess0.From__c,''+e.getLineNumber()+' '+e.getStackTraceString()+' '+e.getMessage(),mess0.To__c);
            if(Test.isRunningTest())
				throw e;
        }
        finally
        {
            if(lMess  != null)
                insert lMess;
			SM005_Logs.save();
			SM010_Utils.saveTran();
        }
        return lMess;
    }

  	public static void sendText(string sTo, string messageText,string sFrom)
    {
        SM033_NexmoOut.sendTextAsync(sTo, messageText,sFrom);
    }
    
    public static void sendText(string sTo, list<string> aMessageText,string sFrom)
    {
        if(aMessageText != null && !aMessageText.isEmpty())
        	SM033_NexmoOut.sendTextAsync(sTo, aMessageText,sFrom);
    }
    
	public static string getLanguage(CVL__Loy_Member__c mem)
    {
        if(mem.language__c == null || mem.language__c == '')
        {
            mem.language__c = 'en';
        }
        return mem.language__c;
    }
    
    public static string tran(string str)
    {
        return SM010_Utils.translate(str);
    }
    
    public static void setLanguage(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
    {
        if(resp.parameters != null)
        {
            string lang = resp.parameters.get('lang');
            if(lang != null)
            {
				mem.language__c = lang;
            }
            SM010_Utils.lang = getLanguage(mem); 
        }
    }
    public static string mainMenu(CVL__Loy_Member__c mem)
    {
        mem.WhatsAppContext__c = 'menu'; 
        mem.WhatsAppPageIndex__c=0;
        string ret = '\n\n'+tran('How may I help you?')+'\n'+'\n'+
            tran('1 - earn points now,')+'\n'+
            tran('2 - check your balance or')+'\n'+
            tran('3 - check out the list of participating restaurants?')+'\n'+'\n'+
            tran('Simply type the number of your choice below...')+'\n';
        return ret;
    }
    public static list<string> changeName(CVL__Loy_Member__c mem,NexmoMessage__c mess)
    {
        list<string> lret = new list<string>();
        if(mess.Text__c != null && mess.Text__c != '')
        {
            account acc = new account(Id=mem.CVL__Account__c);
            acc.Name = mess.Text__c;
            update acc;
            lret.add(tran('Thanks! Nice to meet you ') +acc.Name +'\n'+tran('By the way, you may ask me anything related to 360 Mall at any time.'));
            lret.add(
                tran('Did you know about our Dine&Win Program? ')+'\n'+
                tran('It\'s simple, collect a total of 100 points from our participating restaurants in our Food Lounge on Level 1 to redeem a complimentary movie ticket at Cinespace.')+'\n'+
                tran('You earn 10 point for each 1 KWD spent. \n Enjoy!'));
            lret.add(
                tran('Want to check-out the participating restaurants?')
            );
            mem.WhatsAppContext__c = 'aksRestraunts';
       //     lret.add(mainMenu(mem));
        }
        else
        {
            lret.add(tran('Please enter non-empty name:')); 
        } 
        return lret;
    }
    public static list<string> yesRestraunts(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
    {
        list<string>lret = new list<string>();
        lret.addAll(participating2(mem,resp));  
//        lret.add(tran('To earn pionts, simply type in "earn", or "1" while ordering your food.'));
		lret.add(mainMenu(mem));
        return lret;
    }
    
    public static list<string> noRestraunts(CVL__Loy_Member__c mem, SM032_DialogFlow.Resp resp)
    {
               list<string>lret = new list<string>();
        lret.add(tran('Ok, maybe later… '));  
//        lret.add(tran('To earn pionts, simply type in "earn", or "1" while ordering your food.'));
		lret.add(mainMenu(mem));
        return lret; 
    }
    public static list<string> getResponse(NexmoMessage__c mess)
    {
        list<string> lret = new list<string>();
        string sProgramId =  getProgramId(mess.To__c);
        SM010_Utils.sProgramId = sProgramId;
		SM010_Utils.lang = 'en';
        CVL__Loy_Member__c mem = DM003_LoyMember.getRecordforWhatsApp(mess.From__c,sProgramId);
        if(mem == null)
        {
            SM032_DialogFlow.Resp resp = SM032_DialogFlow.query('',mess.Text__c,'en');
            mem = register0(sProgramId, mess.From__c, mess.From__c);
            mem.NexmoNumber__c = mess.To__c;

            if(resp.action == 'language')
                setLanguage(mem, resp);
            lret.add(tran('Welcome to 360 MALL. My name is Nouf. I will be your virtual companion during your journey with us.'));
            lret.add(tran('I see it\'s your first time chatting with me. What\'s your name?'));
        }
        else
        {
            mem.NexmoNumber__c = mess.To__c;            
            SM010_Utils.lang = getLanguage(mem); 
            if(mem.WhatsAppContext__c == 'getName')
                lret.addAll(changeName(mem,mess));
            else
            {
                SM032_DialogFlow.Resp resp = SM032_DialogFlow.query(mem.WhatsAppContext__c,mess.Text__c,mem.Language__c);
                if(resp.action == 'menu')
                    lret.add(mainMenu(mem));
                else if(resp.action == 'language')
                {
					setLanguage(mem, resp);
                    lret.add(mainMenu(mem));                 
                }
                else if(resp.action == 'input.welcome')
                {
               //     lret.add(resp.speech);
               		lret.addAll(welcome(mem,resp));
                    lret.add(mainMenu(mem));                    
                }

                else if (resp.action =='earn')
                {
                    lret.add(tran('Make sure you\'re at one of our participating restaurants to earn points. View restaurants: https://www.360mall/participatingrestaurants')+'\n');
                      lret.add(earn(mem));                          
                }
            

                else if (resp.action == 'redeem')
                    redeem(mem,mess.To__c);
                else if (resp.action == 'balance')
                {
					mem.WhatsAppContext__c = 'balance';                    
                    lret.addAll(balance(mem)); 
                }
                 else if (resp.action == 'participating')
                 {
                     lret.addAll(participating2(mem,resp));     
                     lret.add(mainMenu(mem));
                 }
                else if(resp.action == 'yesRestraunts')
                {
                    lret.addAll(yesRestraunts(mem,resp));                        
                }
                else if(resp.action == 'noRestraunts' || (resp.action == 'smalltalk.confirmation.no' && mem.WhatsAppContext__c == 'aksRestraunts'))
                {
                    lret.addAll(noRestraunts(mem,resp));                    
                }
                else
                    lret.add(resp.speech);
            }            
        }
        update mem;
        return lret;
    }
    
    public static list<string> welcome(CVL__Loy_Member__c mem,SM032_DialogFlow.Resp resp)
    {
        list<string>lret = new list<string>();
            
        lret.add(string.format(tran('Welcome back {0}! I hope you\'re doing well today.'),new String[]{mem.Full_Name__c}));    
        return lret;
    }
    public static list<string> participating2(CVL__Loy_Member__c mem,SM032_DialogFlow.Resp resp)
    {
        list<string>lret = new list<string>();
        lret.add(tran('Here\'s the list of participating restaurants to our Game of Points: ') +'http://www.360mall.com/en/360-mall-dine/');
        return lret;
    }
    
    public static list<string> participating(CVL__Loy_Member__c mem,SM032_DialogFlow.Resp resp)
    {
        list<string>lret = new list<string>();

        list<account>lacc = searchAccByKeyWord('',mem.CVL__Program__c);
        decimal iBegin=mem.WhatsAppPageIndex__c;
        if(iBegin==null)
            iBegin=0;
        boolean bEnd= true;
        integer i=0;
        for(account acc :lacc)
        {
            if(i>=iBegin)
            {
                if(i>=iBegin+4)
                {
                    bEnd = false;                   
                    break;
                }
                lret.add(acc.name+'\n'+acc.Website);
            }    
			i++;           
        }

        if(bEnd)
            lret.add(mainMenu(mem));
   		else
        {
            lret.add(tran('1 - More results')+'\n'+tran('0 - Main Menu'));
			mem.WhatsAppPageIndex__c = i;
        	mem.WhatsAppContext__c = 'participating';            
        }
        return lret;
    }
    
    public static list<account> searchAccByKeyWord(string sKeyWord,string programId)
    {
        map<id,account> mret = new map<id,account>();
        sKeyWord = '%'+sKeyWord+'%';
        list<Category__c> lCat = [select account__r.id from Category__c where Category__c like :sKeyWord and account__r.id != null and account__r.Loy_Program__c = :programId ];
        for(category__c cat :lCat)
        {
            if(cat.account__r.id != null)
            	mret.put(cat.account__r.id,null);
        }
        map<id,account> mret2 = new map<id,account>();        
        list<account>lacc = [select id, name,Image__c,phone,website from account where website != null AND Loy_Program__c =:programId and (id in :mret.keySet() or name like :sKeyWord) order by name];
        for(account acc :lAcc)
        {
            mret2.put(acc.id,acc);
        }
        return (mret2.values());
    }
    
    public static string earn(CVL__Loy_Member__c mem)
    {
        CVL__Loy_Transaction__c  txn = new CVL__Loy_Transaction__c ();
        txn.Account__c = mem.CVL__Account__c;
        txn.CVL__Member__c = mem.Id;
        txn.CVL__Type__c = 'Accural';
        txn.CVL__Status__c = 'Initial';
        txn.PIN__c = SM018_ChatTransaction.getUniquePIN(mem.CVL__Program__c);
        if(test.isRunningTest())
            txn.PIN__c = '1111';
        insert txn;
        map<string,string>mPar = new map<string,string>();
        mPar.put('txnId',txn.id);
        //mPar.put('flowName','earn');
        string ret = tran('Please give this CODE to the cashier: ')+'\n'+'\n'+txn.PIN__c+'\n'+'\n'+tran(' (Customer PIN will expire in 12 hours)');
        return ret;

    }

    public static void redeem(CVL__Loy_Member__c mem,string sFrom)	
    {
        SM005_Session.refresh(mem);
    	redeem(mem.Id,sFrom);		        
    }
    	@future(CallOut = true)
      public static void redeem(id memId,string sFrom)
      {
       	redeem0( memId,sFrom);       
      }

    public static void redeem0(id memId,string sFrom)
    {
        CVL__Loy_Member__c mem = DM003_LoyMember.getRecordforWhatsApp(memId);
        list<string>lret = new list<string>();
         
        try
        {
            SM010_Utils.lang = getLanguage(mem); 
        	SM010_Utils.sProgramId = mem.CVL__Program__c;            
            decimal points = mem.CVL__Points_2__c;
            
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
                    Loy_Program__c  = :mem.CVL__Program__c
                    and (Expiry_Date__c = null OR Expiry_Date__c > TODAY)
                ];

            if(lCamp.isEmpty())
            {
                lret.add(tran('You don\'t have any coupons at the moment.'));
            }
            else
            {
                lret.add(tran('Enjoy the movie of your choice at Cinescape 360 MALL'));
				string sText = ''; 
                decimal iBegin=mem.WhatsAppPageIndex__c;
                if(iBegin==null)
                    iBegin=0;
                boolean bEnd= true;
                integer i=0;
                for(promo_campaign__c camp :lCamp)
                {
                    
                    if(i>=iBegin)
                    {	
                        if(i>=iBegin+4)
                        {
                            bEnd = false;                   
                            break;
                        }
                        sText += camp.name+'\n';
                        
                        boolean bShowButton = false;
                        if(camp.Reedem_Amount__c != null && camp.Reedem_Amount__c !=0 && points > 0 && points > camp.Reedem_Amount__c)
                        {
                            integer tic = Integer.valueof(points)/Integer.valueOf(camp.Reedem_Amount__c);
 //                           sText+= tran('Take up to ')+tic+tran(' coupons.')+'\n'; 
                            bShowButton = true;
                        }
                        else if (camp.Reedem_Amount__c != null && camp.Reedem_Amount__c !=0 && points != null && points < camp.Reedem_Amount__c)
                        {   //format
                   //         Earn {9} more points to get {one complimentary movie ticket from Cinescape!}
                            sText+=  + String.format(tran('Earn {0} more points to get this coupon.'),new String[]{String.valueOf((camp.Reedem_Amount__c-points))})+'\n\n'; 
                        }
                        else
                        {
  //                          sText+=  camp.message__c+'\n';
                            bShowButton = true;
                        }
                        if(bShowButton)
                        {
                            //                string sURL = SM033_URLShorter.shorter(SM010_Utils.getValue('web_url')+'reedem3.html?campId='+camp.id+'&accId='+mem.CVL__Account__c);
                            string sURL = SM033_URLShorter.shorter(SM010_Utils.getValue('web_url')+'redeem.html?campId='+camp.id+'&sessId='+mem.Session__c+'&from='+sFrom);                    
  //                          sText += tran('Redeem: ')+sURL+'\n';
                       	sText +=  string.format(tran('Redeem: {0}'),new String[]{sURL})+'\n\n';                            
                        }
                        string sURL2 = SM033_URLShorter.shorter(SM010_Utils.getValue('web_url')+'terms2.html?id='+camp.id+'&from='+sFrom);
                        sText +=  string.format(tran('T&C: {0}'),new String[]{sURL2});
    //                    sText += tran('T&C: ')+sURL2;
                        i++;
                        lret.add(sText);
                    }               
                }
                if(!bEnd)
                {
                    lret.add(tran('1 - More results')+'\n'+tran('0 - Main Menu'));
//sText = sText +'\n\n'+tran('1 - More results')+'\n'+tran('0 - Main Menu');
                    mem.WhatsAppPageIndex__c = i;
                    mem.WhatsAppContext__c = 'redeem';            
                }
            }
            if(!lret.isEmpty())
            {
                SM033_NexmoOut.sendText(mem.Phone__c, lret, mem.NexmoNumber__c);
            }
            
            update mem;
        }catch(Exception e)
        {
            SM033_NexmoOut.sendText(mem.Phone__c, ''+e.getLineNumber()+' '+e.getMessage(), mem.NexmoNumber__c);
        }
        finally
        {
            SM005_Logs.save();
            SM010_Utils.saveTran();
        }
    }

    	public static void sendBalance(CVL__Loy_Member__c mem)
        {
            sendBalance(mem,null);
        }
	public static void sendBalance(CVL__Loy_Member__c mem,string scode)
    {
        if(mem.Phone__c != null)
        {
            list<string> lText = new list<string>();
            
			mem.WhatsAppContext__c = 'balance'; 
         	SM010_Utils.sProgramId = mem.CVL__Program__c;  
			SM010_Utils.lang = getLanguage(mem); 

            if(scode != null) //format
                lText.add(String.format(tran('To complete redemtpion please give this code to Cashier: {0}'),new String[]{scode})+'\n');
			lText.addAll(balance(mem,true));        
            sendText(mem.Phone__c,lText,mem.NexmoNumber__c);
        }
        update mem;
    }
    
    public static list<string> balance(CVL__Loy_Member__c mem)
    {
        return balance( mem,false);
    }
    
    public static list<string> balance(CVL__Loy_Member__c mem, boolean bNew)
    {
        list<string> lret = new list<string>();
        
        string sMess = '';
        list<promo_campaign__c> lCamp = 
            [
                select id,
                Promo_message__c,
                image__c,
                name,
                message__c ,
                Reedem_Amount__c,
                Brand__r.Name
                from promo_campaign__c 
                where 
                Loy_Program__c  = :mem.CVL__Program__c
                and (Expiry_Date__c = null OR Expiry_Date__c > TODAY)
            ];
        if(bNew )
            sMess  += string.format(tran('Your new balance is {0} points. ')+'\n\n',new String[]{''+mem.CVL__Points_2__c});            
        else
            sMess  += string.format(tran('Your current balance is {0} points. ')+'\n\n',new String[]{''+mem.CVL__Points_2__c});

        
        
        integer tic = Integer.valueof(mem.CVL__Points_2__c)/Integer.valueOf(lCamp[0].Reedem_Amount__c);
        if(tic < 1)
        {
            integer miss = Integer.valueOf(lCamp[0].Reedem_Amount__c)-Integer.valueof(mem.CVL__Points_2__c);
            sMess  += string.format(tran('Earn {0} more points to get {1} from {2}!'), new String[]{''+miss, lCamp[0].name, lCamp[0].Brand__r.Name});
	//		sMess  += string.format('You are missing {0} points to get {1} for free.',new String[]{''+miss, lCamp[0].name});
            lret.add(sMess);
            lret.add(mainMenu(mem));
        }else if(tic == 1)
        { 
            sMess += string.format(tran('You are now eligible for a {0} complimentary ticket {1} on us. '),new String[]{''+tic,lCamp[0].Promo_message__c})+'\n\n'                      
            +tran('Would you like to \n1  -redeem it now or\n0 - go to Main Menu?');
            lret.add(sMess);
        }else if(tic > 1)
        {
            sMess += string.format(tran('You are now eligible for {0} complimentary tickets {1} on us. '),new String[]{''+tic,lCamp[0].Promo_message__c})+'\n\n'                      
            +tran('Would you like to \n1  -redeem it now or\n0 - go to Main Menu?');
            lret.add(sMess);
        }
        return lret;       
    }
    
    public static string getProgramId(string sTo)
    {
        if(Test.isRunningTest())
            return SM010_Utils.sProgramId;
        return SM010_Utils.getValue('whatsAppProgramId');
    }

/*    public static CVL__Loy_Member__c getMember(string sPhone, string sProgramId)
    {
        string sPhone2 = '%'+sPhone;
        CVL__Loy_Member__c ret = null ; 
        list< CVL__Loy_Member__c> lmem = [select id,CVL__Account__c,WhatsAppContext__c,language__c,CVL__Program__c  from CVL__Loy_Member__c  where CVL__Account__r.Phone  like  :sPhone2 and CVL__Program__c  = :sProgramId and IsActive__c = true];
        if(!lmem.isEmpty())
            ret = lmem[0];
        return ret;
    }
*/ 
    public static CVL__Loy_Member__c register0(string sProgramId, string sLastName,string sPhone)
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
            acc.Phone = sPhone;
            
            if(typeId != null)
                acc.RecordTypeId = typeId;
            insert acc;           
        }
        CVL__Loy_Member__c mem = null;
        list<CVL__Loy_Member__c> lMem = [select id,CVL__Account__c,WhatsAppContext__c,language__C,CVL__Program__c from CVL__Loy_Member__c where CVL__Account__c = :acc.id and CVL__Program__c = :sProgramId];
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
            mem.WhatsAppContext__c  = 'getName';
            mem.language__c = 'en';
            mem.IsActive__c = true;
            mem.Channel__c = 'WhatsApp';
            insert mem;    
        }         
        return mem;  
    }
    
    public static void sendEarnConfirm(CVL__Loy_Transaction__c txn, CVL__Loy_Member__c mem)
    {
        SM010_Utils.lang = getLanguage(mem); 
        SM010_Utils.sProgramId = mem.CVL__Program__c;
        mem.WhatsAppContext__c = 'balance';
        list<string>lText = new list<string>();
        
		string txt = string.format(tran ('Congratulations, you have successfully earned {0} points at {1}'),  new String[]{''+Integer.valueOf(txn.CVL__Accrued_Points_2__c),''+txn.Account__r.name});
//        string txt = tran('Congratulations, you have successfully earned ')+ Integer.valueOf(txn.CVL__Accrued_Points_2__c)+tran(' points at ')+txn.Account__r.name ;
        lText.add(txt);
        lText.addAll(balance(mem,true));
        
        update( new CVL__Loy_Member__c(Id = mem.Id, WhatsAppContext__c =mem.WhatsAppContext__c));   	
        sendText(mem.Phone__c,lText,mem.NexmoNumber__c);
    }

}
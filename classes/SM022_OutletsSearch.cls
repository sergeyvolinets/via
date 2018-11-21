public class SM022_OutletsSearch 
{
    
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
        
        list<account>lacc = [select id, name,Image__c,phone from account where Loy_Program__c =:programId and (id in :mret.keySet() or name like :sKeyWord) order by name];
        for(account acc :lAcc)
        {
            mret.put(acc.id,acc);
        }
        return (mret.values());
    }
    
    public static integer iSize =10;   
    public static chat2AI.Resp outletSearch(string sProgramId, string language)
    {
        string smode = SM010_Utils.getRestParam('mode');
        string sTab = SM010_Utils.getRestParam('tab'); 
        string sKeyWord = SM010_Utils.getRestParam('keyword'); 
        
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
        list<account>lAcc = searchAccByKeyWord(sKeyWord,sProgramId);
        
        if(lAcc.isEmpty())
            return SM007_engatiRest.message(SM020_customer.translate('There is no any shops by keyword ',language)+sKeyWord);   
        chat2AI.Resp ret = new chat2AI.Resp();  
        
        ret.data.type = 'carousel';
        
        list<account> lPart;
        boolean bEnd = true;        
        if(lAcc.size()<=iSize && Test.isRunningTest() == false)
        {
            lPart = lAcc;
        }else
        {
            integer iBegin;
            integer iCurSize;
            chat2AI.Template prev = getOutletsPrev(sProgramId,language);
            if(iTab == 0)
            {
                iBegin = 0;
                iCurSize = iSize-1;
                bEnd = false;
            }
            else
            {
                integer nTabs = Integer.valueOf(Math.ceil((lAcc.size()-1)/(iSize-2)));
                bEnd =(iTab == nTabs);
                iBegin = (iTab * (iSize-2))+1;   
                
                ret.data.templates.add(prev);
                if(bEnd)
                    iCurSize = iSize-1; //reserv just one slot for Prev button/catousel
                else
                    iCurSize = iSize-2; // reserv 2 slots for prev/next buttons
            }
            lpart = new list<account>();
            system.debug('iCurSize ='+iCurSize+' iBegin='+iBegin+' lAcc.size()='+lAcc.size());   
            for(integer i =0; i<iCurSize && (iBegin+i <lAcc.size()); i++)
            {
                account m = lAcc[iBegin+i];
                lpart.add(m);
            }
        }
        for(account acc : lpart)
        {
            chat2AI.Template temp = new chat2AI.Template();
            temp.title = acc.name;
            temp.image_url = acc.image__c;
            chat2AI.Button but = new chat2AI.Button();
            but.payload = 'https://google.com/';
            but.title = SM020_customer.translate('Call Now ',language)+acc.Phone;
            but.type = 'web_url';
			temp.buttons.add(but); 
            
            ret.data.templates.add(temp);         
        }
        
        if(bEnd == false || Test.isRunningTest())
        {
            chat2AI.Template next = getOutletsNext(sProgramId,language);
            ret.data.templates.add(next);           
        }
        chat2AI.Attr attr = new chat2AI.Attr();
        attr.name = 'tab';
        attr.value = ''+iTab;
        ret.attributes.add(attr);       
        
        chat2AI.Attr attr2 = new chat2AI.Attr();
        attr2.name = 'keyword';
        attr2.value = sKeyWord;
        ret.attributes.add(attr2);
        system.debug('ret '+ret);
        return ret;       
    }
    
    public static chat2AI.Template getOutletsNext(string sProgramId,string language)
    {
        chat2AI.Template ret = new chat2AI.Template();
        ret.title = 'Next';
        ret.image_url = SM010_Utils.getValue('nextImage');
        ret.default_action.type = 'web_url';
        ret.default_action.url = 'https://google.com/';
        chat2AI.Button but = new chat2AI.Button();            
        but.payload = 'flow_'+SM010_Utils.getFlowId('getOutletsNext',sProgramId,language);
        but.title = 'Next';
        but.type = 'postback';
        ret.buttons.add(but);           
        return ret;
    }
    public static chat2AI.Template getOutletsPrev(string sProgramId,string language)
    {
        chat2AI.Template ret = new chat2AI.Template();
        ret.title = 'Next';
        ret.image_url = SM010_Utils.getValue('prevImage');
        ret.default_action.type = 'web_url';
        ret.default_action.url = 'https://google.com/';
        chat2AI.Button but = new chat2AI.Button();            
        but.payload = 'flow_'+SM010_Utils.getFlowId('getOutletsNext',sProgramId,language);
        but.title = 'Prev';
        but.type = 'postback';
        ret.buttons.add(but);           
        return ret;
    } 
}
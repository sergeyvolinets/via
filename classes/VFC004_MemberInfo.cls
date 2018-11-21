public class VFC004_MemberInfo 
{
    public string sMemId {get;set;}
    public string sPhone {get;set;}
    public CVL__Loy_Member__c mem {get;set;}
    public CVL__Loy_Program__c pr {get;set;}
    public list<Member__c > vouchers {get;set;}
    public map<id,Member__c > mvoucher ;
    public boolean bRender {get;set;}
    public integer i=0;
    public boolean bRenderPromotion {get;set;}
    public string curPromoId {get;set;}
    public  Member__c curPromo {get;set;}
    public VFC004_MemberInfo() 
    { 
        try
        {
            sMemId = SM010_Utils.getParam('memberId');
            sPhone= SM010_Utils.getParam('phone');
            if(sMemId == '')
                sMemId = 'a071r00001ERpOi';
            getMemberInfo();
            
			bRender = true;
        }catch(Exception e)
        {
            bRender = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage())); 
        }
    }
    
    public void getMemberInfo()
    {

        list<CVL__Loy_Member__c> lMem = null;
        
        if(sMemID != '')
            lMem = [select id, Full_Name__c,Tier_Name__c,Discount__c, CVL__Points_1__c , CVL__Points_2__c, CVL__Program__c, CVL__Account__c   from CVL__Loy_Member__c where id = :sMemId];
		else
        {
           lMem = [select id, Full_Name__c,Tier_Name__c,Discount__c, CVL__Points_1__c , CVL__Points_2__c, CVL__Program__c  from CVL__Loy_Member__c where CVL__Account__r.phone = :sphone];
        }
        if(lMem.isEmpty())
        {
            throw new MyException('Can not find member '+sMemId);
        }
        mem = lMem[0];
        
		list<CVL__Loy_Program__c> lpr = [select id, name, logo__c,title__c,promo_Message__c from CVL__Loy_Program__c where id = :mem.CVL__Program__c];
        if(lpr.isEmpty())
        {
			throw new MyException('Can not find loy program'+mem.CVL__Program__c);
        }
        pr =lpr[0];
        mvoucher = new map<id,Member__c >();      
		vouchers = [select id,campaign_name__c,campaign_promo_message__c, campaign_image__c,reedem_url__c from member__c where Customer__c = :mem.CVL__Account__c and Promo_Campaign__r.Loy_Program__c  = :pr.id   and Status__c <> 'Used'];
    	if(vouchers.isEmpty())
        {
            bRenderPromotion = false;
        }
        else
        {
            curPromo = vouchers[0];
            vouchers.remove(0);
        }
    }
}
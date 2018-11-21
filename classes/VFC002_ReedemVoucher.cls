public class VFC002_ReedemVoucher 
{
    public string sMemberId{get;set;}
    public string imageURL {get;set;}
	
    public member__c mem{get;set;}
    public string sMemberName {get;set;}
    public string sCampaignName {get;set;}
    public string sPromoMessage {get;set;}
    public decimal dVal {get;set;}
    public string sPIN {get;set;}
    public boolean bRender {get;set;}
      
    public VFC002_ReedemVoucher() 
    { 
        bRender = true;
        try
        {
            sMemberId = ApexPages.currentPage().getParameters().get('memberId');
            if(sMemberId == null)
                sMemberId = 'a011r00003d7IWa';
            mem = DM001_Voucher.getRecord(sMemberId);  
            imageURL = mem.Promo_Campaign__r.Image__c;
            sCampaignName = mem.Promo_Campaign__r.Name;  
            sMemberName = mem.Customer__r.Full_Name__c;
            sPromoMessage = mem.Promo_Campaign__r.Promo_message__c;
            SM012_Voucher.validate(mem);
        }catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            bRender = false;             
        }
    }
    public PageReference doReedem()
    {
        id loyMemId =null;
        try
        {
			loyMemId = SM012_Voucher.doReedem2(mem.id, dVal, sPIN,true,1);
        }catch(Exception e)
        {
            ApexPages.addMessage (new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            bRender = false;             
        }
        if(loyMemId != null)
			return new PageReference('/apex/'+SM011_Const.vfpMemberinfo+'?memberId='+loyMemId); 
        else
            return null;
    }
}
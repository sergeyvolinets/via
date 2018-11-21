/*That class reedems voucher in Engati chatbot on HttpGet*/
@RestResource(urlMapping='/coupons/*')
global class SM008_CouponsRest 
{
    @HttpGet
    global static map<string,map<string,string>> getResponse()
    {
        string sMessage  = '';
        try
        {
            RestRequest  req = RestContext.request;
            map<string,object> mPar = req.params;
            string sMemberId = (string)mPar.get('memberId');
            member__c mem = DM001_Voucher.getRecord(sMemberId);
            if(mem.Coupons_Issued__c == null)
                mem.Coupons_Issued__c =0;
            if(mem.Coupons_Issued__c>=mem.promo_campaign__r.Number_of_Coupons_per_Member__c)
            {
                throw new MyException('You\'ve reached the limit of coupons in this campaign.');
            }
            asset a = new asset();
            a.accountid= mem.Customer__c;
            a.Product2Id = mem.promo_campaign__r.Coupon__c;
            a.Member__c = mem.id;
            a.Name =  mem.promo_campaign__r.Coupon__r.name+' '+mem.Customer__r.name;
            insert a;
            
            mem.Coupons_Issued__c +=1;
            update mem;
            system.debug('id: '+a.id);
            string couponCode = ((string) (a.id)).substring(6,15);
            system.debug('code: '+couponcode);
        }catch(Exception e)
        {
            sMessage = e.getMessage();
        }
        return getEngatiMessage(sMessage);
    }
    public static map<string,map<string,string>>  getEngatiMessage(string sMess)
    {
        map<string,map<string,string>> ret = new map<string,map<string,string>> ();
        map<string,string> rdata = new map<string,string>();
        ret.put('data', rdata);       
        rdata.put('text', sMess);
        rdata.put('type', 'text');        
        return ret;        
    }
}
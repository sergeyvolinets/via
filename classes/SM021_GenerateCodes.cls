public class SM021_GenerateCodes {
    private Id recordId;
	public SM021_GenerateCodes(ApexPages.StandardController stdController) {
		recordId = stdController.getId();
	}
	public PageReference onGenerate() {
		Promo_Campaign__c camp = [select id, Total_Coupon_Inventory__c  from Promo_Campaign__c where id = :recordId];
		if(camp.Total_Coupon_Inventory__c == null)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please provide Total Coupon Inventory.'));     
            return null;
        }

        
        list<Voucher_Code__c> lExist = [select id,name from Voucher_Code__c where Promo_Campaign__c  = :recordId];
        set<string>sCodes = new set<string>();
        for(Voucher_Code__c exist: lExist)
        {
            sCodes.add(exist.name);
        }
        list<Voucher_Code__c> lIns = new list<Voucher_Code__c>();
        integer iDigits =6;
        integer delta = (integer)camp.Total_Coupon_Inventory__c - lExist.size();
        for(integer i=0; i<delta; i++)
        {
            if(i>9900)
                break;
            string sCode;
            do
            {
                sCode = ''+SM010_Utils.getRandom(iDigits);
            }while(sCodes.contains(sCode));
            sCodes.add(sCode);
            Voucher_Code__c rec = new Voucher_Code__c();
            rec.Promo_Campaign__c = recordId;
            rec.name = sCode;
            lIns.add(rec);
        }
		insert lIns;
		return new PageReference('/' + recordId);
	}
    
    
	public static integer getRandom(integer iMult)
    {

        return (integer)(Math.ceil(Math.random()*iMult));
    }
}
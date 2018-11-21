public class DM001_Voucher {
    public static Member__c getRecord(id voucherId)
    {
        list<Member__c> lMem = 
            [
                select id,
                Name,
                Customer__c,
                Customer__r.name,
                Promo_Campaign__c,
                Coupons_Issued__c,                   
                promo_campaign__r.id,
                promo_campaign__r.Number_of_Coupons_per_Member__c,
                promo_campaign__r.RecordType.Name,
                promo_campaign__r.Coupon__c ,
                promo_campaign__r.Coupon__r.name ,  
                promo_campaign__r.Image__c ,
                Promo_Campaign__r.Expiry_Date__c,
                Promo_Campaign__r.Availability_DateTime__c,
                Promo_Campaign__r.Availability_DateTime__r.Name, 
                Promo_Campaign__r.Loy_Program__c,
                Promo_Campaign__r.Minimum_Purchase_Amount__c, 
                Promo_Campaign__r.Auto_Register_Loyalty_Member__c,
                Promo_Campaign__r.Promo_message__c,
                Promo_Campaign__r.Discount__c, 
                Promo_Campaign__r.Discount_Amount__c,                     
                Promo_Campaign__r.Reedem_Amount__c,
                Promo_Campaign__r.Reedem_Rate__c,
                Promo_Campaign__r.Brand__r.Name,
                Promo_Campaign__r.Name, 
                Promo_Campaign__r.Default_Outlet__c,
                Customer__r.Full_Name__c,
                Brand_Name__c
                from Member__c 
                where id = :voucherId
            ];
        if(lMem.isEmpty())
        {
            throw new MyException('Can\'t find voucher with \''+voucherId+'\' id.');
        }
        return lMem[0];
    }
    
    
    public static list<CVL__Loy_Transaction__c> getTxn(id voucherId)
    {
        return 
            [
                select 
                id,
                Name,
                Currency_Code__c,
                Parent_Transaction__c,
                CVL__Type__c, 
                CVL__Points__c, 
                CVL__Accrued_Points_1__c, 
                CVL__Accrued_Points_2__c,
                Base_Amount__c,
                Net_Amount__c,
                Discount__c,
                CVL__Member__c ,
                voucher_code2__c
                from CVL__Loy_Transaction__c 
                where voucher__c = :voucherId 
            ];
    }
    public static Member__c getTerms(id voucherId)
    {
        
        list<Member__c> lMem = 
            [
                select id,
                Name,
                Customer__c,
                Customer__r.name,
                Promo_Campaign__c,
                Coupons_Issued__c,                   
                Promo_Campaign__r.Brand__r.Name,
                Promo_Campaign__r.Name,                                
                Customer__r.Full_Name__c,
                Brand_Name__c,
                promo_campaign__r.Image__c , 
                Promo_Campaign__r.Promo_message__c,               
                Promo_Campaign__r.Terms_and_conditions2__c 
                from Member__c 
                where id = :voucherId
            ];
        if(lMem.isEmpty())
        {
            throw new MyException('Can\'t find voucher with \''+voucherId+'\' id.');
        }
        return lMem[0];
    }
    
    public static promo_campaign__c getTerms2(id campId)
    {
        list<promo_campaign__c> lMem = 
            [
                select id,
				name,
               	Image__c , 
                Promo_message__c,               
                Terms_and_conditions2__c,
                Terms_and_conditions__c               
                from promo_campaign__c 
                where id = :campId
            ];
        if(lMem.isEmpty())
        {
            throw new MyException('Can\'t find campaign with \''+campId+'\' id.');
        }
        return lMem[0];
    }   
}
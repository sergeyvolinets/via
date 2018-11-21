public class DM003_LoyMember {
    public static CVL__Loy_Member__c getRecord(id memId)
    {
        list<CVL__Loy_Member__c> lMem = [select id, Full_Name__c,Tier_Name__c,Discount__c, CVL__Points_1__c , CVL__Points_2__c, CVL__Program__c, CVL__Account__c, CVL__Account__r.phone,IsActive__c  from CVL__Loy_Member__c where id = :memId];
        if(lMem.isEmpty())
        {
            throw new MyException('Can not find member '+memId);
        }  
        return lMem[0];
    }
    public static CVL__Loy_Member__c getRecord4CheckSMS (id memId)
    {
        list<CVL__Loy_Member__c> lMem = [select id, CVL__Account__r.phone,SMSCode__c,CVL__Program__r.Name,CVL__Program__r.Title__c from CVL__Loy_Member__c where id = :memId];
        if(lMem.isEmpty())
        {
            throw new MyException('Can not find member '+memId);
        }  
        return lMem[0];       
    }
    
      public static CVL__Loy_Member__c getRecord4Login (string phone, id programId)
    {
        list<CVL__Loy_Member__c> lMem = [select id, CVL__Account__r.phone,SMSCode__c,CVL__Program__c,PIN__c from CVL__Loy_Member__c where CVL__Account__r.phone = :phone and CVL__Program__c = :programId ];
        if(lMem.isEmpty())
        {
            lMem = [select id, CVL__Account__r.phone,SMSCode__c,CVL__Program__c,PIN__c from CVL__Loy_Member__c where CVL__Account__r.phone = :phone];
        }  
        if(lMem.isEmpty())
        {
            throw new MyException('Can not find member with phone '+phone);            
        }
        return lMem[0];       
    }
    
}
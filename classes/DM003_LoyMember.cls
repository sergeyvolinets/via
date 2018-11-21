public class DM003_LoyMember {
  
    public static CVL__Loy_Member__c getRecord(id memId)
    {
        CVL__Loy_Member__c ret = null;
        list<CVL__Loy_Member__c> lMem = 
            [select 
             id, Full_Name__c,Tier_Name__c,
             Discount__c, CVL__Points_1__c , CVL__Points_2__c, 
             CVL__Program__c, CVL__Account__c, 
             CVL__Account__r.phone,IsActive__c 
             ,Loy_Tier__r.Name, CVL__Account__r.Full_Name__c,
             Channel__c,Phone__c,
             WhatsAppContext__c,
             WhatsAppPageIndex__c
             ,language__C  
			,session__c
             ,NexmoNumber__c
             from CVL__Loy_Member__c 
             where id = :memId
            ];
        
        if(lMem.isEmpty())
        {
            	throw new MyException('Can not find member '+memId);
        } 
        else
            ret = lmem[0];
            
        return ret;
    }
    public static CVL__Loy_Member__c getRecord4CheckSMS (id memId)
    {
        list<CVL__Loy_Member__c> lMem = [select id, CVL__Account__r.phone,SMSCode__c,CVL__Program__r.Name,CVL__Program__r.Title__c,CVL__Account__c from CVL__Loy_Member__c where id = :memId];
        if(lMem.isEmpty())
        {
            throw new MyException('Can not find member '+memId);
        }  
        return lMem[0];       
    }
    
      public static CVL__Loy_Member__c getRecord4Login (string phone, id programId)
    {
        list<CVL__Loy_Member__c> lMem = [select id, CVL__Account__r.phone,SMSCode__c,CVL__Program__c,PIN__c,CVL__Account__c from CVL__Loy_Member__c where CVL__Account__r.phone = :phone and CVL__Program__c = :programId ];
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
  
    
    public static CVL__Loy_Member__c getRecordforWhatsApp(string sPhone, string sProgramId)
    {
        string sPhone2 = '%'+sPhone;
        CVL__Loy_Member__c ret = null ; 
        list< CVL__Loy_Member__c> lmem = 
            [
                select 
                id, Full_Name__c,Tier_Name__c,
                Discount__c, CVL__Points_1__c , CVL__Points_2__c, 
                CVL__Program__c, CVL__Account__c, 
                CVL__Account__r.phone,IsActive__c 
                ,Loy_Tier__r.Name, CVL__Account__r.Full_Name__c,
                Channel__c,Phone__c,
                WhatsAppContext__c,
                WhatsAppPageIndex__c
                ,language__C 
                ,session__c
				,NexmoNumber__c
                from CVL__Loy_Member__c 
                where CVL__Account__r.Phone  like  :sPhone2 and CVL__Program__c  = :sProgramId and IsActive__c = true];
        if(!lmem.isEmpty())
            ret = lmem[0];
        return ret;
    }

      public static CVL__Loy_Member__c getRecordforWhatsApp(id memId)
    {
        CVL__Loy_Member__c ret = null ; 
        list< CVL__Loy_Member__c> lmem = 
            [
                select 
                id, Full_Name__c,Tier_Name__c,
                Discount__c, CVL__Points_1__c , CVL__Points_2__c, 
                CVL__Program__c, CVL__Account__c, 
                CVL__Account__r.phone,IsActive__c 
                ,Loy_Tier__r.Name, CVL__Account__r.Full_Name__c,
                Channel__c,Phone__c,
                WhatsAppContext__c,
                WhatsAppPageIndex__c
                ,language__C 
                ,session__c
              ,NexmoNumber__c               
                from CVL__Loy_Member__c 
                where Id = :memId];
        if(!lmem.isEmpty())
            ret = lmem[0];
        return ret;
    }
    
      public static CVL__Loy_Member__c getRecord2(id accId,id programId)
      {
               CVL__Loy_Member__c ret = null;
        list<CVL__Loy_Member__c> lMem = 
            [select 
             id, Full_Name__c,Tier_Name__c,
             Discount__c, CVL__Points_1__c , CVL__Points_2__c, 
             CVL__Program__c, CVL__Account__c, 
             CVL__Account__r.phone,IsActive__c 
             ,Loy_Tier__r.Name, CVL__Account__r.Full_Name__c,
             Channel__c,Phone__c,
             WhatsAppContext__c,
             WhatsAppPageIndex__c
             ,language__C 
             ,NexmoNumber__c             
             from CVL__Loy_Member__c 
             where CVL__Account__c = :accId
             and CVL__Program__c = :programId
            ];
        
        if(lMem.isEmpty())
        {
            	throw new MyException('Can not find member '+accId +' '+programId);
        } 
        else
            ret = lmem[0];
            
        return ret;
      }
    
}
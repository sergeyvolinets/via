trigger LoyMemTrigger on CVL__Loy_Member__c (after insert,after update, before insert, before update) 
{
/*    if(trigger.isAfter && Trigger.isInsert)
    {
        map<id,CVL__LOY_Program__c> mpr = new map<id,CVL__LOY_Program__c>();
        map<id,CVL__Loy_Member__c> mnew = new map<id,CVL__Loy_Member__c>();
        for(CVL__Loy_Member__c rec: Trigger.new)
        {
            mpr.put(rec.CVL__Program__c, null);
            mnew.put(rec.id,rec);
        }
        list<CVL__LOY_Program__c> lpr = [select id,Loy_Tier__c  from CVL__LOY_Program__c where id in :mpr.keySet()];
        for(CVL__LOY_Program__c pr :lpr)
        {
            mpr.put(pr.id,pr);
        }
        list< CVL__Loy_Mem_Tier__c > lins = new list< CVL__Loy_Mem_Tier__c >();
        
        for(CVL__Loy_Member__c rec: Trigger.new)
        {
            CVL__LOY_Program__c pr = mpr.get(rec.CVL__Program__c);
            if(pr != null && pr.Loy_Tier__c != null)
            {
                CVL__Loy_Mem_Tier__c tier = new CVL__Loy_Mem_Tier__c();
                tier.CVL__Active__c = true;
                tier.CVL__Start_Date__c = Date.today();
                tier.CVL__Member__c =rec.id;
                tier.CVL__Tier__c = pr.Loy_Tier__c ; 
                lins.add(tier);
            }		
        }   
        insert lins;
        list<CVL__Loy_Member__c> lupd = new list<CVL__Loy_Member__c>();
        
        for(CVL__Loy_Mem_Tier__c tier :lins)
        {
            
            CVL__Loy_Member__c rec = mnew.get(tier.CVL__Member__c);
            CVL__Loy_Member__c upd = new CVL__Loy_Member__c();
            upd.id = rec.id;
          //  upd.CVL__mem_tier__c = tier.id;
          	upd.Loy_Member_Tier__c = tier.id;
    //        upd.CVL__Tier__c = tier.CVL__Tier__c;
            lupd.add(upd);
        }
        update lupd;
    }
*/    
    if(trigger.isAfter && Trigger.isInsert)
    {
        list<Member__c> lmem = new list<Member__c>();
        list<Promo_Campaign__c> lcamp = new list<Promo_Campaign__c>();
        set<id> sid = new set<id>();
        for(CVL__Loy_Member__c mem: Trigger.new){
            if(mem.CVL__Program__c != null){ 
                sid.add(mem.CVL__Program__c);
            }
        }
        lcamp = [select id, Loy_Program__c from Promo_Campaign__c where Loy_Program__c in :sid];
        map<id,Promo_Campaign__c> mpc = new map<id,Promo_Campaign__c>();
        for(Promo_Campaign__c pc:lcamp)
        {
            mpc.put(pc.Loy_Program__c,pc);
        }
        for(CVL__Loy_Member__c mem: Trigger.new)
        {
            if(mem.CVL__Program__c != null){
                Member__c newmem = new Member__c();
                newmem.Customer__c = mem.CVL__Account__c;
                newmem.Loy_Member__c = mem.id;
                Promo_Campaign__c pc = mpc.get(mem.CVL__Program__c);
                if(pc != null)
                {
                    newmem.Promo_Campaign__c = pc.id;                   
                    lmem.add(newmem);              
                }
            }
        }
        if (!lmem.isEmpty())
            insert lmem;      
    }
}
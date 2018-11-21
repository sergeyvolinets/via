public class SM005_Session 
{
    public static id newSession(id memId,id accId)
    {
        session__c ret = new session__c();
        ret.Loy_Member__c  = memId;
        ret.Account__c = accId;
        ret.Last_Access__c = System.now();
        insert ret;
        return ret.id;
    }

    public static session__c checkAndUpdate(id sessId)
    {
        list<session__c> lSess = [select id, Loy_Member__c, Last_Access__c,account__c from session__c where id = :sessId];
        if(lSess.isEmpty())
        {
            throw new SM005_SessionException('For your security, in case you haven’t redeemed within in a timely manner, this link expires. Please type Redeem on our WhatsApp page to receive a new redemption link.');
        }
        session__c sess = lSess[0];
        if(System.now().getTime()- sess.Last_Access__c.getTime()>getMaxInterval())
        {
             throw new SM005_SessionException('For your security, in case you haven’t redeemed within in a timely manner, this link expires. Please type Redeem on our WhatsApp page to receive a new redemption link.');           
        }

        sess.Last_Access__c = System.now();
        update sess;
        return sess;
    }
    public static Long getMaxInterval()
    {
       string str = SM010_Utils.getValue('Session Alive Seconds');
        if(Test.isRunningTest())
            str = '60';
        return Integer.valueOf(str.trim())*1000;
    }
    
    public static void refresh(CVL__Loy_Member__c mem)
    {
         if(mem.Session__c != null)
        {
            try
            {
                checkAndUpdate(mem.Session__c);
            }catch(Exception e)
            {
                mem.Session__c = null;
            }
            
        }
        if(mem.Session__c == null)
        {
            mem.Session__c = newSession(mem.Id,mem.CVL__Account__c);
        }
    }
}
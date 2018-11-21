public class SM005_Session 
{
    public static id newSession(id memId)
    {
        session__c ret = new session__c();
        ret.Loy_Member__c  = memId;
        ret.Last_Access__c = System.now();
        insert ret;
        return ret.id;
    }

    public static id checkAndUpdate(id sessId)
    {
        list<session__c> lSess = [select id, Loy_Member__c, Last_Access__c from session__c where id = :sessId];
        if(lSess.isEmpty())
        {
            throw new SM005_SessionException('Invalid or expired session '+sessId);
        }
        session__c sess = lSess[0];
        if(System.now().getTime()- sess.Last_Access__c.getTime()>getMaxInterval())
        {
             throw new SM005_SessionException('Invalid or expired session '+sessId);           
        }

        sess.Last_Access__c = System.now();
        update sess;
        return sess.Loy_Member__c;
    }
    public static Long getMaxInterval()
    {
       string str = SM010_Utils.getValue('Session Alive Seconds');
        if(Test.isRunningTest())
            str = '60';
        return Integer.valueOf(str.trim())*1000;

    }
}
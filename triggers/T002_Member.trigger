trigger T002_Member on Member__c (before insert,before update, after insert, after update) 
{
    if(Trigger.isBefore)
    {
        for (Member__c rec: Trigger.new)
        {
            if(rec.Campaign_Name__c  != null && rec.Name != rec.Campaign_Name__c)
            {
                rec.Name = rec.Campaign_Name__c;
            }
        }
    }

}
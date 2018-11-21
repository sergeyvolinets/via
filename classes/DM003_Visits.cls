public class DM003_Visits {
    public static list<Outlet_Visit__c> getVisits(set<id>sMemId, set<id>sOutletId)
    {
        return [select id,Active_Flag__c ,Loy_Member__c ,Outlet__c, Visits__c from  Outlet_Visit__c where Loy_Member__c in :sMemId and Outlet__c in :sOutletId];
    }

}
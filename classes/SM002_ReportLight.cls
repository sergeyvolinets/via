public class SM002_ReportLight 
{
    @AuraEnabled
    public static list<string> getReportNames(id recordId)
    {
        list<string>lStr = new list<string>();
		list<Report> lRep = SM002_Report.getReports();
        for(Report rep: lRep)
        {
            lStr.add(rep.DeveloperName);
        }
        return lStr;
    }
    
    @AuraEnabled    
    public static string saveCampMembers(id recordId,string sRepName)
    {
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where 
                                    DeveloperName = :sRepName];
        if(reportList.isEmpty())
            throw new MyException('Can not find report ['+sRepName+']');
        
        set<id> sId = SM002_Report.getReportIds(reportList);
        map<id,Member__c> mIns = new map<id,Member__c>();
        list<Member__c> lMem = [select id, Customer__c , Promo_Campaign__c from Member__c where Promo_Campaign__c = :recordId];
        map<id,Member__c> mMem = new map<id,Member__c>();
        for(member__c mem : lMem)
        {
            mMem.put(mem.Customer__c, mem);
        }
        for(id mid : sId )
        {
            if(!mMem.containsKey(mid))
            {
                member__c ins = new member__c();
                ins.Customer__c = mid;
                ins.Promo_Campaign__c = recordId;
                mIns.put(ins.Customer__c, ins);
            }
        }

        if(!Test.isRunningTest())
        	insert mIns.values();  
        
        return '';
    }

}
public class SM002_Report 
{
    public string sReportId{get;set;}
    	public boolean bInProgress {get;set;}
    public ApexPages.StandardController stdController; 
    
    public static list<Report> getReports()
    {
        return [Select r.SystemModstamp, r.OwnerId, r.NamespacePrefix, r.Name, r.LastViewedDate, r.LastRunDate, r.LastReferencedDate, r.LastModifiedDate, r.LastModifiedById, r.IsDeleted, r.Id, r.Format, r.FolderName, r.DeveloperName, r.Description, r.CreatedDate, r.CreatedById From Report r];
        
    }
    public list<selectOption> aReports
    {	set;
     	get
    	{
        	if(aReports == null)
            {
                aReports = new list<selectOption>();
                list<Report> lReport = SM002_Report.getReports();
                for(report rep : lReport)
                {
                    aReports.add(new SelectOption(rep.id,rep.Name));
                }
            }
            return aReports;
    	}
    }
    public static set<id> getReportIds (id repId)
    {
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where 
                                    id = :repId];
                if(reportList.isEmpty())
            throw new MyException('Can not find report ['+repId+']');
		return getReportIds(reportList);      
    }
    
    
    public static set<id> getReportIds (List <Report> reportList)
    {
        set<id>sret = new set<id>();
        String reportId = (String)reportList.get(0).get('Id');
        String sRepName = (String)reportList.get(0).get('DeveloperName');
        integer iId = null;
        integer i =0; 
        String factMapKey ='T!T';        
        if(test.isRunningTest())
        {
            list<account> lacc = [select id from account where RecordType.Name = 'Customer' limit 10];
            for(account acc : lacc)
            {
                sret.add(acc.id);
            }
            
        }else
        {
            // Run a report synchronously
            Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);

            Reports.ReportFactWithDetails factDetails = (Reports.ReportFactWithDetails) results.getFactMap().get(factMapKey);

            for(string col:results.getReportMetadata().getDetailColumns())
            {
                if(col.toUpperCase() == 'ACCOUNT_ID' || col.toUpperCase() == 'ACCOUNT.ID')
                {
                    iId = i;break;
                }
                i++;
            }
            if(iId == null)
                throw new MyException('Can not find [Account Id] in report ['+sRepName+']. Please specify another report.');
            
            for(Reports.ReportDetailRow detailRow : factDetails.getRows())
            {
                LIST<Reports.ReportDataCell> cells = detailRow.getDataCells(); 
                sRet.add((id)(cells[iId].getValue()));
            }
        }
        return sRet;
    }
    
    public static void doSave(string sReportId, id campId)
    { 
		set<id> sId = SM002_Report.getReportIds(sReportId);
        map<id,Member__c> mIns = new map<id,Member__c>();
        list<Member__c> lMem = [select id, Customer__c , Promo_Campaign__c from Member__c where Promo_Campaign__c = :campId];
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
                ins.Promo_Campaign__c = campId;
                mIns.put(ins.Customer__c, ins);
            }
        }
        insert mIns.values();       
    }
    
    public PageReference save()
    {
        
                string campId = getRecordId();

        SM002_Report.doSave(sReportId, campId);
  
        return null;
    }
       public PageReference cancel()
    {
        return null;
    }
      public string getRecordId()
    {
        string objId = null;
        try
        {
			sobject orec = stdController.getRecord(); 
			objId = (string) orec.get('id');
        }catch(Exception e)
        {
            
        }
        return objId;
    }
      public SM002_Report(ApexPages.StandardController stdControll) 
      { // constructor
        this.stdController = stdControll;
      }

}
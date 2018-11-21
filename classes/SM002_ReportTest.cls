@IsTest (SeeAllData='true')

public class SM002_ReportTest 
{
     static testMethod void testIt()
    {
        string sRepName = 'Males_Birth_In_April';
        Test.startTest();           
        SM002_ReportLight.getReportNames(null);
        Promo_Campaign__c  camp = new Promo_Campaign__c ();
        camp.name = 'voucher1';
        insert camp;
        report orep = [select id from report where DeveloperName = :sRepName];
        SM002_ReportLight.saveCampMembers(camp.Id,sRepName);
        SM002_Report rep = new SM002_Report(new ApexPages.StandardController(camp));
        list<selectOption> reps = rep.aReports;
        rep.sReportId = orep.id;
        
        rep.save();
        rep.bInProgress = true;
        rep.cancel();       
        Test.stopTest(); 
    }
    
}
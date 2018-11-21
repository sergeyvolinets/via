@IsTest
public class VFC002_ReedemVoucherTest 
{
    static testMethod void testIt()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();
        apexpages.currentpage().getparameters().put('memberId' , data.mem2.id);
        VFC002_ReedemVoucher inf = new VFC002_ReedemVoucher();
        inf.sPIN = '111';
        inf.doReedem();
        string sMemberId = inf.sMemberId;
        
        string imageURL = inf.imageURL;
        
        member__c mem = inf.mem;
        string sMemberName  = inf.sMemberName;
        string sCampaignName = inf.sCampaignName;
        string sPromoMessage = inf.sPromoMessage;
        decimal dVal = inf.dVal;
        string sPIN = inf.sPIN;
        boolean bRender = inf.bRender;       
        Test.stopTest();
    }
}
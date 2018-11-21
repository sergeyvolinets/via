@IsTest
public class VFC004_MemberInfoTest 
{
    static testMethod void testIt()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();
        ApexPages.currentPage().GetParameters().put('memberId' , data.lmem.id);
        ApexPages.currentPage().GetParameters().put('phone' , '12345');  
        VFC004_MemberInfo inf = new VFC004_MemberInfo();
        inf.bRenderPromotion = true;
        inf.curPromoId = null;
        Test.stopTest();
    }
}
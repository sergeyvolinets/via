@IsTest
public class SM005_SessionTest 
{

    static testMethod void testIt()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();
        id sessId = SM005_Session.newSession(data.lmem.id,null);
        session__c sess = SM005_Session.checkAndUpdate(sessId);
        system.assert(sess.Loy_Member__c == data.lmem.id);
        SM010_Utils.getRandom(10);
        Test.stopTest();
    }
}
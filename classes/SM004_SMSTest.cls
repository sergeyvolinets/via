@IsTest 
public class SM004_SMSTest 
{
    static testMethod void testIt()    
    {
        Test.startTest();
        SM004_SMS.sendSms('123','1223',null,'aaaa');
        Test.stopTest();
    }
}
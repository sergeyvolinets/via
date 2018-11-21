@IsTest
public class SM006_CheckSmsTest 
{
    static testMethod void testIt()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/checksms2/';  
        req.addParameter('memberId', data.lmem.id);
        req.addParameter('code', '12345');        

        RestContext.request = req;
        RestContext.response = res;

        req.httpMethod = 'POST';  
        SM006_CheckSms.sendSms();  
        
        req.httpMethod = 'GET';
        SM006_CheckSms.validate();
        
        Test.stopTest();
    }
}
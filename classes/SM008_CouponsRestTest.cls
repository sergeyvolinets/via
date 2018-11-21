@IsTest
public class SM008_CouponsRestTest 
{
    static testMethod void testIt()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/coupons/';  
        req.addParameter('memberId', data.mem.id);
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        SM008_CouponsRest.getResponse();
        Test.stopTest();
    }
    
}
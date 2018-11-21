@IsTest
public class SM015_WayFinderTest {
    static testMethod void testIt()
    {
		Test.startTest(); 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/wayfinder/';  
        req.addParameter('from', 'from');
        req.addParameter('to', 'to');        
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        SM015_WayFinder.getResponse();
        Test.stopTest();
    }
}
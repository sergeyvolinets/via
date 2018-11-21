@IsTest
public class SM009_RegisterTest 
{
    
      static testMethod void testIt()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/chat2AI/';  
        req.addParameter('phone', '432');
        
        req.addParameter('firstName','aaa444');        
        req.addParameter('lastname','bbb444');
		req.addParameter('gender','Male');
		req.addParameter('nationality','ukr'); 
        req.addParameter('program',data.prog.id);
        req.addParameter('pin','1234');        
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        SM009_Register.RegisterResponse resp = SM009_Register.doPost();
        
        req.addParameter('memberId', resp.recordId);
        req.addParameter('id', resp.recordId); 
        req.httpMethod = 'GET';
        SM009_Register.MemberResponse resp2 = SM009_Register.doGet();

				
        Test.stopTest();
    }

}
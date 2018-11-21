@IsTest
public class SM014_LoyProgramTest 
{
        static testMethod void testIt()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();
        
		RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/program/';  
        req.addParameter('id', data.prog.id);
        req.httpMethod = 'GET';    
        RestContext.request = req;
        RestContext.response = res;
        SM014_LoyProgram.ProgramResponse resp = SM014_LoyProgram.doGet();
        Test.stopTest();
    }

}
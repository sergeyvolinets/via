@isTest
public class SM016_CategoryTest 
{
    static testMethod void testIt()
    {
		SM001_DataFactory data = new SM001_DataFactory();
        Category__c cat = new Category__c();
        cat.account__c = data.cust.id;
        insert cat;
        
        Test.startTest();

        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        req.httpMethod = 'GET';
        RestContext.request = req;
		req.addParameter('program', data.prog.id);
        RestContext.response = res;
        SM016_Category.getResponse();
        Test.stopTest();
    }
    
}
@IsTest
public class SM007_engatiRestTest 
{
    static testMethod void testIt()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/chat2AI/';  
        req.addParameter('phone', data.cust.phone);
        req.addParameter('program', data.prog.id);
        req.addParameter('mode', 'NEXT');        
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        SM007_engatiRest.getResponse();


        SM007_engatiRest.gotoFlow('getPromotions',data.prog.id,'en');
        SM007_engatiRest.gotoFlow('getPin',data.prog.id,'en');
        SM007_engatiRest.register(data.cust.phone,data.prog.id,'en');
        SM007_engatiRest.message('123', new map<string,string>{'aaa'=>'bbb'},null,null,'en');
        SM015_CheckPhone.getResponse();
        Test.stopTest();
    }
    
    static testMethod void testIt2()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/loyinfo/';  
        req.addParameter('phone', data.cust.phone);
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        SM007_engatiRest2.getResponse();
        Test.stopTest();        
    }
}
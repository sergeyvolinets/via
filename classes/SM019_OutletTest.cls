@IsTest
public class SM019_OutletTest 
{
  static testMethod void testIt()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();    
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        RestContext.response = res;
        
        req.requestURI = '/services/apexrest/chat2aiOutlet/';  
        req.addParameter('type', 'login');
        req.addParameter('program', data.prog.id);
        req.addParameter('outletpin', '1111');
        SM019_Outlet.response();
        
        req.addParameter('type', 'submitTxn');  
        req.addParameter('outlet', data.outlet.id);
        req.addParameter('txnpin', '1111');
        req.addParameter('amount','200');
        SM019_Outlet.response(); 
        
        req.addParameter('type', 'submitTxn');  
        req.addParameter('outlet', data.outlet.id);
        req.addParameter('txnpin', '1111');
        req.addParameter('amount','200');
        SM019_Outlet.response();   
        
         
        req.addParameter('type', 'history');  
        req.addParameter('outlet', data.outlet.id);
        SM019_Outlet.response();   
               
        Test.stopTest();
    }
}
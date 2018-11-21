@IsTest
public class SM020_CustomerTest 
{
     static testMethod void testIt()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();    
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/chat2AICustomer/';  
        req.addParameter('phone', data.cust.phone);
        req.addParameter('program', data.prog.id);   
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        req.addParameter('type', 'login');        
        SM020_Customer.getResponse();
        req.addParameter('type', 'getPin'); 
        req.addParameter('pass', '1111');
		SM020_Customer.getResponse();
    
		req.addParameter('type', 'register'); 
		req.addParameter('phone', '380556547755');
 		req.addParameter('name', 'abc');                        
        req.addParameter('pin', '1111');
        req.addParameter('pin2', '1111');   
        req.addParameter('language','en');
        req.addParameter('host','host');        
		SM020_Customer.getResponse();
    
        req.addParameter('checkMemId', data.lmem.id);
        req.addParameter('checkAccId', data.lmem.CVL__Account__c);  
        req.addParameter('smsCode', '1234');
		req.addParameter('type', 'checkSms'); 
		SM020_Customer.getResponse();

		req.addParameter('memId', data.lmem.id);
        req.addParameter('accId', data.lmem.CVL__Account__c);  
		req.addParameter('type', 'earn'); 
  		SM020_Customer.getResponse();  


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
 
        req.addParameter('type', 'checkTxn');          
        SM020_Customer.getResponse();
        
		req.addParameter('type', 'getPromotions'); 
   		SM020_Customer.getResponse();         
		SM020_Customer.iSize = 1;
                req.addParameter('mode','PREV');
  		SM020_Customer.getResponse();   
 		SM020_Customer.iSize = 1;
                req.addParameter('mode','NEXT');
  		SM020_Customer.getResponse();        
        
        req.addParameter('campId', data.camp.id); 
		req.addParameter('mode','NEXT');      
        req.addParameter('type', 'getCat');           
        SM020_Customer.getResponse(); 
        
  		req.addParameter('mode','empty');    
         req.addParameter('type', 'getCat');           
        SM020_Customer.getResponse();        
        SM020_Customer.getCatNext(data.prog.id,'en');
        SM020_Customer.getCatPrev(data.prog.id,'en'); 
        
        Test.stopTest();
    }
    
    
         static testMethod void testIt2()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();  
        
        
           RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/chat2AICustomer/';  
        req.addParameter('phone', data.cust.phone);
        req.addParameter('program', data.prog.id);   
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        req.addParameter('type', 'getPin'); 
        req.addParameter('pass', '1111');
        req.addParameter('memId', data.lmem.id);
        req.addParameter('accId', data.lmem.CVL__Account__c);  
        req.addParameter('type', 'redeem');
        req.addParameter('campId', data.camp2.id);
  		SM020_Customer.getResponse();   
		req.addParameter('type', 'test');
  		SM020_Customer.getResponse();

		req.addParameter('type', 'test2');
  		SM020_Customer.getResponse();
 		req.addParameter('type', 'info');     
  		SM020_Customer.getResponse();   
  		req.addParameter('type', 'searchKey');     
  		SM020_Customer.getResponse();   
		req.addParameter('mode','empty');        
        req.addParameter('keyword','Category1');
   		req.addParameter('type', 'searchKey2');  
		
        SM022_OutletsSearch.iSize = 1;
        SM020_Customer.getResponse(); 
		req.addParameter('mode','NEXT');         
        SM020_Customer.getResponse();         
		req.addParameter('mode','PREV');     
        SM020_Customer.getResponse(); 
        
		req.addParameter('type', 'balance');        
  		SM020_Customer.getResponse();

        req.addParameter('type', 'changeLang'); 
        
        SM020_Customer.getResponse();
   		req.addParameter('type', 'checkTxn');           
        req.addParameter('programId','empty');
        req.addParameter('memId','empty');  
        SM020_Customer.getResponse();        
        Test.stopTest();
    }
    static testMethod void testIt3()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();  
        SM021_GenerateCodes codes = new SM021_GenerateCodes(new ApexPages.StandardController(data.camp2));
        codes.onGenerate();
        Test.stopTest();
    }

}
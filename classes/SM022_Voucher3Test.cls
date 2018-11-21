@IsTest
public class SM022_Voucher3Test 
{
   static testMethod void test1()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();
        SM021_GenerateCodes codes = new SM021_GenerateCodes(new ApexPages.StandardController(data.camp));
        codes.onGenerate();       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res; 
        req.requestURI = '/services/apexrest/voucher2/';  
        req.addParameter('id', data.mem2.id);
        req.httpMethod = 'GET';    
        

        req.addParameter('campId', data.camp.id);
        req.addParameter('accId', data.cust.id);
        SM012_Voucher.VoucherResponse resp = SM022_Voucher3.doGet();
        
        req.addParameter('amount', '100');
        req.addParameter('pin', '111');
        req.httpMethod = 'POST';
        req.addParameter('id', data.mem.id);        
        SM012_Voucher.ReedemResponse resp2 = SM022_Voucher3.doReedem();

        Test.stopTest();
    }
    
   static testMethod void testErr()
   {
    Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();
        SM021_GenerateCodes codes = new SM021_GenerateCodes(new ApexPages.StandardController(data.camp));
        codes.onGenerate();       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res; 
  //      req.requestURI = '/services/apexrest/voucher2/';  
  //      req.addParameter('id', data.mem2.id);
        req.httpMethod = 'GET';    
        

    //    req.addParameter('campId', data.camp.id);
    //    req.addParameter('accId', data.cust.id);
    try
    {
        SM012_Voucher.VoucherResponse resp = SM022_Voucher3.doGet();        
    }catch(Exception e)
    {
        
    }

        
   //     req.addParameter('amount', '100');
   //     req.addParameter('pin', '111');
   //     req.httpMethod = 'POST';
   //     req.addParameter('id', data.mem.id);   
    try
    {     
        SM012_Voucher.ReedemResponse resp2 = SM022_Voucher3.doReedem();
    }catch(Exception e)
    {
        
    }
        Test.stopTest();      
   }
}
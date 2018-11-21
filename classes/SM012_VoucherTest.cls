@IsTest
public class SM012_VoucherTest 
{
    static testMethod void testIt()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();
        
                RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/voucher2/';  
        req.addParameter('id', data.mem2.id);
        req.httpMethod = 'GET';    
        
        RestContext.request = req;
        RestContext.response = res;
        SM012_Voucher.VoucherResponse resp0 = SM012_terms.doGet();   
		req.addParameter('id', data.camp.id);
		SM012_terms2.doGet();            
        SM012_Voucher.VoucherResponse resp = SM012_Voucher.doGet();
        
        req.addParameter('amount', '100');
        req.addParameter('pin', '111');
        req.httpMethod = 'POST';
        SM012_Voucher.ReedemResponse resp2 = SM012_Voucher.doReedem();
        req.addParameter('voucherId', data.mem2.id);
        SM013_Txn.doGet();
        Test.stopTest();
    }
    
 
}
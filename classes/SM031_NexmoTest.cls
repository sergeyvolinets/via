@isTest
public class SM031_NexmoTest 
{
    static testMethod void testIt()
    {
        SM001_DataFactory data = new SM001_DataFactory();

        Test.startTest();
        RestRequest req = new RestRequest(); 
        req.requestBody =Blob.valueOf( '{"from":{"type":"whatsapp","number":"12345"},"to":{"type":"whatsapp","number":"54321"},"message":{"content":{"text":"text","type":"template","template":{"name":"whatsapp:hsm:technology:nexmo:verify","parameters":[{"default":"Nexmo Verification"},{"default":"64873"},{"default":"10"}]}}}}');
        RestResponse res = new RestResponse(); 
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        SM010_Utils.sProgramId = data.prog.Id;
        SM031_Nexmo.getMessage();
        SM031_Nexmo.getMessage();      
        Test.stopTest();    
    }
    
    
      static testMethod void testIt2()
    {
        Test.startTest();
        SM001_DataFactory data = new SM001_DataFactory();        
        SM032_DialogFlow.Resp resp = new SM032_DialogFlow.Resp();
		CVL__Loy_Member__c mem = DM003_LoyMember.getRecordforWhatsApp(data.cust.phone,data.lmem.CVL__Program__c);
        system.assert(mem != null,'data.lmem is null');
        SM010_Utils.sProgramId = data.prog.Id;
        SM010_Utils.lang = 'en';
        SM031_Nexmo.welcome(mem, resp);
        SM031_Nexmo.noRestraunts(mem,resp);   
        SM031_Nexmo.yesRestraunts(mem,resp);         
        SM031_Nexmo.participating2(mem,resp);
        SM031_Nexmo.participating(mem,resp);
        SM031_Nexmo.searchAccByKeyWord('', data.lmem.CVL__Program__c);
        SM031_Nexmo.earn(mem); 
 //       SM031_Nexmo.redeem(mem, '54321');
        Test.stopTest();    
    }
    
         static testMethod void testIt3()
    {
        Test.startTest();
        SM001_DataFactory data = new SM001_DataFactory();        
        SM032_DialogFlow.Resp resp = new SM032_DialogFlow.Resp();
		CVL__Loy_Member__c mem = DM003_LoyMember.getRecordforWhatsApp(data.cust.phone,data.lmem.CVL__Program__c);
        system.assert(mem != null,'data.lmem is null');
        SM010_Utils.sProgramId = data.prog.Id;
        SM010_Utils.lang = 'en';
        SM031_Nexmo.redeem(mem, '54321');
        Test.stopTest();    
    }
    
    
    static testMethod void testIt4()
    {
        Test.startTest();
        SM001_DataFactory data = new SM001_DataFactory();        
        SM032_DialogFlow.Resp resp = new SM032_DialogFlow.Resp();
        CVL__Loy_Member__c mem = DM003_LoyMember.getRecordforWhatsApp(data.cust.phone,data.lmem.CVL__Program__c);
        system.assert(mem != null,'data.lmem is null');
        SM010_Utils.sProgramId = data.prog.Id;
        SM031_Nexmo.setLanguage(mem,resp);
        Test.stopTest();    
    }
}
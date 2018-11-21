@IsTest 
public class DM003_LoyMemberTest 
{
    static testMethod void getRecord()
    {
        SM001_DataFactory data = new SM001_DataFactory();
        Test.startTest();
        
        DM003_LoyMember.getRecord(data.lmem.id);
        Test.stopTest();       
    }
    
    
    static testMethod void     getRecord4CheckSMS ()
    {
        SM001_DataFactory data = new SM001_DataFactory();        
        Test.startTest(); 
                DM003_LoyMember.getRecord4CheckSMS(data.lmem.id);

        Test.stopTest();       
    }
    
    
    static testMethod void getRecord4Login()
    {
         SM001_DataFactory data = new SM001_DataFactory();        
        Test.startTest(); 
        DM003_LoyMember.getRecord4Login(data.cust.phone,data.prog.id);
        Test.stopTest();         
    }
    
    static testMethod void getRecordforWhatsApp()
    {
        SM001_DataFactory data = new SM001_DataFactory();        
        Test.startTest(); 
        DM003_LoyMember.getRecordforWhatsApp(data.cust.phone,data.prog.id);
		DM003_LoyMember.getRecordforWhatsApp(data.lmem.id);
        Test.stopTest();         
    }
    
        static testMethod void getRecord2()
    {
        SM001_DataFactory data = new SM001_DataFactory();
        Test.startTest();
        
        DM003_LoyMember.getRecord2(data.cust.id,data.prog.id);
        Test.stopTest();       
    }
}
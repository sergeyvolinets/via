@IsTest 
public class SM032_DialogFlowTest 
{
    static testMethod void testIt()    
    {
        Test.startTest();
        SM032_DialogFlow.query('aaa', 'bbb', 'en');
        Test.stopTest();        
    }
}
@IsTest
public class SM030_ImageTest 
{
     static testMethod void testIt()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();
        SM030_Image.getImage(data.cust.id);
        SM030_Image.getImage(data.prog.id);
        SM030_Image.getImage(data.camp.id);       
        
        SM030_Image.saveTheFile(data.cust.id, 'aaa.txt', '', 'text/plain');
        SM030_Image.saveTheFile(data.prog.id, 'bbb.txt', '', 'text/plain');
        SM030_Image.saveTheFile(data.camp.id, 'ccc.txt', '', 'text/plain');        
        Test.stopTest(); 
        
    }
}
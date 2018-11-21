@IsTest 
public class SM033_URLShorterTest 
{
  static testMethod void testIt()    
    {
        Test.startTest();
        SM033_URLShorter.shorter('google.com');
        Test.stopTest();
    }
/*      static testMethod void testIt2()    
    {
        Test.startTest();
        SM033_URLShorter.shorter2('google.com');
        Test.stopTest();
    }*/
}
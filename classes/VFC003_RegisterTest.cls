@IsTest
public class VFC003_RegisterTest 
{
    static testMethod void testIt()
    {
        Test.startTest(); 
        SM001_DataFactory data = new SM001_DataFactory();
        ApexPages.currentPage().GetParameters().put('programId' , data.prog.id);
        ApexPages.currentPage().GetParameters().put('phone' , '12345');  
        VFC003_Register inf = new VFC003_Register();
        inf.sFirstName = 'aaaaaa';
        inf.sLastName = 'aaaaa';
        inf.nationality = 'aaaa';
        inf.gender = 'Male';
        inf.sPIN='1234';
        inf.sPIN2='1234';
        inf.register();
        Test.stopTest();
    }
}
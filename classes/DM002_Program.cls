public class DM002_Program 
{
    public static CVL__Loy_Program__c getRecord(id programId)
    {
        list<CVL__Loy_Program__c> lPrg = [select id,name,Logo__c, Promo_Message__c, Title__c from  CVL__Loy_Program__c where id = :programId ];
        if(lPrg.isEmpty())
        {
                throw new MyException('Can\'t find program with \''+programId+'\' id.');
        }
        return lPrg[0];
    }

}
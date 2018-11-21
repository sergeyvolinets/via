public class SM010_Utils 
{
    public static string getParam(string sparamName)
    {
        string sRet = ApexPages.currentPage().getParameters().get(sParamName);
        if (sRet == null)
        {
            sRet = '';
        }
        sRet = sRet.trim();
        if(sRet == 'null')
            sRet = '';       
        return sRet;
    }
    
    public static string getRestParam(string sParamName)
    {
        string sRet = (string)RestContext.request.params.get(sParamName);
        if(sRet == null)
            sRet = '';
        sRet = sRet.trim();
        if(sRet == 'null' || sRet == 'empty')
            sRet = '';
        return sRet;
    }
    
    public static string getValue(string sName)
    {
        Values__c val = Values__c.getInstance(sName);
        if(val == null)
        {
            if(Test.isRunningTest())
                return '';
            throw new MyException('Can\'t find '+sName+'in Values custom settings. Please notify admin.');
        }
        return val.Value__c;
    }
    
    public static string getFlowId(string flowName,string programId, string language)
    {
        /*string sRet='';
string sQl = 'select id, '+flowName+'__c from CVL__Loy_Program__c where id = \''+programId+'\'';
list<sobject> lobj = Database.query(sQl);
if(lObj.isEmpty())
throw new MyException('Can\'t find loyalty program with id ['+programId+']');  
sobject obj = lobj.get(0);
sRet = (string) obj.get(flowName+'__c');
if((sRet == null || sRet == '') && Test.isRunningTest() == false)
throw new MyException('Flow '+flowName+' is not defined in loyalty program ['+programId+']. Please notify admin.');  
return sRet;       */ 
        /*
// тут нет разбивки по programId
Flow__c f = Flow__c.getInstance(flowName);//flowName+' '+language
if(f == null)
{
if(Test.isRunningTest())
return '';
f = Flow__c.getInstance(flowName);
if (f == null)
throw new MyException('Can\'t find flow id for '+flowName+'in Flow custom settings. Please notify admin.');

}
return f.Value__c;
*/
        return translate(flowName, language, true);
    }
    
    public static string getRandom(integer len)
    {
        final string chars = '0123456789';
        string ret ='';
        while(ret.length()<len)
        {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            ret += chars.substring(idx,idx+1);
        }
        return ret;
    }
    
    public static string sProgramId=null;  
    public static string translate(string str, string sLang)
    {
        return translate(str,sLang,false);
    }
    public static string translate(string str, string sLang,boolean bFlow)
    {

        // это не подходит потому что при появлении нового языка фактически надо править маппы в апексе, а это пользователь сам не сможет делать
        // , и по-этому если мы скажем ему что надо будет доплачивать за время разработчиков при появлении нового языка - клиент не поймет этого.
        //нужно сделать что-то типа такого. если будет несколько/много вызовов translate за один поток выполнения, то видимо надо добавить кеширование
        string sRet;
        string sFieldName = sLang+'__c';
        string sPrId = sProgramId.trim();
        string sKey = str.replaceAll('[^a-zA-Z0-9 -]','').trim();
        string sQuery = 'select Id, key__c, default_value__c, '+sFieldName+' from Translation__c where Loy_Program__c =\''+sPrId+'\' and key__c = \''+sKey+'\' and bFlow__c = '+bFlow;
        system.debug('translate.sQuery = '+sQuery);
        list<sobject> sObj = Database.query(sQuery);
        Translation__c tr;
        if(sObj.isEmpty())
        {
            tr = new Translation__c();         
            tr.Loy_Program__c = sPrId;
            tr.key__c = sKey; 
            tr.put(sFieldName,null);
            tr.bFlow__c = bFlow;
            if(tr.bFlow__c != true)
                tr.default_value__c = str;
            insert tr;
            sObj.add(tr);
        }
        else
        {
            tr = (Translation__c)sObj[0];
        }
        sRet = (string)tr.get(sFieldName);
        if(sRet == null || sRet == '')
        {
            if((tr.default_value__c != null && tr.default_value__c != '' )|| Test.isRunningTest()) // для флоу, если нет перевода, берем значение по-умолчанию
                sRet = tr.default_value__c;
            else 
                throw new MyException('Can not find translation for ['+sKey+'] in program ['+sProgramId+']');           
        }
        if(str.startsWith(' '))
            sRet = ' '+sRet;
        if(str.endsWith(' '))
            sRet = ''+sret+' ';
        return sRet;
        /*
string trstr;
if (language == 'ar')
trstr = Translator.toArab.get(str);
else if (language == 'Other')
trstr = Translator.toOther.get(str);
if (trstr != null && trstr != '')
return trstr;
else 
return str;*/
    }
    /* public String translate(String labelName, String language){
PageReference r = Page.ZLabelTranslator;
r.getParameters().put('label_lang', language);
r.getParameters().put('label', labelName);  
String labelValue = r.getContent().toString();
return labelValue;
}*/
    
    
}
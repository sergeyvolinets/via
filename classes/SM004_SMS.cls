public class SM004_SMS 
{   
    public static map<string,string> getAuthHeader()
    {
        map<string,string> headers = new map <string,string>();        
        String username = SM010_Utils.getValue('SMSLogin');
        String password = SM010_Utils.getValue('SMSPassword');
        Blob headerValue = Blob.valueOf(username+':'+password);
        headers.put('Authorization','Basic '+ EncodingUtil.base64Encode(headerValue));
        headers.put('Content-Type', 'application/json');
        return headers;        
    }

    public static string getBody(string phone,string code,string sfrom)
    {
        map<string,string> mret = new map<string,string>();
        mret.put('to', phone);
        mret.put('text', 'Your verification code is '+code);
        mret.put('from', sfrom);
        return JSON.serialize(mret);
    }
 
    @future(CallOut=true)
    public static void sendSms(string phone,string code,id memberId,string sfrom)
    {
        try
        {
            if (Test.isRunningTest())
                Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
            Object o = SM003_Http.request('https://api.infobip.com/sms/1/text/single', 'POST', SM004_SMS.getAuthHeader(), getBody(phone, code,sfrom), 'SMS', memberId);
        }
        catch( Exception ex)
        {
        } 
        finally
        {
            SM005_Logs.save();
        }
    }
}
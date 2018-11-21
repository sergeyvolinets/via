global class SM033_NexmoOut {

  global static void sendText(string sTo, string messageText,string sFrom)
    {
        if (Test.isRunningTest())
            Test.setMock(HttpCalloutMock.class, new SM004_SMSMock ());
        Object o = SM003_Http.request('https://api.nexmo.com/beta/messages', 'POST', getAuthHeader(sFrom), getBody(sTo, messageText,sFrom), 'NexmoOut', null);
    }
    
      @future(CallOut=true)   
    global static void sendTextAsync(string sTo, string messageText,string sFrom)
    {
        try
        {
            sendText(sTo,messageText,sFrom);
        }
        catch( Exception ex)
        {
        } 
        finally
        {
            SM005_Logs.save();
        }
    }
    @future(CallOut=true)      
    global static void sendTextAsync(string sTo, list<string> aMessageText,string sFrom)
    {
        sendText(sTo,aMessageText, sFrom);
    }
    
    
    global static void sendText(string sTo, list<string> aMessageText,string sFrom)
    {
        try
        {
            for(string messageText : aMessageText)
            {
                sendText(sTo,messageText,sFrom);
            }
        }
        catch( Exception ex)
        {
        } 
        finally
        {
            SM005_Logs.save();
        }
    }
    

    
/*    
          public static map<string,string> getAuthHeader()
    {
        map<string,string> headers = new map <string,string>();        
        headers.put('Authorization','Basic ZTA1M2E0MDA6M095SlIwalBzQ1lJYmxjZA==');
        headers.put('Content-Type', 'application/json');
        return headers;        
    }
*/
    
    public static map<string,string> getAuthHeader(string sPhone)
    {
        map<string,string> headers = new map <string,string>();  

		if(!Test.isRunningTest())
        {
            Auth__c a = Auth__c.getInstance(sPhone);
        headers.put('Authorization','Basic '+ EncodingUtil.base64Encode(Blob.valueOf(a.login__c +':'+a.password__c)));
//			headers.put('Authorization','Basic ZTA1M2E0MDA6M095SlIwalBzQ1lJYmxjZA==');
        }

        headers.put('Content-Type', 'application/json');
        return headers;           
    }
    
    
      /*
{
    "from": { "type": "whatsapp", "number": "447418342138" },
    "to": { "type": "whatsapp", "number": "380668657070" },
    "message": {
      "content": {
        "type": "text",
        "text": "This is a WhatsApp Message sent from the Messages API"
      }
    }
  }
*/
  public static string getBody(string sTo,string messageText,string sFrom)
    {
        map<string,object> mret = new map<string,object>();
        map<string,string> mFrom = new map<string,string>();
        mFrom.put('type','whatsapp');
        mFrom.put('number',sFrom);
 //       mFrom.put('number','447418342138');        
        mret.put('from', mFrom);
  
        
        map<string,string> mTo = new map<string,string>();
        mTo.put('type','whatsapp');
        mTo.put('number',sTo);
        mret.put('to', mTo);
        
        map<string,object> mMess = new map<string,object>();
        map<string,string> mCont = new map<string,string>(); 
        mCont.put('type', 'text');
        mCont.put('text', messageText);
        mMess.put('content',mCont);
        mret.put('message', mMess);
        return JSON.serialize(mret);
    }
    
}
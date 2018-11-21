public class SM032_DialogFlow {

    public class Resp
    {
        public string action;
        public map<string,string> parameters;
        public string speech;
        public list<string>messages;
            
    }
      public static map<string,string> getAuthHeader()
    {
        map<string,string> headers = new map <string,string>();        
        headers.put('Authorization','Bearer  9067755bfc3048a283052f73cffc25e0');
        headers.put('Content-Type', 'application/json');
        headers.put('charset','utf-8');
        return headers;        
    }
    
    
    
     public static string getBody(string messageText,string context,string lang)
    {
        map<string,object> mret = new map<string,object>();
        list<string>lcon = new list<string>();
        if(context != null)
        	lcon.add(context);
        mret.put('contexts',lcon);
        mret.put('lang',lang);
        mret.put('timezone','America/New_York');
        mret.put('query',messageText);
        mret.put('sessionId','12345'); 
        return JSON.serialize(mret);
    }
    
    
    public static SM032_DialogFlow.Resp parse(string jsonString)
    {
        SM032_DialogFlow.Resp ret = new SM032_DialogFlow.Resp();
        ret.messages = new list<string>();
        ret.parameters = new map<string,string>();
        Map<string,object>mObj = (Map<string,object>)JSON.deserializeUntyped(jsonString);
        map<string,object>mres = (map<string,object>)mObj.get('result');
        map<string,object>mFul = (map<string,object>)mres.get('fulfillment');   
        ret.speech = (string)mFul.get('speech');
        list<object>lobj = (list<object>)mFul.get('messages');
        for(object o: lObj)
        {
            map<string,object> mm = (map<string,object>)o;
            ret.messages.add((string)mm.get('speech'));
        }
        ret.action = (string)mRes.get('action');
  		map<string,object>mPar = (map<string,object>)mRes.get('parameters');
        for(string sParName: mPar.keySet())
        {
            ret.parameters.put(sParName, (string)mPar.get(sParName));
        }
        return ret;
        
    }
    
      public static SM032_DialogFlow.Resp query(string context, string messageText,string lang)
    {
        if (Test.isRunningTest())
            Test.setMock(HttpCalloutMock.class, new SM032_DialogFlowMock ());
        HttpResponse resp = SM003_Http.request('https://api.dialogflow.com/v1/query?v=20150910', 'POST', getAuthHeader(), getBody(messageText, context, lang), 'DialogFlow', null);
        return parse(resp.getBody());
    }  
}
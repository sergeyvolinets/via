public class SM033_URLShorter {

    
    public static string sKey = 'AIzaSyDLZJz2GIdfpKFAslKGHiOqMYBd1qGIJQ0';

      
          public static map<string,string> getAuthHeader()
    {
        map<string,string> headers = new map <string,string>();        
        headers.put('Content-Type', 'application/json');
        return headers;        
    }
    
    public static string getBody(string sURL)
    {
        map<string,object>mret = new map<string,object>();
        mret.put('longUrl',sURL);
        return JSON.serialize(mret);     
    }
    
    public static string parse(string jsonString)
    {
        Map<string,object>mObj = (Map<string,object>)JSON.deserializeUntyped(jsonString);
        return (string)mObj.get('id');
    }
    
    public static string accessToken;
    public static  String getAccessToken() {
        if(accessToken == null)
        {
            HttpResponse resp = SM003_Http.request('callout:Bitly/oauth/access_token', 'POST', null, '', 'bitlyAccesstoken', null);
            accessToken = (string)resp.getBody();
        }
        return accessToken;
    }
    
       public static string shorter(string sURL)
    {
  //      return sURL;
     	string sEndPoint =  ' https://www.googleapis.com/urlshortener/v1/url?key='+sKey 
		;
if (Test.isRunningTest())
            Test.setMock(HttpCalloutMock.class, new SM032_DialogFlowMock ());
        HttpResponse resp = SM003_Http.request(sEndPoint, 'POST', getAuthHeader(), getBody(sURL), 'urlShorter', null);
        
        return parse((string)resp.getBody()); 
    }
 /*   
    public static string shorter2(string sURL)
    {
  //      return sURL;
     	string sEndPoint =  'callout:Bitly/v3/shorten?access_token=' 
            		+ getAccessToken() 
            		+'&longUrl=' + EncodingUtil.urlEncode( sURL, 'UTF-8' ) 
            		+'&format=txt';
        if (Test.isRunningTest())
            Test.setMock(HttpCalloutMock.class, new SM032_DialogFlowMock ());
        HttpResponse resp = SM003_Http.request(sEndPoint, 'GET', null, '', 'urlShorter', null);
        
        return (string)resp.getBody(); 
    }*/
}
public class SM003_Http 
{

    Public Static Integer TIMEOUT = 100000; // IMO-3716 // Default HTTP Timeout

    Public Static HttpRequest buildRequest(map<String,String> headers, String url, String method, String body){
        HttpRequest request = new HttpRequest();
        request.setTimeout(TIMEOUT); // timeout in milliseconds 
        if (headers != null) {
            for(String hkey : headers.keySet()){
                request.setHeader(hkey, headers.get(hkey)); 
            }   
        }
        
        request.setEndpoint(url);
        request.setMethod(method);
        if (body != null && body.length() > 0) {
            request.setBody(body);
        }
        return request;
    }
    
    Public static HttpResponse request(String url, String method, Map<String,String> headers, String body,string callType, string recId)   
    {
                 Http h = new Http();
        HttpRequest request = buildRequest(headers, url, method.toUpperCase(), body);        
        HttpResponse response;
        string sStatus = '';
        string sStatusCode = '';
        DateTime dtBeg = DateTime.now();
        DateTime dtEnd;
        string sErrorMessage = '';
        try
        {
//            log('Request', request, getBodyForLog(request,callType));
            dtBeg = DateTime.now();
            response = h.send(request);
            dtEnd = DateTime.now();
            sStatusCode = ''+ response.getStatusCode();
            if (response.getStatusCode() > 299) {
                system.debug('SM001_Rest_Client: Failed to recieve a success code from remote. Code was: ' + response.getStatusCode() + ' request was ' + request + ' Response Body is: ' + response.getBody());
                throw new MyException(response.getBody());
            }
            sStatus = 'Success';
        }catch(Exception e)
        {
            if(dtEnd == null)
            {
                dtEnd = DateTime.now();
            }
            sStatus = 'Error';
            sErrorMessage = e.getMessage();
            if(sErrorMessage != null && sErrorMessage.length()>254)
            {
                sErrorMessage = sErrorMessage.substring(0, 253);
            }
            throw e;
        }
        finally
        {
            SM005_Logs.LogCallOut(recId,callType, request.getBody(),  response.getBody(),  dtBeg,  dtEnd, sErrorMessage);
        }
        return response;    
    }
    

}
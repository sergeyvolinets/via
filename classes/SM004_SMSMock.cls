global class SM004_SMSMock implements HttpCalloutMock
{
    global static HTTPResponse respond(HTTPRequest req) 
    {
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        String reqBody = req.getBody();
        string bodyResp = '';//JSON.serialize();
        
        res.setBody(bodyResp);
        return res;
    }
}
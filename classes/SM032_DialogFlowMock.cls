global class SM032_DialogFlowMock  implements HttpCalloutMock
{
   global static HTTPResponse respond(HTTPRequest req) 
   {
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        String reqBody = req.getBody();
        string bodyResp =    '{"id": "6d491e3f-cbdb-4115-854a-0da5832483d0","timestamp": "2018-11-18T11:27:32.898Z","lang": "en","result": {"source": "agent","resolvedQuery": "Do you know Louloua?","action": "input.unknown","actionIncomplete": false,"parameters": {},"contexts": [{"name": "menu","parameters": {},"lifespan": 4}],"metadata": {"intentId": "8fe7ef57-73d2-4b7e-95ba-b34c819382c8","webhookUsed": "false","webhookForSlotFillingUsed": "false",'+
'"isFallbackIntent": "true","intentName": "Default Fallback Intent"},"fulfillment": {"speech": "Sorry, I didn\'t get that. Can you rephrase?","messages": [{"type": "simple_response","platform": "google","textToSpeech": "Resp"},{"type": "basic_card","platform": "google","formattedText": "test","buttons": []},{"type": 0,"speech": "Say that one more time?"}]},"score": 1.0},"status": {"code": 200,"errorType": "success"},"sessionId": "12345"}}';        
        res.setBody(bodyResp);
        return res;
    }
}
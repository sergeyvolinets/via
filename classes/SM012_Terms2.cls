/*
 * this class provides REST CRUD for reedem voucher html page
 */
@RestResource(urlMapping='/terms2/*')

global class SM012_Terms2 {

    
      global class Response
    {
        public promo_campaign__c camp{get;set;}
        public string errorCode {get;set;}
        public string errorMessage {get;set;}
        public Response()
        {
            errorCode = '';
            errorMessage = '';
        }
    }
    
           @HttpGet
    global static Response doGet()
    {
        Response resp = new Response();
        try
        {
            string voucherId = (string)RestContext.request.params.get('id');    
            resp.camp = DM001_Voucher.getTerms2(voucherId);
            if(resp.camp.Terms_And_Conditions__c != null)
				resp.camp.Terms_And_Conditions__c = resp.camp.Terms_And_Conditions__c.unescapeHtml4().unescapeXml().replace('<br>','.').replace('-','');
        }catch(Exception ex)
        {
            resp.errorCode = '1';
            resp.errorMessage = ex.getMessage();
        }
        return resp;
    }
}
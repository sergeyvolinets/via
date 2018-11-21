@RestResource(urlMapping='/program/*')
global class SM014_LoyProgram 
{
    
        global class ProgramResponse
    {
        public CVL__Loy_Program__c  program{get;set;}
        public string errorCode {get;set;}
        public string errorMessage {get;set;}
        public ProgramResponse()
        {
            errorCode = '';
            errorMessage = '';
        }
    }

	@HttpGet
    global static ProgramResponse doGet()
    {
        ProgramResponse resp = new ProgramResponse();
        try
        {
            string sId = (string)RestContext.request.params.get('id');    
            resp.program = DM002_Program.getRecord(sId);
        }catch(Exception ex)
        {
            resp.errorCode = '1';
            resp.errorMessage = ex.getMessage();
        }
        return resp;
    }
}
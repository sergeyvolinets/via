/*
 * this class provides REST CRUD for reedem voucher html page
 */
@RestResource(urlMapping='/terms/*')

global class SM012_Terms 
{
 
           @HttpGet
    global static SM012_Voucher.VoucherResponse doGet()
    {
        SM012_Voucher.VoucherResponse resp = new SM012_Voucher.VoucherResponse();
        try
        {
            integer i=0;
            i++;
            i++;
            i++;
            string voucherId = (string)RestContext.request.params.get('id');    
            resp.voucher = DM001_Voucher.getTerms(voucherId);
        }catch(Exception ex)
        {
            resp.errorCode = '1';
            resp.errorMessage = ex.getMessage();
        }
        return resp;
    }
}
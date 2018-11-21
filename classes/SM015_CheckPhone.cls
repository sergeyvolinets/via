@RestResource(urlMapping='/check/*')
global class SM015_CheckPhone 
{
 @HttpGet
	global static chat2AI.Resp getResponse()
    {
        string sErr = '';
        chat2AI.Resp ret = null;
        try
        {
            object obj = RestContext.request.params;
            string sPhone = SM010_Utils.getRestParam('phone');
         	string sProgramId = SM010_Utils.getRestParam('program');
            if(sProgramId == null || sProgramId.trim()=='')
            {
                sProgramId = SM010_Utils.getValue('Default_Program_Id');
            }
            
            integer iTab =0;
             sPhone = sPhone.trim();
            string sPhone2 = '%'+sPhone;
      //      list<account> lacc = [select id from account where Phone like  :sPhone2];
      		list< CVL__Loy_Member__c> lacc = [select id from CVL__Loy_Member__c  where CVL__Account__r.Phone  like  :sPhone2 and CVL__Program__c  = :sProgramId];
            if(lacc.isEmpty())
                ret = SM007_engatiRest.register(sphone,sProgramId,'en');
            else
                ret = SM007_engatiRest.gotoFlow('getPin',sProgramId);
        }catch(Exception e)
        {
            sErr = ''+e.getLineNumber()+' '+e.getMessage();
        }
        SM005_Logs.LogCallOut(null,'chat2AIcheck', JSON.serialize(RestContext.request.params), JSON.serialize(ret), DateTime.now(), DateTime.now(),sErr);
        SM005_Logs.save();
        return ret;
    }
}
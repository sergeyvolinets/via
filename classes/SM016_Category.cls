@RestResource(urlMapping='/category/*')
global class SM016_Category {
    @HttpGet
	global static chat2AI.Resp getResponse()
    {
        string sLang = SM010_Utils.getRestParam('language');
        string sProgramId = SM010_Utils.getRestParam('program');
        if(sProgramId == null || sProgramId.trim()=='')
                sProgramId = SM010_Utils.getValue('Default_Program_Id');
        if(sLang == null || sLang == '')
                sLang = 'en';
        string sErr = '';
        chat2AI.Resp ret = new chat2AI.Resp();
		SM010_Utils.sProgramId = sProgramId;
        SM010_Utils.lang = sLang;
        try
        {
         	AggregateResult[] lres= [select category__c from category__c group by category__c];           
            ret.data.type = 'msg_options';
            ret.data.text = 'Please chose your category:';
			for(AggregateResult res : lres)
            {
                string cat = (string)res.get('Category__c');
                chat2AI.Option opt = new chat2AI.Option();
                opt.text = cat;
                opt.postback = 'flow_'+SM010_Utils.getFlowId('SubCategory',sProgramId,sLang)+'||cat='+cat;
                ret.data.options.add(opt);
            }
        }catch(Exception e)
        {
            sErr = ''+e.getLineNumber()+' '+e.getMessage();
            if(Test.isRunningTest())
                throw e;
        }
        SM005_Logs.LogCallOut(null,'category', JSON.serialize(RestContext.request.params), JSON.serialize(ret), DateTime.now(), DateTime.now(),sErr);
        SM005_Logs.save();
        return ret;
    } 
}
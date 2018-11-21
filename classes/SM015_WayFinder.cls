@RestResource(urlMapping='/wayfinder/*')
global class SM015_WayFinder {
   @HttpGet
	global static chat2AI.Resp getResponse()
    {
        string sErr = '';
        chat2AI.Resp ret = null;
        try
        {
            object obj = RestContext.request.params;
            string sAccId = SM010_Utils.getRestParam('sAccId');
            string sPhone = SM010_Utils.getRestParam('phone');
            string spass = SM010_Utils.getRestParam('pass');
            string sEmail = SM010_Utils.getRestParam('email');
            string sfrom = SM010_Utils.getRestParam('from');
            string sto = SM010_Utils.getRestParam('to');
            if(true)
            {
                //       	ret=gotoFlow('debug',new map<string,string>{'p1'=>sAccId,'p2'=>sPhone,'p3'=>sEmail});              
            }
                ret=getWay(sFrom,sTo);
        }catch(Exception e)
        {
            sErr = ''+e.getLineNumber()+' '+e.getMessage();
        }
        SM005_Logs.LogCallOut(null,'wayfinder', JSON.serialize(RestContext.request.params), JSON.serialize(ret), DateTime.now(), DateTime.now(),sErr);
        SM005_Logs.save();
        return ret;
    }
  
    public static chat2AI.Resp getWay(string sFrom, string sTo)
    {
        
        chat2AI.Resp ret = new chat2AI.Resp();  
        ret.data.type = 'carousel';

        chat2AI.Template temp = new chat2AI.Template();
        temp.title = 'Wayfinder';
        temp.image_url = SM010_Utils.getValue('wayImage');
        temp.Subtitle = 'your way from '+sFrom+' to '+sTo;
        chat2AI.Button but = new chat2AI.Button();
        string sUrl = 'http://static.3dwayfinder.com/projects/07e5828d3441e5c002c7ac2bb9b201f0/Frame/?source='+sFrom+'&destination='+sTo;
//        string sUrl = 'http://static.3dwayfinder.com/projects/94d921a4e23e79634cd110483e6796a7/Frame/?source='+sFrom+'&destination='+sTo;
        but.payload = sUrl;
        but.title = 'Show';
        but.type = 'web_url';
        temp.buttons.add(but);

        temp.default_action.type = 'web_url';
        temp.default_action.url = sUrl;
        ret.data.templates.add(temp);
        
        system.debug('ret '+ret);
        return ret;       
    }
}
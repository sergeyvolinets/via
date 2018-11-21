public class SM030_Image {
 @AuraEnabled   
    public static string getImage(String recordId) {
        string sRet = '';
        if(recordId.indexOf('001')==0)
        {
            account acc = [ select image__c from account where id = :recordId];
            sRet = acc.image__c;
        } else if(recordId.indexOf('a06')==0)
        {
            CVL__Loy_Program__c pr = [select Logo__c from CVL__Loy_Program__c where  id = :recordId];
            sRet = pr.Logo__c;
        }
        else if(recordId.indexOf('a0F') == 0)
        {
            
            Promo_Campaign__c  pc = [select Image__c from Promo_Campaign__c where  id = :recordId];
            sRet = pc.Image__c;
          
        }
        return sRet;

    }
    
    @AuraEnabled
    public static string saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
/*       Attachment a = new Attachment();
        a.parentId = parentId;
        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;
        insert a;  */
        
		Document d = new document();
        d.Body = EncodingUtil.base64Decode(base64Data);
        d.IsInternalUseOnly = false;
        d.ContentType = contentType;
        d.IsPublic = true;
        d.FolderId = [select id from folder where name = 'Shared Documents' limit 1].id;
        d.Name = fileName;
		insert d;
        
        
		string domain = SM010_Utils.getValue('Domain2');
        string sImageURL =  domain+'/servlet/servlet.FileDownload?file='+d.Id;
        string sParId = parentId;
        if(sParId.indexOf('001')==0)
        {
            account acc = new account();
            acc.id = parentId;
            acc.Image__c =sImageURL;
            update acc;           
        }
        else if(sParId.indexOf('a06')==0)
        {
            CVL__Loy_Program__c pr = new CVL__Loy_Program__c ();
            pr.id = parentId;
            pr.Logo__c = sImageURL;
            update pr;
        }
        else if(sParId.indexOf('a0F') == 0)
        {
            Promo_Campaign__c  pc = new Promo_Campaign__c ();
            pc.id = parentId;
            pc.Image__c = sImageURL;
            update pc;           
        }
        system.debug('sImageURL '+sImageURL);
        return sImageURL;
    }
}
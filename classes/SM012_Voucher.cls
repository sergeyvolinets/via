/*
 * this class provides REST CRUD for reedem voucher html page
 */
@RestResource(urlMapping='/voucher2/*')
global class SM012_Voucher 
{
    global class VoucherResponse
    {
        public Member__c voucher{get;set;}
        public integer ticketsCnt {get;set;}
        public string errorCode {get;set;}
        public string errorMessage {get;set;}
        public VoucherResponse()
        {
            errorCode = '';
            errorMessage = '';
        }
    }
    
        global class ReedemResponse
    {
        public string errorCode {get;set;}
        public string errorMessage {get;set;}
        public id txnId {get;set;}
        public id voucherId {get;set;}
        public string voucherCode {get;set;}
        public ReedemResponse()
        {
            errorCode = '';
            errorMessage = '';
        }
    }
    
        @HttpGet
    global static VoucherResponse doGet()
    {
        VoucherResponse resp = new VoucherResponse();
        try
        {
            string voucherId = (string)RestContext.request.params.get('id');    
            resp.voucher = DM001_Voucher.getRecord(voucherId);
            validate(resp.voucher);

        }catch(Exception ex)
        {
            resp.errorCode = '1';
            resp.errorMessage = ex.getMessage();
        }
        return resp;
    }
    
    public static void validate(Member__c voucher)
    {
        if(voucher.promo_campaign__r.Number_of_Coupons_per_Member__c != null)
        {
            if(voucher.Coupons_Issued__c>=voucher.promo_campaign__r.Number_of_Coupons_per_Member__c)
            {
                throw new MyException('You can not use this coupon since you have used it already.');         
            }            
        }
        if(voucher.Promo_Campaign__r.Availability_DateTime__c != null)
        {
            if(BusinessHours.isWithin(voucher.Promo_Campaign__r.Availability_DateTime__c,system.Datetime.now()) == false)
            {
                throw new MyException('The coupon availability date time is '+voucher.Promo_Campaign__r.Availability_DateTime__r.Name+', so it can\'t be used at the moment.');                     
            }
        }
    }
    
    @HttpPost
    global static ReedemResponse doReedem()
    {
        string voucherId = (string)RestContext.request.params.get('id');   
        decimal dVal = decimal.valueOf(RestContext.request.params.get('amount')); 
        string pin = (string)RestContext.request.params.get('pin'); 
        //integer qt = integer.valueOf(RestContext.request.params.get('qt'));
        ReedemResponse resp = new ReedemResponse();
        try
        {
            resp.txnId = doReedem2(voucherId,dVal,pin,false,1);
        }catch(Exception ex)
        {
            resp.errorCode = '1';
            resp.errorMessage = ex.getMessage();
        }
        return resp;
    }
    
    global static id doReedem2(id voucherId, decimal dVal, string sPIN,boolean bRetLoyMember, integer qt)
    {  
       if(qt == null || qt == 0)
           qt = 1;
        CVL__Loy_Transaction__c tr;
        CVL__Loy_Transaction__c tr2;
        Member__c  voucher = DM001_Voucher.getRecord(voucherId);
        validate(voucher);
        Member__c mem = voucher;
        // добавить поиск promo campaign сюда?
        string loyMemId = null;
        if(voucher.Promo_Campaign__r.Minimum_Purchase_Amount__c != null && dVal < voucher.Promo_Campaign__r.Minimum_Purchase_Amount__c)
        {
            throw new MyException( 'The Purchase Amount is not enough to Reedem. The minimal amount is '+voucher.Promo_Campaign__r.Minimum_Purchase_Amount__c+'.');                     
        }
        CVL__Loy_Member__c lmem = null;
        if(mem.Promo_Campaign__r.Loy_Program__c != null)
        {
            list<CVL__Loy_Member__c> llmem = [select id,CVL__Points_2__c from CVL__Loy_Member__c  where CVL__Program__c = :mem.Promo_Campaign__r.Loy_Program__c and CVL__Account__c = :mem.Customer__c];
            
            if(!llmem.isEmpty())
            {
                lmem = llmem[0];
            }
        }
  
		id outletId = null;
        if(sPIN == null)
        {
            outletId = voucher.Promo_Campaign__r.Default_Outlet__c;
        }
        else
        {
            list<Campaign_Outlet__c> lbrand = [select id,account__c from Campaign_Outlet__c where account__r.PIN__c = :sPIN and Promo_Campaign__c = :mem.Promo_Campaign__c];
            if(lbrand.size() == 0)
            {
                throw new MyException( 'Provided PIN is invalid.');                 
            }
            outletId = lbrand[0].account__c;           
        }
 
        if(mem.Coupons_Issued__c == null)
        {
            mem.Coupons_Issued__c = 0;
        }
        mem.Coupons_Issued__c +=1;
        if(mem.Coupons_Issued__c >= mem.Promo_Campaign__r.Number_of_Coupons_per_Member__c)
        {
            mem.Status__c = 'Used';
            map<id,member__c> mid = new  map<id,member__c> ();
            list< Promo_Rel__c> lRel = [select id,Next_Campaign__c,Next_Campaign__r.Number_of_Coupons_per_Member__c  from Promo_Rel__c where Next_Campaign__c <> null AND Prev_Campaign__c  = :mem.Promo_Campaign__c];
            for(Promo_Rel__c rel :lRel)
            {
                mid.put(rel.Next_Campaign__c, null);
            }
            list<member__c> lmem2 = [select id ,Promo_Campaign__c from member__c where Promo_Campaign__c in :mid.keySet() and customer__c = :mem.Customer__c];
            for(member__c mem2 : lmem2)
            {
                mid.put(mem2.Promo_Campaign__c, mem2);
            }
            list<member__c> lins = new list<member__c>();
            for(id campId :mid.keySet())
            {
                member__c mem3 = mid.get(campId);
                if(mem3 == null)
                {
                    mem3 = new member__C();
                    mem3.Customer__c = mem.Customer__c;
                    mem3.Promo_Campaign__c = campId;
                    lins.add(mem3);
                }
            }
            if(!lins.isEmpty())
                insert lins;
        }
        else
        {
            mem.Status__c = 'Active';                
        }
        if(lmem!= null && mem.Loy_Member__c == null)
        	mem.Loy_Member__c =lmem.id;
        update mem;
        
        Promo_Campaign__c camp = [select id,Total_Coupon_Inventory__c  from Promo_Campaign__c where id = :mem.Promo_Campaign__c];
        if(camp.Total_Coupon_Inventory__c == null)
            camp.Total_Coupon_Inventory__c =0;
        camp.Total_Coupon_Inventory__c -=1;
        update camp;
        
        if(mem.Promo_Campaign__r.Loy_Program__c != null)
        {
            if(lmem == null)
            {
                if(mem.Promo_Campaign__r.Auto_Register_Loyalty_Member__c == true)
                {
                    //Promo_Campaign__c camp1 = new Promo_Campaign__c();
                    //camp1 = [select id from Promo_Campaign__c where RecordType.name = 'New Member Welcome'];
                    lmem = new    CVL__Loy_Member__c();
                    //if (camp1!=null)
                    //    lmem.CVL__Program__c = camp1.Loy_Program__c;
                    //else    
                    lmem.CVL__Program__c = mem.Promo_Campaign__r.Loy_Program__c;
                    lmem.CVL__Account__c  = mem.Customer__c;
                    lmem.CVL__Joined_Date__c = date.today();
					lmem.CVL__Points_2__c =0;                  
                    
                    insert lmem;   
                    // ошибка при execute anonimous 87 SM001_DataFactory (вставляется Flow с заданным именем, и такой уже есть)
                    // есть Member__c и CVL__Loy_Member__c , у Member есть master-detail с PromoCampaign а у Loy Member нет. 
                    // lmem.Promo_Campaign__c = mem.Promo_Campaign__r.id;
                    // TODO добавить поиск Promo Campaign с типом New Member Welcome и если такая есть, то добавлять ее новому Участнику Программы лояльности VIAF-13
                }
            }
            if(lmem.CVL__Points_2__c <dVal*qt)
				throw new MyException( 'Not enough points.');     
            
            decimal dNetTotal = dVal*qt;
            if(mem.Promo_Campaign__r.Discount__c != null && mem.Promo_Campaign__r.Discount__c != 0)
            {
                dNetTotal = dVal*(1-mem.Promo_Campaign__r.Discount__c/100)*qt;
            }
            if(mem.Promo_Campaign__r.Discount_Amount__c != null && mem.Promo_Campaign__r.Discount_Amount__c != 0)
            {
                dNetTotal = (dNetTotal - mem.Promo_Campaign__r.Discount_Amount__c)*qt;
            }
            id parTranId = null;
            if(dNetTotal >0)
            {
                loyMemId = lmem.id;
                tr = new CVL__Loy_Transaction__c();
                tr.Base_Amount__c = dVal;
                tr.Net_Amount__c = dNetTotal;
                tr.Discount__c = mem.Promo_Campaign__r.Discount__c;
                tr.CVL__Points__c = dNetTotal;
                tr.CVL__Type__c = 'Accural';
                tr.CVL__Status__c = 'Queued';
                tr.CVL__Member__c = lmem.id;
                tr.Voucher__c =mem.id;
                tr.Account__c = outletId;
                SM012_Voucher.updateVisits(new list<CVL__Loy_Transaction__c> {tr});
                insert tr; 
                parTranId = tr.id;
            }
            
            
            if((mem.Promo_Campaign__r.Reedem_Amount__c != null && mem.Promo_Campaign__r.Reedem_Amount__c != 0 )
               || (mem.Promo_Campaign__r.Reedem_Rate__c != null && mem.Promo_Campaign__r.Reedem_Rate__c != 0 ))
            {
                tr2 = new CVL__Loy_Transaction__c();
                tr2.Parent_Transaction__c = parTranId;
                decimal points2 = 0;
                if(mem.Promo_Campaign__r.Reedem_Amount__c != null && mem.Promo_Campaign__r.Reedem_Amount__c != 0 )
                    points2 -= mem.Promo_Campaign__r.Reedem_Amount__c*qt;
                if(mem.Promo_Campaign__r.Reedem_Rate__c != null && mem.Promo_Campaign__r.Reedem_Rate__c != 0 )
                    points2 -= dNetTotal * mem.Promo_Campaign__r.Reedem_Rate__c;
                tr2.CVL__Points__c = points2;
                tr2.CVL__Type__c = 'Redemption';
                tr2.CVL__Status__c = 'Queued';
                tr2.CVL__Member__c = lmem.id;
                tr2.Voucher__c =mem.id;
                tr2.Account__c = outletId;
                if(lmem.CVL__Points_2__c +tr2.CVL__Points__c<0)
                    throw new MyException( 'Not enough points.');                 
                insert tr2;                      
            }
            
        }
        if(bRetLoyMember)
            return loyMemId;
        else if (tr != null)
        	return tr.id;
        else if(tr2 != null)
            return tr2.id;
        return null;
    }
    
    public static void updateVisits(list<CVL__Loy_Transaction__c> ltr)
    {
        List <CVL__Loy_Transaction__c> lStatusQueued = new List<CVL__Loy_Transaction__c>();
        set<id> sOutletId = new set<id>();
        set<id> sMemId = new set<id>();
        for(CVL__Loy_Transaction__c tr :ltr)
        {
            if(tr.CVL__Type__c != 'Accural')
                continue;
            tr.New_visit__c = 0;
            if(tr.Account__c != null)
            {
                sOutletId.add(tr.Account__c);
                sMemId.add(tr.CVL__Member__c);
            }
        }
        if(!sOutletId.isEmpty())
        {
            list<Outlet_Visit__c> lVis = DM003_Visits.getVisits(sMemId,sOutletId);
            map<string,Outlet_Visit__c> mVis = new map<string,Outlet_Visit__c>();
            for(Outlet_Visit__c vis :lVis)
            {
                mVis.put(''+vis.Loy_Member__c+'_'+vis.Outlet__c,vis);
            }
            map<string,Outlet_Visit__c> mUpsert = new map<string,Outlet_Visit__c>();
            for(CVL__Loy_Transaction__c tr :ltr)
            {
                if(tr.Account__c != null)
                {
                    string sKey = ''+tr.CVL__Member__c+'_'+tr.Account__c;
                    Outlet_Visit__c vis = mVis.get(sKey);
                    if(vis == null)
                    {
                        vis = new Outlet_Visit__c();
                        vis.Outlet__c = tr.Account__c;
                        vis.Loy_Member__c = tr.CVL__Member__c;
                        vis.Visits__c =0;
                        mVis.put(''+vis.Loy_Member__c+'_'+vis.Outlet__c,vis);
                        tr.New_visit__c = 1;
                    }
                    else if(vis.Active_Flag__c == false)
                        tr.New_visit__c = 1;    
                    vis.Active_Flag__c = true;
                    vis.Visits__c =vis.Visits__c +1;
                    mUpsert.put(sKey, vis);
                }
            }
            if(!mUpsert.isEmpty())
                upsert mUpsert.values();
        }
    }

}
public class SM001_DataFactory 
{
    public recordtype custType;
    public recordtype brandType;
    public recordtype outletType;    
    public account brand;
    public account outlet;    
    public account cust;
    public account cust2;
    public Promo_Campaign__c  camp;
    public Promo_Campaign__c  camp2;    
    public Member__c mem;
    public Member__c mem2;    
    public Campaign_Outlet__c campout;
    public CVL__Loy_Program__c prog;
    public CVL__Loy_Program__c prog2;    
    public CVL__Loy_Tier__c tier;
    public CVL__Loy_Member__c lmem;
    public SM001_DataFactory()
    {
        Initialize();
    }
    public void Initialize()
    {
        custType = [select id,name, sobjecttype from recordtype where sobjecttype = 'Account' and name = 'Customer'];
        brandType = [select id,name, sobjecttype from recordtype where sobjecttype = 'Account' and name = 'Brand'];  
        outletType = [select id,name, sobjecttype from recordtype where sobjecttype = 'Account' and name = 'Outlet'];
        brand = new account(name= 'brand1',recordtypeid = brandType.id,PIN__c ='111');
        insert brand;
        cust = new account(name = 'cust1',recordtypeid = custType.id,phone = '12345');
        insert cust;
 
        cust2 = new account(name = 'cust2',recordtypeid = custType.id,phone = '23456');
        insert cust2;
        
        prog = new CVL__Loy_Program__c ();
        prog.Name = 'prog123';
        insert prog;
        
        tier = new CVL__Loy_Tier__c();
        tier.CVL__Upper_Limit_Of_The_Range__c=10000;
        tier.CVL__Lower_End_Of_The_Range__c=0;
        tier.CVL__Program__c=prog.id;
        tier.CVL__Discount__c=0;
        
        insert tier;
        prog.Loy_Tier__c = tier.id;
        update prog;
        outlet = new account(name=  'outlet1', recordtypeid = outletType.id,PIN__c ='1111');
        outlet.Loy_Program__c = prog.id;
        insert outlet;
        
        Category__c cat = new Category__c ();
        cat.Category__c = 'Category1';
        cat.Account__c = outlet.id;
        insert cat;
        
        prog2 = new CVL__Loy_Program__c ();
        prog2.Name = 'prog234';
        insert prog2;
			        
        camp = new Promo_Campaign__c ();
        camp.name = 'voucher1';
        camp.Auto_Register_Loyalty_Member__c = true;
        camp.Loy_Program__c = prog.id;
        camp.Discount__c = 1;
        camp.Discount_Amount__c = 1;        
        camp.Reedem_Amount__c =10;
        camp.Reedem_Rate__c = 0.01;
        camp.Total_Coupon_Inventory__c = 10;
        insert camp;
        
        camp2 = new Promo_Campaign__c ();
        camp2.name = 'voucher2';
        camp2.Auto_Register_Loyalty_Member__c = true;
        camp2.Loy_Program__c = prog.id;
        camp2.Total_Coupon_Inventory__c = 10;
        camp2.Parent_Promo_Campaign__c = camp.Id;
        insert camp2;
        
        Promo_Rel__c rel = new Promo_Rel__c();
        rel.Prev_Campaign__c = camp.id;
        rel.Next_Campaign__c = camp2.id;
        insert rel;
        
        list<Member__c> mems = new list<Member__c>();
        for(integer i =0;i<25; i++)
        {
            mem = new Member__c();
            mem.name = 'm'+i;
            mem.Promo_Campaign__c = camp.id;
            mem.Customer__c = cust.id;
            mems.add(mem);
        }

        mem2 = new Member__c();
        mem2.Promo_Campaign__c = camp.id;
        mem2.Customer__c = cust2.id;
        mems.add(mem2);
        
        insert mems;
        
        campout = new Campaign_Outlet__c();
        campout.Account__c = brand.id;
        campout.Promo_Campaign__c = camp.id;
        insert campout;
        
		campout = new Campaign_Outlet__c();
        campout.Account__c = brand.id;
        campout.Promo_Campaign__c = camp2.id;
        insert campout;
        
        Flow__c f = new Flow__c();
        f.Name = 'getPromotions';
        insert f;
        
   
         
        lmem = new CVL__Loy_Member__c();
        lmem.CVL__Account__c = cust.id;
        lmem.CVL__Program__c = prog.id;
        lmem.CVL__Points_2__c = 20000;
        lmem.PIN__c = '1111';
        insert lmem;
    }

}
({
    doInit : function(component,event)
    {
        var recordId = component.get("v.recordId");    
        var actionCfg = component.get("c.getReportNames");

        actionCfg.setParams({"recordId" : recordId});     
        actionCfg.setCallback(this, function(response){
            console.log('inside callback actionCfg');
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.reports",response.getReturnValue());
            }
            console.log('finished callback actionCfg');
        });
        $A.enqueueAction(actionCfg);
    },
    doSave : function(component,event)
    {
        var recordId = component.get("v.recordId");  
//        alert('recordId = '+recordId);
        var sRepName = component.get("v.sRepName");         
        var actSave = component.get("c.saveCampMembers");
//        alert('recordId = '+recordId+ ' srepName = '+sRepName);        
        actSave.setParams({ "recordId" : recordId, "sRepName" : sRepName});     
        actSave.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(actSave);
    }
})
({
    doInit : function(component)
    {
        var recordId = component.get("v.recordId");    
        var actionImg = component.get("c.getImage");
              
        actionImg.setParams({ "recordId" : recordId});
        actionImg.setCallback(this, function(response){
            var state = response.getState();
			console.log('inside callback actionImg state '+state);
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.image",response.getReturnValue());
				console.log('finished callback actionImg '+response.getReturnValue());
            }

        });
        $A.enqueueAction(actionImg);
    },
    
    saveFile: function(component,event) {
		console.log('saveFile start');    
        var f = event.target.files[0];
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        var r = new FileReader();
        r.onload = function(e) {
            var contents = e.target.result;
            var base64Mark = 'base64,';
            var dataStart = contents.indexOf(base64Mark) + base64Mark.length;
            var fileContents = contents.substring(dataStart);
            var action = component.get("c.saveTheFile");
            action.setParams({
                parentId: component.get("v.recordId"),
                fileName: f.name,
                base64Data: encodeURIComponent(fileContents),
                contentType: file.type
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('saveFile state '+state);                
                if (component.isValid() && state === "SUCCESS") {
                    component.set("v.image",response.getReturnValue());
                    console.log('finished callback saveFile '+response.getReturnValue());
                }});
            $A.enqueueAction(action);
        }
        r.readAsDataURL(file);
    }
})
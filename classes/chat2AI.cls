global class chat2AI 
{
    global class Button 
    {
        webService string payload {get;set;}
        webservice string title {get;set;}   
        webservice string type {get;set;}
        public Button()
        {
            payload = '';
            title = '';
            type = '';
        }
    }  
    
    global class Action 
    {
        webService string url {get;set;}
        webservice string type {get;set;}
        public Action()
        {
            url = '';
            type = '';
        }
    }
    
    global class Template 
    {
        webService string title {get;set;}  
        webService string image_url {get;set;}  
        webservice list<Button> buttons {get;set;}  
        webService string subtitle {get;set;}         
        webservice Action default_action {get;set;}  
        public Template()
        {
            buttons = new list<Button>();
            default_action = new Action();
            title = '';
            image_url = '';
            subtitle = '';
        }
    }
    
    global class Option
    {
         webService string text {get;set;}
         webService string postback {get;set;}     
        public Option()
        {  
            text = '';
            postback = '';
        }
    }
    
    
    
    global class Data 
    {
        webService string type {get;set;}
        webservice list<Template> templates {get;set;}  
        webservice list<Option> options {get;set;}          
        webservice string path_to_follow {get;set;} 
        webservice string text{get;set;}
        public Data()
        {
            templates = new list<Template>();
            path_to_follow = '';
            text = '';
            type = '';
            options = new list<Option>();
        }
    }
    
    global class Attr
    {
        webService string name {get;set;}
        webService string value {get;set;}
        public Attr()
        {
            name = '';
            value = '';
        }
    }
    
    global class Resp
    {
        webService Data data {get;set;}
        webService list<Attr> attributes  {get;set;}
        public Resp()
        {
            data = new Data();
            attributes = new list<Attr>();
        }
    }

}
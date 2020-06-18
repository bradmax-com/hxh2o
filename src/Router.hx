package;

typedef RoutePart = {
    @:optional var subRoutes:Map<String, RoutePart>;
    @:optional var callback:Map<String, Dynamic>->Dynamic->Dynamic->Void;
    @:optional var variableName:String;
};

class Router<I,O>{
    var routes:RoutePart = {
        subRoutes: new Map<String, RoutePart>(),
        callback: null
    };
    
    public function new(){}
    
    public function print(?r:RoutePart = null, ?path:String = ""){
        if(r == null)
            r = routes;
        
        if(r.callback != null)
            Sys.println(path);
        
        if(r.subRoutes == null)
            return;
        
        var keys = r.subRoutes.keys();
            
        for(i in keys){
            var sub = r.subRoutes.get(i);
            print(sub, path + "/" + i);
        } 
    }
    
    public function addRoute(path:String, func:Map<String, Dynamic>->I->O->Void){
        var apath:Array<String> = path.split("/");
        var currentRoute = routes.subRoutes;
        
        while(apath.length > 0){
            var name = apath.shift();
            var last = apath.length == 0;
            var variableName:String = name.charAt(0) == ":"
                ? name.substr(1)
                : null;
            name = name.charAt(0) == ":"
                ? "*"
                : name;

            if(currentRoute.exists(name)){
                if(last){
                    var tmp = currentRoute.get(name);
                    tmp.callback = func;
                    tmp.variableName = variableName;
                }else if(name == "*"){
                    var point = currentRoute.get(name);
                    if(point.subRoutes == null)
                        point.subRoutes = new Map<String, RoutePart>();
                  
                    currentRoute = currentRoute.get(name).subRoutes;
                }else{
                    currentRoute = currentRoute.get(name).subRoutes;
                }
            }else{
                if(last){
                    currentRoute.set(name, {
                        callback: func,
                        variableName: variableName
                    });
                }else{
                    currentRoute.set(name, {
                        subRoutes: new Map<String, RoutePart>(),
                        variableName: variableName
                    });
                    currentRoute = currentRoute.get(name).subRoutes;
                }
            }   
        }
    }
    
    public function resolve(path:String):I->O->Void{
        var apath:Array<String> = path.split("/");
        
        var currentRoute = routes.subRoutes;
        var func:Map<String, Dynamic>->I->O->Void = null;
        var params:Map<String, Dynamic> = null;
        
        for(i in apath){
            if(currentRoute == null){
                return null;
            }else if(currentRoute.exists(i)){
                var node = currentRoute.get(i);
	            currentRoute = node.subRoutes;
	            func = node.callback;
            }else if(currentRoute.exists("*")){
            	var node = currentRoute.get("*");
                if(params == null)
                    params = new Map<String, Dynamic>();

                params.set(node.variableName, parse(i));
                currentRoute = node.subRoutes;
                func = node.callback;
            }else{
                return null;
            }
        }

        if(func == null){
            return null;
        }else{
            if(params == null)
                params = new Map<String, Dynamic>();
                
            return func.bind(params);
        }
    }

    public function parse(value:String):Dynamic{
        var n = Std.parseInt(value);
        if(n+"" == value)
            return n;

        var n = Std.parseFloat(value);
        if(n+"" == value)
            return n;

        if(value == "true")
            return true;

        if(value == "false")
            return false;

        return value;
    }
}
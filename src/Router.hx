package;

using StringTools;


typedef PathSolver = {
    len: Int,
    pattern: String,
    vars: Array<String>,
    parts: Array<Int>,
    ereg: EReg,
    callback: Map<String, Dynamic>->Dynamic->Dynamic->Void,
}

class Router<I,O>{

    var paths:Array<PathSolver> = [];
    
    public function new(){}
    
    public function addRoute(path:String, func:Map<String, Dynamic>->I->O->Void){
        var urlEreg = new EReg(":([a-zA-Z0-9._%\\-!~.*]+)", "g");
		urlEreg.match(path);
		var vars = [];
        try{
            var matches = urlEreg.split(path).length;            
            var pos = urlEreg.matchedPos();
            vars.push(path.substr(pos.pos + 1, pos.len).replace("/",""));
            var i = 0;
            while(urlEreg.matchSub(path, pos.pos + pos.len) == true && i++<matches){
                pos = urlEreg.matchedPos();
	            vars.push(path.substr(pos.pos + 1, pos.len).replace("/",""));
            }
            
        }catch(err:Dynamic){}
        
        var e = urlEreg.replace(path, "([a-zA-Z0-9._%\\-!~.*]+)");
        e = e.replace("/", "\\/");

        paths.sort(function(a:Dynamic, b:Dynamic){
            var ia = a.len;
            var ib = b.len;
            return ia < ib ? 1 : -1;
        });

        var urlParts = path.split("/");
        var parts = [];
        for(i in 0...urlParts.length){
            if(urlParts[i].charAt(0) == ":")
            	parts.push(i);            
        }

        paths.push({
            len: path.split("/").length,
            pattern: path,
            vars: vars,
            parts: parts,
            ereg: new EReg(e, "m"),
            callback: func
        });
    }

    public function print(){
        for(i in paths)
            trace(i.pattern);
    }

    public function resolve(path:String):I->O->Void{        
        var solver:PathSolver = null;
        for(i in 0...paths.length)
            if(paths[i].ereg.match(path)){
            	solver = paths[i];
	            break;
            }
            
        if(solver == null)
            return null; 
        
        var pathParts = path.split("/");
        var values:Array<String> = [];
        for(i in solver.parts)
            values.push(pathParts[i]);
            
        var func:Map<String, Dynamic>->I->O->Void = null;
        var params:Map<String, Dynamic> = new Map();
        for(i in 0...values.length)
            params.set(solver.vars[i], parse(values[i]));
        func = solver.callback;

        return func.bind(params);
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
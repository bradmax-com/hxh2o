package;

typedef Req = HXH2O.Request;
typedef Res = HXH2O.Response;

class H2oApi
{
    var router = new Router<Req,Res>();

    public function new(){
        HXH2O.getInstance().registerHandler(handler);
    }

    public function addRoute(path:String, func:Map<String, Dynamic>->Req->Res->Void){
        router.addRoute(path, func);
    }

    public function bind(host:String, port:Int, processNumbers = 1){
        Sys.println("------------KNOWN-ROUTES------------");
        router.print();
        Sys.println("------------------------------------");
        Sys.println('HOST: $host PORT: $port');
        Sys.println("------------------------------------");
        HXH2O.getInstance().bind(host, port, processNumbers);
    }

    public dynamic function unknownPath(path:String, req:Req, res:Res){
        res.status = 500;
        res.reason = "Internal Server Error";
        res.setBody('Path "$path" not found');
    }

    public function handler(req:Req, res:Res){
        var path:String = req.path.split("?")[0];

        path = path.charAt(0) == "/"
            ? path.substr(1)
            : path;

        path = path.charAt(path.length - 1) == "/"
            ? path.substr(0, path.length - 1)
            : path;

        var f = router.resolve(path);

        if(f == null)
            unknownPath(path, req, res);
        else
            f(req, res);
    }
}
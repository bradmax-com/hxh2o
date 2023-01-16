package hxh2o;

class H2oApi
{
    var router = new Router<Request,Response>();

    public function new(){
        HXH2O.getInstance().registerHandler(handler);
    }

    public function addRoute(path:String, func:Map<String, Dynamic>->Request->Response->Void){
        router.addRoute(path, func);
    }

    public function bind(host:String, port:Int, internalPort:Int){
        Sys.println("------------KNOWN-ROUTES------------");
        router.print();
        Sys.println("------------------------------------");
        Sys.println('HOST: $host PORT: $port');
        Sys.println("------------------------------------");
        HXH2O.getInstance().bind(host, port, internalPort);
    }

    public dynamic function unknownPath(path:String, req:Request, res:Response){
        res.status = 500;
        res.reason = "Internal Server Error";
        res.setBody('Path "$path" not found');
    }

    public function handler(req:Request, res:Response){
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
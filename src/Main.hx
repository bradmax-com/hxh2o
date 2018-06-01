package;

typedef Req = HXH2O.Request;
typedef Res = HXH2O.Response;

class Main
{
    public static function main(){
        new Main();
    }

    var router = new Router<Req,Res>();

    public function new(){
        router.addRoute("user/:id/name", userName);
        router.addRoute("user/:id", user);
        router.addRoute("stats/v1/collect", statsCollect);
        router.print();

        HXH2O.getInstance().registerHandler(handler);
        HXH2O.getInstance().bind("0.0.0.0", 12345);
    }

    function userName(params:Map<String, Dynamic>, req:Req, res:Res){

    }

    function user(params:Map<String, Dynamic>, req:Req, res:Res){

    }

    function statsCollect(params:Map<String, Dynamic>, req:Req, res:Res){

    }

    function unknownPath(path:String){
        
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
            unknownPath(path);
        else
            f(req, res);
    }
}

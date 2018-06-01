package;

typedef H2oReq = HXH2O.Request;
typedef H2oRes = HXH2O.Response;

class Main
{
    public static function main(){
        new Main();
    }

    var api = new H2oApi();

    public function new(){
        api.addRoute("user/:id/name", userName);
        api.addRoute("user/:id", user);
        api.addRoute("stats/v1/collect", statsCollect);
        api.bind("0.0.0.0", 12345);
    }

    function userName(params:Map<String, Dynamic>, req:H2oReq, res:H2oRes){
        res.status = 200;
        res.reason = "OK";
    }

    function user(params:Map<String, Dynamic>, req:H2oReq, res:H2oRes){

    }

    function statsCollect(params:Map<String, Dynamic>, req:H2oReq, res:H2oRes){

    }
}

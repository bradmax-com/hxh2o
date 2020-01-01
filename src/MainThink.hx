package;

// typedef H2oReq = HXH2O.Request;
// typedef H2oRes = HXH2O.Response;

class MainThink
{
    public static function main(){
        new Main();
    }

    var api = new H2oApi();

    public function new(){
        api.addRoute("user/:id/name", userName);
        api.addRoute("user/:id", user);
        api.addRoute("stats/v1/collect", statsCollect);
        api.bind("0.0.0.0", 12345, 12346);
    }

    function userName(params:Map<String, Dynamic>, req:HXH2O.Request, res:HXH2O.Response){
        res.status = 200;
        res.reason = "OK";
        res.setBody('user id: ${params.get("id")}');
    }

    function user(params:Map<String, Dynamic>, req:HXH2O.Request, res:HXH2O.Response){
        res.status = 200;
        res.reason = "OK";
        res.setBody('user id: ${params.get("id")}');
    }

    function statsCollect(params:Map<String, Dynamic>, req:HXH2O.Request, res:HXH2O.Response){

    }
}


class SampleRouter implements hxh2o.IRoute {
    @:get("/user/:id")
    function getUser(id : Int) {
    // do something with `id`
    }
}
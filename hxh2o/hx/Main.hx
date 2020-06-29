package;

import hxh2o.Request;
import hxh2o.Response;
import hxhiredis.Redis;

class Main
{
    public static function main(){
        new Main();
    }

    var api = new hxh2o.H2oApi();
    var redis = new Redis();

    public function new(){
        // redis.connect("172.31.7.94", 6379);
        api.addRoute("user/:id/name", userName);
        api.addRoute("user/:id", user);
        api.addRoute("redis/:key/:val", redisSet);
        api.addRoute("redis/:key", redisGet);
        api.addRoute("stats/v1/collect", statsCollect);
        api.bind("0.0.0.0", 12345, 12346);
    }

    function userName(params:Map<String, Dynamic>, req:Request, res:Response){
        res.status = 200;
        res.reason = "OK";
        res.setBody('user id: ${params.get("id")}');
    }

    function user(params:Map<String, Dynamic>, req:Request, res:Response){
        res.status = 200;
        res.reason = "OK";
        res.setBody('user id: ${params.get("id")}');
    }

    function statsCollect(params:Map<String, Dynamic>, req:Request, res:Response){
        res.status = 200;
        res.reason = "OK";
        res.setBody('stats collected');
    }

    function redisSet(params:Map<String, Dynamic>, req:Request, res:Response){
        res.status = 200;
        res.reason = "OK";
        var key = params.get('key');
        var val = params.get('val');
        res.setBody(redis.command('SET $key $val'));
    }

    function redisGet(params:Map<String, Dynamic>, req:Request, res:Response){
        res.status = 200;
        res.reason = "OK";
        var key = params.get('key');
        res.setBody(redis.command('GET $key'));
    }
}

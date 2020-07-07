package;

import haxe.io.BytesBuffer;
import hxh2o.Request;
import hxh2o.Response;
import hxhiredis.Redis;
import hxhiredis.RedisCluster;

class Main
{
    public static function main(){
        new Main();
    }

    var api = new hxh2o.H2oApi();
    var redis = new Redis();

    public function new(){

        var r = new Redis();
        var connected = false;
        try{
            // r.connect("192.168.0.123", 6379);
            r.connect("192.168.10.2", 6379);
            connected = true;
        }catch(err:Dynamic){
            trace(err);
            connected = false;
        }

        while(true){
            try{
                if(connected){
                    trace("======================>>>> :)");
                    
                    var data = new haxe.io.BytesBuffer();
                    data.addByte(88);
                    data.addByte(88);
                    data.addByte(88);
                    for(i in 0...1024){
                        data.addByte(i%128);
                    }
                    data.addByte(88);
                    data.addByte(88);
                    data.addByte(88);
                    var bytes = data.getBytes();
                    trace("binary");
                    var response = r.commandArgv(['SET', 'data128', bytes]);


                    var data = new haxe.io.BytesBuffer();
                    data.addByte(88);
                    data.addByte(88);
                    data.addByte(88);
                    for(i in 0...1024){
                        data.addByte(i%256);
                    }
                    data.addByte(88);
                    data.addByte(88);
                    data.addByte(88);

                    trace("binary");
                    var bytes = data.getBytes();
                    var response = r.commandArgv(['SET', 'data256', bytes]);
                }else{
                    // r.reconnect();
                    connected = true;
                }
            }catch(err:Dynamic){
                connected = false;
                trace(err);
            }
            Sys.sleep(1);
        }




        redis.connect("bradmax-redis.kelmfo.clustercfg.euc1.cache.amazonaws.com", 6379);
        // redis.connect("172.31.7.94", 6379);
        api.addRoute("user/:id/name", userName);
        api.addRoute("user/:id", user);
        api.addRoute("redis/:key/:val", redisSet);
        api.addRoute("redis/:key", redisGet);
        api.addRoute("redis/command/:cmd", redisCommand);
        api.addRoute("stats/v1/collect", statsCollect);
        while(true){
            try{
                api.bind("0.0.0.0", 12345, 12346);
            }catch(err:Dynamic){
                trace(err);
            }
        }
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
        res.setBody("REDIS: \n" + redis.command('SET $key $val'));
    }

    function redisGet(params:Map<String, Dynamic>, req:Request, res:Response){
        res.status = 200;
        res.reason = "OK";
        var key = params.get('key');
        res.setBody("REDIS: \n" + redis.command('GET $key'));
    }

    function redisCommand(params:Map<String, Dynamic>, req:Request, res:Response){
        res.status = 200;
        res.reason = "OK";
        var command = params.get('cmd').split("_").join(" ");
        res.setBody("REDIS: \n" + redis.command(command));
    }
    
}

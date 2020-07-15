package;

import haxe.io.BytesBuffer;
import haxe.io.Bytes;
import hxh2o.Request;
import hxh2o.Response;
import hxhiredis.Redis;
import hxhiredis.RedisCluster;
import cpp.vm.Thread;

class Main
{
    public static function main(){
        new Main();
    }

    var api = new hxh2o.H2oApi();
    var r = new RedisCluster();

    function checkBytes(){
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
        trace(bytes.length);
        r.commandArgv(['SET', 'data256', bytes.toString()]);
        var response = r.commandArgv(['GET', 'data256']);
        trace(Bytes.ofString(response).length);
    }
    function checkAppendCommand(){
        for(i in 0...500)
            r.commandArgv(["ZADD", "testZREMRANGEBYSCORE", ""+i, "u_"+i]);

        for(i in 500...1000)
            r.appendCommand('ZADD testZREMRANGEBYSCORE $i u_$i');
        r.getBulkReply();

        for(i in 1000...1500)
            r.appendCommandArgv(["ZADD", "testZREMRANGEBYSCORE", ""+i, "u_"+i]);
        r.getBulkReply();

        var cmd = 'ZREMRANGEBYSCORE testZREMRANGEBYSCORE 0 5000';
        r.appendCommand(cmd);
        var res = r.getBulkReply();
        r.command("FLUSHALL");
        return res;
    }

    public function new(){

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
            Sys.sleep(1);
        }
        var arr:Array<String> = [];
        arr = [];
        arr.push('SADD');
        arr.push('arr_test');
        for(i in 0...1000){
            arr.push('test_$i');
        }
        r.commandArgv(arr);
        while(true){
            var response = r.commandArgv(['SMEMBERS', 'arr_test']);
            Sys.sleep(0.001);
        }









        // var data = new haxe.io.BytesBuf 
        
        // return;
        while(false){
            try{
                if(connected){
                    // trace("======================>>>> :)");
                    checkAppendCommand();
                }else{
                    // r.reconnect();
                    connected = true;
                }
            }catch(err:Dynamic){
                connected = false;
                trace(err);
            }
            Sys.sleep(0.01);
        }


        var id:Int = cast untyped __cpp__("fork()");
        if(id > 0){
            testApi();
        }else{
            // r.connect("bradmax-redis.kelmfo.clustercfg.euc1.cache.amazonaws.com", 6379);
            // redis.connect("172.31.7.94", 6379);
            api.addRoute("redis/test/:id", redisTest);
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
    }

    function testApi(){
        Sys.sleep(3);
        while(true){
            try{
                var r = Math.random();
                trace("START", r);
                var res = haxe.Http.requestUrl('http://0.0.0.0:12345/redis/test/$r');
                trace("END", res);
                Sys.sleep(0.0001);
            }catch(err:Dynamic){
                trace('ERROR: $err');
            }
        }

    }
    function redisTest(params:Map<String, Dynamic>, req:Request, res:Response){
        res.status = 200;
        res.reason = "OK";
        var id = params.get('id');
        checkBytes();
        res.setBody("REDIS: " + checkAppendCommand());
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
        res.setBody("REDIS: \n" + r.command('SET $key $val'));
    }

    function redisGet(params:Map<String, Dynamic>, req:Request, res:Response){
        res.status = 200;
        res.reason = "OK";
        var key = params.get('key');
        res.setBody("REDIS: \n" + r.command('GET $key'));
    }

    function redisCommand(params:Map<String, Dynamic>, req:Request, res:Response){
        res.status = 200;
        res.reason = "OK";
        var command = params.get('cmd').split("_").join(" ");
        res.setBody("REDIS: \n" + r.command(command));
    }
    
}

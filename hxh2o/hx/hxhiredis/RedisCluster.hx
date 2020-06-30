package hxhiredis;

import hxhiredis.Redis;
import hxhiredis.Crc16;

using StringTools;

typedef Range = {
    var from:Null<Int>;
    @:optional var to:Null<Int>;
}

typedef Node = {
    var hash:String;
    var host:String;
    var port:Int;
    var slots:Array<Range>;
}

/*

------------KNOWN-ROUTES------------
hx/hxh2o/Router.hx:87: redis/command/:cmd
hx/hxh2o/Router.hx:87: user/:id/name
hx/hxh2o/Router.hx:87: redis/:key/:val
hx/hxh2o/Router.hx:87: user/:id
hx/hxh2o/Router.hx:87: redis/:key
hx/hxh2o/Router.hx:87: stats/v1/collect
------------------------------------
HOST: 0.0.0.0 PORT: 12345
------------------------------------
hx/hxhiredis/Redis.hx:163: docker command: GET A

GET A1

GET A2

GET A3

type: 6
hx/hxhiredis/Redis.hx:167: GET A
hx/hxhiredis/Redis.hx:168: 6
hx/hxhiredis/Redis.hx:169: MOVED 6373 172.31.24.45:6379
hx/hxhiredis/Redis.hx:239: redis,6,MOVED 6373 172.31.24.45:6379,0,0
hx/hxhiredis/Redis.hx:163: docker command: CLUSTER NODES

CLUSTER NODES1

CLUSTER NODES2

CLUSTER NODES3

type: 1

1070:9ba537d4b500403609debdaa6f318910cdc47ffc 172.31.16.216:6379@1122 slave 4ddcc0c9812c49f564b3f712e68f9023cbb2770a 0 1593503418000 26 connected
d6e40430b6701cf5cc59c9cbd13db5e5b002c3bf 172.31.24.45:6379@1122 master - 0 1593503419000 28 connected 5462-7410 8776-10922
3b9b747160f2b574481d6ceae87d439d63b22eb3 172.31.7.94:6379@1122 myself,master - 0 1593503415000 23 connected 1402-2767 7411-8775 13213-14577
1b6d513bcaa5b69d45d19d0aa4374ecfc9efd3fc 172.31.28.44:6379@1122 master - 0 1593503418546 27 connected 0-1401 2768-5461
212dc520b41c7f16b0c763504e1250efe81c2894 172.31.46.85:6379@1122 slave 3b9b747160f2b574481d6ceae87d439d63b22eb3 0 1593503416000 23 connected
f5c84065b306b88e8d703675a63cbc29d615b24a 172.31.5.116:6379@1122 slave 1b6d513bcaa5b69d45d19d0aa4374ecfc9efd3fc 0 1593503418000 27 connected
3bd8412d4e6a5267c330aae86dc1d31395eac13f 172.31.45.69:6379@1122 slave d6e40430b6701cf5cc59c9cbd13db5e5b002c3bf 0 1593503419550 28 connected
4ddcc0c9812c49f564b3f712e68f9023cbb2770a 172.31.40.167:6379@1122 master - 0 1593503418000 26 connected 10923-13212 14578-16383

hx/hxhiredis/Redis.hx:167: CLUSTER NODES
hx/hxhiredis/Redis.hx:168: 1
hx/hxhiredis/Redis.hx:169: 9ba537d4b500403609debdaa6f318910cdc47ffc 172.31.16.216:6379@1122 slave 4ddcc0c9812c49f564b3f712e68f9023cbb2770a 0 1593503418000 26 connected
d6e40430b6701cf5cc59c9cbd13db5e5b002c3bf 172.31.24.45:6379@1122 master - 0 1593503419000 28 connected 5462-7410 8776-10922
3b9b747160f2b574481d6ceae87d439d63b22eb3 172.31.7.94:6379@1122 myself,master - 0 1593503415000 23 connected 1402-2767 7411-8775 13213-14577
1b6d513bcaa5b69d45d19d0aa4374ecfc9efd3fc 172.31.28.44:6379@1122 master - 0 1593503418546 27 connected 0-1401 2768-5461
212dc520b41c7f16b0c763504e1250efe81c2894 172.31.46.85:6379@1122 slave 3b9b747160f2b574481d6ceae87d439d63b22eb3 0 1593503416000 23 connected
f5c84065b306b88e8d703675a63cbc29d615b24a 172.31.5.116:6379@1122 slave 1b6d513bcaa5b69d45d19d0aa4374ecfc9efd3fc 0 1593503418000 27 connected
3bd8412d4e6a5267c330aae86dc1d31395eac13f 172.31.45.69:6379@1122 slave d6e40430b6701cf5cc59c9cbd13db5e5b002c3bf 0 1593503419550 28 connected
4ddcc0c9812c49f564b3f712e68f9023cbb2770a 172.31.40.167:6379@1122 master - 0 1593503418000 26 connected 10923-13212 14578-16383

hx/hxhiredis/Redis.hx:239: redis,1,9ba537d4b500403609debdaa6f318910cdc47ffc 172.31.16.216:6379@1122 slave 4ddcc0c9812c49f564b3f712e68f9023cbb2770a 0 1593503418000 26 connected
d6e40430b6701cf5cc59c9cbd13db5e5b002c3bf 172.31.24.45:6379@1122 master - 0 1593503419000 28 connected 5462-7410 8776-10922
3b9b747160f2b574481d6ceae87d439d63b22eb3 172.31.7.94:6379@1122 myself,master - 0 1593503415000 23 connected 1402-2767 7411-8775 13213-14577
1b6d513bcaa5b69d45d19d0aa4374ecfc9efd3fc 172.31.28.44:6379@1122 master - 0 1593503418546 27 connected 0-1401 2768-5461
212dc520b41c7f16b0c763504e1250efe81c2894 172.31.46.85:6379@1122 slave 3b9b747160f2b574481d6ceae87d439d63b22eb3 0 1593503416000 23 connected
f5c84065b306b88e8d703675a63cbc29d615b24a 172.31.5.116:6379@1122 slave 1b6d513bcaa5b69d45d19d0aa4374ecfc9efd3fc 0 1593503418000 27 connected
3bd8412d4e6a5267c330aae86dc1d31395eac13f 172.31.45.69:6379@1122 slave d6e40430b6701cf5cc59c9cbd13db5e5b002c3bf 0 1593503419550 28 connected
4ddcc0c9812c49f564b3f712e68f9023cbb2770a 172.31.40.167:6379@1122 master - 0 1593503418000 26 connected 10923-13212 14578-16383
,0,0

*/





class RedisCluster {

    private var nodes:Array<Node> = [];
    private var connections:Map<String, Redis> = new Map();

    public function new(){}
    
    public function connect(host:String, port:Int):Void{
        var key = '$host:$port';
        if(!connections.exists(key)){
            var r = new Redis();
            r.connect(host, port);
            connections.set(key, r);
        }
    }

    public function command(cmd:String):Dynamic{
        for(redis in connections){
            return r.command(cmd);
            break;
        }
    }

    public function appendCommand(cmd:String){
        for(redis in connections){
            return r.appendCommand(cmd);
            break;
        }
    }

    public function getBulkReply():Array<String>{
        for(redis in connections){
            return r.getBulkReply();
            break;
        }
    }

    function updateCluster(){
        for(redis in connections){
            nodes = parseNodes(r.command("CLUSTER NODES"));
            break;
        }
    }

    private function parseNodes(input:String):Array<Node>
    {
        var value = input.split('\n');
        var arr:Array<Node> = [];
        
        for(i in value){
            try{
                var data:Array<String> = i.split(' ');
                var c = data[1].split('@')[0].split(':');
                var node:Node = {
                    hash: data[0],
                    host: c[0],
                    port: Std.parseInt(c[1]),
                    slots: new Array<Range>()
                };

                for(i in 8...data.length){
                    var range = data[i].split('-');
                    if(range.length > 1){
                        node.slots.push({from: Std.parseInt(range[0]), to: Std.parseInt(range[1])});
                    }else{
                        node.slots.push({from: Std.parseInt(range[0])});
                    }

                }
                arr.push(node);
            }catch(err:Dynamic){
                continue;
            }
        }

        return arr;
    }

    function getKey(cmd:String):String{
        var arr = cmd.split(" ");
        return arr[1];
    }

    function findInstanceByKey(key:String):Redis{
        var slot = getSlot(key);
        for(i in nodes){
            if(isSlotInNode(slot, i)){
                var key = '${i.host}:${i.port}';
                if(connections.exists(key)){
                    return connections.get(key);
                }else{
                    return connect(i.host, i.port);
                }
                break;
            }
        }
    }

    private function isSlotInNode(slot:Int, node:Node):Bool{
        for(range in node.slots){
            if(range.to == null){
                if(range.from == slot){
                    return true;
                }
            }else{
                if(slot >= range.from && slot <=range.to){
                    return true;
                }
            }
        }
        return false;
    }

    function getSlot(key:String):Int
        return Crc16.make(haxe.io.Bytes.ofString(key)) % 16384;
}
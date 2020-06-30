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
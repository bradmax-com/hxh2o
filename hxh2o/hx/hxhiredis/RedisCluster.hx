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


class RedisCluster 
{
    var nodes:Array<Node> = [];
    var connections:Map<String, Redis> = new Map();
    var connection:Redis;
    var bulkOrder:Map<Redis, Array<Int>> = new Map();
    var bulkIndex = 0;

    public function new(){}
    
    public function connect(host:String, port:Int):Void {
        var h = new sys.net.Host(host);
        host = h.toString();
        var key = '$host:$port';
        if(!connections.exists(key)){
            var r = new Redis();
            r.connect(host, port);
            connections.set(key, r);
        }
        updateCluster();
    }

    public function command(cmd:String):Dynamic {
        var redis = findInstanceByCommand(cmd);
        try{
            return redis.command(cmd);
        }catch(err:Dynamic){
            if(err.indexOf("MOVED") == 0){
                trace("REDIS MOVED");
                updateCluster();
                return command(cmd);
            }else if(checkConnectionError(err)){
                trace("REDIS CONNECTION ERROR");
                reconnect(redis);
                return command(cmd);
            }else{
                throw err;
            }
        }
        return null;
    }

    public function appendCommand(cmd:String){
        var redis = findInstanceByCommand(cmd);
        if(!bulkOrder.exists(redis))
            bulkOrder.set(redis, []);
        bulkOrder.get(redis).push(bulkIndex);
        bulkIndex++;

        try{
            redis.appendCommand(cmd);
        }catch(err:Dynamic){
            if(err.indexOf("MOVED") == 0){
                trace("REDIS MOVED");
                updateCluster();
                appendCommand(cmd);
            }else if(checkConnectionError(err)){
                trace("REDIS CONNECTION ERROR");
                reconnect(redis);
                appendCommand(cmd);
            }else{
                throw err;
            }
        }
    }

    public function getBulkReply():Array<Dynamic>{
        var redises = new Array<Redis>();
        for(n in nodes){
            redises.push(connections.get('${n.host}:${n.port}'));
        }

        var res:Array<Dynamic> = [];
        for(redis in redises){
            var indexes = bulkOrder.get(redis);
            var bulk = redis.getBulkReply();
            for(i in indexes){
                res[i] = bulk[i];
            }
        }

        bulkOrder = new Map();
        bulkIndex = 0;
        return res;

        // var res:Array<String> = [];
        // for(redis in connections){
        //     try{
        //         res = res.concat(redis.getBulkReply());
        //         // break;
        //     }catch(err:Dynamic){
        //         if(err.indexOf("MOVED") == 0){
        //             trace("REDIS MOVED");
        //             updateCluster();
        //             res = getBulkReply();
        //         }else if(checkConnectionError(err)){
        //             trace("REDIS CONNECTION ERROR");
        //             reconnect(redis);
        //             res = getBulkReply();
        //         }else{
        //             throw err;
        //         }
        //     }
        // }
        // return res;
    }

    function reconnect(redis:Redis){
        trace("REDIS RECONNECT");
        try{
            redis.reconnect();
        }catch(err:Dynamic){
            updateCluster();
        }
    }

    function updateCluster(){
        trace("REDIS UPDATE CLUSTER");
        var healthyNodeExists = false;
        for(redis in connections){
            try{
                nodes = parseNodes(redis.command("CLUSTER NODES"));
                healthyNodeExists = true;
                break;
            }catch(err:Dynamic){
                trace("ERROR updateCluster:", err);
            }
        }
        while(!healthyNodeExists){            
            try{
                for(redis in connections){
                    redis.reconnect();
                    healthyNodeExists = true;
                    break;
                }
            }catch(err:Dynamic){
                trace('ERROR updateCluster: $err');
            }
        }
    }

    function checkConnectionError(err:Dynamic):Bool{
        switch(err){
            case Redis.CONNECTION_REFUSED:
                return true;
            case Redis.SERVER_CLOSED_THE_CONNECTION:
                return true;
            case Redis.CONNECTION_RESET_BY_PEER:
                return true;
        }
        return false;
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

    function findInstanceByCommand(cmd:String):Redis{
        // trace("findInstanceByCommand", cmd);
        return findInstanceByKey(getKey(cmd));
    }

    function getKey(cmd:String):String{
        var arr = cmd.split(" ");
        return arr[1];
    }

    function findInstanceByKey(key:String):Redis{
        var slot = getSlot(key);
        for(i in nodes){  
            // trace("findInstanceByKey", nodes);
            if(isSlotInNode(slot, i)){
                var key = '${i.host}:${i.port}';
                if(connections.exists(key)){
                    // trace("connections.exists", key);
                    return connections.get(key);
                }else{
                    var redis = new Redis();
                    redis.connect(i.host, i.port);
                    connections.set(key, redis);
                    // trace("!connections.exists", key);
                    return redis;
                }
                // break;
            }
        }
        return null;
    }

    private function isSlotInNode(slot:Int, node:Node):Bool{
        // trace("isSlotInNode", slot, node);
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
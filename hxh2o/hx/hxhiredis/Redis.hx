package hxhiredis;

import cpp.ConstPointer;
import cpp.StdString;
import cpp.Char;
import cpp.ConstCharStar;
import cpp.Pointer;

@:buildXml('
<set name="HXH2O" value="${haxelib:hxh2o}/hxh2o" />
<set name="HXH2O_LIB" value="${haxelib:hxh2o}/hxh2o/h2o" />
<set name="H2O" value="${HXH2O}/h2o" />
<set name="H2O_MAIN" value="/usr/lib/h2o" />

// <set name="HXH2O_LIB" value="/usr/lib/haxe/lib/hxh2o/h2o" />
// <set name="HXH2O" value="${haxelib:hxh2o}/hxh2o" />
// <set name="H2O" value="${HXH2O}/h2o" />

<files id="haxe">
    <flag value="-I${HXH2O}" />

    <compilerflag value="-I${HXH2O}/cpp/"/>
    <compilerflag value="-I${HXH2O}/" />
    <compilerflag value="-I${H2O}/include/"/>
    <compilerflag value="-I${H2O_MAIN}/include/"/>
    <compilerflag value="-I${H2O}/deps/hiredis/"/>
    <compilerflag value="-I${H2O_MAIN}/deps/hiredis/"/>
    <compilerflag value="-I${HXH2O_LIB}/deps/hiredis/"/>
    <compilerflag value="-I${H2O_MAIN}/deps/hiredis/"/>

    <compilerflag value="-I/opt/local/include/" />
    <compilerflag value="-I/usr/include/" />
    
    <compilerflag value="-I./include"/>
    <compilerflag value="-Iinclude"/>
</files>
<target id="haxe">
    <flag value="-Iinclude"/>
    <flag value="-I./include"/>
    <flag value="-I${H2O}/include"/>
    <flag value="-I${HH2O_MAIN2O}/include"/>
    <flag value="-I${H2O}/deps/hiredis"/>
    <flag value="-I${H2O_MAIN}/deps/hiredis"/>
    <flag value="-I${HXH2O_LIB}/deps/hiredis"/>
    <flag value="-I${H2O_MAIN}/deps/hiredis"/>
    <flag value="-I/usr/include"/>

    <flag value="-L/usr/port/x866_64-port -gnu/"/>
    <flag value="-L${H2O}/"/>
    <flag value="-L${HXH2O_LIB}/"/>
    <flag value="-L${H2O_MAIN}/"/>

    <!--<lib name="-lhiredis"/>-->
</target>
')

@:unreflective
@:structAccess
@:native("redisReply")
extern class RedisReply {}

@:unreflective
@:structAccess
@:native("redisReplyPtr")
extern class RedisReplyPtr {}

@:unreflective
@:structAccess
@:native("redisReplyPtrPtr")
extern class RedisReplyPtrPtr {}

@:unreflective
@:structAccess
@:native("redisContext")
extern class RedisContext {}

@:unreflective
@:structAccess
@:native("redisReader")
extern class RedisReader {}

@:unreflective
@:structAccess
@:native("HXredisReplyArray")
extern class HXredisReplyArrayAccess {}

@:unreflective
@:structAccess
@:native("HXredisReply")
extern class HXredisReply {
    public var error:Bool;
    public var type:Int;
    public var integer:Int;
    public var dval:Float;
    public var len:Int;
    public var str:String;
    public var vtype:String;
    public var elements:Int;
    public var element:HXredisReplyArrayAccess;
}

typedef Reply = {
    status:Int,
    data:Dynamic,
}

@:headerCode('
typedef struct HXredisReply HXredisReply;
    struct HXredisReply {
        bool error;
        int type;
        int integer;
        Float dval;
        int len;
        String str;
        String vtype;
        int elements;
        struct HXredisReply **element;
    };
')

@:headerInclude('../cpp/HxRedisImport.h')
@:cppInclude('../cpp/HxRedisGlue.cpp')

class Redis {
    public static inline var CONNECTION_REFUSED = "Connection refused";
    public static inline var SERVER_CLOSED_THE_CONNECTION = "Server closed the connection";
    public static inline var CONNECTION_RESET_BY_PEER = "Connection reset by peer";

    public static inline var HX_REDIS_ERR = -1;
    public static inline var HX_REDIS_OK = 0;

    public static inline var HX_REDIS_ERR_IO = 1; /* Error in read or write */
    public static inline var HX_REDIS_ERR_EOF = 3; /* End of file */
    public static inline var HX_REDIS_ERR_PROTOCOL = 4; /* Protocol error */
    public static inline var HX_REDIS_ERR_OOM = 5; /* Out of memory */
    public static inline var HX_REDIS_ERR_TIMEOUT = 6; /* Timed out */
    public static inline var HX_REDIS_ERR_OTHER = 2; /* Everything else... */

    public static inline var HX_REDIS_REPLY_STRING = 1;
    public static inline var HX_REDIS_REPLY_ARRAY = 2;
    public static inline var HX_REDIS_REPLY_INTEGER = 3;
    public static inline var HX_REDIS_REPLY_NIL = 4;
    public static inline var HX_REDIS_REPLY_STATUS = 5;
    public static inline var HX_REDIS_REPLY_ERROR = 6;
    public static inline var HX_REDIS_REPLY_DOUBLE = 7;
    public static inline var HX_REDIS_REPLY_BOOL = 8;
    public static inline var HX_REDIS_REPLY_MAP = 9;
    public static inline var HX_REDIS_REPLY_SET = 10;
    public static inline var HX_REDIS_REPLY_ATTR = 11;
    public static inline var HX_REDIS_REPLY_PUSH = 12;
    public static inline var HX_REDIS_REPLY_BIGNUM = 13;
    public static inline var HX_REDIS_REPLY_VERB = 14;

    var context:Pointer<RedisContext>;
    var reader:Pointer<RedisReader>;
    var reply:RedisReplyPtr;
    var bulkSize = 0;    
    var host:String = null;
    var port:Int = -1;

    public function new(){
    }
    
    public function getHost():String{
        return host;
    }
    
    public function getPort():Int{
        return port;
    }

    public function connect(host:String, port:Int):Void{
        var h = new sys.net.Host(host);
        this.host = h.toString();
        this.port = port;
        try{
            Sys.println('Redis host connected $host:$port');
            context = __redisConnect(StdString.ofString(host).c_str(), port);
            checkError();
        }catch(err:Dynamic){
            throw err;
        }
    }

    public function reconnect():Void{
        var i = __redisReconnect(context);

        if(i == 0) return;
        try{
            checkError();
        }catch(err:Dynamic){
            throw err;
        }
    }

    public function command(cmd:String):Dynamic{
        var resPointer = __command(context, cmd);
        var res = resPointer.ref;

        if(res.error){
            throw res.str;
        }

        var retValue = readReplyObject(res);

        if(retValue.status == HX_REDIS_REPLY_ERROR){
            throw retValue.data;
        }

        try{
            checkError();
        }catch(err:Dynamic){
            throw err;
        }

        untyped __cpp__("__freeHXredisReply({0})", resPointer);
        return retValue.data;
    }

    public function appendCommand(cmd:String){
        bulkSize++;
        __redisAppendCommand(context, StdString.ofString(cmd).c_str());
        try{
            checkError();
        }catch(err:Dynamic){
            throw err;
        }
    }

    public function getBulkReply():Array<String>{
        var arr = new Array<String>();

        while(bulkSize-- > 0){
            var rep:Dynamic = cast getReply();
            if(rep != null)
                arr.push(rep);
        }
        bulkSize = 0;
        return arr;
    }

    function checkError(){
        var s:String = __checkError(context);

        if(s != ""){
            bulkSize = 0;
            throw s;
        }
    }

    function getReply():Dynamic{
        var resPointer = __getReply(context);
        var res = resPointer.ref;

        if(res.error){
            throw res.str;
        }

        var retValue:Dynamic = readReplyObject(res);

        try{
            checkError();
        }catch(err:Dynamic){
            throw err;
        }

        untyped __cpp__("__freeHXredisReply({0})", resPointer);
        return retValue;
    }

    function readReplyObject(res:HXredisReply):Reply{
        // trace("redis", res.type, res.str, res.integer, res.dval);
        var data:Dynamic = null;
        switch(res.type){
            case HX_REDIS_REPLY_STRING:
                data = res.str;
            case HX_REDIS_REPLY_INTEGER:
                data = res.integer;
            case HX_REDIS_REPLY_DOUBLE:
                data = res.dval;
            case HX_REDIS_REPLY_BOOL:
                data = res.integer == 1;
            case HX_REDIS_REPLY_ERROR:
                data = res.str;
            case HX_REDIS_REPLY_ARRAY:
                var arr:Array<Dynamic> = [];
                for(i in 0...res.elements){
                    var type:Int = untyped __cpp__("{0}.element[{1}]->type",res,i);
                    switch(type){
                        case HX_REDIS_REPLY_STRING:
                            var val:String = untyped __cpp__("{0}.element[{1}]->str",res,i);
                            arr.push(val);
                        case HX_REDIS_REPLY_INTEGER:
                            var val:Int = untyped __cpp__("{0}.element[{1}]->integer",res,i);
                            arr.push(val);
                        case HX_REDIS_REPLY_DOUBLE:
                            var val:Float = untyped __cpp__("{0}.element[{1}]->dval",res,i);
                            arr.push(val);
                        case HX_REDIS_REPLY_BOOL:
                            var val:Int = untyped __cpp__("{0}.element[{1}]->integer",res,i);
                            arr.push(val == 1);
                    }
                }
                data = arr;
        }
        return {data: data, status: res.type};
    }

    function freeReply(){
        __freeReplyObject(reply);
    }

    function readerCreate(){
        reader = __redisReaderCreate();
    }

    function readerFree(){
        __redisReaderFree(reader);
    }

    function readerFeed(){
        var size = 1024;
        var buffer:ConstCharStar = null;
        __redisReaderFeed(reader, buffer, size);
        return buffer.toString();
    }

    #if (haxe_ver >= 4.000)

    @:extern
    @:native("redisReaderCreate")
    public static function __redisReaderCreate():Pointer<RedisReader>;

    @:extern
    @:native("redisReaderFree")
    public static function __redisReaderFree(reader:Pointer<RedisReader>):Void;

    @:extern
    @:native("redisReaderFeed")
    public static function __redisReaderFeed(reader:Pointer<RedisReader>, buffer:ConstCharStar, size:Int):Void;

    @:extern
    @:native("__getReply")
    public static function __getReply(c:Pointer<RedisContext>):Pointer<HXredisReply>;

    @:extern
    @:native("__command")
    public static function __command(c:Pointer<RedisContext>, cmd:String):Pointer<HXredisReply>;

    @:extern
    @:native("__checkError")
    public static function __checkError(c:Pointer<RedisContext>):String;

    @:extern
    @:native("freeReplyObject")
    public static function __freeReplyObject(reply:RedisReplyPtr):Void;

    @:extern
    @:native("redisAppendCommand")
    public static function __redisAppendCommand(context:Pointer<RedisContext>, command:ConstPointer<Char>):Int;

    @:extern
    @:native("redisConnect")
    public static function __redisConnect(host:ConstPointer<Char>, port:Int):Pointer<RedisContext>;

    @:extern
    @:native("redisReconnect")
    public static function __redisReconnect(c:Pointer<RedisContext>):Int;

    #else

    @:extern
    @:native("redisReaderCreate")
    public static function __redisReaderCreate():Pointer<RedisReader> return null;

    @:extern
    @:native("redisReaderFree")
    public static function __redisReaderFree(reader:Pointer<RedisReader>):Void return null;

    @:extern
    @:native("redisReaderFeed")
    public static function __redisReaderFeed(reader:Pointer<RedisReader>, buffer:ConstCharStar, size:Int):Void return null;

    @:extern
    @:native("__getReply")
    public static function __getReply(c:Pointer<RedisContext>):Pointer<HXredisReply> return null;

    @:extern
    @:native("__command")
    public static function __command(c:Pointer<RedisContext>, cmd:String):Pointer<HXredisReply> return null;

    @:extern
    @:native("__checkError")
    public static function __checkError(c:Pointer<RedisContext>):String return null;

    @:extern
    @:native("freeReplyObject")
    public static function __freeReplyObject(reply:RedisReplyPtr):Void return null;

    @:extern
    @:native("redisAppendCommand")
    public static function __redisAppendCommand(context:Pointer<RedisContext>, command:ConstPointer<Char>):Int return null;

    @:extern
    @:native("redisConnect")
    public static function __redisConnect(host:ConstPointer<Char>, port:Int):Pointer<RedisContext> return null;

    @:extern
    @:native("redisReconnect")
    public static function __redisReconnect(c:Pointer<RedisContext>):Int return null;

    #end

}
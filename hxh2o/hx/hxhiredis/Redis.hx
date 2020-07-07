package hxhiredis;

import cpp.ConstPointer;
import cpp.StdString;
import cpp.Char;
import cpp.ConstCharStar;
import cpp.Pointer;
import haxe.io.Bytes;
import haxe.io.BytesData;

// @:headerInclude('../cpp/HxRedisImport.h')
// @:cppInclude('../cpp/HxRedisGlue.cpp')
@:buildXml('
<set name="HXH2O" value="${haxelib:hxh2o}/hxh2o" />
<set name="HXH2O_LIB" value="/usr/lib/h2o" />
<set name="HIREDIS" value="${HXH2O_LIB}/deps/hiredis" />

<files id="haxe">
    <flag value="-I${HXH2O}" />

    <compilerflag value="-I${HXH2O}/cpp/"/>
    <compilerflag value="-I${H2O_MAIN}/include/"/>
    <compilerflag value="-I${HIREDIS}/"/>

    <compilerflag value="-I/opt/local/include/" />
    <compilerflag value="-I/usr/include/" />
    
    <compilerflag value="-I./include"/>
    <compilerflag value="-Iinclude"/>


    <file name="${HXH2O}/cpp/HxRedisGlue.cpp"/>
</files>
<target id="haxe">
    <flag value="-Iinclude"/>
    <flag value="-I./include"/>
    <flag value="-I${HH2O_MAIN2O}/include"/>
    <flag value="-I${HIREDIS}"/>
    <flag value="-I/usr/include"/>
    <flag value="-I${HXH2O}/cpp"/>

    <flag value="-L/usr/lib/x86_64-linux-gnu/"/>
    <flag value="-L${HXH2O_LIB}/"/>
    <flag value="-L${H2O_MAIN}/"/>
    <flag value="-L${HIREDIS}/"/>
    <flag value="-L${HXH2O}/cpp/"/>

    <lib name="-lhiredis"/>
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
#include <../cpp/HxRedisImport.h>
')


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
            context = __redisConnect(host, port);
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

    public function commandArgv(cmdArr:Array<String>):Dynamic{
        var lenArr:Array<Int> = [];
        var strArr:Array<BytesData> = [];
        for(i in cmdArr){
            #if (haxe_ver >= 4.000)
            if(Std.isOfType(i, Bytes)){
            #else
            if(Std.is(i, Bytes)){
            #end
                lenArr.push(i.length);
                var bytes:Bytes = cast i;
                strArr.push(bytes.getData());
            }else{
                var bytes = Bytes.ofString(i);
                trace(bytes.length);
                lenArr.push(bytes.length);
                strArr.push(bytes.getData());
            }
        }
        var resPointer = __redisCommandArgv(context, strArr.length, strArr, lenArr);
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

        untyped __cpp__("_freeRedisReply({0})", resPointer);
        return retValue.data;
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

        untyped __cpp__("_freeRedisReply({0})", resPointer);
        return retValue.data;
    }

    public function appendCommandArgv(cmdArr:Array<Dynamic>){
        bulkSize++;
        var lenArr:Array<Int> = [];
        var strArr:Array<BytesData> = [];
        for(i in cmdArr){
            #if (haxe_ver >= 4.000)
            if(Std.isOfType(i, Bytes)){
            #else
            if(Std.is(i, Bytes)){
            #end
                lenArr.push(i.length);
                var bytes:Bytes = cast i;
                strArr.push(bytes.getData());
            }else{
                lenArr.push((""+i).length);
                strArr.push(Bytes.ofString(""+i).getData());
            }
        }
        __redisAppendCommandArgv(context, strArr.length, strArr, lenArr);
        try{
            checkError();
        }catch(err:Dynamic){
            throw err;
        }
    }

    public function appendCommand(cmd:String){
        bulkSize++;
        __redisAppendCommand(context, cmd);
        try{
            checkError();
        }catch(err:Dynamic){
            throw err;
        }
    }

    public function getBulkReply():Array<Dynamic>{
        var arr = new Array<Dynamic>();

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

        if(retValue.status == HX_REDIS_REPLY_ERROR){
            throw retValue.data;
        }

        try{
            checkError();
        }catch(err:Dynamic){
            throw err;
        }

        untyped __cpp__("_freeRedisReply({0})", resPointer);
        return retValue.data;
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

    @:extern @:native("_redisReaderCreate")
    public static function __redisReaderCreate():Pointer<RedisReader>;

    @:extern @:native("_redisReaderFree")
    public static function __redisReaderFree(reader:Pointer<RedisReader>):Void;

    @:extern @:native("_redisReaderFeed")
    public static function __redisReaderFeed(reader:Pointer<RedisReader>, buffer:ConstCharStar, size:Int):Void;

    @:extern @:native("_getReply")
    public static function __getReply(c:Pointer<RedisContext>):Pointer<HXredisReply>;

    @:extern @:native("_command")
    public static function __command(c:Pointer<RedisContext>, cmd:String):Pointer<HXredisReply>;
    
    @:extern @:native("_redisCommandArgv")
    public static function __redisCommandArgv(c:Pointer<RedisContext>, len:Int, strArr:Array<BytesData>, lenArr:Array<Int>):Pointer<HXredisReply>;

    @:extern @:native("_redisAppendCommandArgv")
    public static function __redisAppendCommandArgv(c:Pointer<RedisContext>, len:Int, strArr:Array<BytesData>, lenArr:Array<Int>):Int;

    @:extern @:native("_checkError")
    public static function __checkError(c:Pointer<RedisContext>):String;

    @:extern @:native("_freeReplyObject")
    public static function __freeReplyObject(reply:RedisReplyPtr):Void;

    @:extern @:native("_redisAppendCommand")
    public static function __redisAppendCommand(context:Pointer<RedisContext>, command:String):Int;

    @:extern @:native("_redisConnect")
    public static function __redisConnect(host:String, port:Int):Pointer<RedisContext>;

    @:extern @:native("_redisReconnect")
    public static function __redisReconnect(c:Pointer<RedisContext>):Int;

    #else

    @:extern @:native("_redisReaderCreate")
    public static function __redisReaderCreate():Pointer<RedisReader> return null;

    @:extern @:native("redisReaderFree")
    public static function __redisReaderFree(reader:Pointer<RedisReader>):Void return null;

    @:extern @:native("redisReaderFeed")
    public static function __redisReaderFeed(reader:Pointer<RedisReader>, buffer:ConstCharStar, size:Int):Void return null;

    @:extern @:native("_getReply")
    public static function __getReply(c:Pointer<RedisContext>):Pointer<HXredisReply> return null;

    @:extern @:native("_command")
    public static function __command(c:Pointer<RedisContext>, cmd:String):Pointer<HXredisReply> return null;
    
    @:extern @:native("_redisCommandArgv")
    public static function __redisCommandArgv(c:Pointer<RedisContext>, len:Int, strArr:Array<BytesData>, lenArr:Array<Int>):Pointer<HXredisReply> return null;

    @:extern @:native("_redisAppendCommandArgv")
    public static function __redisAppendCommandArgv(c:Pointer<RedisContext>, len:Int, strArr:Array<BytesData>, lenArr:Array<Int>):Int return null;

    @:extern @:native("_checkError")
    public static function __checkError(c:Pointer<RedisContext>):String return null;

    @:extern @:native("_freeReplyObject")
    public static function __freeReplyObject(reply:RedisReplyPtr):Void return null;

    @:extern @:native("_redisAppendCommand")
    public static function __redisAppendCommand(context:Pointer<RedisContext>, command:String):Int return null;

    @:extern @:native("redisConnect")
    public static function __redisConnect(host:String, port:Int):Pointer<RedisContext> return null;

    @:extern @:native("redisReconnect")
    public static function __redisReconnect(c:Pointer<RedisContext>):Int return null;

    #end

}
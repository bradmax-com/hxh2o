package;

@:buildXml('
<set name="HXH2O" value="/home/tkwiatek/hxh2o" />
<set name="H2O" value="/home/tkwiatek/h2o" />

<files id="haxe">
    <flag value="-I${HXH2O}" />

    <compilerflag value="-I${HXH2O}/cpp/"/>
    <compilerflag value="-I${H2O}/deps/yoml/"/>
    <compilerflag value="-I${HXH2O}/" />
    <compilerflag value="-I${H2O}/include/"/>

    <compilerflag value="-I/opt/local/include/" if="mac"/>
    <compilerflag value="-I/usr/include/" if="linux"/>
    
    <compilerflag value="-I./include"/>
    <compilerflag value="-Iinclude"/>
    <file name="${HXH2O}/cpp/simple.cpp" >
    </file>
</files>

<files id="haxe">
  <compilerflag value="-I${HXH2O}" />
</files>

<files id="__main__">
  <compilerflag value="-I./include"/>
</files>


<target id="haxe">
    <flag value="-Iinclude"/>
    <flag value="-I./include"/>
    <flag value="-I${H2O}/include"/>
    <flag value="-I/opt/local/include" if="mac"/>
    <flag value="-I/usr/include" if="linux"/>
    <flag value="-I${H2O}/deps/yoml"/>


    <flag value="-L/usr/lib/x86_64-linux-gnu/" if="linux"/>
    <flag value="-L/opt/local/lib/" if="mac"/>
    <flag value="-L${H2O}/"/>
    <flag value="-v"/>

    <lib name="-ldl" />
    <lib name="-luv" />
    <lib name="-lh2o" />
    <lib name="-lssl" />
    <lib name="-lcrypto" />
    <lib name="-lz" />
    <lib name="-lh2o-evloop" />

    <!--
    <flag value="-Wall"/>
    <flag value="-static"/>
    -->
    
    

</target>


')

class Request {
    public var path:String;
    public var method:String;
    public var body:String;
    public var headers:Map<String, String>;

    public function new(){}
}

class Response {
    private var map = new Map<String, String>();
    private var keys:Array<String> = [];
    private var index = 0;

    public var status:Int = 404;
    public var reason:String = "Not Found";
    public var body:String = "";

    public function new(){}

    public function headerGet(key:String):String{
        return map.get(key);
    }

    public function headerSet(key:String, value:String){
        map.set(key, value);
    }
    
    public function headerNext():String{
        return keys[index++];
    }

    public function headerHasNext():Bool{
        return index < keys.length;
    } 

    public function headerReset(){
        for(i in map.keys())
            keys.push(i);
        index = 0;
    }
}

@:unreflective
@:structAccess
@:native("CRequest")
extern class CRequest {
    public var path:String;
    public var method:String;
    public var body:String;
    public var headers:Map<String, String>;
}

@:headerCode('
#include <../../cpp/Import.h>

typedef struct CRequest CRequest;
    struct CRequest {
        String path;
        String method;
        String body;
        ::haxe::ds::StringMap headers;
    };
')

class HXH2O
{
    private static var instance:HXH2O = null;
    public static function getInstance():HXH2O{
        if(instance == null)
            instance = new HXH2O();

        return instance;
    }

    private function new(){}

    public function bind(host:String, port:Int){
        hxh2o_bind(host, port);
    }

    dynamic private static function handlerFunction(req:Request, res:Response){

    }

    public function registerHandler(handler: Request->Response->Void){
        handlerFunction = handler;
    }

    public static function request(req:CRequest){
        var request = new Request();
        request.body = req.body;
        request.headers = req.headers;
        request.method = req.method;
        request.path = req.path;

        var response = new Response();
        
        handlerFunction(request, response);

        return response;
    }

    @:extern @:native("_hxh2o_bind")
    public static function hxh2o_bind(host:String, port:Int):Dynamic return null;
}
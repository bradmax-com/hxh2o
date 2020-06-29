package hxh2o;

@:buildXml('
<set name="HXH2O" value="${haxelib:hxh2o}/hxh2o" />
<set name="HXH2O_LIB" value="/usr/lib/haxe/lib/hxh2o/h2o" />
<!--<set name="HXH2O_LIB" value="/usr/lib/haxe/lib/hxh2o/git/h2o" />-->
<set name="H2O" value="${HXH2O}/h2o" />

<files id="haxe">
    <flag value="-I${HXH2O}" />

    <compilerflag value="-I${HXH2O_LIB}/deps/yoml/"/>
    <!--
    <compilerflag value="-I${HXH2O}/cpp/"/>
    <compilerflag value="-I${HXH2O}/" />
    <compilerflag value="-I${H2O}/include/"/>
    <compilerflag value="-I${H2O}/deps/yoml/"/>

    <compilerflag value="-I/opt/local/include/" />
    <compilerflag value="-I/usr/include/" />
    
    <compilerflag value="-I./include"/>
    <compilerflag value="-Iinclude"/>
    -->
    <file name="${HXH2O}/cpp/simple.cpp"/>
</files>

<files id="haxe">
    <!--
    <compilerflag value="-I${HXH2O}" />
    -->
</files>

<files id="__main__">
    <compilerflag value="-I./include"/>
</files>

<target id="haxe">
    <!--
    <flag value="-Iinclude"/>
    <flag value="-I./include"/>
    <flag value="-I${H2O}/include"/>
    <flag value="-I${H2O}/deps/yoml"/>
    <flag value="-I${HXH2O_LIB}/deps/yoml"/>
    <flag value="-I/usr/include"/>
    -->

    <flag value="-L/usr/lib/x86_64-linux-gnu/"/>
    <flag value="-L${H2O}/"/>
    <flag value="-L${HXH2O_LIB}/"/>

    <lib name="-ldl"/>
    <lib name="-luv"/>
    <lib name="-lh2o" />
    <lib name="-lssl" />
    <lib name="-lcrypto" />
    <lib name="-lh2o-evloop" />
    <lib name="-lz" />
</target>
')



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
#include <../cpp/Import.h>

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

    public function bind(host:String, port:Int, internalPort:Int){
        hxh2o_bind(host, port, internalPort);
    }

    dynamic private static function handlerFunction(req:Request, res:Response){

    }

    public function registerHandler(handler: Request->Response->Void){
        handlerFunction = handler;
    }

    public static function request(req:CRequest){
        var request = new Request();
        request.body = req.body;
        request.method = req.method;
        request.path = req.path;
        request.headers = new Map();
        request.params = new Map();

        if(req.headers != null){
            for(i in req.headers.keys()){
                if(req.headers.exists(i))
                    request.headers.set(i, req.headers.get(i));
            }
        }

        var uri = req.path;
        var i = request.path.indexOf( '?' );
        var eq = -1;
        var ap = -1;
        var key = "";
        var val = "";
        if( i != -1 ) {
            var s:String = uri.substr( i+1 );
            uri = uri.substr(0, i);
            while(s.length > 0){
                eq = s.indexOf("=");
                ap = s.indexOf("&");                
                key = s.substr(0, eq);
                val = s.substr(eq + 1, ap == -1 ? null : (ap - eq - 1));
                
                request.params.set( key, eq == ap ? null : val );
                
                s = s.substr(ap + 1);      
                if(ap == -1)
                    break;
            }
        }

        var response = new Response();
        
        handlerFunction(request, response);

        return response;
    }

    @:extern @:native("_hxh2o_bind")
    public static function hxh2o_bind(host:String, port:Int, internalPort:Int):Dynamic;
}
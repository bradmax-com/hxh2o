package hxh2o;

class Request {
    public var path:String;
    public var method:String;
    public var body:String;
    public var headers:Map<String, String>;
    public var params:Map<String, String>;

    public function new(){}
}
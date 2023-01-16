package hxh2o;

class Response {
    private var map = new Map<String, String>();
    private var keys:Array<String> = [];
    private var index = 0;
    private var body:haxe.io.BytesData;

    public var status:Int = 404;
    public var reason:String = "Not Found";

    public function new(){}

    public function setBody(b: String){
        body = haxe.io.Bytes.ofString(b).getData();
    }

    public function setBodyBytes(b: haxe.io.Bytes){
        body = b.getData();
    }

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
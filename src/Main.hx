package;

typedef Req = HXH2O.Request;
typedef Res = HXH2O.Response;

class Main
{
    public static function main(){
        new Main();
    }

    public function new(){
        HXH2O.getInstance().registerHandler(handler);
        HXH2O.getInstance().bind("0.0.0.0", 12345);
    }

    public static function handler(req:Req, res:Res){
        trace("request " + haxe.Timer.stamp());
    }
}

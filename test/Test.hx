package;

import Router;

class Test{
    public static 
    function main(){
        var api = new Router<Int, Int>();
        api.addRoute("v1/flex_model/:clientToken/:modelSignature", test);
        api.addRoute("v1/:clientToken", test);
        api.addRoute("v1/:clientToken/gym/enter", test);
        api.addRoute("v1/gym/enter/:clientToken", test);
        api.addRoute("void", test);

        api.print();
        // api.addRoute("v1/gym/enter/:clientToken", test);
        // api.addRoute("v1/:clientToken/gym/enter", test);
        try{

            api.resolve("v1/xxx/gym/enter")(2, 1);
            api.resolve("v1/gym/enter/xxx")(2, 1);
            api.resolve("void")(3, 1);
            api.resolve("v1/flex_model/a/b")(4, 1);
            api.resolve("v1/xxx")(0, 1);
            api.resolve("dupa")(10, 1);

        }catch(err:Dynamic){}
    }

    static function test(a:Map<String, Dynamic>, b:Int, c:Int) {
        trace(b+c);
    }
}
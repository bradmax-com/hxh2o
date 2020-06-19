package;

import Router;

class Test{
    public static 
    function main(){
        var api = new Router<Int, Int>();
        // api.addRoute("v1/flex_model/:clientToken/:modelSignature", test);
        // api.addRoute("v1/:clientToken", test);
        // api.addRoute("v1/:clientToken/gym/enter", test);
        // api.addRoute("v1/gym/enter/:clientToken", test);
        // api.addRoute("void", test);




        api.addRoute("v1/:clientToken", test2);
        api.addRoute("v1/license/:clientToken", test);   
        api.addRoute("v1/script.js", test);
        api.addRoute("v1/clappr.js", test);
        api.addRoute("v1/gc.html", test);
        api.addRoute("v1/buffer", test);    
        api.addRoute("v1/update_geo", test);
        api.addRoute("v1/update_dev", test);
        api.addRoute("v1/update_ua", test);
        api.addRoute("v1/gym/enter/:clientToken", test);
        api.addRoute("v1/:clientToken/gym/enter", test);
        api.addRoute("v1/realtime/:clientToken/:movieId", test);
        api.addRoute("v1/flex_model/:clientToken/:modelSignature", test);
        api.addRoute("void", test);

        api.print();
        // api.addRoute("v1/gym/enter/:clientToken", test);
        // api.addRoute("v1/:clientToken/gym/enter", test);
        try{

            api.resolve("v1/buffer")(1,2);
            api.resolve("v1/xxx")(1,2);
            // api.resolve("v1/xxx/gym/enter")(2, 1);
            // api.resolve("v1/gym/enter/xxx")(2, 1);
            // api.resolve("void")(3, 1);
            // api.resolve("v1/flex_model/a/b")(4, 1);
            // api.resolve("v1/xxx")(0, 1);
            // api.resolve("dupa")(10, 1);

        }catch(err:Dynamic){trace("fail");}
    }

    static function test(a:Map<String, Dynamic>, b:Int, c:Int) {
        trace(b+c);
    }

    static function test2(a:Map<String, Dynamic>, b:Int, c:Int) {
        trace(b+c+100);
    }
}
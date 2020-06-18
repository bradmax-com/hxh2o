package;

import Router;

class Test{
    public static 
    function main(){
        var api = new Router<Int, Int>();
        trace("v1/flex_model/:clientToken/:modelSignature");
        api.addRoute("v1/flex_model/:clientToken/:modelSignature", test);
        trace("v1/:clientToken");
        api.addRoute("v1/:clientToken", test);
        trace("v1/:clientToken/gym/enter");
        api.addRoute("v1/:clientToken/gym/enter", test);
        api.addRoute("void", test);

        // api.addRoute("v1/gym/enter/:clientToken", test);
        // api.addRoute("v1/:clientToken/gym/enter", test);
        api.resolve("v1/xxx/gym/enter")(2, 1);
        api.resolve("void")(3, 1);
        api.resolve("v1/flex_model/a/b")(4, 1);
        api.resolve("v1/xxx")(0, 1);
        api.print();
    }

    static function test(a:Map<String, Dynamic>, b:Int, c:Int) {
        trace(b+c);
    }
}
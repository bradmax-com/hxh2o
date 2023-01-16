package hxh2o.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import hxh2o.macros.Macros.*;

class BuildIRoute {
  macro public static function complete() : Array<Field> {
    var fields = Context.getBuildFields();
    injectConstructor(fields);
    injectToString(fields);
    patchMethods(fields);
    makeControllerFunctionsPublic(fields);
    return fields;
  }

  static function injectConstructor(fields : Array<Field>) {
    if(hasField(fields, "new")) return;
    fields.push(createFunctionField("new"));
  }

  static function injectToString(fields : Array<Field>) {
    if(hasField(fields, "toString")) return;
    var cls = Context.getLocalClass().toString();
    fields.push(createFunctionField("toString", macro : String, macro return $v{cls}));
  }

  static function makeControllerFunctionsPublic(fields : Array<Field>) {
    for(field in fields) {
      for (method in hxh2o.Methods.list)
        if(hasMeta(field.meta, ":" + method))
          makeFieldPublic(field);
    }
  }

  static function patchMethods(fields : Array<Field>) {
    var fields = filterControllerMethods(fields);
    for(field in fields) {
      switch field.kind {
        case FFun(f): f.args = f.args.concat([
            // { name : "request", type : macro : express.Request, value : null, opt : false },
            // { name : "response", type : macro : express.Response, value : null, opt : false },
            // { name : "next", type : macro : express.Next, value : null, opt : false }
            { name : "request", type : macro : HXH2O.Request, value : null, opt : false },
            { name : "response", type : macro : HXH2O.Response, value : null, opt : false },
            // { name : "next", type : macro : express.Next, value : null, opt : false }
          ]);
        case _: continue;
      }
    }
  }

  static function filterControllerMethods(fields : Array<Field>) {
    var results = [];
    for(field in fields) {
      if(null == field.meta) continue;
      for(meta in field.meta) {
        var find = meta.name.substring(1);
        var a:Array<String> = cast hxh2o.Methods.list;
        if (a.indexOf(find) < 0) {
          continue;
        }
        results.push(field);
        break;
      }
    }
    return results;
  }
}
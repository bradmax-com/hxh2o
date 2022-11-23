package;

import hxh2o.H2oApi;
import hxh2o.Router;

typedef H2oReq = hxh2o.HXH2O.Request;
typedef H2oRes = hxh2o.HXH2O.Response;

class App {
	public static function main() {
		new App();
	}

	var api = new H2oApi();

	public function new() {
		api.addRoute("user/:id/name", userName);
		api.addRoute("user/:id", user);
		api.addRoute("stats/v1/collect", statsCollect);
		api.bind("0.0.0.0", 9000);
	}

	function userName(params:Map<String, Dynamic>, req:H2oReq, res:H2oRes) {
		res.status = 200;
		res.reason = "OK";
		res.setBody('user id: ${params.get("id")}');
	}

	function user(params:Map<String, Dynamic>, req:H2oReq, res:H2oRes) {
		res.status = 200;
		res.reason = "OK";
		res.setBody('user id: ${params.get("id")}');
	}

	function statsCollect(params:Map<String, Dynamic>, req:H2oReq, res:H2oRes) {}
}

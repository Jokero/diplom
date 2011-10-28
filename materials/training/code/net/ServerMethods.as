package code.net {

	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import flash.events.Event;
	import flash.events.IOErrorEvent;

	public class ServerMethods extends Sprite {
	
		public static var LOAD:String  = "load";
		public static var ERROR:String = "error";
	
		private var request:URLRequest;
		private var loader:URLLoader;
		private var vars:URLVariables;
		
		private var incomingData:XML;
		
		private var url:String = "http://localhost/training/api.php";
	
		public function ServerMethods(viewerID:String, authKey:String, method:String, params:Object = null) {

			request 	   = new URLRequest(url);
			request.method = URLRequestMethod.POST;
			
			vars		   = new URLVariables();
			vars.viewerID  = viewerID;
			vars.method    = method;
			vars.authKey   = authKey;
			vars.rnd	   = Math.random();
			
			for(var i:String in params) vars[i] = params[i];
			
			request.data   = vars;

			loader 		   = new URLLoader();
			loader.addEventListener(Event.COMPLETE, onLoad);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
		
		}
		
		// Передача полученных данных
		public function getData():XML {
		
			return incomingData;
		
		}
		
		// Обработчики событий
		private function onLoad(e:Event):void {
		
			var loader:URLLoader = URLLoader(e.target);
			incomingData 		 = XML(loader.data);
			
			trace(incomingData.s.l);

			dispatchEvent( new Event(LOAD) );
		
		}
		
		private function onError(e:IOErrorEvent):void { dispatchEvent( new Event(ERROR) ); }
	
	}

}
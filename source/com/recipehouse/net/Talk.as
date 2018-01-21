package com.recipehouse.net {
	
	import com.coursevector.data.JSON;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.display.Sprite;
	
	public class Talk extends Sprite {
		
		public static const NAME_ERROR:String = "name_error";
		public static const NAME_AVAIL:String = "name_avail";
		public static const NAME_TAKEN:String = "name_taken";
		public static const NAME_SUCCESS:String = "name_success";
		public static const NAME_FAIL:String = "name_fail";
		public static const RECIPE_NUM:String = "recipe_num";
		public static const RECIPE_NUM_ERROR:String = "recipe_num_error";
		public static const SEND_SUCCESS:String = "send_success";
		public static const SEND_ERROR:String = "send_error";
		public static const SEND_FAIL:String = "send_fail";
		public static const ERASE_SUCCESS:String = "erase_success";
		public static const ERASE_ERROR:String = "erase_error";
		public static const ERASE_FAIL:String = "erase_fail";
		public static const GET_SUCCESS:String = "get_success";
		public static const GET_ERROR:String = "get_error";
		private var _numRecipes:uint;
		private var _recipeData:Array;
		private var _recipeId:uint;
		
		public function Talk() { }
		
		// checkUserName ///////////////////////////////////////////////////
		public function checkUserName(strUserName:String):void {
			var request:URLRequest = new URLRequest("http://www.coursevector.com/recipehouse/checkUserName.php");
			var loader:URLLoader = new URLLoader();
			var _vars:URLVariables = new URLVariables();
			_vars.UserName = strUserName;
			request.data = _vars;
			request.method = URLRequestMethod.POST;
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.addEventListener(Event.COMPLETE, onNameComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onNameIOError);
			loader.load(request);
		}
		
		private function onNameComplete(e:Event):void {
			var loader:URLLoader = URLLoader(e.target);
			if(loader.data.isAvail == "true") {
				dispatchEvent(new Event(NAME_AVAIL));
			} else {
				dispatchEvent(new Event(NAME_TAKEN));
			}
		}
		
		private function onNameIOError(event:IOErrorEvent):void {
			dispatchEvent(new Event(NAME_ERROR));
		}
		///////////////////////////////////////////////////////////////////
		
		// saveUserName ///////////////////////////////////////////////////
		public function saveUserName(strNew:String, strOld:String):void {
			var request:URLRequest = new URLRequest("http://www.coursevector.com/recipehouse/saveUserName.php");
			var loader:URLLoader = new URLLoader();
			var _vars:URLVariables = new URLVariables();
			_vars.newName = strNew;
			if(strOld != "NONE") {
				_vars.oldName = strOld;
			}
			request.data = _vars;
			request.method = URLRequestMethod.POST;
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.addEventListener(Event.COMPLETE, onNameSaveComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onNameIOError);
			
            loader.load(request);
		}
		
		private function onNameSaveComplete(e:Event):void {
			var loader:URLLoader = URLLoader(e.target);
			if(loader.data.success == "true" || loader.data.success == true) {
				dispatchEvent(new Event(NAME_SUCCESS));
			} else {
				dispatchEvent(new Event(NAME_FAIL));
			}
		}
		///////////////////////////////////////////////////////////////////
		
		// checkRecipes ///////////////////////////////////////////////////
		public function checkRecipes(strUserName:String):void {
			var request:URLRequest = new URLRequest("http://www.coursevector.com/recipehouse/checkRecipes.php");
			var loader:URLLoader = new URLLoader();
			var _vars:URLVariables = new URLVariables();
			_numRecipes = undefined;
			_vars.UserName = strUserName;
			request.data = _vars;
			request.method = URLRequestMethod.POST;
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.addEventListener(Event.COMPLETE, onRecipeComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onRecipeIOError);
			loader.load(request);
		}
		
		private function onRecipeComplete(e:Event):void {
			var loader:URLLoader = URLLoader(e.target);
			_numRecipes = uint(loader.data.hasRecipes);
			dispatchEvent(new Event(RECIPE_NUM));
		}
		
		private function onRecipeIOError(event:IOErrorEvent):void {
			dispatchEvent(new Event(RECIPE_NUM_ERROR));
		}
		
		public function get numRecipes():uint {
			return _numRecipes;
		}
		// getRecipes ///////////////////////////////////////////////////
		public function getRecipes(strUserName:String):void {
			var request:URLRequest = new URLRequest("http://www.coursevector.com/recipehouse/getRecipes.php");
			var loader:URLLoader = new URLLoader();
			var _vars:URLVariables = new URLVariables();
			_recipeData = undefined;
			_recipeId = undefined;
			_vars.UserName = strUserName;
			request.data = _vars;
			request.method = URLRequestMethod.POST;
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.addEventListener(Event.COMPLETE, onGetComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onGetIOError);
			loader.load(request);
		}
		
		private function onGetComplete(e:Event):void {
			var loader:URLLoader = URLLoader(e.target);
			_recipeId = uint(loader.data.messageId);
			_recipeData = JSON.deserialize(loader.data.messageData);
			dispatchEvent(new Event(GET_SUCCESS));
		}
		
		private function onGetIOError(event:IOErrorEvent):void {
			dispatchEvent(new Event(GET_ERROR));
		}
		
		public function get recipeData():Array {
			return _recipeData;
		}
		
		public function get recipeId():uint {
			return _recipeId;
		}
		
		// eraseRecipes ///////////////////////////////////////////////////
		public function eraseRecipes(id:uint):void {
			var request:URLRequest = new URLRequest("http://www.coursevector.com/recipehouse/eraseRecipes.php");
			var loader:URLLoader = new URLLoader();
			var _vars:URLVariables = new URLVariables();
			_vars.id = id;
			request.data = _vars;
			request.method = URLRequestMethod.POST;
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.addEventListener(Event.COMPLETE, onEraseComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onEraseIOError);
			loader.load(request);
		}
		
		private function onEraseComplete(e:Event):void {
			var loader:URLLoader = URLLoader(e.target);
			if(loader.data.success == "true" || loader.data.success == true) {
				dispatchEvent(new Event(ERASE_SUCCESS));
			} else {
				dispatchEvent(new Event(ERASE_FAIL));
			}
		}
		
		private function onEraseIOError(event:IOErrorEvent):void {
			dispatchEvent(new Event(ERASE_ERROR));
		}
		
		// setRecipes ///////////////////////////////////////////////////
		public function sendRecipes(arrRecipients:Array, arrRecipes:Array):void {
			var request:URLRequest = new URLRequest("http://www.coursevector.com/recipehouse/sendRecipes.php");
			var loader:URLLoader = new URLLoader();
			var _vars:URLVariables = new URLVariables();
			var strRecipeData:String = JSON.serialize(arrRecipes);
			var strRecipients:String = "";
			for(var i:int = 0; i < arrRecipients.length; i++) {
				strRecipients += arrRecipients[i];
				if(i != (arrRecipients.length - 1)) strRecipients += ",";
			}
			
			_vars.sendData = strRecipeData;
			_vars.sendTo = strRecipients;
			request.data = _vars;
			request.method = URLRequestMethod.POST;
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.addEventListener(Event.COMPLETE, onSendComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onSendIOError);
			loader.load(request);
		}
		
		private function onSendComplete(e:Event):void {
			var loader:URLLoader = URLLoader(e.target);
			if(loader.data.success == "true" || loader.data.success == true) {
				dispatchEvent(new Event(SEND_SUCCESS));
			} else {
				dispatchEvent(new Event(SEND_FAIL));
			}
		}
		
		private function onSendIOError(event:IOErrorEvent):void {
			dispatchEvent(new Event(SEND_ERROR));
		}
	}	
}
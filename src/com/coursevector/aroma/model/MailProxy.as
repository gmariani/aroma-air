////////////////////////////////////////////////////////////////////////////////
//
//  COURSE VECTOR
//  Copyright 2008 Course Vector
//  All Rights Reserved.
//
//  NOTICE: Course Vector permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
/**
 * A single class to control both the Video and Audio proxy
 * 
 * TODO: Fade in/out when seeking
 * 
 * @author Gabriel Mariani
 * @version 0.1
 */

package com.coursevector.aroma.model {
	
    import org.puremvc.as3.multicore.interfaces.IProxy;
    import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	import com.coursevector.aroma.ApplicationFacade;
	import com.coursevector.formats.JSON;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

    public class MailProxy extends Proxy implements IProxy {
        public static const NAME:String = 'MailProxy';
		
		//private var _numRecipes:uint;
		private var _recipeData:Array;
		private var _recipeId:uint;
		
		public function MailProxy() {
            super(NAME);
        }
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		public function get recipeData():Array {
			return _recipeData;
		}
		
		public function get recipeId():uint {
			return _recipeId;
		}
		
		/*public function get numRecipes():uint {
			return _numRecipes;
		}*/
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function checkRecipes(strUserName:String):void {
			var _vars:URLVariables = new URLVariables();
			//_numRecipes = undefined;
			_vars.action = "checkRecipes";
			_vars.userName = strUserName;
			setLoader(ApplicationFacade.URL_PATH + "Aroma.php", _vars, onRecipeComplete, onRecipeIOError);
		}
		
		public function getRecipes(strUserName:String):void {
			var _vars:URLVariables = new URLVariables();
			_recipeData = undefined;
			_recipeId = undefined;
			_vars.action = "getRecipes";
			_vars.userName = strUserName;
			setLoader(ApplicationFacade.URL_PATH + "Aroma.php", _vars, onGetComplete, onGetIOError);
		}
		
		public function eraseRecipes(id:uint):void {
			var _vars:URLVariables = new URLVariables();
			_vars.action = "deleteRecipe";
			_vars.id = id;
			setLoader(ApplicationFacade.URL_PATH + "Aroma.php", _vars, onEraseComplete, onEraseIOError);
		}
		
		public function sendRecipes(arrRecipients:Array, arrRecipes:Array):void {
			var _vars:URLVariables = new URLVariables();
			var strRecipeData:String = JSON.serialize(arrRecipes);
			var strRecipients:String = "";
			strRecipients += arrRecipients.toString();
			/*for(var i:int = 0; i < arrRecipients.length; i++) {
				strRecipients += arrRecipients.toString();
				if(i != (arrRecipients.length - 1)) strRecipients += ",";
			}*/
			
			_vars.action = "saveRecipes";
			_vars.sendData = strRecipeData;
			_vars.sendTo = strRecipients;
			setLoader(ApplicationFacade.URL_PATH + "Aroma.php", _vars, onSendComplete, onSendIOError);
		}
		
		private function setLoader(url:String, vars:URLVariables, onComplete:Function, onError:Function):void {
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
			request.data = vars;
			request.method = URLRequestMethod.POST;
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(request);
		}
		
		private function onRecipeComplete(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			//_numRecipes = uint(loader.data.hasRecipes);
			// Number of recipes in inbox
			sendNotification(ApplicationFacade.MAIL_NEW, uint(loader.data.hasRecipes));
		}
		
		private function onRecipeIOError(event:IOErrorEvent):void {
			sendNotification(ApplicationFacade.MAIL_ERROR, "Unable to check inbox");
		}
		
		private function onGetComplete(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			_recipeId = uint(loader.data.messageId);
			_recipeData = JSON.deserialize(loader.data.messageData);
			sendNotification(ApplicationFacade.MAIL_SUCCESS, {id:_recipeId, data:_recipeData});
		}
		
		private function onGetIOError(event:IOErrorEvent):void {
			sendNotification(ApplicationFacade.MAIL_ERROR, "Unable to retrieve mail");
		}
		
		private function onEraseComplete(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			if(loader.data.success == "true" || loader.data.success == true) {
				sendNotification(ApplicationFacade.ERASE_SUCCESS);
			} else {
				sendNotification(ApplicationFacade.ERASE_FAIL);
			}
		}
		
		private function onEraseIOError(event:IOErrorEvent):void {
			sendNotification(ApplicationFacade.ERASE_ERROR);
		}
		
		private function onSendComplete(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			if(loader.data.success == "true" || loader.data.success == true) {
				sendNotification(ApplicationFacade.SEND_SUCCESS);
			} else {
				sendNotification(ApplicationFacade.SEND_FAIL);
			}
		}
		
		private function onSendIOError(event:IOErrorEvent):void {
			sendNotification(ApplicationFacade.SEND_ERROR);
		}
	}
}
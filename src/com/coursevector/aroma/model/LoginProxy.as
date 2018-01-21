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
 * Facade of the NetStream and NetConnection classes
 * 
 * @author Gabriel Mariani
 * @version 0.1
 */

 // TODO: Check username
 // Save/Login properly

package com.coursevector.aroma.model {
	
    import org.puremvc.as3.multicore.interfaces.IProxy;
    import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	import com.coursevector.aroma.ApplicationFacade;
	import cv.managers.SOManager;
	import com.coursevector.aroma.model.vo.LoginVO;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLVariables;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoaderDataFormat;
	
	public class LoginProxy extends Proxy implements IProxy {
		
		public static const NAME:String = 'LoginProxy';
		
		private var soManager:SOManager = new SOManager();
		private var tempLoginVO:LoginVO;
		
		public function LoginProxy() {
            super(NAME, new LoginVO());
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		public function get loginVO():LoginVO {
			return data as LoginVO;
		}
		
		public function get loggedIn():Boolean {
			return (authToken != null);
		}
		
		public function get authToken():String {
			return loginVO.authToken;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		private function login(tryLogin:LoginVO):void {
			if (!loggedIn) {
				loginVO.username = tryLogin.username;
				loginVO.password = tryLogin.password;
				loginVO.authToken = tryLogin.authToken;
				soManager.save("loginVO", loginVO);
				sendNotification(ApplicationFacade.LOGIN_SUCCESS, authToken);
			} else {
				logout();
				login(tryLogin);
			}
		}
		
		public function logout():void {
			if (loggedIn) data = new LoginVO();
			sendNotification(ApplicationFacade.LOGGED_OUT);
		}
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
			soManager.open("aromaData");
			var savedLogin:LoginVO = soManager.data.loginVO as LoginVO;
			if (savedLogin && savedLogin.authToken) {
				login(savedLogin);
			}
		}
		
		public function createUser(strUser:String, strPass:String):void {
			tempLoginVO = new LoginVO();
			tempLoginVO.username = strUser;
			tempLoginVO.password = strPass;
			tempLoginVO.authToken = "aroma_auth"; // ? dunno what else to put here
			
			var _vars:URLVariables = new URLVariables();
			_vars.action = "createUser";
			_vars.userName = strUser;
			_vars.password = strPass;
			setLoader(ApplicationFacade.URL_PATH + "Aroma.php", _vars, onUserCreate, onCreateIOError);
		}
		
		/*public function saveUserName(strNew:String, strOld:String):void {
			tempLoginVO = new LoginVO();
			tempLoginVO.username = strNew;
			tempLoginVO.password = ""; // not used right now
			tempLoginVO.authToken = "aroma_auth"; // ? dunno what else to put here
			
			var _vars:URLVariables = new URLVariables();
			_vars.action = "saveUserName";
			_vars.newName = strNew;
			if(strOld != "NONE") _vars.oldName = strOld;
			setLoader(ApplicationFacade.URL_PATH + "Aroma.php", _vars, onNameSaveComplete, onNameIOError);
		}*/
		
		public function updateUser(strOldUser:String, strUser:String, strPass:String):void {
			tempLoginVO = new LoginVO();
			tempLoginVO.username = strUser;
			tempLoginVO.password = strPass;
			tempLoginVO.authToken = "aroma_auth"; // ? dunno what else to put here
			
			var _vars:URLVariables = new URLVariables();
			_vars.action = "updateUser";
			_vars.oldName = strOldUser;
			_vars.userName = strUser;
			_vars.password = strPass;
			setLoader(ApplicationFacade.URL_PATH + "Aroma.php", _vars, onUserUpdate, onUpdateIOError);
		}
		
		public function loginUser(strUser:String, strPass:String):void {
			tempLoginVO = new LoginVO();
			tempLoginVO.username = strUser;
			tempLoginVO.password = strPass;
			tempLoginVO.authToken = "aroma_auth"; // ? dunno what else to put here
			
			var _vars:URLVariables = new URLVariables();
			_vars.action = "loginUser";
			_vars.userName = strUser;
			_vars.password = strPass;
			setLoader(ApplicationFacade.URL_PATH + "Aroma.php", _vars, onUserLogin, onLoginIOError);
		}
		
		public function checkUserName(strUserName:String):void {
			var _vars:URLVariables = new URLVariables();
			_vars.action = "checkUserName";
			_vars.userName = strUserName;
			setLoader(ApplicationFacade.URL_PATH + "Aroma.php", _vars, onNameComplete, onNameIOError);
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function onNameComplete(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			if(loader.data.isAvail == "true") {
				sendNotification(ApplicationFacade.NAME_AVAIL);
			} else {
				sendNotification(ApplicationFacade.NAME_TAKEN);
			}
		}
		
		private function onNameIOError(event:IOErrorEvent):void {
			sendNotification(ApplicationFacade.NAME_ERROR);
		}
		
		private function onCreateIOError(event:IOErrorEvent):void {
			sendNotification(ApplicationFacade.CREATE_FAIL);
		}
		
		private function onUpdateIOError(event:IOErrorEvent):void {
			sendNotification(ApplicationFacade.UPDATE_FAIL);
		}
		
		private function onLoginIOError(event:IOErrorEvent):void {
			sendNotification(ApplicationFacade.LOGIN_FAIL);
		}
		
		private function onUserCreate(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			if (loader.data.success == "true" || loader.data.success == true) {
				login(tempLoginVO);
				sendNotification(ApplicationFacade.CREATE_SUCCESS);
			} else {
				sendNotification(ApplicationFacade.CREATE_FAIL);
			}
		}
		
		private function onUserUpdate(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			if (loader.data.success == "true" || loader.data.success == true) {
				login(tempLoginVO);
				sendNotification(ApplicationFacade.UPDATE_SUCCESS);
			} else {
				sendNotification(ApplicationFacade.UPDATE_FAIL);
			}
		}
		
		private function onUserLogin(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			if (loader.data.success == "true" || loader.data.success == true) {
				login(tempLoginVO);
			} else {
				sendNotification(ApplicationFacade.LOGIN_FAIL);
			}
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
	}
}
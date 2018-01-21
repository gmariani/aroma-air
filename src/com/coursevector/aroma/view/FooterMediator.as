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
* ...
* @author Gabriel Mariani
* @version 0.1
* 
*/

package com.coursevector.aroma.view {
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import com.coursevector.aroma.ApplicationFacade;
	//import com.coursevector.aroma.model.LoginProxy;
	import com.coursevector.aroma.model.WindowProxy;
	import com.coursevector.aroma.model.vo.LoginVO;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.Stage;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.display.NativeWindowResize;
	import flash.geom.Rectangle;
	import flash.events.TextEvent;
	
	import gs.TweenLite;

	public class FooterMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'FooterMediator';
		
		private var _windowProxy:WindowProxy;
		//private var _loginProxy:LoginProxy;
		private var txtCopyRight:TextField;
		private var txtName:TextField;
		private var txtStatus:TextField;
		private var sprFooter:Sprite;
		private var userName:String = "";
		
		public function FooterMediator(viewComponent:Object) {
			super(NAME, viewComponent);
			
			init();
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		/*private function get loginProxy():LoginProxy {
			if(_loginProxy == null) _loginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			return _loginProxy;
		}*/
		
		private function get windowProxy():WindowProxy {
			if(_windowProxy == null) _windowProxy = facade.retrieveProxy(WindowProxy.NAME) as WindowProxy;
			return _windowProxy;
		}
		
		private function get stage():Stage {
			return root.stage;
		}
		
		private function get root():DisplayObjectContainer {
			return viewComponent as DisplayObjectContainer;
		}
		
		public function get height():Number {
			return sprFooter.height;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function resize(x:Number, y:Number, bounds:Rectangle):void {
			root.x = x;
			root.y = y;
			sprFooter.width = bounds.width;
			txtCopyRight.x = (bounds.width - txtCopyRight.width) / 2;
		}
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function listNotificationInterests():Array {
			return [ApplicationFacade.LOGIN_SUCCESS, ApplicationFacade.LOGGED_OUT, ApplicationFacade.SQL_ERROR, ApplicationFacade.SQL_START, ApplicationFacade.SQL_FINISH];
		}
		
		override public function handleNotification(note:INotification):void {
			var o:LoginVO = note.getBody() as LoginVO;
			
			switch (note.getName())	{
				case ApplicationFacade.LOGIN_SUCCESS :
				case ApplicationFacade.LOGGED_OUT :
					//setLogStatus(loginProxy.loggedIn, o);
					break;
				case ApplicationFacade.SQL_ERROR :
				case ApplicationFacade.SQL_START :
					txtStatus.text = note.getBody() as String;
					TweenLite.to(txtStatus, 0.25, { autoAlpha:1 } );
					break;
				case ApplicationFacade.SQL_FINISH :
					TweenLite.to(txtStatus, 0.25, { autoAlpha:0 } );
					break;
			}
		}
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
			
			setUserName("");
			//setLogStatus(loginProxy.loggedIn);
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function setLogStatus(value:Boolean, vo:LoginVO=null):void {
			if (value == true) {
				setUserName(vo.username);
			} else {
				setUserName("");
			}
		}
		
		private function init():void {
			sprFooter = root.getChildByName("sprFooter") as Sprite;
			sprFooter.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			txtName = root.getChildByName("txtName") as TextField;
			txtName.autoSize = TextFieldAutoSize.LEFT;
			txtName.embedFonts = true;
			txtName.visible = false;
			txtName.alpha = 0;
			
			txtStatus = root.getChildByName("txtStatus") as TextField;
			txtStatus.autoSize = TextFieldAutoSize.RIGHT;
			txtStatus.embedFonts = true;
			txtStatus.visible = false;
			txtStatus.alpha = 0;
			
			txtCopyRight = root.getChildByName("txtCopyRight") as TextField;
			txtCopyRight.htmlText = "<a href='event:web'>" + new Date().fullYear + " Course Vector</a> | <a href='event:about'>About Aroma</a>";
			txtCopyRight.autoSize = TextFieldAutoSize.CENTER;
			txtCopyRight.embedFonts = true;
			txtCopyRight.addEventListener(TextEvent.LINK, onLink);
		}
		
		private function onLink(e:TextEvent):void {
			if (e.text == "about") {
				sendNotification(ApplicationFacade.ABOUT_SHOW);
			} else {
				navigateToURL(new URLRequest("http://blog.coursevector.com/"));
			}
		}
		
		private function setUserName(strName:String):void {
			if (strName.length == 0) strName = "(Please set in Preferences page)";
			txtName.htmlText = "My User Name: <b>" + strName + "</b>";
		}
		
		private function onMouseDown(e:MouseEvent):void {
			var g:uint = ApplicationFacade.GRIPPER_SIZE;
			if (stage.mouseX >= 0 && stage.mouseX <= g && stage.mouseY <= windowProxy.height && stage.mouseY >= windowProxy.height - g) {
				sendNotification(ApplicationFacade.START_RESIZE, NativeWindowResize.BOTTOM_LEFT );
			} else if (stage.mouseX <= windowProxy.width && stage.mouseX >= windowProxy.width - g && stage.mouseY <= windowProxy.height && stage.mouseY >= windowProxy.height - g) {
				sendNotification(ApplicationFacade.START_RESIZE, NativeWindowResize.BOTTOM_RIGHT );
			} else if (stage.mouseX >= 0 && stage.mouseX <= g) {
				sendNotification(ApplicationFacade.START_RESIZE, NativeWindowResize.LEFT );
			} else if (stage.mouseX >= windowProxy.width - g && stage.mouseX <= windowProxy.width) {
				sendNotification(ApplicationFacade.START_RESIZE, NativeWindowResize.RIGHT );
			} else if (stage.mouseY >= windowProxy.height - g && stage.mouseY <= windowProxy.height) {
				sendNotification(ApplicationFacade.START_RESIZE, NativeWindowResize.BOTTOM );
			}
		}
	}
}
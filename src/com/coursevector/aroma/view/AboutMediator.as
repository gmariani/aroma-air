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
*/

package com.coursevector.aroma.view {

	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import com.coursevector.aroma.ApplicationFacade;
	import cv.managers.UpdateManager;
	
	import fl.controls.Button;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindow;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.events.MouseEvent;

	public class AboutMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'AboutMediator';
		private var txtTitle:TextField;
		private var txtMessage:TextField;
		private var btnOk:Button;
		private var um:UpdateManager;
		private var aw:NativeWindow;
		private var btnClose:SimpleButton;
		private var sprHeader:Sprite;
		
		public function AboutMediator(viewComponent:Object) {
			super(NAME, viewComponent);
			
			um = UpdateManager.instance;
			
			txtTitle = root.getChildByName("txtTitle") as TextField;
			txtTitle.text = "About Aroma";
			
			txtMessage = root.getChildByName("txtMessage") as TextField;
			txtMessage.embedFonts = true;
			txtMessage.htmlText = "Version : <b>" + um.currentVersion + "</b><br/><br/>© " + new Date().fullYear + " Gabriel Mariani<br/>If you're wondering, the logo is<br> supposed to be tea leaves.<br/><br><a href='http://blog.coursevector.com/aroma'><u>http://blog.coursevector.com/aroma</u></a>";
			
			sprHeader = root.getChildByName("sprHeader") as Sprite;
			sprHeader.addEventListener(MouseEvent.MOUSE_DOWN, onMove);
			
			btnOk = root.getChildByName("btnOk") as Button;
			btnOk.addEventListener(MouseEvent.CLICK, onClickOk);
			
			btnClose = root.getChildByName("btnClose") as SimpleButton;
			btnClose.addEventListener(MouseEvent.CLICK, windowHandler);
			
			createWindow();
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		private function get root():MovieClip {
			return viewComponent as MovieClip;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function listNotificationInterests():Array {
			return [ApplicationFacade.ABOUT_SHOW];
		}
		
		override public function handleNotification(note:INotification):void {
			switch(note.getName()) {
				case ApplicationFacade.ABOUT_SHOW :
					if (aw.closed) createWindow();
					aw.activate();
					aw.orderToFront();
					aw.visible = true;
					ApplicationFacade.TRACKER.trackPageview("/aroma/" + ApplicationFacade.VERSION + "/AboutScreen");
					break;
			}
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function onClickOk(event:MouseEvent):void {
			//aw.close();
			aw.visible = false;
		}
		
		private function createWindow():void {
			
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.maximizable = false;
			winArgs.minimizable = true;
			winArgs.resizable = false;
			winArgs.systemChrome = NativeWindowSystemChrome.NONE;
			winArgs.type = NativeWindowType.NORMAL;
			winArgs.transparent = true;
			
			aw = new NativeWindow(winArgs);
			aw.title = "About Aroma";
			aw.width = 326;
			aw.height = 251;
			aw.stage.align = StageAlign.TOP_LEFT;
			aw.stage.scaleMode = StageScaleMode.NO_SCALE;
			aw.stage.addChild(root);
		}
		
		private function onMove(event:MouseEvent):void {
			aw.startMove();
		}
		
		private function windowHandler(e:MouseEvent):void {
			switch(e.target) {
				case btnClose :
					aw.close();
					break;
			}
		}
	}
}
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

package com.coursevector.aroma.view {

	import fl.controls.Button;
	import fl.controls.TextArea;
	import flash.display.MovieClip;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import com.coursevector.aroma.ApplicationFacade;

	public class UpdateMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'UpdateMediator';
		
		private var uw:NativeWindow;
		private var txtTitle:TextField;
		private var txtVersions:TextField;
		private var taNotes:TextArea;
		private var txtMessage:TextField;
		private var sprHeader:Sprite;
		private var btnInstall:Button;
		private var btnCancel:Button;
		private var btnClose:SimpleButton;
		private var btnMinimize:SimpleButton;
		
		public function UpdateMediator(viewComponent:Object) {
			super(NAME, viewComponent);
			
			// Init
			txtMessage = root.getChildByName("txtMessage") as TextField;
			txtTitle = root.getChildByName("txtTitle") as TextField;
			txtVersions = root.getChildByName("txtVersions") as TextField;
			taNotes = root.getChildByName("taNotes") as TextArea;
			
			btnInstall = root.getChildByName("btnInstall") as Button;
			btnInstall.addEventListener(MouseEvent.CLICK, onClickInstall);
			
			btnCancel = root.getChildByName("btnCancel") as Button;
			btnCancel.addEventListener(MouseEvent.CLICK, onClickCancel);
			
			sprHeader = root.getChildByName("sprHeader") as Sprite;
			sprHeader.addEventListener(MouseEvent.MOUSE_DOWN, onMove);
			
			btnClose = root.getChildByName("btnClose") as SimpleButton;
			btnMinimize = root.getChildByName("btnMinimize") as SimpleButton;
			btnClose.addEventListener(MouseEvent.CLICK, windowHandler);
			btnMinimize.addEventListener(MouseEvent.CLICK, windowHandler);
			
			txtTitle.text = "Update Available";
			txtTitle.mouseEnabled = false;
			
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
		
		//
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function listNotificationInterests():Array {
			return [ApplicationFacade.UPDATE_AVAIL, ApplicationFacade.UPDATE_PROGRESS, ApplicationFacade.UPDATE_ERROR, ApplicationFacade.UPDATE_LOAD_ERROR];
		}
		
		override public function handleNotification(note:INotification):void {
			var o:Object = note.getBody();
			switch(note.getName()) {
				case ApplicationFacade.UPDATE_AVAIL :
					txtMessage.text = "An updated version of " + o.currentName + " is available for download.";
					txtVersions.text = o.currentVersion + "\n" + o.remoteVersion;
					taNotes.htmlText = o.description;
					
					if (uw.closed) createWindow();
					uw.activate();
					uw.orderToFront();
					uw.visible = true;
					break;
				case ApplicationFacade.UPDATE_PROGRESS :
					var percent:uint = (o.bytesLoaded / o.bytesTotal) * 100;
					txtTitle.text = "Downloading... " + Math.ceil(percent) + "%";
					break;
				case ApplicationFacade.UPDATE_ERROR :
					btnCancel.enabled = true;
					txtTitle.text = "Error installing update.";
					break;
				case ApplicationFacade.UPDATE_LOAD_ERROR :
					btnCancel.enabled = true;
					txtTitle.text = "Error downloading update.";
					break;
			}
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function onClickCancel(event:MouseEvent):void {
			uw.close();
		}
		
		private function onClickInstall(event:MouseEvent):void {
			btnInstall.enabled = false;
			btnCancel.enabled = false;
			txtTitle.text = "Downloading...";
			sendNotification(ApplicationFacade.UPDATE_INSTALL);
		}
		
		private function createWindow():void {
			
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.maximizable = false;
			winArgs.minimizable = true;
			winArgs.resizable = false;
			winArgs.type = NativeWindowType.NORMAL;
			winArgs.systemChrome = NativeWindowSystemChrome.NONE;
			winArgs.transparent = true;
			
			uw = new NativeWindow(winArgs);
			uw.title = "Update Available";
			uw.width = 536;
			uw.height = 431;
			uw.stage.align = StageAlign.TOP_LEFT;
			uw.stage.scaleMode = StageScaleMode.NO_SCALE;
			uw.stage.addChild(root);
		}
		
		private function onMove(event:MouseEvent):void {
			uw.startMove();
		}
		
		private function windowHandler(e:MouseEvent):void {
			switch(e.target) {
				case btnClose :
					uw.close();
					break;
				case btnMinimize :
					uw.minimize();
					break;
			}
		}
	}
}
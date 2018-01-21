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
* Manages loading and sending skins to the other mediators
* 
* @author Gabriel Mariani
* @version 0.1
*/

package com.coursevector.aroma.view {
	
	import flash.display.MovieClip;
	import flash.display.NativeWindowDisplayState;
	import gs.TweenLite;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import com.google.analytics.AnalyticsTracker;
	import com.google.analytics.GATracker;
	
	import com.coursevector.aroma.ApplicationFacade;
	import com.coursevector.aroma.view.EditScreenMediator;
	import com.coursevector.aroma.view.HeaderMediator;
	import com.coursevector.aroma.view.DisplayScreenMediator;
	import com.coursevector.aroma.model.WindowProxy;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flash.display.NativeWindowResize;
	import flash.events.NativeDragEvent;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragManager;
	import flash.desktop.NativeDragActions;
	import flash.desktop.ClipboardTransferMode;
	
	public class StageMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'StageMediator';
		
		//private var tracker:AnalyticsTracker;
		private var eM:EditScreenMediator;
		private var hM:HeaderMediator;
		private var dM:DisplayScreenMediator;
		private var sprHit:Sprite;
		private var mcCornerGripper:MovieClip;
		private var _windowProxy:WindowProxy;
		
		public function StageMediator(viewComponent:DisplayObjectContainer) {
			super(NAME, viewComponent);
			
			// Analytics
			ApplicationFacade.TRACKER = new GATracker(viewComponent, "UA-349755-7", "AS3", false);
			ApplicationFacade.TRACKER.trackPageview("/aroma/" + ApplicationFacade.VERSION + "/MainScreen");
			
			root.alpha = 0;
			root.visible = false;
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		private function get stage():Stage {
			return root.stage;
		}
		
		private function get root():DisplayObjectContainer {
			return viewComponent as DisplayObjectContainer;
		}
		
		private function get windowProxy():WindowProxy {
			if(_windowProxy == null) _windowProxy = facade.retrieveProxy(WindowProxy.NAME) as WindowProxy;
			return _windowProxy;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function resize(x:Number, y:Number, bounds:Rectangle):void {
			root.x = x;
			sprHit.width = bounds.width;
			sprHit.height = bounds.height;
			mcCornerGripper.x = sprHit.width - 12;
			mcCornerGripper.y = y + sprHit.height - 12;
		}
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function listNotificationInterests():Array {
			return [ApplicationFacade.SQL_ERROR, ApplicationFacade.DISPLAY_STATE_CHANGE];
		}
		
		override public function handleNotification(note:INotification):void {
			switch (note.getName())	{
				case ApplicationFacade.SQL_ERROR :
					sendNotification(ApplicationFacade.ALERT, {title:"Save Error", icon:ApplicationFacade.ERROR, message:note.getBody() as String } );
					break;
				case ApplicationFacade.DISPLAY_STATE_CHANGE :
					// Hide corner grip when maximized
					mcCornerGripper.visible = !(note.getBody().after == NativeWindowDisplayState.MAXIMIZED);
					break;
			}
		}
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
			
			mcCornerGripper = root.getChildByName("mcCornerGripper") as MovieClip;
			mcCornerGripper.useHandCursor = true;
			mcCornerGripper.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			hM = new HeaderMediator(root.getChildByName("mcHeader"));
			facade.registerMediator(hM);
			
			dM = new DisplayScreenMediator(root.getChildByName("mcDisplayScreen"));
			dM.y = hM.height;
			facade.registerMediator(dM);
			
			eM = new EditScreenMediator(root.getChildByName("mcEditScreen"));
			eM.y = stage.height;
			facade.registerMediator(eM);
			
			sprHit = root.getChildByName("mcDragHitArea") as Sprite;
			sprHit.useHandCursor = false;
			sprHit.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			// Init Stage
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, dragHandler);
			stage.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, dragHandler);
			
			TweenLite.to(root, 1, { autoAlpha:1 } );
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function onMouseDown(e:MouseEvent):void {
			if (e.currentTarget == mcCornerGripper) {
				sendNotification(ApplicationFacade.START_RESIZE, NativeWindowResize.BOTTOM_RIGHT);
			} else {
				var g:uint = ApplicationFacade.GRIPPER_SIZE;
				if (stage.mouseX >= 0 && stage.mouseX <= g) {
					sendNotification(ApplicationFacade.START_RESIZE, NativeWindowResize.LEFT );
				} else if (stage.mouseX >= windowProxy.width - g && stage.mouseX <= windowProxy.width) {
					sendNotification(ApplicationFacade.START_RESIZE, NativeWindowResize.RIGHT );
				} else if (stage.mouseY >= windowProxy.height - g && stage.mouseY <= windowProxy.height) {
					sendNotification(ApplicationFacade.START_RESIZE, NativeWindowResize.BOTTOM);
				}
			}
		}
		
		private function dragHandler(e:NativeDragEvent):void {
			switch(e.type) {
				case NativeDragEvent.NATIVE_DRAG_ENTER :
					var cb:Clipboard = e.clipboard;
					if(cb.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)){
						NativeDragManager.dropAction = NativeDragActions.LINK;
						NativeDragManager.acceptDragDrop(stage);
					} else {
						trace("StageMediator::dragHandler - Error : Unrecognized format");
					}
					break;
				case NativeDragEvent.NATIVE_DRAG_DROP :
					var arrFiles:Array = e.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT, ClipboardTransferMode.ORIGINAL_ONLY) as Array;
					sendNotification(ApplicationFacade.DRAG_IMPORT, arrFiles);
					break;
			}
		}
	}
}
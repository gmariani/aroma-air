package com.coursevector.aroma.model {
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
    import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.Stage;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.desktop.NativeApplication;
	
	import com.coursevector.aroma.ApplicationFacade;
	
	public class WindowProxy extends Proxy implements IProxy {
		
		public static const NAME:String = 'WindowProxy';
		
		private var win:NativeWindow;
		
		public function WindowProxy() {
			super(NAME);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		public function set stage(value:DisplayObjectContainer):void {
			win = value.stage.nativeWindow;
			win.addEventListener(Event.RESIZE, onWindowResize);
			win.addEventListener(Event.CLOSING, onClosing);
			win.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, onWindowDisplay);
			// Slightly more than stage to trigger resize event
			win.width = 900;
			win.height = 625;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
		}
		
		public function startResize(value:String):void {
			win.startResize(value);
		}
		
		public function startMove():void {
			win.startMove();
		}
		
		public function close():void {
			sendNotification(ApplicationFacade.EXIT);
		}
		
		public function maximize():void {
			if(win.displayState != NativeWindowDisplayState.MAXIMIZED){
				win.maximize();
			} else {
				win.restore();
			}
		}
		
		public function minimize():void {
			win.minimize();
		}
		
		public function get width():Number {
			return win.width;
		}
		
		public function set width(value:Number):void {
			win.width = value;
		}
		
		public function get height():Number {
			return win.height;
		}
		
		public function set height(value:Number):void {
			win.height = value;
		}
		
		public function get bounds():Rectangle {
			return win.bounds;
		}
		
		public function set bounds(value:Rectangle):void {
			win.bounds = value;
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function onWindowResize(e:NativeWindowBoundsEvent):void	{
			sendNotification(ApplicationFacade.RESIZE, { before:e.beforeBounds, after:e.afterBounds } );
		}
		
		private function onWindowDisplay(e:NativeWindowDisplayStateEvent):void {
			sendNotification(ApplicationFacade.DISPLAY_STATE_CHANGE, { before:e.beforeDisplayState, after:e.afterDisplayState } );
		}
		
		private function onClosing(event:Event):void {
			sendNotification(ApplicationFacade.EXIT);
			
			// Close all windows
			var nA:NativeApplication = NativeApplication.nativeApplication;
			for (var i:int = nA.openedWindows.length - 1; i >= 0; --i) { 
				NativeWindow(nA.openedWindows[i]).close();
			}
		}
	}
}
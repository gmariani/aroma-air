package com.coursevector.aroma.model {
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
    import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	
	import com.coursevector.aroma.ApplicationFacade;
	
	public class AppProxy extends Proxy implements IProxy {
		
		public static const NAME:String = 'AppProxy';
		
		private var app:NativeApplication;
		
		public function AppProxy() {
			super(NAME);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
			
			app = NativeApplication.nativeApplication;
			app.addEventListener(Event.EXITING, onExiting);
		}
		
		public function exit():void {
			app.dispatchEvent(new Event(Event.EXITING));
			app.exit();
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function onExiting(event:Event):void {
			sendNotification(ApplicationFacade.EXITING);
		}
	}
}
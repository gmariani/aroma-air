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

	import flash.events.Event;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import com.coursevector.aroma.ApplicationFacade;
	import com.coursevector.aroma.view.components.PopUp;

	public class PopUpMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'PopUpMediator';
		
		// Assets
		private var p:PopUp = new PopUp();
		
		// Variables
		
		
		public function PopUpMediator(viewComponent:Object) {
			super(NAME, viewComponent);
			
			init();
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		//
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		//
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function listNotificationInterests():Array {
			return [ApplicationFacade.CONFIRM, ApplicationFacade.ALERT];
		}
		
		override public function handleNotification(note:INotification):void {
			var o:Object = note.getBody();
			p.title = o.title;
			p.popupType = note.getName();
			p.callee = o.callee;
			p.icon = o.icon;
			p.text = o.message;
			p.activate();
		}
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
			
			//
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function init():void {
			p.addEventListener(PopUp.ACCEPT, popupHandler);
			p.addEventListener(PopUp.DECLINE, popupHandler);
		}
		
		private function popupHandler(event:Event):void {
			sendNotification(event.type, event.target.callee);
		}
	}
}
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

package com.coursevector.aroma.controller {
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import com.coursevector.aroma.ApplicationFacade;
	import com.coursevector.aroma.view.DisplayScreenMediator;
	import com.coursevector.aroma.view.EditScreenMediator;
	import com.coursevector.aroma.view.HeaderMediator;
	
	import gs.TweenLite;
	
	public class DisplayCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			var eM:EditScreenMediator = facade.retrieveMediator(EditScreenMediator.NAME) as EditScreenMediator;
			var dM:DisplayScreenMediator = facade.retrieveMediator(DisplayScreenMediator.NAME) as DisplayScreenMediator;
			var hM:HeaderMediator = facade.retrieveMediator(HeaderMediator.NAME) as HeaderMediator;
			var onScreenY:Number = hM.height;
			var offScreenY:Number = ApplicationFacade.CENTER_HEIGHT + onScreenY;
			
			switch(note.getBody()) {
				case EditScreenMediator.NAME :
					TweenLite.to(dM, .75, { y: -offScreenY } );
					TweenLite.to(eM, .75, { y: onScreenY } );
					hM.hideDisplayButtons();
					hM.showEditButtons();
					ApplicationFacade.TRACKER.trackPageview("/aroma/" + ApplicationFacade.VERSION + "/EditScreen");
					break;
				default :
					TweenLite.to(dM, .75, { y: onScreenY } );
					TweenLite.to(eM, .75, { y: offScreenY } );
					hM.showDisplayButtons();
					hM.hideEditButtons();
					sendNotification(ApplicationFacade.SET_TITLE, "");
					ApplicationFacade.TRACKER.trackPageview("/aroma/" + ApplicationFacade.VERSION + "/MainScreen");
			}
		}
	}
}
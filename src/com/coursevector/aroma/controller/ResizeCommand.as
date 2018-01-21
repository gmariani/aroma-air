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
* Manages all settings pertaining to the PlayListProxy
* 
* @author Gabriel Mariani
* @version 0.1
*/

package com.coursevector.aroma.controller {
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import com.coursevector.aroma.ApplicationFacade;
	import com.coursevector.aroma.view.StageMediator;
	import com.coursevector.aroma.view.HeaderMediator;
	//import com.coursevector.aroma.view.FooterMediator;
	import com.coursevector.aroma.view.DisplayScreenMediator;
	import com.coursevector.aroma.view.EditScreenMediator;
	
	public class ResizeCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			var o:Object = note.getBody();
			var sM:StageMediator = facade.retrieveMediator(StageMediator.NAME) as StageMediator;
			var hM:HeaderMediator = facade.retrieveMediator(HeaderMediator.NAME) as HeaderMediator;
			//var fM:FooterMediator = facade.retrieveMediator(FooterMediator.NAME) as FooterMediator;
			var dM:DisplayScreenMediator = facade.retrieveMediator(DisplayScreenMediator.NAME) as DisplayScreenMediator;
			var eM:EditScreenMediator = facade.retrieveMediator(EditScreenMediator.NAME) as EditScreenMediator;
			hM.resize(0, 0, o.after);
			//o.after.height -= fM.height;
			//fM.resize(0, o.after.height, o.after);
			o.after.height -= hM.height;
			o.after.height--;
			o.after.width--;
			sM.resize(0, hM.height, o.after);
			ApplicationFacade.CENTER_HEIGHT = o.after.height;
			dM.resize(o.after);
			eM.resize(o.after);
			
			// Reposition
			var onScreenY:Number = hM.height;
			var offScreenY:Number = ApplicationFacade.CENTER_HEIGHT + onScreenY;// + fM.height;
			if (dM.y < 0) {
				dM.y = -offScreenY;
				eM.y = onScreenY;
			} else {
				dM.y = onScreenY;
				eM.y = offScreenY;
			}
		}
	}
}
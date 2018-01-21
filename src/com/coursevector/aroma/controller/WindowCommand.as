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
* Manages all settings pertaining to the MediaProxy
* 
* @author Gabriel Mariani
* @version 0.1
*/

package com.coursevector.aroma.controller {
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import com.coursevector.aroma.ApplicationFacade;
	import com.coursevector.aroma.model.WindowProxy;

	public class WindowCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			var w:WindowProxy = facade.retrieveProxy(WindowProxy.NAME) as WindowProxy;
			
			switch(note.getName()) {
				case ApplicationFacade.CLOSE :
					w.close();
					break;
				case ApplicationFacade.MAXIMIZE :
					w.maximize();
					break;
				case ApplicationFacade.MINIMIZE :
					w.minimize();
					break;
				case ApplicationFacade.START_RESIZE :
					w.startResize(note.getBody() as String);
					break;
				case ApplicationFacade.START_MOVE :
					w.startMove();
					break;
			}
		}
	}
}
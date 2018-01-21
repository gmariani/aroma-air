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
* 
* @author Gabriel Mariani
* @version 0.1
*/

package com.coursevector.aroma.controller {
	
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import com.coursevector.aroma.ApplicationFacade;
	import com.coursevector.aroma.view.DisplayScreenMediator;
	import com.coursevector.aroma.view.EditScreenMediator;
	import com.coursevector.aroma.view.HeaderMediator;
	import com.coursevector.aroma.view.PrintMediator;
	
	public class PrintCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			var dM:DisplayScreenMediator = facade.retrieveMediator(DisplayScreenMediator.NAME) as DisplayScreenMediator;
			var prM:PrintMediator = facade.retrieveMediator(PrintMediator.NAME) as PrintMediator;
			
			switch(note.getName()) {
				case ApplicationFacade.PRINT :
					prM.showPopUp();
					break;
				case ApplicationFacade.PRINT_SPOOL :
					prM.printRecipes(note.getBody() as String, dM.selectedRecipes);
					break;
			}
		}
	}
}
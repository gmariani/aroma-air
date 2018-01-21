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
	
	public class DeleteCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			var dM:DisplayScreenMediator = facade.retrieveMediator(DisplayScreenMediator.NAME) as DisplayScreenMediator;
			
			var str:String = "You are about to delete recipes: \n\n";
			
			for(var i:String in dM.selectedRecipes) {
				str += dM.selectedRecipes[i].title + "\n";
			}
			
			sendNotification(ApplicationFacade.CONFIRM, {title:"Warning", icon:ApplicationFacade.WARNING, message:str, callee:"onClickDelete" } );
		}
	}
}
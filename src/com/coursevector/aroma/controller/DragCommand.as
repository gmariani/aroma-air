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
	
	import flash.display.DisplayObject;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import com.coursevector.aroma.ApplicationFacade;
	import com.coursevector.aroma.model.DragProxy;
	import com.coursevector.aroma.view.DisplayScreenMediator;
	import flash.filesystem.File;
	
	public class DragCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			var dP:DragProxy = facade.retrieveProxy(DragProxy.NAME) as DragProxy;
			var dM:DisplayScreenMediator = facade.retrieveMediator(DisplayScreenMediator.NAME) as DisplayScreenMediator;
			
			switch(note.getName()) {
				case ApplicationFacade.DRAG_EXPORT :
					dP.dragExport(dM.selectedRecipes, note.getBody() as DisplayObject);
					break;
				case ApplicationFacade.EXPORT :
					dP.fileExport(dM.selectedRecipes, note.getBody() as File);
					break;
				case ApplicationFacade.DRAG_IMPORT :
					dP.dragImport(note.getBody() as Array);
					break;
				case ApplicationFacade.IMPORT :
					dP.fileImport(note.getBody() as Array);
					break;
			}
		}
	}
}
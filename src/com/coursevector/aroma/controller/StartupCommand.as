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
* Initializes the Model and Views and their sub components
* Initializes the StageMediator and passes the stage reference
* Initializes the proxies
* 
* @author Gabriel Mariani
* @version 0.1
*/

package com.coursevector.aroma.controller {
	
	import com.coursevector.aroma.model.DragProxy;
	import org.puremvc.as3.multicore.interfaces.ICommand;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	import com.coursevector.aroma.ApplicationFacade;
	import com.coursevector.aroma.view.PopUpMediator;
	import com.coursevector.aroma.view.UpdateMediator;
	import com.coursevector.aroma.view.PrintMediator;
	import com.coursevector.aroma.view.StageMediator;
	import com.coursevector.aroma.view.AboutMediator;
	import com.coursevector.aroma.model.SQLProxy;
	//import com.coursevector.aroma.model.MailProxy;
	import com.coursevector.aroma.model.UpdateProxy;
	//import com.coursevector.aroma.model.LoginProxy;
	import com.coursevector.aroma.model.WindowProxy;
	import com.coursevector.aroma.model.AppProxy;
	import com.coursevector.aroma.model.DragProxy;
	
	import flash.display.DisplayObjectContainer;
	
	public class StartupCommand extends SimpleCommand implements ICommand {
		
		override public function execute(note:INotification):void {
			
			//--------------------------------------
			//  Model
			//--------------------------------------
			
			facade.registerProxy(new SQLProxy());
			
			facade.registerProxy(new UpdateProxy());
			
			//facade.registerProxy(new MailProxy());
			
			//facade.registerProxy(new LoginProxy());
			
			facade.registerProxy(new AppProxy());
			
			facade.registerProxy(new DragProxy());
			
			var wP:WindowProxy = new WindowProxy();
			facade.registerProxy(wP);
			
			//--------------------------------------
			//  View
			//--------------------------------------
			
			var stage:DisplayObjectContainer = note.getBody() as DisplayObjectContainer;
			
			// Display loading icon til database is opened
			// PrepViewCommand
			
			facade.registerMediator(new AboutMediator(new AboutScreen()));
			
			var sM:StageMediator = new StageMediator(stage);
			facade.registerMediator(sM);
			
			var pM:PopUpMediator = new PopUpMediator(stage);
			facade.registerMediator(pM);
			
			var uM:UpdateMediator = new UpdateMediator(new UpdateScreen());
			facade.registerMediator(uM);
			
			var prM:PrintMediator = new PrintMediator(stage);
			facade.registerMediator(prM);
			
			wP.stage = stage;
			
			sendNotification(ApplicationFacade.INITIALIZED, stage);
		}
	}
}
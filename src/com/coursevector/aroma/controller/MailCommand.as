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
	import com.coursevector.aroma.model.LoginProxy;
	import com.coursevector.aroma.model.MailProxy;
	
	// TODO: Make sure actually works
	
	public class MailCommand extends SimpleCommand implements ICommand {
		
		private var numToCheck:int;
		
		override public function execute(note:INotification):void {
			var l:LoginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			var m:MailProxy = facade.retrieveProxy(MailProxy.NAME) as MailProxy;
			var o:Object = note.getBody();
			
			switch(note.getName()) {
				case ApplicationFacade.MAIL_CHECK :
					if(l.loggedIn) {
						//sprGlobalFooter.setUserName(soManager.data.userName);
						m.checkRecipes(l.loginVO.username);
					} else {
						sendNotification(ApplicationFacade.MAIL_ERROR, "Can't check inbox, please login first");
					}
					break;
				case ApplicationFacade.MAIL_SEND :
					if (l.loggedIn) {
						// TODO: ensure all recipients exist via loginproxy
						//RecipeTalk.addEventListener(Talk.NAME_TAKEN, onNameTaken);
						numToCheck = arrRecipient.length;
						for(var i:String in o.to) {
							l.checkUserName(o.to[i]);
						}
						m.sendRecipes(o.to, o.data);
					} else {
						sendNotification(ApplicationFacade.MAIL_ERROR, "Can't send mail, please login first");
					}
					break;
				case ApplicationFacade.NAME_ERROR :
					numToCheck--;
					if (numToCheck == 0) m.sendRecipes(o.to, o.data);
					break;
			}
		}
	}
}
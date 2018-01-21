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
* @version 2.0.0
*/

/*
 * RoadMap
 * 
 * 2.0.0
 * -----
 * -Features
 * Resizable windows - DONE
 * Auto-Update - DONE
 * Header graphics update - DONE
 * Test that database isn't deleted on update - DONE
 * auto-create database if non-existant - DONE
 * fade in ui when opening - DONE
 * have checkbox to designate which search option was selected - DONE
 * auto-create default recipe? - DONE
 * change spacing of ingredients on edit - DONE
 * remove borders of form on edit - DONE
 * Add Yields field - DONE
 * Add source field - DONE
 * Add notes field - DONE
 * Move edit/delete to header - DONE
 * Ability to search by more fields - DONE
 * Remove dropdowns from ingredients - DONE
 * add loading icons to indicate database activity - DONE
 * add form validation - DONE
 * new icon - DONE
 * recipe sorting (a-z, z-a, star) - DONE
 * draggable splitter on recipe display
 * rating inside of recipe list - DONE
 * 
 * -Bugs
 * word wrap title, author, category - DONE
 * have display update when recipe inserted - DONE
 * have display update when recipe deleted - DONE
 * close db conn when exit - DONE
 * fix recipe saving ( SQL COMMAND, fix switch) - DONE
 * fix search dropdown buttons - DONE
 * fix buttons from being accessible when no recipes present - DONE
 * fix resizing of header - DONE
 * fix maximize restore - DONE
 * fix spacing of alert when deleting recipe - DONE
 * disable print - DONE
 * size ingredients initially - DONE
 * fix spacing of pages so you can't see add recipe fade in on load - DONE
 * If error saving recipe, don't change screens - DONE
 * fix search - DONE
 * split database into two tables to not rely on JSON - NOT SURE ABOUT THIS
 * fix masking of ingredients in edit menu - DONE
 * fix spacing of lots of ingredients - DONE
 * add scrollbar in recipe display - DONE
 * add hand cursor for all buttons - DONE
 * hide/disable buttons when in edit mode - DONE
 * add listener to hide search drop down - DONE
 * center popups - DONE
 * close all windows when closing app - DONE
 * changed yields field from integer to text to not lock up saving - DONE
 * 
 * 
 * 2.1.0
 * -----
 * //add filter by category. stars (moved to 2.0)
 * //new icon (moved to 2.0)
 * 
 * -Features
 * printing - DONE
 * add print button - DONE
 * filetype icons - DONE
 * export database (.ckbk) -> .db - Not sure i want to
 * export individual recipes (.rcpe) -> AMF3 - DONE
 * 
 * -Bugs
 * fix how star sorting is represented - DONE
 * focus on newest ingredient added to form - DONE
 * move category dropdown to before rating in edit form - DONE
 * Fix drag-drop hit area - DONE
 * 
 * 2.1.1
 * -----
 * -Features
 * Changed edit ingredients from scroll pane to scrollbar and sprite - DONE
 * 
 * -Bugs
 * Add hand cursor to sort button - DONE
 * Add hand cursor to star sort button - DONE
 * Recenter grab bar on resize - DONE
 * Resize print 3x5 - DONE
 * Add hand cursor to delete ingredient button - DONE
 * select first recipe in recipe list - DONE
 * Fix focus on ingredient textfield - DONE
 * 
 * 2.2.0
 * -----
 * //import individual recipes (drag-drop) (moved to 2.1.0)
 * 
 * -Features
 * Add button/window to determine print type - DONE
 * Move cancel and save to top? - DONE
 * Add import/export button - DONE
 * 
 * -Bugs
 * Format 3x5 so it can be folded in half - Maybe later, get review from jen
 * Fixed EDIT_SAVE, EDIT_CANCEL duplicate bug - DONE
 * 
 * 2.2.1
 * -----
 * 
 * - Bugs
 * Fixed save issue if you had an empty ingredient
 * 
 * 2.2.2
 * -----
 * - Features
 * Add return to add new ingredient
 * No error on empty ingredients, automatically deletes them
 * Added about window
 * 
 * 2.2.3
 * -----
 * - Bugs
 * Turn ingredients into single lines
 * 
 * 2.3.0
 * -----
 * - Features
 * Updated and cleaned up UI
 * Added support for pictures in recipes
 * Popup for save errors
 * Popup to ask to save changes if any
 * Popup when image clicked for close up
 * Added corner drag button
 * 
 * - Bugs
 * Fixed removal of ingredients too fast caused them to overlap
 * Fixed minor UI glitches
 * Fixed selecting first recipe in a sorted list
 * 
 * 2.5.0
 * -----
 * Tagging
 * import database (drag-drop)
 * email files
 *     Determine online status so it doens't break
 *     flash.events.Event.NETWORK_CHANGE
 * Folder organization
 *    recipe book view
 *    recipe detail view
 * 
 * Future
 * -----
 * meal plan view?
 * calendar planner
 * 
 */

package com.coursevector.aroma {
	
	import flash.display.DisplayObjectContainer;
    import org.puremvc.as3.multicore.interfaces.IFacade;
    import org.puremvc.as3.multicore.patterns.facade.Facade;
	import org.puremvc.as3.multicore.patterns.observer.Notification;
	
	import com.coursevector.aroma.controller.StartupCommand;
	import com.coursevector.aroma.controller.WindowCommand;
	import com.coursevector.aroma.controller.AppCommand;
	import com.coursevector.aroma.controller.ResizeCommand;
	import com.coursevector.aroma.controller.DisplayCommand;
	import com.coursevector.aroma.controller.DragCommand;
	import com.coursevector.aroma.controller.EditCommand;
	import com.coursevector.aroma.controller.DeleteCommand;
	import com.coursevector.aroma.controller.UpdateCommand;
	import com.coursevector.aroma.controller.PrintCommand;
	import com.coursevector.aroma.controller.SQLCommand;
	import com.coursevector.aroma.view.components.PopUp;
    
    public class ApplicationFacade extends Facade implements IFacade {
		
		public static var VERSION:String = "2.3.1";
		public static var CENTER_HEIGHT:Number = 0;
		public static const GRIPPER_SIZE:uint = 10;
		public static const URL_PATH:String = "http://www.coursevector.com/projects/aroma/";
		public static const ABOUT_SHOW:String = "ABOUT_SHOW";
		
        // Notification name constants
        public static const STARTUP:String = "startup";
        public static const INITIALIZED:String = "initialized";
        public static const DISPLAY_CHANGE:String = "DISPLAY_CHANGE";
		
		// WindowProxy
		public static const RESIZE:String = "RESIZE";
		public static const DISPLAY_STATE_CHANGE:String = "DISPLAY_STATE_CHANGE";
		public static const EXITING:String = "EXITING";
		
		// LoginProxy
		public static const NAME_ERROR:String = "NAME_ERROR";
		public static const NAME_AVAIL:String = "NAME_AVAIL";
		public static const NAME_TAKEN:String = "NAME_TAKEN";
		public static const CREATE_SUCCESS:String = "CREATE_SUCCESS";
		public static const CREATE_FAIL:String = "CREATE_FAIL";
		public static const UPDATE_SUCCESS:String = "UPDATE_SUCCESS";
		public static const UPDATE_FAIL:String = "UPDATE_FAIL";
		public static const LOGIN_SUCCESS:String = 'LOGIN_SUCCESS';
		public static const LOGIN_FAIL:String = 'LOGIN_FAIL';
		public static const LOGGED_OUT:String = 'LOGGED_OUT';
		
		// MailProxy
		public static const MAIL_CHECK:String = "MAIL_CHECK";
		public static const MAIL_SEND:String = "MAIL_SEND";
		public static const MAIL_ERASE:String = "MAIL_ERASE";
		public static const MAIL_NEW:String = "MAIL_NEW";
		public static const RECIPE_NUM:String = "RECIPE_NUM";
		public static const RECIPE_NUM_ERROR:String = "RECIPE_NUM_ERROR";
		public static const SEND_SUCCESS:String = "SEND_SUCCESS";
		public static const SEND_ERROR:String = "SEND_ERROR";
		public static const SEND_FAIL:String = "SEND_FAIL";
		public static const ERASE_SUCCESS:String = "ERASE_SUCCESS";
		public static const ERASE_ERROR:String = "ERASE_ERROR";
		public static const ERASE_FAIL:String = "ERASE_FAIL";
		public static const MAIL_SUCCESS:String = "MAIL_SUCCESS";
		public static const MAIL_ERROR:String = "MAIL_ERROR";
		
		// SQLProxy
		public static const SQL_OPEN:String = "SQL_OPEN";
		public static const SQL_RESULT:String = "SQL_RESULT";
		public static const SQL_START:String = "SQL_START";
		public static const SQL_FINISH:String = "SQL_FINISH";
		public static const SQL_ERROR:String = "SQL_ERROR";
		public static const SQL_SAVE:String = "SQL_SAVE";
		public static const SQL_DELETE:String = "SQL_DELETE";
		public static const EXIT:String = "EXIT";
		
		// UpdateProxy
		public static const UPDATE_AVAIL:String = "UPDATE_AVAIL";
		public static const UPDATE_DOWNLOAD:String = "UPDATE_DOWNLOAD";
		public static const UPDATE_LOAD_ERROR:String = "UPDATE_LOAD_ERROR";
		public static const UPDATE_NONE_AVAIL:String = "UPDATE_NONE_AVAIL";
		public static const UPDATE_ERROR:String = "UPDATE_ERROR";
		public static const UPDATE_CHECKING:String = "UPDATE_CHECKING";
		public static const UPDATE_PROGRESS:String = "UPDATE_PROGRESS";
		public static const UPDATE_INSTALL:String = "UPDATE_INSTALL";
		public static const UPDATE_CHECK:String = "UPDATE_CHECK";
		
		// DragProxy
		public static const DRAG_EXPORT:String = "DRAG_EXPORT";
		public static const EXPORT:String = "EXPORT";
		public static const DRAG_IMPORT:String = "DRAG_IMPORT";
		public static const IMPORT:String = "IMPORT";
		
		// StageMediator
		public static const START_RESIZE:String = "START_RESIZE";
		public static const START_MOVE:String = "START_MOVE";
		
		// HeaderMediator
		public static const SEARCH:String = "SEARCH";
		public static const SEARCH_TYPE_NAME:String = "Name";
		public static const SEARCH_TYPE_INGREDIENT:String = "Ingredient";
		public static const SEARCH_TYPE_AUTHOR:String = "Author";
		public static const SEARCH_TYPE_CATEGORY:String = "Category";
		public static const SEARCH_TYPE_SOURCE:String = "Source";
		public static const CLOSE:String = "CLOSE";
		public static const MAXIMIZE:String = "MAXIMIZE";
		public static const MINIMIZE:String = "MINIMIZE";
		public static const ADD:String = "ADD";
		public static const SET_TITLE:String = "SET_TITLE";
		
		// PrintMediator
		public static const PRINT:String = "PRINT";
		public static const PRINT_SPOOL:String = "PRINT_SPOOL";
		public static const CARD_3X5:String = "CARD_3X5";
		public static const CARD_4X6:String = "CARD_4X6";
		public static const PAGE:String = "PAGE";
		
		// EditScreenMediator
		public static const EDIT_SAVE:String = "EDIT_SAVE";
		public static const EDIT_DELETE:String = "EDIT_DELETE";
		public static const EDIT_CANCEL:String = "EDIT_CANCEL";
		public static const EDIT_MODIFIED:String = "EDIT_MODIFIED";
		public static const ADD_INGREDIENT:String = "ADD_INGREDIENT";
		public static const ADD_PICTURE:String = "ADD_PICTURE";
		public static const REMOVE_PICTURE:String = "REMOVE_PICTURE";
		
		// DisplayScreenMediator
		public static const EDIT:String = "EDIT";
		public static const DELETE:String = "DELETE";
		public static const SHARE:String = "SHARE";
		public static const MULTIPLE_SELECTED:String = "MULTIPLE_SELECTED";
		public static const NONE_SELECTED:String = "NONE_SELECTED";
		
		// PopUpMediator
		public static const ALERT:String = PopUp.ALERT;
		public static const CONFIRM:String = PopUp.CONFIRM
		public static const WARNING:String = PopUp.WARNING;
		public static const INFORMATION:String = PopUp.INFORMATION;
		public static const ERROR:String = PopUp.ERROR;
		public static const ACCEPT:String = PopUp.ACCEPT;
		public static const DECLINE:String = PopUp.DECLINE;
		
		public function ApplicationFacade(key:String) {
			super(key);	
		}
		
		/**
         * Singleton ApplicationFacade Factory Method
         */
        public static function getInstance(key:String):ApplicationFacade {
            if (instanceMap[key] == null) instanceMap[key] = new ApplicationFacade(key);
            return instanceMap[key] as ApplicationFacade;
        }
		
		/**
         * Application startup
         * 
         * @param app a reference to the application component 
         */  
        public function startup(app:DisplayObjectContainer):void {
        	sendNotification(ApplicationFacade.STARTUP, app);
        }
		
        override protected function initializeController():void {
			super.initializeController();
			
			registerCommand(ApplicationFacade.STARTUP, 			StartupCommand);
			registerCommand(ApplicationFacade.CLOSE, 			WindowCommand);
			registerCommand(ApplicationFacade.MAXIMIZE, 		WindowCommand);
			registerCommand(ApplicationFacade.MINIMIZE, 		WindowCommand);
			registerCommand(ApplicationFacade.START_RESIZE, 	WindowCommand);
			registerCommand(ApplicationFacade.START_MOVE, 		WindowCommand);
			registerCommand(ApplicationFacade.EXIT, 			AppCommand);
			registerCommand(ApplicationFacade.RESIZE, 			ResizeCommand);
			registerCommand(ApplicationFacade.DISPLAY_CHANGE,	DisplayCommand);
			registerCommand(ApplicationFacade.DELETE,			DeleteCommand);
			registerCommand(ApplicationFacade.EDIT,				EditCommand);
			//registerCommand(ApplicationFacade.EDIT_SAVE,		EditCommand);
			//registerCommand(ApplicationFacade.EDIT_CANCEL,	EditCommand);
			registerCommand(ApplicationFacade.SQL_SAVE,			SQLCommand);
			registerCommand(ApplicationFacade.SQL_DELETE,		SQLCommand);
			registerCommand(ApplicationFacade.EXITING,			SQLCommand);
			registerCommand(ApplicationFacade.UPDATE_INSTALL,	UpdateCommand);
			registerCommand(ApplicationFacade.INITIALIZED,		UpdateCommand);
			registerCommand(ApplicationFacade.PRINT,			PrintCommand);
			registerCommand(ApplicationFacade.PRINT_SPOOL,		PrintCommand);
			registerCommand(ApplicationFacade.DRAG_EXPORT,		DragCommand);
			registerCommand(ApplicationFacade.EXPORT,			DragCommand);
			registerCommand(ApplicationFacade.DRAG_IMPORT,		DragCommand);
			registerCommand(ApplicationFacade.IMPORT,			DragCommand);
        }
    }
}
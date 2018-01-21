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
* 
* scalable ui
* sends notification for searches
* sends notification for nav buttons
* sends notification for nativewindow actions
* sends notification to check inbox
* 
* listens for when inbox has message
*/

package com.coursevector.aroma.view {
	
	import flash.text.TextFieldAutoSize;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	import com.coursevector.aroma.ApplicationFacade;
	import com.coursevector.aroma.view.components.SearchDropDown;
	import com.coursevector.aroma.view.EditScreenMediator;
	//import com.coursevector.aroma.view.PrefScreenMediator;
	import gs.TweenLite;
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.filesystem.File;
	import flash.events.FileListEvent;
	import flash.net.FileFilter;
	
	public class HeaderMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'HeaderMediator';
		
		// Assets
		// Display
		private var btnAddRecipe:MovieClip;
		private var btnEditRecipe:MovieClip;
		private var btnDeleteRecipe:MovieClip;
		private var btnPrintRecipe:MovieClip;
		private var btnImportRecipe:MovieClip;
		private var btnExportRecipe:MovieClip;
		// Edit
		private var btnCancel:MovieClip;
		private var btnSave:MovieClip;
		private var btnAddIng:MovieClip;
		private var btnAddPic:MovieClip;
		private var btnRemovePic:MovieClip;
		// Other
		private var sprLogo:Sprite;
		private var btnClose:SimpleButton;
		private var sprHeader:Sprite;
		private var btnMaximize:SimpleButton;
		private var btnMinimize:SimpleButton;
		private var sprSearch:Sprite;
		private var mcPipe:MovieClip;
		private var mcPipe2:MovieClip;
		private var txtSearch:TextField;
		private var txtSearchTitle:TextField;
		private var sprSearchDD:SearchDropDown;
		
		// Variables
		private var _searchType:String = ApplicationFacade.SEARCH_TYPE_NAME;
		private var _searchText:String = "";
		private var isMulti:Boolean = false;
		private var isNone:Boolean = false;
		private var fileDir:File = File.desktopDirectory;
		private var fileRecipe:File = File.desktopDirectory.resolvePath("untitled.rcpe");
		private var isModified:Boolean = false;
		
		public function HeaderMediator(viewComponent:Object) {
			super(NAME, viewComponent);
			
			init();
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		private function get root():DisplayObjectContainer {
			return viewComponent as DisplayObjectContainer;
		}
		
		public function get height():Number {
			return sprHeader.height;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function resize(x:Number, y:Number, bounds:Rectangle):void {
			root.x = x;
			root.y = y;
			sprHeader.width = bounds.width;
			var rightMargin:uint = 12;
			var leftMargin:uint = 7.5;
			var btnWidth:uint = 19;
			btnClose.x = bounds.width - rightMargin - btnWidth;
			btnMaximize.x = btnClose.x - btnWidth;
			btnMinimize.x = btnMaximize.x - btnWidth;
			
			sprSearch.x = bounds.width - rightMargin - sprSearch.width;
			txtSearch.x = sprSearch.x;
			sprSearchDD.x = sprSearch.x - 20;
			txtSearchTitle.x = sprSearch.x + ((sprSearch.width - txtSearchTitle.width) / 2);
			sprLogo.x = (bounds.width - sprLogo.width) / 2;
			
			// Display Buttons
			btnAddRecipe.x = leftMargin;
			btnEditRecipe.x = btnAddRecipe.x + btnAddRecipe.width + 5;
			btnDeleteRecipe.x = btnEditRecipe.x + btnEditRecipe.width + 5;
			btnPrintRecipe.x = btnDeleteRecipe.x + btnDeleteRecipe.width + 5;
			btnImportRecipe.x = btnPrintRecipe.x + btnPrintRecipe.width + 5;
			btnExportRecipe.x = btnImportRecipe.x + btnImportRecipe.width + 5;
			
			// Edit Buttons
			btnCancel.x = leftMargin;
			btnSave.x = btnCancel.x + btnCancel.width + 5;
			mcPipe.x = btnSave.x + btnSave.width;
			btnAddIng.x = mcPipe.x + 5;
			mcPipe2.x = btnAddIng.x + btnAddIng.width;
			btnAddPic.x = mcPipe2.x + 5;
			btnRemovePic.x = btnAddPic.x + btnAddPic.width + 5;
		}
		
		public function hideEditButtons():void {
			disableButton(btnCancel);
			disableButton(btnSave);
			disableButton(btnAddIng);
			disableButton(btnAddPic);
			disableButton(btnRemovePic);
			TweenLite.to(mcPipe, .25, { autoAlpha:0 } );
			TweenLite.to(mcPipe2, .25, { autoAlpha:0 } );
		}
		
		public function hideDisplayButtons():void {
			disableButton(btnAddRecipe);
			disableButton(btnEditRecipe);
			disableButton(btnDeleteRecipe);
			disableButton(btnPrintRecipe);
			disableButton(btnImportRecipe);
			disableButton(btnExportRecipe);
		}
		
		public function showEditButtons():void {
			enableButton(btnCancel);
			enableButton(btnSave);
			enableButton(btnAddIng);
			enableButton(btnAddPic);
			enableButton(btnRemovePic);
			TweenLite.to(mcPipe, .25, { autoAlpha:0.5 } );
			TweenLite.to(mcPipe2, .25, { autoAlpha:0.5 } );
		}
		
		public function showDisplayButtons():void {
			enableButton(btnAddRecipe);
			
			if (isNone) {
				disableButton(btnEditRecipe);
				disableButton(btnDeleteRecipe);
				disableButton(btnPrintRecipe);
				disableButton(btnImportRecipe);
				disableButton(btnExportRecipe);
			} else if (!isNone && isMulti) {
				disableButton(btnEditRecipe);
				enableButton(btnDeleteRecipe);
				enableButton(btnPrintRecipe);
				enableButton(btnImportRecipe);
				disableButton(btnExportRecipe);
			} else if (!isNone && !isMulti) {
				enableButton(btnEditRecipe);
				enableButton(btnDeleteRecipe);
				enableButton(btnPrintRecipe);
				enableButton(btnImportRecipe);
				enableButton(btnExportRecipe);
			} else {
				disableButton(btnEditRecipe);
				disableButton(btnDeleteRecipe);
				disableButton(btnPrintRecipe);
				disableButton(btnImportRecipe);
				disableButton(btnExportRecipe);
			}
		}
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function listNotificationInterests():Array {
			return [ApplicationFacade.ACCEPT, ApplicationFacade.SET_TITLE, ApplicationFacade.MULTIPLE_SELECTED, ApplicationFacade.NONE_SELECTED, ApplicationFacade.EDIT_MODIFIED, ApplicationFacade.DECLINE];
		}
		
		override public function handleNotification(note:INotification):void {
			var o:Object = note.getBody();
			switch (note.getName())	{
				case ApplicationFacade.SET_TITLE :
					var txt:TextField = sprLogo.getChildByName("txtLabel") as TextField;
					txt.autoSize = TextFieldAutoSize.CENTER;
					txt.htmlText = "<b>" + String(note.getBody()) + "Aroma</b>";
					break;
				case ApplicationFacade.MULTIPLE_SELECTED :
					isNone = false;
					if (Boolean(note.getBody()) == true) {
						isMulti = true;
						disableButton(btnEditRecipe);
						disableButton(btnExportRecipe);
					} else {
						isMulti = false;
						enableButton(btnEditRecipe);
						enableButton(btnExportRecipe);
					}
					enableButton(btnDeleteRecipe);
					enableButton(btnPrintRecipe);
					enableButton(btnImportRecipe);
					break;
				case ApplicationFacade.NONE_SELECTED :
					isNone = true;
					disableButton(btnEditRecipe);
					disableButton(btnDeleteRecipe);
					disableButton(btnPrintRecipe);
					disableButton(btnImportRecipe);
					disableButton(btnExportRecipe);
					break;
				case ApplicationFacade.EDIT_MODIFIED :
					isModified = note.getBody() as Boolean;
					break;
				case ApplicationFacade.DECLINE :
					if (note.getBody() == "onCancelEdit") {
						sendNotification(ApplicationFacade.EDIT_CANCEL);
						sendNotification(ApplicationFacade.DISPLAY_CHANGE);
					}
					break;
				case ApplicationFacade.ACCEPT :
					if (note.getBody() == "onCancelEdit") {
						sendNotification(ApplicationFacade.EDIT_SAVE);
					}
					break;
			}
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function disableButton(btn:MovieClip):void {
			btn.enabled = false;
			btn.removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			btn.removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
			TweenLite.to(btn, .25, { autoAlpha:0 } );
		}
		
		private function enableButton(btn:MovieClip):void {
			btn.enabled = true;
			btn.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			btn.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			TweenLite.to(btn, .25, { autoAlpha:0.5 } );
		}
		
		private function init():void {
			fileDir.addEventListener(FileListEvent.SELECT_MULTIPLE, onImport);
			fileRecipe.addEventListener(Event.SELECT, onExport);
			
			btnAddRecipe = root.getChildByName("btnAddRecipe") as MovieClip;
			btnEditRecipe = root.getChildByName("btnEditRecipe") as MovieClip;
			btnDeleteRecipe = root.getChildByName("btnDeleteRecipe") as MovieClip;
			btnPrintRecipe = root.getChildByName("btnPrintRecipe") as MovieClip;
			btnImportRecipe = root.getChildByName("btnImportRecipe") as MovieClip;
			btnExportRecipe = root.getChildByName("btnExportRecipe") as MovieClip;
			btnCancel = root.getChildByName("btnCancel") as MovieClip;
			btnSave = root.getChildByName("btnSave") as MovieClip;
			btnAddIng = root.getChildByName("btnAddIng") as MovieClip;
			btnAddPic = root.getChildByName("btnAddPic") as MovieClip;
			btnRemovePic = root.getChildByName("btnRemovePic") as MovieClip;
			sprLogo = root.getChildByName("sprLogo") as Sprite;
			mcPipe = root.getChildByName("mcPipe") as MovieClip;
			mcPipe2 = root.getChildByName("mcPipe2") as MovieClip;
			sprSearch = root.getChildByName("sprSearch") as Sprite;
			sprHeader = root.getChildByName("sprHeader") as Sprite;
			btnClose = root.getChildByName("btnClose") as SimpleButton;
			btnMinimize = root.getChildByName("btnMinimize") as SimpleButton;
			btnMaximize = root.getChildByName("btnMaximize") as SimpleButton;
			txtSearch = root.getChildByName("txtSearch") as TextField;
			txtSearchTitle = root.getChildByName("txtSearchTitle") as TextField;
			sprSearchDD = root.getChildByName("sprSearchDD") as SearchDropDown;
			
			txtSearchTitle.mouseEnabled = false;
			
			sprLogo.addEventListener(MouseEvent.CLICK, clickHandler);
			sprLogo.mouseChildren = false;
			sprLogo.buttonMode = true;
			
			initButton(btnAddRecipe);
			initButton(btnEditRecipe);
			initButton(btnDeleteRecipe);
			initButton(btnPrintRecipe);
			initButton(btnImportRecipe);
			initButton(btnExportRecipe);
			initButton(btnCancel);
			initButton(btnSave);
			initButton(btnAddIng);
			initButton(btnAddPic);
			initButton(btnRemovePic);
			
			sprSearchDD.dataProvider = [ApplicationFacade.SEARCH_TYPE_NAME, ApplicationFacade.SEARCH_TYPE_INGREDIENT, ApplicationFacade.SEARCH_TYPE_AUTHOR, ApplicationFacade.SEARCH_TYPE_CATEGORY, ApplicationFacade.SEARCH_TYPE_SOURCE];
			sprSearchDD.addEventListener(SearchDropDown.SELECTED, onSelected);
			
			btnClose.addEventListener(MouseEvent.CLICK, windowHandler);
			btnMaximize.addEventListener(MouseEvent.CLICK, windowHandler);
			btnMinimize.addEventListener(MouseEvent.CLICK, windowHandler);
			
			sprHeader.addEventListener(MouseEvent.MOUSE_DOWN, onMove);
			
			txtSearch.text = "";
			txtSearch.addEventListener(Event.CHANGE, onChangeSearch);
			
			hideEditButtons();
			showDisplayButtons();
		}
		
		private function initButton(btn:MovieClip):void {
			btn.alpha = .5;
			btn.buttonMode = true;
			btn.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			btn.addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			btn.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		private function overHandler(e:MouseEvent):void {
			if(e.currentTarget.enabled) {
				TweenLite.to(e.currentTarget, 0.5, { autoAlpha:1 } );
			} else {
				TweenLite.to(e.currentTarget, 0.25, { autoAlpha:0 } );
			}
		}
		
		private function outHandler(e:MouseEvent):void {
			if(e.currentTarget.enabled) {
				TweenLite.to(e.currentTarget, 0.5, { autoAlpha:.5 } );
			} else {
				TweenLite.to(e.currentTarget, 0.25, { autoAlpha:0 } );
			}
		}
		
		/*private function highlightButton(curButton:SimpleButton):void {
			curButton.enabled = true;
			TweenMax.sequence(curButton, [
				{time:.15, alpha:1, y:30},
				{time:.15, alpha:.2},
				{time:.15, alpha:1},
				{time:.15, alpha:.2},
				{time:.15, alpha:1},
				{time:.15, alpha:.2},
				{time:.15, alpha:1}
			]);
		}*/
		
		private function clickHandler(e:MouseEvent):void {
			switch(e.currentTarget) {
				case sprLogo :
					sendNotification(ApplicationFacade.ABOUT_SHOW);
					break;
				case btnAddRecipe :
					sendNotification(ApplicationFacade.ADD);
					sendNotification(ApplicationFacade.SET_TITLE, "Add Recipe - ");
					sendNotification(ApplicationFacade.DISPLAY_CHANGE, EditScreenMediator.NAME);
					break;
				case btnEditRecipe :
					sendNotification(ApplicationFacade.EDIT);
					sendNotification(ApplicationFacade.SET_TITLE, "Edit Recipe - ");
					sendNotification(ApplicationFacade.DISPLAY_CHANGE, EditScreenMediator.NAME);
					break;
				case btnCancel :
					if (isModified) {
						sendNotification(ApplicationFacade.CONFIRM, {title:"Save Changes?", icon:ApplicationFacade.CONFIRM, message:"Would you like to save changes?", callee:"onCancelEdit" } );
					} else {
						sendNotification(ApplicationFacade.EDIT_CANCEL);
						sendNotification(ApplicationFacade.DISPLAY_CHANGE);
					}
					break;
				case btnSave :
					sendNotification(ApplicationFacade.EDIT_SAVE);
					break;
				case btnDeleteRecipe :
					sendNotification(ApplicationFacade.DELETE);
					break;
				case btnPrintRecipe :
					sendNotification(ApplicationFacade.PRINT);
					break;
				case btnImportRecipe :
					var allFilter:FileFilter = new FileFilter("All Files", "*.*;");
					var recipeFilter:FileFilter = new FileFilter("Recipes", "*.rcpe;");
					fileDir.browseForOpenMultiple("Select a recipe", [recipeFilter, allFilter]);
					break;
				case btnExportRecipe :
					fileRecipe.browseForSave("Save As");
					break;
				case btnAddIng :
					sendNotification(ApplicationFacade.ADD_INGREDIENT);
					break;
				case btnAddPic :
					sendNotification(ApplicationFacade.ADD_PICTURE);
					break;
				case btnRemovePic :
					sendNotification(ApplicationFacade.REMOVE_PICTURE);
					break;
			}
		}
		
		private function onSelected(e:Event):void {
			_searchType = e.target.curSelected;
			sendNotification(ApplicationFacade.SEARCH, {string:_searchText, type:_searchType});
		}
		
		private function onChangeSearch(e:Event):void {
			_searchText = txtSearch.text;
			sendNotification(ApplicationFacade.SEARCH, {string:_searchText, type:_searchType});
		}
		
		private function onImport(event:FileListEvent):void {
			sendNotification(ApplicationFacade.IMPORT, event.files);
		}
		
		private function onExport(event:Event):void {
			sendNotification(ApplicationFacade.EXPORT, event.target);
		}
		
		private function onMove(e:MouseEvent):void {
			sendNotification(ApplicationFacade.START_MOVE);
		}
		
		private function windowHandler(e:MouseEvent):void {
			switch(e.target) {
				case btnClose :
					sendNotification(ApplicationFacade.CLOSE);
					break;
				case btnMaximize :
					sendNotification(ApplicationFacade.MAXIMIZE);
					break;
				case btnMinimize :
					sendNotification(ApplicationFacade.MINIMIZE);
					break;
			}
		}
	}
}
// TODO fix update display when a new recipe is added

package com.recipehouse {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.desktop.Updater;
	
	import gs.TweenLite;
	import com.recipehouse.DisplayRecipe;
	import com.recipehouse.AddRecipe;
	import com.recipehouse.Preferences;
	import com.recipehouse.GlobalNav;
	import com.recipehouse.GlobalFooter;
	import com.recipehouse.sql.SQLRecipe;
	import com.recipehouse.net.Talk;
	import com.recipehouse.ui.PopUp;
	import com.recipehouse.ui.InboxButton;
	import com.recipehouse.display.ReceivePopUp;
	import com.coursevector.data.SOManager;
	
	public class Main extends Sprite {
		
		private const STARTX:uint = 16;
		
		private var btnAddRecipe:SimpleButton = new AddRecipeButton();
		private var btnPreferences:SimpleButton = new PreferencesButton();
		private var btnInbox:InboxButton = new InboxButton();
		private var btnClose:SimpleButton = new CloseButton();
		private var btnMin:SimpleButton = new MinimizeButton();
		
		private var sprGlobalNav:GlobalNav = new GlobalNav();
		private var sprGlobalFooter:GlobalFooter = new GlobalFooter();
		private var sprDisplayRecipe:DisplayRecipe = new DisplayRecipe();
		private var sprAddRecipe:AddRecipe = new AddRecipe();
		private var sprPreferences:Preferences = new Preferences();
		private var sprPageHolder:Sprite = new Sprite();
		private var sprMask:Sprite = new Sprite();
		private var sprFade:Sprite = new FadeCover();
		private var sprReceivePopUp:ReceivePopUp = new ReceivePopUp();
		private var sprAlert:PopUp = new PopUp();
		private var soManager:SOManager = new SOManager();
		
		private var _displayPage:String = "DisplayRecipe";
		private var arrPageList:Array = new Array();
		private var sqlRecipe:SQLRecipe;
		private var recipeInterval:uint;
		private var	RecipeTalk:Talk = new Talk();
		private var curVersion:String = "1.0.0";
		private var newVersion:String;
		private var isStarted:Boolean = false;
		
		public function Main():void {
			// Get Recipes
			sqlRecipe = new SQLRecipe();
			sqlRecipe.addEventListener(SQLRecipe.RESULT, onDBResult);
			sqlRecipe.addEventListener(SQLRecipe.UPDATE, onDBUpdate);
			sqlRecipe.load();
			
			// TODO: add filter by category. stars
			// TODO: refined printing styling, include author, category, stars
			// TODO: Add print style to preferences
			// TODO: Add 'From' to shared recipes
			// TODO: Auto Update
			// TODO: Determine online status so it doens't break
			// flash.events.Event.NETWORK_CHANGE
		}
		
		private function init():void {
			// Add Pages
			sprDisplayRecipe.addEventListener(DisplayRecipe.EDIT_RECIPE, onEditRecipe);
			sprDisplayRecipe.addEventListener(DisplayRecipe.LOAD_RECIPE, onLoadRecipe);
			sprDisplayRecipe.addEventListener(DisplayRecipe.DELETE_RECIPE, onDeleteRecipe);
			sprDisplayRecipe.setRecipeList(sqlRecipe.getRecipes());
			arrPageList.push({objRef:sprDisplayRecipe, curY:0, label:"DisplayRecipe"});
			sprPageHolder.addChild(sprDisplayRecipe);
			
			sprAddRecipe.y = sprDisplayRecipe.height;
			sprAddRecipe.addEventListener(AddRecipe.SAVE, onSaveRecipe);
			sprAddRecipe.addEventListener(AddRecipe.CANCEL, onCancel);
			arrPageList.push({objRef:sprAddRecipe, curY:sprAddRecipe.y * -1, label:"AddRecipe"});
			sprPageHolder.addChild(sprAddRecipe);
			
			sprPreferences.y = -1 * (sprPreferences.height + 70);
			sprPreferences.addEventListener(Preferences.CANCEL, onCancel);
			sprPreferences.addEventListener(Preferences.SAVE, onPrefSave);
			arrPageList.push({objRef:sprPreferences, curY:sprPreferences.y * -1, label:"Preferences"});
			sprPageHolder.addChild(sprPreferences);
			
			sprPageHolder.x = STARTX;
			addChild(sprPageHolder);
			
			// Nav Fade
			sprFade.x = STARTX + 1;
			sprFade.y = 27;
			addChild(sprFade);
			
			// Page Mask
			sprMask.graphics.beginFill(0x00FF00, .5);
			sprMask.graphics.drawRect(0, 0, 1000, 560);
			sprMask.graphics.endFill();
			sprMask.y = 27;
			sprMask.x = 0;
			addChild(sprMask);
			sprPageHolder.mask = sprMask;
			
			// Add Nav
			sprGlobalNav.addButton(btnPreferences);
			btnPreferences.addEventListener(MouseEvent.CLICK, onClickPreferences);
			
			sprGlobalNav.addButton(btnAddRecipe);
			btnAddRecipe.addEventListener(MouseEvent.CLICK, onClickAddRecipe);
			
			sprGlobalNav.addButton(btnInbox);
			btnInbox.enabled = false;
			btnInbox.alpha = 0;
			btnInbox.y = 35;
			btnInbox.addEventListener(MouseEvent.CLICK, onClickInbox);
			
			sprGlobalNav.x = STARTX;
			sprGlobalNav.addEventListener(GlobalNav.SEARCH, onSearch);
			sprGlobalNav.addEventListener(GlobalNav.SEARCH_TYPE, onSearchType);
			addChild(sprGlobalNav);
			
			// Add Footer
			sprGlobalFooter.x = STARTX;
			addChild(sprGlobalFooter);
			
			soManager.open("aromaData");
			
			initTalk();
			
			// Window Actions
			sprGlobalNav.sprLogo.addEventListener(MouseEvent.MOUSE_DOWN, onStartMove);
			sprGlobalFooter.addEventListener(MouseEvent.MOUSE_DOWN, onStartMove);
			mcDragHitArea.addEventListener(MouseEvent.MOUSE_DOWN, onStartMove);
			
			btnClose.x = 862.5;
			btnClose.y = 23;
			btnClose.scaleX = 1.50;
			btnClose.scaleY = 1.50;
			btnClose.addEventListener(MouseEvent.CLICK, onClickClose);
			addChild(btnClose);
			
			btnMin.x = 842;
			btnMin.y = 23;
			btnMin.scaleX = 1.50;
			btnMin.scaleY = 1.50;
			btnMin.addEventListener(MouseEvent.CLICK, onClickMinimize);
			addChild(btnMin);

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			isStarted = true;
		}
		
		private function initTalk():void {
			// Check Recipe Interval
			recipeInterval = setInterval(checkRecipes, 30 * 1000);
			RecipeTalk.addEventListener(Talk.RECIPE_NUM, onRecipeNum);
			RecipeTalk.addEventListener(Talk.RECIPE_NUM_ERROR, onRecipeNumError);
			
			sprReceivePopUp.addEventListener(PopUp.ACCEPT, onReceiveSave);
			sprReceivePopUp.addEventListener(PopUp.DECLINE, onReceiveCancel);
			addChild(sprReceivePopUp);
			addChild(sprAlert);
			
			checkRecipes();
		}
		
		private function checkRecipes():void {
			if(soManager.data.userName) {
				sprGlobalFooter.setUserName(soManager.data.userName);
				RecipeTalk.checkRecipes(soManager.data.userName);
			}
		}
		
		private function changePage(page:String):void {
			_displayPage = page;
			var gotoY:Number;
			
			for(var i in arrPageList) {
				if(arrPageList[i].label == _displayPage) {
					gotoY = arrPageList[i].curY;
					break;
				}
			}
			
			TweenLite.to(sprPageHolder, .75, {y:gotoY});
		}
		
		private function checkVersion():void {
			// hit checkVersion.php
			// and set newVersion = checkVersion's return version
			newVersion = "1.0.0";
			
			// if curVersion < newVersion
			if(curVersion == newVersion) {
				init();
			} else {
				getUpdate();
			}
		}
		
		private function getUpdate():void {
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, updateFileCompleteHandler);

			var request:URLRequest = new URLRequest("http://www.coursevector.com/download/Aroma.air");
			try {
				loader.load(request);
			} catch (error:Error) {
				trace("Unable to load Aroma.air for updating.");
			}
		}
	
		private function updateFileCompleteHandler(event:Event):void {
			var updater:Updater = new Updater();
			var fileTemp:File = File.createTempFile();
			var loader:URLLoader = URLLoader(event.target);
			var fileStream:FileStream = new FileStream();
			fileStream.open(fileTemp, FileMode.WRITE);
			fileStream.writeBytes(loader.data, 0, loader.bytesTotal);
			fileStream.close();
			trace("about to update");
			updater.update(fileTemp, newVersion);
		}
		
		/// On Events ///
		
		private function onDBResult(e:Event):void {
			checkVersion();
		}
		
		private function onDBUpdate(e:Event):void {
			sprDisplayRecipe.setRecipeList(sqlRecipe.getRecipes());
		}
		
		private function onClickClose(e:MouseEvent):void {
			stage.nativeWindow.close();
		}
		
		private function onClickMaximize(e:MouseEvent):void {
			stage.nativeWindow.maximize();
		}
		
		private function onClickMinimize(e:MouseEvent):void {
			stage.nativeWindow.minimize();
		}
		
		private function onRecipeNum(e:Event):void {
			if(btnInbox.alpha != 1 && RecipeTalk.numRecipes > 0) {
				sprAlert.title = "Information";
				sprAlert.icon = "information";
				sprAlert.text = "You have received " + RecipeTalk.numRecipes + " recipe(s)! Please select which ones you would like to save.";
				sprAlert.show();
				//sprGlobalNav.showButton(btnInbox);
				sprGlobalNav.highlightButton(btnInbox);
			} else if(btnInbox.alpha == 1 && RecipeTalk.numRecipes > 0) {
				// Do nothing
			} else {
				sprGlobalNav.hideButton(btnInbox);
			}
			btnInbox.setNumber(RecipeTalk.numRecipes);
		}
		
		private function onRecipeNumError(e:Event):void {
			trace("Error checking number of recipes");
		}
		
		private function onReceiveSave(e:Event):void {
			sqlRecipe.saveMultiRecipe(sprReceivePopUp.selectedRecipes);
			changePage("DisplayRecipe");
			RecipeTalk.eraseRecipes(sprReceivePopUp.recipeId);
			// Temporary until i can find a way to quickly figure out how many recipes remain onteh server
			sprGlobalNav.hideButton(btnInbox);
		}
		
		private function onReceiveCancel(e:Event):void {
			RecipeTalk.eraseRecipes(sprReceivePopUp.recipeId);
			sprGlobalNav.hideButton(btnInbox);
		}
		
		public function onStartMove(event:MouseEvent):void {
			stage.nativeWindow.startMove();
		}
		
		private function onSearch(e:Event):void {
			sprDisplayRecipe.searchRecipeList(sprGlobalNav.searchText);
			if(_displayPage != "DisplayRecipe") changePage("DisplayRecipe");
		}
		
		private function onSearchType(e:Event):void {
			sprDisplayRecipe.searchType(sprGlobalNav.searchType);
		}
		
		private function onSaveRecipe(e:Event):void {
			var curRecipe = e.target.recipe;
			sqlRecipe.saveRecipe(e.target.recipe);
			sprGlobalNav.showButton(btnAddRecipe);
			sprGlobalNav.showButton(btnPreferences);
			changePage("DisplayRecipe");
		}
		
		private function onCancel(e:Event):void {
			sprGlobalNav.showButton(btnAddRecipe);
			sprGlobalNav.showButton(btnPreferences);
			changePage("DisplayRecipe");
		}
		
		private function onEditRecipe(e:Event):void {
			var curRecipe = e.target.editRecipeTarget;
			sprAddRecipe.recipe = curRecipe;
			changePage("AddRecipe");
		}
		
		private function onClickDisplayRecipe(e:MouseEvent):void {
			changePage("DisplayRecipe");
		}
		
		private function onClickAddRecipe(e:MouseEvent):void {
			sprGlobalNav.hideButton(btnAddRecipe);
			sprGlobalNav.showButton(btnPreferences);
			if(soManager.data.userName) {
				sprAddRecipe.setUserName(soManager.data.userName);
			} else {
				sprAddRecipe.setUserName("<Recipe Author>");
			}
			sprAddRecipe.reset();
			changePage("AddRecipe");
		}
		
		private function onClickPreferences(e:MouseEvent):void {
			sprGlobalNav.hideButton(btnPreferences);
			sprGlobalNav.showButton(btnAddRecipe);
			changePage("Preferences");
		}
		
		private function onClickInbox(e:MouseEvent):void {
			if(RecipeTalk.numRecipes == 0) sprGlobalNav.hideButton(btnInbox);
			btnInbox.enabled = false;
			sprReceivePopUp.userName = soManager.data.userName;
			sprReceivePopUp.show();
		}
		
		private function onLoadRecipe(e:Event):void {
			sprDisplayRecipe.setRecipeList(sqlRecipe.getRecipes());
		}
		
		private function onDeleteRecipe(e:Event):void {
			var toDelete:Array = sprDisplayRecipe.toDelete;
			sqlRecipe.deleteRecipe(toDelete);
		}
		
		private function onPrefSave(e:Event):void {
			sprGlobalFooter.setUserName(soManager.data.userName);
		}
	}
}
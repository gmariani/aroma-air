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

package com.coursevector.aroma.view {
	
	import cv.util.ScaleUtil;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.IOErrorEvent;
	import flash.text.engine.FontLookup;
	import flash.text.engine.Kerning;
	import flash.text.engine.RenderingMode;
	import flash.text.Font;
	import flash.text.StyleSheet;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.ByteArray;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import com.coursevector.aroma.model.SQLProxy;
	import com.coursevector.aroma.view.components.Rating;
	import com.coursevector.aroma.ApplicationFacade;
	import com.coursevector.aroma.view.components.RecipeCellRenderer;
	import com.coursevector.aroma.view.components.ImagePopUp;
	import com.coursevector.aroma.view.EditScreenMediator;
	
	import fl.controls.List;
	import fl.controls.UIScrollBar;
	import fl.containers.ScrollPane;
	import fl.data.DataProvider;
	
	import cv.text.TextFlow;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import gs.TweenLite;

	public class DisplayScreenMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'DisplayScreenMediator';
		
		// Assets
		private var txtRecipe:TextField;
		private var txtRecipe2:TextField;
		private var txtListTitle:TextField;
		private var mcStarToggle:StarIcon;
		private var mcSortToggle:MovieClip;
		private var mcRandom:MovieClip;
		private var mcGradient:MovieClip;
		private var btnNotes:Sprite;
		private var sprHolder:Sprite = new Sprite();
		private var sprSplitter:Sprite;
		private var sprStarRating:Rating = new Rating(false);
		private var listRecipes:List;
		private var paneRecipe:ScrollPane = new ScrollPane();
		private var ldrPicture:Loader = new Loader();
		private var popUp:ImagePopUp;
		
		// Variables
		private var dpRecipeList:DataProvider = new DataProvider();
		private var masterRecipeList:DataProvider = new DataProvider();
		private var isMultipleSelected:Boolean = false;
		private var arrRecipient:Array = new Array();
		private var objRecipe:Object = new Object();
		private var _sqlProxy:SQLProxy;
		private var recipeWidth:Number;
		private var spacing:Number = 1.5;
		private var boundsHeight:Number = 100;
		private var boundsWidth:Number = 100;
		private var isSortAZ:Boolean = true;
		private var isSortStar:Boolean = false;
		private var textFlow:TextFlow;
		
		private const H1_TAG_START:String = "<font face='Bookman Old Style' size='25' color='#872301'><textformat leading='3'><b>";
		private const H1_TAG_END:String = "</b></textformat></font><br/>";
		
		private const H2_TAG_START:String = "<font face='Bell MT' size='15' color='#872301'><textformat leading='3'><b>";
		private const H2_TAG_END:String = "</b></textformat></font><br/>";
		
		private const H3_TAG_START:String = "<font face='Bookman Old Style' size='15' color='#872301'><textformat leading='3'><i><b>";
		private const H3_TAG_END:String = "</b></i></textformat></font><br/>";
		
		private const LI_TAG_START:String = "<font face='Arial' size='12' color='#872301'>\u2022 <textformat blockindent='15'>";
		private const LI_TAG_END:String = "</textformat></font><br/>";
		
		private const DIRECTIONS_CLASS_START:String = "<font face='Arial' size='12' color='#872301'>";
		private const DIRECTIONS_CLASS_END:String = "</font><br/>";
		
		public function DisplayScreenMediator(viewComponent:Object) {
			super(NAME, viewComponent);
			init();
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		private function get sqlProxy():SQLProxy {
			if(_sqlProxy == null) _sqlProxy = facade.retrieveProxy(SQLProxy.NAME) as SQLProxy;
			return _sqlProxy;
		}
		
		private function get root():DisplayObjectContainer {
			return viewComponent as DisplayObjectContainer;
		}
		
		public function get selectedRecipe():Object {
			return objRecipe;
		}
		
		public function get selectedRecipes():Array {
			if (listRecipes.selectedItems.length > 1) {
				var arrTemp:Array = new Array();
				var arrData:Array = listRecipes.selectedItems;
				
				for(var i:String in arrData) {
					arrTemp.push(arrData[i].data);
				}
				return arrTemp;
			}
			
			return [listRecipes.selectedItem.data];
		}
		
		public function get y():Number {
			return root.y;
		}
		
		public function set y(value:Number):void {
			root.y = value;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function resize(bounds:Rectangle):void {
			boundsHeight = bounds.height;
			boundsWidth = bounds.width;
			
			var mcGripper:MovieClip = sprSplitter.getChildByName("mcGripper") as MovieClip;
			var mcBG:MovieClip = sprSplitter.getChildByName("mcBG") as MovieClip;
			mcBG.height = boundsHeight;
			mcGripper.y = (mcBG.height / 2) - (mcGripper.height / 2);
			
			// 1st column
			listRecipes.width = sprSplitter.x - 3;
			listRecipes.height = boundsHeight - listRecipes.y;
			mcGradient.width = listRecipes.width;
			mcGradient.height = boundsHeight;
			mcSortToggle.x = sprSplitter.x - 27;
			mcStarToggle.x = mcSortToggle.x - mcStarToggle.width - 3.5;
			mcRandom.x = mcStarToggle.x - mcRandom.width - 7;
			
			// 2nd column
			arrangeRecipe();
		}
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function listNotificationInterests():Array {
			return [ApplicationFacade.SQL_RESULT, ApplicationFacade.SEARCH, ApplicationFacade.ACCEPT, ApplicationFacade.DECLINE];
		}
		
		override public function handleNotification(note:INotification):void {
			var o:Object = note.getBody();
			
			switch (note.getName())	{
				case ApplicationFacade.SQL_RESULT :
					resetRecipeList();
					break;
				case ApplicationFacade.SEARCH :
					searchRecipeList(o.string, o.type);
					break;
				case ApplicationFacade.ACCEPT :
					if (note.getBody() == "onClickDelete") {
						deleteRecipe(this.selectedRecipes);
					}
					break;
				case ApplicationFacade.DECLINE :
					//
					break;
			}
		}
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
			
			resetRecipeList();
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function arrangeRecipe():void {
			var rightMargin:uint = 10;
			var bottomMargin:uint = 20;
			paneRecipe.x = listRecipes.x + listRecipes.width + 10;
			paneRecipe.y = 0;
			paneRecipe.width = boundsWidth - paneRecipe.x - rightMargin;
			paneRecipe.height = boundsHeight - bottomMargin;
			
			var mainColumnWidth:Number = paneRecipe.width - 25;
			
			sprStarRating.x = mainColumnWidth - sprStarRating.width - 10;
			sprStarRating.y = 65;
			
			btnNotes.x = mainColumnWidth - btnNotes.width - 5;
			btnNotes.y = sprStarRating.y - btnNotes.height - 5;
			
			ldrPicture.x = mainColumnWidth - 210;
			ldrPicture.y = sprStarRating.y + sprStarRating.height + 5;
			
			//
			txtRecipe.width = paneRecipe.width - (ldrPicture.width > 0 ? ldrPicture.width + 50 : 5) - 5;
			txtRecipe.height = ldrPicture.y + ldrPicture.height + 5;
			
			txtRecipe2.width = mainColumnWidth;
			txtRecipe2.y = txtRecipe.height + 15;
			
			textFlow.reflow();
			//
			
			paneRecipe.update();
		}
		
		private function init():void {
			
			sprSplitter = root.getChildByName("sprSplitter") as Sprite;
			btnNotes = root.getChildByName("btnNotes") as Sprite;
			txtListTitle = root.getChildByName("txtListTitle") as TextField;
			mcStarToggle = root.getChildByName("mcStarToggle") as StarIcon;
			mcSortToggle = root.getChildByName("mcSortToggle") as MovieClip;
			mcRandom = root.getChildByName("mcRandom") as MovieClip;
			mcGradient =   root.getChildByName("mcGradient") as MovieClip;
			listRecipes =  root.getChildByName("listRecipes") as List;
			txtRecipe =  root.getChildByName("txtRecipe") as TextField;
			txtRecipe2 =  root.getChildByName("txtRecipe2") as TextField;
			
			// Splitter
			sprSplitter.addEventListener(MouseEvent.MOUSE_DOWN, splitterHandler);
			sprSplitter.buttonMode = true;
			
			// Recipe Holder
			root.addChild(sprHolder);
			
			// Recipe
			txtRecipe.embedFonts = true;
			sprHolder.addChild(txtRecipe);
			txtRecipe.x = 15;
			txtRecipe.y = 25;
			
			txtRecipe2.embedFonts = true;
			txtRecipe2.autoSize = TextFieldAutoSize.LEFT;
			sprHolder.addChild(txtRecipe2);
			txtRecipe2.x = 15;
			
			textFlow = new TextFlow([txtRecipe, txtRecipe2], "");
			
			// Picture
			ldrPicture.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			ldrPicture.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			ldrPicture.addEventListener(MouseEvent.CLICK, ldrHandler);
			ldrPicture.addEventListener(MouseEvent.ROLL_OVER, ldrHandler);
			ldrPicture.addEventListener(MouseEvent.ROLL_OUT, ldrHandler);
			sprHolder.addChild(ldrPicture);
			
			// Rating
			sprStarRating.x = 235;
			sprStarRating.y = 50;
			sprHolder.addChild(sprStarRating);
			
			// Notes Btn
			btnNotes.buttonMode = true;
			btnNotes.addEventListener(MouseEvent.CLICK, onClickNote);
			btnNotes.addEventListener(MouseEvent.ROLL_OVER, onOverButton);
			btnNotes.addEventListener(MouseEvent.ROLL_OUT, onOutButton);
			btnNotes.x = 514;
			btnNotes.y = 0;
			sprHolder.addChild(btnNotes);
			
			paneRecipe.source = sprHolder;
			root.addChild(paneRecipe);
			
			// List
			listRecipes.setStyle("scrollBarWidth", 5);
			listRecipes.setStyle("scrollArrowHeight", 0);
			listRecipes.setStyle("cellRenderer", RecipeCellRenderer);
			listRecipes.rowHeight = 17;
			listRecipes.dataProvider = dpRecipeList;
			listRecipes.labelField = "title";
			listRecipes.addEventListener(Event.CHANGE , onItemClickList);
			listRecipes.addEventListener("itemDown", onItemDownList);
			
			// Sort Options
			mcStarToggle.alpha = 0.5;
			mcStarToggle.addEventListener(MouseEvent.CLICK, onClickStar);
			mcStarToggle.buttonMode = true;
			mcSortToggle.gotoAndStop(1);
			mcSortToggle.addEventListener(MouseEvent.CLICK, onClickSort);
			mcSortToggle.buttonMode = true;
			
			// Random
			mcRandom.addEventListener(MouseEvent.CLICK, onClickRandom);
			mcRandom.buttonMode = true;
		}
		
		private function ldrHandler(e:MouseEvent):void {
			switch(e.type) {
				case MouseEvent.CLICK :
					popUp = new ImagePopUp(objRecipe.picture);
					break;
				case MouseEvent.ROLL_OVER :
					Mouse.cursor = MouseCursor.BUTTON;
					break;
				case MouseEvent.ROLL_OUT :
					Mouse.cursor = MouseCursor.AUTO;
					break;
			}
		}
		
		private function onLoaderComplete(e:Event):void {
			var bitmap:Bitmap = ldrPicture.content as Bitmap;
			bitmap.smoothing = true;
			ScaleUtil.toFit(ldrPicture.content, new Rectangle(0, 0, 200, 200));
			TweenLite.to(ldrPicture.content, 0.5, { autoAlpha:1 } );
			arrangeRecipe();
		}
		
		private function onError(e:IOErrorEvent):void {
			throw Error("DisplayScreenMediator::ldrPicture : " + e.text);
		}
		
		private function splitterHandler(event:MouseEvent):void {
			if (event.type == MouseEvent.MOUSE_DOWN) {
				var rectBounds:Rectangle = new Rectangle(200, 0, boundsWidth - 415, 0);
				sprSplitter.startDrag(false, rectBounds);
				root.stage.addEventListener(MouseEvent.MOUSE_MOVE, splitterHandler);
				root.stage.addEventListener(MouseEvent.MOUSE_UP, splitterHandler);
			} else if(event.type == MouseEvent.MOUSE_MOVE) {
				// update column 1
				listRecipes.width = sprSplitter.x - 3;
				mcGradient.width = listRecipes.width;
				mcSortToggle.x = sprSplitter.x - 27;
				mcStarToggle.x = mcSortToggle.x - mcStarToggle.width - 3.5;
				mcRandom.x = mcStarToggle.x - mcRandom.width - 7;
				
				// update column 2
				arrangeRecipe();
			} else {
				sprSplitter.stopDrag();
				root.stage.removeEventListener(MouseEvent.MOUSE_MOVE, splitterHandler);
				root.stage.removeEventListener(MouseEvent.MOUSE_UP, splitterHandler);
			}
		}
		
		private function onClickStar(event:MouseEvent):void {
			isSortStar = !isSortStar;
			mcStarToggle.alpha = (isSortStar) ? 1 : .5;
			determineSortFrame();
			sort();
		}
		
		private function determineSortFrame():void {
			if (isSortAZ) {
				if (isSortStar) {
					mcSortToggle.gotoAndStop(3);
				} else {
					mcSortToggle.gotoAndStop(1);
				}
			} else {
				if (isSortStar) {
					mcSortToggle.gotoAndStop(4);
				} else {
					mcSortToggle.gotoAndStop(2);
				}
			}
		}
		
		// Select random recipe
		private function onClickRandom(e:MouseEvent):void {
			if (dpRecipeList.length > 0) {
				var idx:int = int(dpRecipeList.length * Math.random());
				if (idx == dpRecipeList.length) idx = dpRecipeList.length - 1;
				if (idx < 0) idx = 0;
				listRecipes.selectedItem = listRecipes.getItemAt(idx);
				selectRecipe();
			} else {
				onSelectNone(true);
			}
		}
		
		private function onClickSort(event:MouseEvent):void {
			isSortAZ = !isSortAZ;
			determineSortFrame();
			sort();
		}
		
		private function sort():void {
			if (isSortAZ) {
				if (isSortStar) {
					dpRecipeList.sort(sortOnRating);
				} else {
					dpRecipeList.sortOn("label", Array.CASEINSENSITIVE);
				}
			} else {
				if (isSortStar) {
					dpRecipeList.sort(sortOnRating, Array.DESCENDING);
				} else {
					dpRecipeList.sortOn("label", Array.CASEINSENSITIVE | Array.DESCENDING);
				}
			}
		}
		
		private function sortOnRating(a:Object, b:Object):int {
			var aRating:int = a.data.rating;
			var bRating:int = b.data.rating;
			
			if(aRating > bRating) {
				return 1;
			} else if(aRating < bRating) {
				return -1;
			} else  {
				//aRating == bRating
				return 0;
			}
		}
		
		private function searchRecipeList(strSearch:String, strType:String):void {
			if (strSearch == "" || strSearch.length < 1) {
				dpRecipeList = getRecipeList();
				listRecipes.dataProvider = dpRecipeList;
				selectFirstRecipe();
				return;
			}
			
			var dpTemp:DataProvider = getRecipeList();
			dpRecipeList = new DataProvider();
			for(var i:uint = 0; i < dpTemp.length; i++) {
				var curRecipe:Object = dpTemp.getItemAt(i);
				var pattern:RegExp = new RegExp(strSearch, "ig");
				var result:Object;
				
				switch(strType) {
					case ApplicationFacade.SEARCH_TYPE_NAME :
						result = pattern.exec(curRecipe.label);
						break;
					case ApplicationFacade.SEARCH_TYPE_INGREDIENT :
						for(var j:String in curRecipe.data.ingredients) {
							result = pattern.exec(curRecipe.data.ingredients[j]);
							if(result != null) {
								dpRecipeList.addItem(curRecipe);
								result = null;
								break;
							}
						}
						break;
					case ApplicationFacade.SEARCH_TYPE_AUTHOR :
						result = pattern.exec(curRecipe.data.author);
						break;
					case ApplicationFacade.SEARCH_TYPE_CATEGORY :
						result = pattern.exec(curRecipe.data.category);
						break;
					case ApplicationFacade.SEARCH_TYPE_SOURCE :
						result = pattern.exec(curRecipe.data.source);
						break;
				}
				
				if(result != null) dpRecipeList.addItem(curRecipe);
			}
			
			listRecipes.dataProvider = dpRecipeList;
			sort();
			selectFirstRecipe();
		}
		
		private function resetRecipeList():void {
			dpRecipeList = new DataProvider();
			masterRecipeList = new DataProvider();
			var sqlData:Array = sqlProxy.getRecipes();
			
			for (var i:String in sqlData) {
				masterRecipeList.addItem({label:sqlData[i].title, data:sqlData[i]});
			}
			
			dpRecipeList = masterRecipeList;
			listRecipes.dataProvider = dpRecipeList;
			
			selectFirstRecipe();
			sort();
		}
		
		private function selectFirstRecipe():void {
			if(dpRecipeList.length > 0) {
				listRecipes.selectedItem = listRecipes.getItemAt(0);
				selectRecipe();
			} else {
				onSelectNone(true);
			}
		}
		
		private function determineIcon(item:Object):String {
			if(item.data.isShared == "true") {
				return "ShareOn";
			} else {
				return "ShareOff";
			}
		}
		
		private function getRecipeList():DataProvider {
			return masterRecipeList;
		}
		
		private function selectRecipe():void {
			var startY:uint = 0;
			var arrRecipes:Array = this.selectedRecipes;
			objRecipe = arrRecipes[0];
			
			if(arrRecipes.length < 1) {
				onSelectNone(false);
			} else if (arrRecipes.length > 1) {
				sendNotification(ApplicationFacade.MULTIPLE_SELECTED, true);
				TweenLite.to(btnNotes, .25, { autoAlpha:0 } );
				TweenLite.to(ldrPicture.content, .25, {autoAlpha:0, onComplete:ldrPicture.unload});
				
				// Populate recipe
				textFlow.text = H1_TAG_START + "Multiple recipes selected" + H1_TAG_END;
				sprStarRating.stars = 0;
			} else {
				sendNotification(ApplicationFacade.MULTIPLE_SELECTED, false);
				if (objRecipe.notes.length > 0) {
					TweenLite.to(btnNotes, .25, {autoAlpha:.5});
				} else {
					TweenLite.to(btnNotes, .25, {autoAlpha:0});
				}
				TweenLite.to(ldrPicture.content, .25, {autoAlpha:0, onComplete:ldrPicture.unload});
				
				// Populate recipe
				var strRecipe:String = H1_TAG_START + objRecipe.title + H1_TAG_END;
				strRecipe += H2_TAG_START + "Courtesy of " + ((objRecipe.author.length > 0) ? objRecipe.author : "Unknown") + ((objRecipe.source.length > 0) ? " (" + objRecipe.source + ")" : "") + H2_TAG_END;
				strRecipe += H3_TAG_START + objRecipe.category + " - Yields: " + objRecipe.yields + H3_TAG_END + "<br/>";
				sprStarRating.stars = objRecipe.rating;
				
				// Draw ingredients
				for(var j:String in objRecipe.ingredients) {
					strRecipe += LI_TAG_START + unescape(objRecipe.ingredients[j]) + LI_TAG_END;
				}
				
				// Show Picture
				if (objRecipe.picture != "" && objRecipe.picture) {
					TweenLite.to(ldrPicture.content, .25, { autoAlpha:0 } );
					try {
						objRecipe.picture.inflate();
					} catch (e:Error) {
						//trace("DisplayScreenMediator::selectRecipe - " + e.message);
					}
					try {
						ldrPicture.loadBytes(objRecipe.picture);
					} catch (e:Error) {
						//trace("DisplayScreenMediator::selectRecipe - " + e.message);
					}
				} else {
					TweenLite.to(ldrPicture.content, .25, {autoAlpha:0, onComplete:ldrPicture.unload});
				}
				
				strRecipe += "<br/>" + DIRECTIONS_CLASS_START + "<p>" + objRecipe.directions + "</p>" + DIRECTIONS_CLASS_END;
				textFlow.text = strRecipe;
			}
			
			arrangeRecipe();
		}
		
		private function removeAllChildren(obj:Sprite):void {
			if(obj.numChildren > 0) {
				var len:int = obj.numChildren;
				for(var i:int = 0; i < len; i++) {
					obj.removeChildAt(0);
				}
			}
		}
		
		private function deleteRecipe(arrRecipes:Array):void {
			sendNotification(ApplicationFacade.SQL_DELETE, arrRecipes);
		}
		
		/// On Event ///
		
		private function onClickNote(event:MouseEvent):void {
			sendNotification(ApplicationFacade.ALERT, {title:"Notes", icon:ApplicationFacade.INFORMATION, message:objRecipe.notes } );
		}
		
		private function onItemClickList(e:Event):void {
			selectRecipe();
		}
		
		private function onItemDownList(event:Event):void {
			event.stopPropagation();
			sendNotification(ApplicationFacade.DRAG_EXPORT, event.target);
		}
		
		private function onOverButton(e:MouseEvent):void {
			if(e.target.enabled) TweenLite.to(e.target, 0.5, { alpha:1 } );
		}
		
		private function onOutButton(e:MouseEvent):void {
			TweenLite.to(e.target, 0.5, { alpha:.5 } );
		}
		
		private function onSelectNone(isSearch:Boolean):void {
			sendNotification(ApplicationFacade.NONE_SELECTED);
			TweenLite.to(btnNotes, .25, {autoAlpha:0});
			
			// Populate recipe
			textFlow.text = H1_TAG_START + ((isSearch == true) ? "No recipes found" : "No recipes selected") + H1_TAG_END;
			sprStarRating.stars = 0;
		}
	}
}
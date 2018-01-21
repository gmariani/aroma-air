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
*/

package com.coursevector.aroma.view {

	import cv.util.ScaleUtil;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	import fl.controls.ComboBox;
	import fl.controls.UIScrollBar;
	import fl.controls.List;
	import fl.controls.Button;
	import fl.containers.ScrollPane;
	import fl.managers.StyleManager;
	import fl.events.ScrollEvent;
	import fl.controls.ScrollBarDirection;
	import fl.events.ScrollEvent;
	
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.geom.Rectangle;

	import gs.TweenLite;
	import com.adobe.images.JPGEncoder;
	import flash.net.URLStream;
	
	import com.coursevector.aroma.ApplicationFacade;
	import com.coursevector.aroma.view.components.Ingredient;
	import com.coursevector.aroma.view.components.Rating;
	import com.coursevector.aroma.model.vo.LoginVO;

	public class EditScreenMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'EditScreenMediator';
		
		// Assets
		private var sprRating:Rating = new Rating(true);
		private var sprIngHolder:Sprite = new Sprite();
		private var mcPlaceholder:MovieClip;
		private var txtTitle:TextField;
		private var txtTitleInput:TextField;
		private var txtDirection:TextField;
		private var txtDirectionInput:TextField;
		private var txtNotes:TextField;
		private var txtNotesInput:TextField;
		private var txtAuthor:TextField;
		private var txtAuthorInput:TextField;
		private var txtSource:TextField;
		private var txtSourceInput:TextField;
		private var txtYields:TextField;
		private var txtYieldsInput:TextField;
		private var txtCategory:TextField;
		private var txtRating:TextField;
		private var txtPicture:TextField;
		private var sbDirection:UIScrollBar;
		private var sbNotes:UIScrollBar;
		private var sbIngredient:UIScrollBar;
		private var ddCategory:ComboBox;
		private var sprSeperator:Sprite;
		
		private var sprAuthorBG:Sprite;
		private var sprSourceBG:Sprite;
		private var sprTitleBG:Sprite;
		private var sprDirectionBG:Sprite;
		private var sprNotesBG:Sprite;
		private var sprYieldsBG:Sprite;
		
		// Variables
		private var arrIngredientList:Array = new Array();
		private var frmtInput:TextFormat = new TextFormat();
		private var frmtComponent:TextFormat = new TextFormat();
		private var data:Object;
		private var colWidth:Number;
		private var colHeight:Number;
		private var ingSpacing:uint = 3;
		private var ingredientHeight:Number = 0;
		private var stream:URLStream;
		private var filePicture:File = File.desktopDirectory;
		private var imgFilter:FileFilter = new FileFilter("Images (*.jpg, *.jpeg, *.gif, *.png)", "*.jpg;*.jpeg;*.gif;*.png");
		private var ldrPicture:Loader;
		private var baImage:ByteArray;
		private var rectPicture:Rectangle = new Rectangle(75, 275, 244, 130);
		private var rectOringalSize:Rectangle;
		private var bmp:Bitmap;
		
		public function EditScreenMediator(viewComponent:Object) {
			super(NAME, viewComponent);
			
			init();
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		private function get root():DisplayObjectContainer {
			return viewComponent as DisplayObjectContainer;
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
			// Left Column
			colWidth = bounds.width / 2;
			colHeight = bounds.height - sprIngHolder.y;
			sizeAllChildren(sprIngHolder, colWidth - 20);
			
			var rect:Rectangle = sprIngHolder.scrollRect;
			rect.width = colWidth - 10;
			rect.height = colHeight;
			sprIngHolder.scrollRect = rect;
			sbIngredient.x = sprIngHolder.x + (colWidth - 15);
			sbIngredient.height = rect.height;
			updateScrollBox();
			
			sprSeperator.height = bounds.height - sprSeperator.y - 20;
			
			// Right Column
			var rightMargin:Number = 15;
			var rightMargin2:Number = 30;
			sprSeperator.x = colWidth;
			txtCategory.x = sprSeperator.x + 10;
			ddCategory.x = txtCategory.x + txtCategory.width + 5;
			txtRating.x = ddCategory.x + ddCategory.width + 10;
			sprRating.x = txtRating.x + txtRating.width + 5;
			
			txtAuthor.x = sprSeperator.x + 10;
			txtAuthorInput.x = txtAuthor.x + txtAuthor.width + 4;
			txtAuthorInput.width = bounds.width - txtAuthorInput.x - rightMargin;
			sprAuthorBG.x = txtAuthorInput.x - 2;
			sprAuthorBG.y = txtAuthorInput.y - 2;
			drawBG(sprAuthorBG, txtAuthorInput.width + 4, 24);
			
			txtSource.x = sprSeperator.x + 10;
			txtSourceInput.x = txtSource.x + txtSource.width + 4;
			txtSourceInput.width = bounds.width - txtSourceInput.x - rightMargin;
			sprSourceBG.x = txtSourceInput.x - 2;
			sprSourceBG.y = txtSourceInput.y - 2;
			drawBG(sprSourceBG, txtSourceInput.width + 4, 24);
			
			txtYields.x = sprSeperator.x + 10;
			txtYieldsInput.x = txtYields.x + txtYields.width + 4;
			txtYieldsInput.width = bounds.width - txtYieldsInput.x - rightMargin;
			sprYieldsBG.x = txtYieldsInput.x - 2;
			sprYieldsBG.y = txtYieldsInput.y - 2;
			drawBG(sprYieldsBG, txtYieldsInput.width + 4, 24);
			
			txtTitle.x = sprSeperator.x + 10;
			txtTitleInput.x = txtTitle.x + txtTitle.width + 4;
			txtTitleInput.width = bounds.width - txtTitleInput.x - rightMargin;
			sprTitleBG.x = txtTitleInput.x - 2;
			sprTitleBG.y = txtTitleInput.y - 2;
			drawBG(sprTitleBG, txtTitleInput.width + 4, 24);
			
			var availableHeight:Number = bounds.height - txtDirection.y - 40 - (txtDirection.height + txtNotes.height);
			availableHeight /= 3;
			
			txtDirection.x = sprSeperator.x + 10;
			txtDirectionInput.x = txtDirection.x + 2.5;
			txtDirectionInput.height = availableHeight;
			txtDirectionInput.width = bounds.width / 2 - rightMargin2;
			sprDirectionBG.x = txtDirectionInput.x - 2;
			sprDirectionBG.y = txtDirectionInput.y - 2;
			sbDirection.x = txtDirectionInput.x + txtDirectionInput.width + 5;
			sbDirection.setSize(5, txtDirectionInput.height);
			sbDirection.update();
			drawBG(sprDirectionBG, txtDirectionInput.width + 4, txtDirectionInput.height + 4);
			
			txtNotes.x = sprSeperator.x + 10;
			txtNotes.y = txtDirectionInput.y + txtDirectionInput.height + 5;
			txtNotesInput.x = txtNotes.x + 2.5;
			txtNotesInput.y = txtNotes.y + txtNotes.height + 5;
			txtNotesInput.height = availableHeight;
			txtNotesInput.width = bounds.width / 2 - rightMargin2;
			sprNotesBG.x = txtNotesInput.x - 2;
			sprNotesBG.y = txtNotesInput.y - 2;
			sbNotes.x = txtNotesInput.x + txtNotesInput.width + 5;
			sbNotes.y = txtNotesInput.y;
			sbNotes.setSize(5, txtNotesInput.height);
			sbNotes.update();
			drawBG(sprNotesBG, txtNotesInput.width + 4, txtNotesInput.height + 4);
			
			txtPicture.x = sprSeperator.x + 10;
			txtPicture.y = txtNotesInput.y + txtNotesInput.height + 5;
			rectPicture.x = txtPicture.x + 2.5;
			rectPicture.y = txtPicture.y + txtPicture.height + 5;
			rectPicture.width = bounds.width / 2 - rightMargin2;
			rectPicture.height = availableHeight - 15;
			
			if (bmp) {
				bmp.x = rectPicture.x + (rectPicture.width / 2) - (bmp.width / 2); // Center Horiz
				bmp.y = rectPicture.y;
				ScaleUtil.toFit(bmp, rectPicture);
			}
			mcPlaceholder.x = rectPicture.x;
			mcPlaceholder.y = rectPicture.y;
			mcPlaceholder.width = rectPicture.width;
			mcPlaceholder.height = rectPicture.height;
		}
		
		public function setRecipe(objRecipe:Object):void {
			reset();
			
			data = objRecipe;
			txtTitleInput.text = data.title;
			txtTitleInput.setTextFormat(frmtInput);
			
			txtDirectionInput.text = data.directions;
			txtDirectionInput.setTextFormat(frmtInput);
			sbDirection.update();
			
			txtNotesInput.text = data.notes;
			txtNotesInput.setTextFormat(frmtInput);
			sbNotes.update();
			
			txtAuthorInput.text = data.author;
			txtAuthorInput.setTextFormat(frmtInput);
			
			txtSourceInput.text = data.source;
			txtSourceInput.setTextFormat(frmtInput);
			
			txtYieldsInput.text = data.yields;
			txtYieldsInput.setTextFormat(frmtInput);
			
			sprRating.stars = data.rating;
			for(var k:uint = 0; k < ddCategory.length; k++) {
				if(ddCategory.getItemAt(k).label == data.category) {
					ddCategory.selectedIndex = k;
					break;
				}
			}
			
			ingredientHeight = 10;
			for(var i:String in data.ingredients) {
				addIngredient();
			}
			
			var rect:Rectangle = sprIngHolder.scrollRect;
			rect.width = colWidth - 10;
			sprIngHolder.scrollRect = rect;
			sbIngredient.setScrollProperties(sbIngredient.height, 0, ingredientHeight - sbIngredient.height, sbIngredient.height);
			sbIngredient.update();
			
			for(var j:uint = 0; j < arrIngredientList.length; j++) {
				arrIngredientList[j].data = data.ingredients[j];
			}
			
			baImage = (data.picture != "") ? data.picture : null;
			if (baImage) {
				//baImage.inflate();
				loadBitmap();
			}
		}
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function listNotificationInterests():Array {
			return [ApplicationFacade.ADD_INGREDIENT, ApplicationFacade.ADD_PICTURE, ApplicationFacade.REMOVE_PICTURE, ApplicationFacade.ADD, ApplicationFacade.EDIT_CANCEL, ApplicationFacade.EDIT_SAVE];
		}
		
		override public function handleNotification(note:INotification):void {
			switch (note.getName())	{
				case ApplicationFacade.ADD :
					reset();
					break;
				case ApplicationFacade.EDIT_CANCEL :
					reset();
					break;
				case ApplicationFacade.EDIT_SAVE :
					saveRecipe();
					break;
				case ApplicationFacade.ADD_INGREDIENT :
					onClickAddIng();
					break;
				case ApplicationFacade.ADD_PICTURE :
					try {
						filePicture.browseForOpen("Select Image", [imgFilter]);
					} catch (e:Error) {
						trace("EditScreenMediator::onCLickAddPic - " + e.message);
					}
					break;
				case ApplicationFacade.REMOVE_PICTURE :
					TweenLite.to(bmp, 0.5, { autoAlpha:0, onComplete:destroyBMP } );
					rectOringalSize = null;
					sendNotification(ApplicationFacade.EDIT_MODIFIED, true);
					break;
			}
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function addIngredient():void {			
			var startY:uint = 0;
			var newIng:Ingredient = new Ingredient();
			
			for(var i:String in arrIngredientList) {
				startY += newIng.height + ingSpacing;
			}
			
			newIng.x = 0;
			newIng.y = startY;
			newIng.addEventListener(Ingredient.DELETE, onDeleteIngredient);
			newIng.addEventListener(Ingredient.ADD, onClickAddIng);
			newIng.setWidth(colWidth - 20);
			arrIngredientList.push(newIng);
			sprIngHolder.addChild(newIng);
			root.stage.focus = newIng.label;
			
			ingredientHeight = startY + newIng.height + ingSpacing + 10;
		}
		
		private function deleteIngredient(curIng:Sprite):void {
			var tempIdx:uint;
			var currentIng:Ingredient;
			
			// Find Ingredient
			for(var i:String in arrIngredientList) {
				if(arrIngredientList[i] == curIng) {
					currentIng = arrIngredientList[i];
					tempIdx = uint(i);
					break;
				}
			}
			
			// Remove
			arrIngredientList.splice(tempIdx, 1);
			TweenLite.to(currentIng, .5, { autoAlpha:0, onComplete:onFinishDelete, onCompleteParams:[currentIng] } );
			updateScrollBox();
		}
		
		private function updateScrollBox():void {
			// Re-Adjust
			var startY:uint = 0;
			var l:int = arrIngredientList.length;
			for (var j:uint = 0; j < l; j++) {
				arrIngredientList[j].y = startY;
				//TweenLite.to(arrIngredientList[j], .5, { y:startY, onComplete:sbIngredient.update });
				startY += arrIngredientList[j].height + ingSpacing;
			}
			ingredientHeight = startY + 10;
			
			// Update
			sbIngredient.setScrollProperties(sbIngredient.height, 0, ingredientHeight - sbIngredient.height, sbIngredient.height);
			sbIngredient.update();
			if (ingredientHeight < sbIngredient.height) setScrollPosition(0);
		}
		
		private function drawBG(spr:Sprite, w:Number, h:Number):void {
			spr.graphics.clear();
			spr.graphics.beginFill(0xFFF3D5, 1);
			spr.graphics.drawRoundRect(0, 0, w, h, 5);
			spr.graphics.endFill();
		}
		
		private function getRecipe():Object {
			if(data == null) data = new Object();
			
			data.title = txtTitleInput.text;
			data.directions = txtDirectionInput.text;
			data.notes = txtNotesInput.text;
			data.rating = sprRating.stars;
			data.author = txtAuthorInput.text;
			data.source = txtSourceInput.text;
			data.yields = txtYieldsInput.text;
			data.category = ddCategory.selectedLabel;
			
			// Not sure if i should resize it or just leave it alone
			/*bmp.width = rectOringalSize.width;
			bmp.height = rectOringalSize.height;
			if (rectOringalSize.width > 800 && rectOringalSize.height > 800) ScaleUtil.toFit(bmp, 800, 800);
			var bmd:BitmapData = new BitmapData(bmp.width, bmp.height);
			bmd.draw(bmp, null, null, null, null, true);
			data.picture = new JPGEncoder(90).encode(bmd);*/
			if (baImage) baImage.deflate();
			data.picture = baImage;
			
			data.ingredients = new Object();
			for(var i:uint = 0; i < arrIngredientList.length; i++) {
				data.ingredients[i] = arrIngredientList[i].data;
			}
			return data;
		}
		
		private function init():void {
			filePicture.addEventListener(Event.SELECT, picSelected);
			
			// Input Format
			frmtInput.bold = false;
			frmtInput.color = 0x872301;
			frmtInput.size = 15;
			frmtInput.font = "Arial";
			
			// Component Format
			frmtComponent.bold = false;
			frmtComponent.color = 0x872301;
			frmtComponent.size = 15;
			frmtComponent.font = "Tw Cen MT";
			
			StyleManager.setStyle("embedFonts", true);
			StyleManager.setStyle("textFormat", frmtComponent);
			StyleManager.setStyle("buttonWidth", 14);
			StyleManager.setStyle("scrollBarWidth", 5);
			StyleManager.setStyle("scrollArrowHeight", 0);
			
			sbIngredient = root.getChildByName("sbIngredient") as UIScrollBar;
			sbDirection = root.getChildByName("sbDirection") as UIScrollBar;
			sbNotes = root.getChildByName("sbNotes") as UIScrollBar;
			ddCategory = root.getChildByName("ddCategory") as ComboBox;
			txtTitle = root.getChildByName("txtTitle") as TextField;
			txtTitleInput = root.getChildByName("txtTitleInput") as TextField;
			txtDirection = root.getChildByName("txtDirection") as TextField;
			txtDirectionInput = root.getChildByName("txtDirectionInput") as TextField;
			txtNotes = root.getChildByName("txtNotes") as TextField;
			txtNotesInput = root.getChildByName("txtNotesInput") as TextField;
			txtAuthor = root.getChildByName("txtAuthor") as TextField;
			txtAuthorInput = root.getChildByName("txtAuthorInput") as TextField;
			txtSource = root.getChildByName("txtSource") as TextField;
			txtSourceInput = root.getChildByName("txtSourceInput") as TextField;
			txtYields = root.getChildByName("txtYields") as TextField;
			txtYieldsInput = root.getChildByName("txtYieldsInput") as TextField;
			txtCategory = root.getChildByName("txtCategory") as TextField;
			txtRating = root.getChildByName("txtRating") as TextField;
			txtPicture = root.getChildByName("txtPicture") as TextField;
			sprSeperator = root.getChildByName("sprSeperator") as Sprite;
			sprAuthorBG = root.getChildByName("sprAuthorBG") as Sprite;
			sprTitleBG = root.getChildByName("sprTitleBG") as Sprite;
			sprDirectionBG = root.getChildByName("sprDirectionBG") as Sprite;
			sprSourceBG = root.getChildByName("sprSourceBG") as Sprite;
			sprNotesBG = root.getChildByName("sprNotesBG") as Sprite;
			sprYieldsBG = root.getChildByName("sprYieldsBG") as Sprite;
			mcPlaceholder = root.getChildByName("mcPlaceholder") as MovieClip;
			
			txtTitleInput.addEventListener(Event.CHANGE, changeHandler);
			txtTitleInput.maxChars = 150;
			txtDirectionInput.addEventListener(Event.CHANGE, changeHandler);
			txtAuthorInput.maxChars = 75;
			txtAuthorInput.addEventListener(Event.CHANGE, changeHandler);
			txtSourceInput.maxChars = 75;
			txtSourceInput.addEventListener(Event.CHANGE, changeHandler);
			txtYieldsInput.maxChars = 150;
			txtYieldsInput.addEventListener(Event.CHANGE, changeHandler);
			
			// Rating
			sprRating.x = 534;
			sprRating.y = 5;
			sprRating.stars = 1;
			sprRating.addEventListener(Event.CHANGE, changeHandler);
			root.addChild(sprRating);
			
			// Components
			ddCategory.addItem({label:"Breakfast", 				data:"Breakfast"});
			ddCategory.addItem({label:"Side Dish",				data:"SideDish"});
			ddCategory.addItem({label:"Entre", 					data:"Entre"});
			ddCategory.addItem({label:"Dessert",				data:"Dessert"});
			ddCategory.addItem({label:"Drink",					data:"Drink"});
			ddCategory.addItem({label:"Appetizer / Snack",		data:"AppSnack"});
			ddCategory.rowCount = 6;
			ddCategory.addEventListener(Event.CHANGE, changeHandler);
			
			sprIngHolder.scrollRect = new Rectangle(0, 0, 440, 280);
			sprIngHolder.x = 1;
			sprIngHolder.y = 27;
			root.addChild(sprIngHolder);
			root.addChild(sbIngredient);
			
			sbIngredient.x = 435;
			sbIngredient.y = 27;
			sbIngredient.addEventListener(ScrollEvent.SCROLL, onScroll, false, 0, true);
			
			sbDirection.setSize(5, txtDirectionInput.height + 10);
			txtDirectionInput.addEventListener(Event.CHANGE, changeHandler);
			sbNotes.setSize(5, txtNotesInput.height + 10);
			txtNotesInput.addEventListener(Event.CHANGE, changeHandler);
		}
		
		private function destroyBMP():void {
			if (bmp) {
				root.removeChild(bmp);
				bmp = null;
			}
		}
		
		private function picSelected(event:Event):void {
			destroyBMP();
			
			if(stream == null) {
				stream = new URLStream();
				stream.addEventListener(Event.COMPLETE, onBytesLoaded);
				stream.addEventListener(IOErrorEvent.IO_ERROR, destroyStream);
				stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, destroyStream);
			} else {
				destroyStream();
			}
			try	{
				stream.load(new URLRequest(filePicture.url));
			} catch(e:Error) {
				trace("EditScreenMediator::picSelected - " + e.message);
			}
			sendNotification(ApplicationFacade.EDIT_MODIFIED, true);
		}
		
		private function onBytesLoaded(event:Event):void {
			baImage = new ByteArray();
			stream.readBytes(baImage, 0, stream.bytesAvailable)
			destroyStream();
			
			loadBitmap();
		}
		
		private function loadBitmap():void {
			if(ldrPicture == null) {
				ldrPicture = new Loader();
				ldrPicture.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
				ldrPicture.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, destroyLoader);
			} else {
				destroyLoader();
			}
			
			try {
				ldrPicture.loadBytes(baImage);
			} catch (e:Error) {
				//trace("EditScreenMediator::loadBitmap - " + e.message);
			}
		}
		
		private function destroyLoader(event:Event = null):void {
			if(ldrPicture) {
				try {
					ldrPicture.close();
				} catch (e:Error) {
					//trace("EditScreenMediator::destroyLoader 1 - " + e.message);
				}
				
				try {
					ldrPicture.unload();
				} catch (e2:Error) {
					//trace("EditScreenMediator::destroyLoader 2 - " + e2.message);
				}
				
				ldrPicture.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
				ldrPicture.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, destroyLoader);
				ldrPicture = null;
			}
		}
		
		private function onLoaderComplete(event:Event):void {
			var bitmap:Bitmap = ldrPicture.content as Bitmap;
			var newBitmapData:BitmapData = bitmap.bitmapData.clone();
			bmp = new Bitmap(newBitmapData);
			bitmap.bitmapData.dispose();
			destroyLoader();
			
			rectOringalSize = bmp.getRect(bmp);
			
			ScaleUtil.toFit(bmp, rectPicture);
			
			bmp.alpha = 0;
			bmp.x = rectPicture.x + (rectPicture.width / 2) - (bmp.width / 2); // Center Horiz
			bmp.y = rectPicture.y;
			bmp.smoothing = true;
			root.addChild(bmp);
			TweenLite.to(bmp, 0.5, { autoAlpha:1 } );
		}
		
		private function destroyStream(event:Event = null):void {
			if(stream) {
				try	{
					stream.close();
				} catch (e:Error) {
					//trace("EditScreenMediator::destroyStream - " + e.message);
				}
				
				stream.removeEventListener(Event.COMPLETE, onBytesLoaded);
				stream.removeEventListener(IOErrorEvent.IO_ERROR, destroyStream);
				stream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, destroyStream);
				stream = null;
			}
		}
		
		private function setScrollPosition(pos:Number):void {
			var r:Rectangle = sprIngHolder.scrollRect;
			r.y = pos;// Since there is a little border above the list
			sprIngHolder.scrollRect = r;
		}
		
		private function onScroll(event:ScrollEvent):void {
			setScrollPosition(event.position);
		}
		
		private function changeHandler(e:Event):void {
			var spr:Sprite;
			switch(e.currentTarget) {
				case txtTitleInput :
					spr = sprTitleBG;
					break;
				case txtAuthorInput :
					spr = sprAuthorBG;
					break;
				case txtDirectionInput :
					spr = sprDirectionBG;
					break;
				case txtNotesInput :
					spr = sprNotesBG;
					break;
				case txtSourceInput :
					spr = sprSourceBG;
					break;
				case txtYieldsInput :
					spr = sprYieldsBG;
					break;
			}
			if(spr) TweenLite.to(spr, 0.25, { tint:null, alpha:1 } );
			sendNotification(ApplicationFacade.EDIT_MODIFIED, true);
		}
		
		private function onDeleteIngredient(e:Event):void {
			deleteIngredient(e.target as Sprite);
			sendNotification(ApplicationFacade.EDIT_MODIFIED, true);
		}
		
		private function onFinishDelete(oldIng:DisplayObject):void {
			sprIngHolder.removeChild(oldIng);
			sbIngredient.setScrollProperties(sbIngredient.height, 0, ingredientHeight - sbIngredient.height, sbIngredient.height);
			sbIngredient.update();
		}
		
		private function onClickAddIng(e:Event = null):void {
			addIngredient();
			
			var rect:Rectangle = sprIngHolder.scrollRect;
			rect.width = colWidth - 10;
			sprIngHolder.scrollRect = rect;
			
			sbIngredient.setScrollProperties(sbIngredient.height, 0, ingredientHeight - sbIngredient.height, sbIngredient.height);
			sbIngredient.update();
			sbIngredient.scrollPosition = sbIngredient.maxScrollPosition;
			
			sendNotification(ApplicationFacade.EDIT_MODIFIED, true);
		}
		
		private function removeAllChildren(obj:Sprite):void {
			if(obj.numChildren > 0) {
				var len:int = obj.numChildren;
				for(var i:int = 0; i < len; i++) {
					obj.removeChildAt(0);
				}
			}
			
			ingredientHeight = 10;
		}
		
		private function reset():void {
			data = new Object();
			arrIngredientList = new Array();
			removeAllChildren(sprIngHolder);
			sbIngredient.update();
			destroyLoader();
			destroyBMP();
			destroyStream();
			txtTitleInput.text = "";
			txtTitleInput.setTextFormat(frmtInput);
			txtDirectionInput.text = "";
			txtDirectionInput.setTextFormat(frmtInput);
			txtNotesInput.text = "";
			txtNotesInput.setTextFormat(frmtInput);
			txtAuthorInput.text = "";
			txtAuthorInput.setTextFormat(frmtInput);
			txtSourceInput.text = "";
			txtSourceInput.setTextFormat(frmtInput);
			txtYieldsInput.text = "1";
			txtYieldsInput.setTextFormat(frmtInput);
			sprRating.stars = 1;
			ddCategory.selectedIndex = 0;
			sendNotification(ApplicationFacade.EDIT_MODIFIED, false);
		}
		
		private function saveRecipe():void {
			// Recipe invalid
			if(arrIngredientList.length == 0) {
				sendNotification(ApplicationFacade.ALERT, {title:"Error", icon:ApplicationFacade.ERROR, message:"To save a recipe, there needs to be atleast one ingredient." } );
				return;
			}
			
			if(txtTitleInput.text.length == 0) {
				sendNotification(ApplicationFacade.ALERT, {title:"Error", icon:ApplicationFacade.ERROR, message:"To save a recipe, there needs to be a title." } );
				TweenLite.to(sprTitleBG, 0.5, { tint:0xFF0000, alpha:0.75 } );
				return;
			}
			
			if(txtDirectionInput.text.length == 0) {
				sendNotification(ApplicationFacade.ALERT, {title:"Error", icon:ApplicationFacade.ERROR, message:"To save a recipe, there needs to be some directions." } );
				TweenLite.to(sprDirectionBG, 0.5, { tint:0xFF0000, alpha:0.75 } );
				return;
			}
			
			// Ingredient empty, remove
			var i:int = arrIngredientList.length;
			while (i >= 0) {
				if(arrIngredientList[i]) {
					if (arrIngredientList[i].data.length <= 1) {
						arrIngredientList.splice(uint(i), 1);
						i = arrIngredientList.length;
					}
				}
				i--;
			}
			
			sendNotification(ApplicationFacade.SQL_SAVE, getRecipe());
			reset();
			sendNotification(ApplicationFacade.DISPLAY_CHANGE);
		}
		
		private function sizeAllChildren(obj:Sprite, w:Number):void {
			if(obj.numChildren > 1) {
				var len:int = obj.numChildren;
				for (var i:int = 0; i < len; i++) {
					var ing:Ingredient = obj.getChildAt(i) as Ingredient;
					ing.setWidth(w);
				}
			}
		}
	}
}
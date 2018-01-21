/**
*	Copyright (c) 2007 Course Vector.  All Rights Reserved.
*	#############################################################################
*	#	Add Recipe																#
*	#############################################################################
* 	
*	@author Gabriel Mariani
*/

package com.recipehouse {
	
	import fl.controls.ComboBox;
	import fl.controls.UIScrollBar;
	import fl.controls.List;
	import fl.controls.Button;
	import fl.containers.ScrollPane;
	import fl.managers.StyleManager;
	
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.EventDispatcher;
	
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	
	import flash.filters.DropShadowFilter;
	
	import gs.TweenLite;
	import com.recipehouse.add.Ingredient;
	import com.recipehouse.ui.Rating;
	import com.recipehouse.ui.PopUp;
	
	public class AddRecipe extends Sprite {
		
		private var _data:Object;
		public static const SAVE:String = "save";
		public static const CANCEL:String = "cancel";
		private var arrIngredientList:Array = new Array();
		
		private var sprTitleBG:Sprite = new Sprite();
		private var sprSeperator:Sprite = new Sprite();
		private var sprAuthorBG:Sprite = new Sprite();
		private var sprDirectionBG:Sprite = new Sprite();
		private var sprIngHolder:Sprite = new Sprite();
		
		private var txtPageTitle:TextField = new TextField();
		private var txtTitle:TextField = new TextField();
		private var txtTitleInput:TextField = new TextField();
		private var txtDirection:TextField = new TextField();
		private var txtDirectionInput:TextField = new TextField();
		private var txtAuthor:TextField = new TextField();
		private var txtAuthorInput:TextField = new TextField();
		private var txtIngredient:TextField = new TextField();
		private var txtCategory:TextField = new TextField();
		private var txtRating:TextField = new TextField();
		
		private var filterDropShadow:DropShadowFilter;
		
		private var frmtTitle:TextFormat = new TextFormat();
		private var frmtInput:TextFormat = new TextFormat();
		private var frmtPageTitle:TextFormat = new TextFormat();
		private var frmtComponent:TextFormat = new TextFormat();
		
		private var sprRating:Rating = new Rating(true);
		
		private var sbDirection:UIScrollBar = new UIScrollBar();
		private var btnAddIng:SimpleButton = new AddIngredientButton();
		private var btnCancel:SimpleButton = new CancelButton();
		private var btnSave:SimpleButton = new SaveButton();
		private var listIngredient:List = new List();
		private var paneIngredient:ScrollPane = new ScrollPane();
		private var sprAlert:PopUp = new PopUp();
		private var ddCategory:ComboBox = new ComboBox();
		private var _userName:String = "<Recipe Author>";
		
		public function AddRecipe():void {
			init();
		}
		
		private function init():void {
			
			// Init Shadow
			filterDropShadow = new DropShadowFilter();
			filterDropShadow.color = 0x000000;
			filterDropShadow.alpha = .25;
			filterDropShadow.blurX = 4;
			filterDropShadow.blurY = 4;
			filterDropShadow.angle = 45 * (Math.PI/180);
			filterDropShadow.distance = 2;
			filterDropShadow.quality = 3;
			
			// Page Title Format
			frmtPageTitle.bold = true;
			frmtPageTitle.color = 0x872301;
			frmtPageTitle.size = 25;
			frmtPageTitle.font = "Arial";
			
			// Title Format
			frmtTitle.bold = false;
			frmtTitle.color = 0x872301;
			frmtTitle.size = 15;
			frmtTitle.font = "Arial";
			
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
			
			initGlobal();			
			initRating();
			initAuthor();
			initCategory();
			initTitle();
			initDescription();			
			initIngredient();
			
			addChild(sprAlert);
		}
		
		// PUBLIC //
		public function setUserName(strName:String):void {
			_userName = strName;
		}
		
		public function reset():void {
			_data = new Object();
			arrIngredientList = new Array();
			removeAllChildren(sprIngHolder);
			paneIngredient.update();
			
			txtTitleInput.text = "<Recipe Name>";
			txtTitleInput.setTextFormat(frmtInput);
			txtDirectionInput.text = "<Recipe Directions>";
			txtDirectionInput.setTextFormat(frmtInput);
			txtAuthorInput.text = _userName;
			txtAuthorInput.setTextFormat(frmtInput);
			sprRating.stars = 1;
			ddCategory.selectedIndex = 0;
		}
		
		public function get recipe():Object {
			if(_data == null) _data = new Object();
			
			_data.title = txtTitleInput.text;
			_data.directions = txtDirectionInput.text;
			_data.rating = sprRating.stars;
			_data.author = txtAuthorInput.text;
			_data.category = ddCategory.selectedLabel;
			
			_data.ingredients = new Object();
			for(var i:uint = 0; i < arrIngredientList.length; i++) {
				_data.ingredients[i] = arrIngredientList[i].data;
			}
			return _data;
		}
		
		public function set recipe(objRecipe:Object):void {
			reset();
			
			_data = objRecipe;
			txtTitleInput.text = _data.title;
			txtTitleInput.setTextFormat(frmtInput);
			
			txtDirectionInput.text = _data.directions;
			txtDirectionInput.setTextFormat(frmtInput);
			
			txtAuthorInput.text = _data.author;
			txtAuthorInput.setTextFormat(frmtInput);
			
			sprRating.stars = _data.rating;
			for(var k:uint = 0; k < ddCategory.length; k++) {
				if(ddCategory.getItemAt(k).label == _data.category) {
					ddCategory.selectedIndex = k;
					break;
				}
			}
			
			for(var i:String in _data.ingredients) {
				addIngredient();
			}
			
			for(var j:uint = 0; j < arrIngredientList.length; j++) {
				arrIngredientList[j].data = _data.ingredients[j];
			}
		}
		
		// PRIVATE //
		
		private function initGlobal():void {
			// Page Title
			txtPageTitle.x = 15;
			txtPageTitle.y = 160;
			txtPageTitle.autoSize = TextFieldAutoSize.LEFT;
			txtPageTitle.antiAliasType = AntiAliasType.ADVANCED;
			txtPageTitle.text = "Add Recipe";
			txtPageTitle.embedFonts = true;
			txtPageTitle.setTextFormat(frmtPageTitle);
			addChild(txtPageTitle);
			
			// Seperator
			sprSeperator.graphics.lineStyle(1, 0xD77100, 1);
			sprSeperator.graphics.moveTo(0, 0);
			sprSeperator.graphics.lineTo(0, 360);
			sprSeperator.filters = [filterDropShadow];
			sprSeperator.x = 465;
			sprSeperator.y = 205;
			addChild(sprSeperator);
			
			// Cancel Button
			btnCancel.x = 10;
			btnCancel.y = 510;
			btnCancel.addEventListener(MouseEvent.CLICK, onClickCancel);
			addChild(btnCancel);
			
			// Save Button
			btnSave.x = 85;
			btnSave.y = 510;
			btnSave.addEventListener(MouseEvent.CLICK, onClickSave);
			addChild(btnSave);
		}
		
		private function initRating():void {
			// Title
			txtRating.x = 480;
			txtRating.y = 205;
			txtRating.autoSize = TextFieldAutoSize.LEFT;
			txtRating.antiAliasType = AntiAliasType.ADVANCED;
			txtRating.text = "Rating:";
			txtRating.embedFonts = true;
			txtRating.setTextFormat(frmtTitle);
			addChild(txtRating);
			
			sprRating.x = 534;
			sprRating.y = 203.3;
			sprRating.stars = 1;
			addChild(sprRating);
		}
		
		private function initCategory():void {
			// Title
			txtCategory.x = 660;
			txtCategory.y = 205;
			txtCategory.autoSize = TextFieldAutoSize.LEFT;
			txtCategory.antiAliasType = AntiAliasType.ADVANCED;
			txtCategory.text = "Category:";
			txtCategory.embedFonts = true;
			txtCategory.setTextFormat(frmtTitle);
			addChild(txtCategory);
			
			// Add Category DropDown
			ddCategory.x = 737;
			ddCategory.y = 205;
			ddCategory.width = 130;
			ddCategory.addItem({label:"Breakfast", data:"Breakfast"});
			ddCategory.addItem({label:"Side Dish", data:"SideDish"});
			ddCategory.addItem({label:"Entre", data:"Entre"});
			ddCategory.addItem({label:"Dessert", data:"Dessert"});
			ddCategory.addItem({label:"Drink", data:"Drink"});
			ddCategory.addItem({label:"Appetizers / Snacks", data:"AppSnack"});
			addChild(ddCategory);
		}
		
		private function initAuthor():void {
			// Title
			txtAuthor.x = 480;
			txtAuthor.y = 230;
			txtAuthor.autoSize = TextFieldAutoSize.LEFT;
			txtAuthor.antiAliasType = AntiAliasType.ADVANCED;
			txtAuthor.text = "Author:";
			txtAuthor.embedFonts = true;
			txtAuthor.setTextFormat(frmtTitle);
			addChild(txtAuthor);
			
			// Title BG
			sprAuthorBG.graphics.lineStyle(2, 0xE3870E, 1);
			sprAuthorBG.graphics.beginFill(0xFFF3D5, 1);
			sprAuthorBG.graphics.drawRoundRect(0, 0, 385, 30, 5);
			sprAuthorBG.graphics.endFill();
			sprAuthorBG.x = 480;
			sprAuthorBG.y = 252;
			addChild(sprAuthorBG);
			
			// Title Input			
			txtAuthorInput.antiAliasType = AntiAliasType.ADVANCED;
			txtAuthorInput.x = 482;
			txtAuthorInput.y = 256;
			txtAuthorInput.width = 380;
			txtAuthorInput.height = 25;
			txtAuthorInput.embedFonts = true;
			txtAuthorInput.type = TextFieldType.INPUT;
			txtAuthorInput.text = _userName;
			txtAuthorInput.setTextFormat(frmtInput);
			addChild(txtAuthorInput);
		}
		
		private function initTitle():void {
			// Title
			txtTitle.x = 480;
			txtTitle.y = 285;
			txtTitle.autoSize = TextFieldAutoSize.LEFT;
			txtTitle.antiAliasType = AntiAliasType.ADVANCED;
			txtTitle.text = "Name:";
			txtTitle.embedFonts = true;
			txtTitle.setTextFormat(frmtTitle);
			addChild(txtTitle);
			
			// Title BG
			sprTitleBG.graphics.lineStyle(2, 0xE3870E, 1);
			sprTitleBG.graphics.beginFill(0xFFF3D5, 1);
			sprTitleBG.graphics.drawRoundRect(0, 0, 385, 30, 5);
			sprTitleBG.graphics.endFill();
			sprTitleBG.x = 480;
			sprTitleBG.y = 307;
			addChild(sprTitleBG);
			
			// Title Input			
			txtTitleInput.antiAliasType = AntiAliasType.ADVANCED;
			txtTitleInput.x = 482;
			txtTitleInput.y = 311;
			txtTitleInput.width = 380;
			txtTitleInput.height = 25;
			txtTitleInput.embedFonts = true;
			txtTitleInput.type = TextFieldType.INPUT;
			txtTitleInput.text = "<Recipe Name>";
			txtTitleInput.setTextFormat(frmtInput);
			addChild(txtTitleInput);
		}
		
		private function initDescription():void {
			// Direction Title
			txtDirection.x = 480;
			txtDirection.y = 337;
			txtDirection.autoSize = TextFieldAutoSize.LEFT;
			txtDirection.antiAliasType = AntiAliasType.ADVANCED;
			txtDirection.text = "Directions:";
			txtDirection.embedFonts = true;
			txtDirection.setTextFormat(frmtTitle);
			addChild(txtDirection);
			
			// Direction BG
			sprDirectionBG.graphics.lineStyle(2, 0xE3870E, 1);
			sprDirectionBG.graphics.beginFill(0xFFF3D5, 1);
			sprDirectionBG.graphics.drawRoundRect(0, 0, 385, 205, 5);
			sprDirectionBG.graphics.endFill();
			sprDirectionBG.x = 480;
			sprDirectionBG.y = 360;
			addChild(sprDirectionBG);
			
			// Direction Input
			txtDirectionInput.antiAliasType = AntiAliasType.ADVANCED;
			txtDirectionInput.x = 482;
			txtDirectionInput.y = 364;
			txtDirectionInput.width = 380;
			txtDirectionInput.height = 195;
			txtDirectionInput.multiline = true;
			txtDirectionInput.wordWrap = true;
			txtDirectionInput.embedFonts = true;
			txtDirectionInput.type = TextFieldType.INPUT;
			txtDirectionInput.text = "<Recipe Directions>";
			txtDirectionInput.setTextFormat(frmtInput);
			addChild(txtDirectionInput);
			
			// Direction ScrollBar
			sbDirection.scrollTarget = txtDirectionInput;
			sbDirection.setSize(5, txtDirectionInput.height + 10);
			sbDirection.move(txtDirection.x + txtDirectionInput.width + 10, txtDirectionInput.y - 4);
			addChild(sbDirection);
		}
		
		private function initIngredient():void {
			// Ingredient Title
			txtIngredient.x = 15;
			txtIngredient.y = 205;
			txtIngredient.autoSize = TextFieldAutoSize.LEFT;
			txtIngredient.antiAliasType = AntiAliasType.ADVANCED;
			txtIngredient.text = "Ingredients:";
			txtIngredient.embedFonts = true;
			txtIngredient.setTextFormat(frmtTitle);
			addChild(txtIngredient);
			
			// Add Ingredient Button
			btnAddIng.x = 350;
			btnAddIng.y = 190;
			btnAddIng.addEventListener(MouseEvent.CLICK, onClickAddIng);
			addChild(btnAddIng);
			
			// Scroll Pane
			paneIngredient.source = sprIngHolder;
			paneIngredient.move(15, 227);
			paneIngredient.width = 440;
			paneIngredient.height = 280;
			addChild(paneIngredient);
		}
		
		private function addIngredient():void {			
			var spacer:uint = 5;
			var itemHeight:uint = 31;
			var startY:uint = 0;
			var newIng:Ingredient = new Ingredient();
			
			for(var i in arrIngredientList) {
				startY += itemHeight + spacer;
			}
			newIng.x = 0;
			newIng.y = startY;
			newIng.addEventListener(Ingredient.DELETE, onDeleteIngredient);
			arrIngredientList.push(newIng);
			sprIngHolder.addChild(newIng);
			paneIngredient.update();
		}
		
		private function deleteIngredient(curIng:Sprite):void {
			var tempIdx:uint;
			var currentIng:Ingredient;
			
			// Find Ingredient
			for(var i in arrIngredientList) {
				if(arrIngredientList[i] == curIng) {
					currentIng = arrIngredientList[i];
					tempIdx = i;
					break;
				}
			}
			
			// Remove
			arrIngredientList.splice(tempIdx, 1);
			TweenLite.to(currentIng, .5, {alpha:0}, 0, onFinishDelete, [currentIng]);
			
			// Re-Adjust
			var spacer:uint = 5;
			var itemHeight:uint = 31;
			var startY:uint = 0;
			for(var j:uint = 0; j < arrIngredientList.length; j++) {
				TweenLite.to(arrIngredientList[j], .5, {y:startY}, 0, paneIngredient.update);
				startY += itemHeight + spacer;
			}
			
			// Update
			paneIngredient.update();
		}		
		
		private function saveRecipe():void {
			// Recipe invalid
			if(arrIngredientList.length == 0 || txtTitleInput.text.length == 0 || txtDirectionInput.text.length == 0) {
				sprAlert.title = "Error";
				sprAlert.text = "To save a recipe, there needs to be atleast one ingredient, a title and some directions.";
				sprAlert.show();
				return;
			}
			
			// Ingredient invalid
			for(var i:String in arrIngredientList) {
				var curIngData:Object = arrIngredientList[i].data;
				if(curIngData.label.length <= 1) {
					sprAlert.title = "Error";
					sprAlert.text = "To save a recipe, each ingredient needs atleast a name.";
					sprAlert.show();
					return;
				}
			}
			
			dispatchEvent(new Event(SAVE));
		}		
		
		private function cancel():void {
			reset();
			dispatchEvent(new Event(CANCEL));
			
		}
		
		private function removeAllChildren(obj:Sprite):void {
			if(obj.numChildren > 0) {
				var len:int = obj.numChildren;
				for(var i:int = 0; i < len; i++) {
					obj.removeChildAt(0);
				}
			}
		}
		
		private function onClickAddIng(e:MouseEvent):void {
			addIngredient();
		}
		
		private function onClickCancel(e:MouseEvent):void {
			cancel();
		}
		
		private function onClickSave(e:MouseEvent):void {
			saveRecipe();
		}
		
		private function onDeleteIngredient(e:Event):void {
			deleteIngredient(e.target as Sprite);
		}
		
		private function onFinishDelete(oldIng):void {
			sprIngHolder.removeChild(oldIng);
			paneIngredient.update();
		}
	}
}
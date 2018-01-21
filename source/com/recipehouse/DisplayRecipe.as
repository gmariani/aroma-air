/**
*	Copyright (c) 2007 Course Vector.  All Rights Reserved.
*	#############################################################################
*	#	Display Recipe															#
*	#############################################################################
* 	
*	@author Gabriel Mariani
*/

package com.recipehouse {

	import fl.controls.Button;
	import fl.controls.List;
	import fl.controls.ScrollBar;
	
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOrientation;
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	
	import fl.data.DataProvider;
	import flash.geom.Rectangle;
	import flash.filters.DropShadowFilter;
	
	import flash.text.TextField;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fl.events.ListEvent;
	
	import gs.TweenLite;
	import com.recipehouse.print.PrintCard;
	import com.recipehouse.print.PrintPage;
	import com.recipehouse.ui.Rating;
	import com.recipehouse.ui.PopUp;
	import com.recipehouse.display.SharePopUp;
	import com.recipehouse.display.RecipeCellRenderer;
	import com.recipehouse.net.Talk;
	import com.coursevector.data.SOManager;

	public class DisplayRecipe extends Sprite {
		
		public static const EDIT_RECIPE:String = "editRecipe";
		public static const LOAD_RECIPE:String = "loadRecipe";
		public static const DELETE_RECIPE:String = "deleteRecipe";
		private var filterDropShadow:DropShadowFilter;
		
		private var txtTitle:TextField = new TextField();
		private var txtInstructions:TextField = new TextField();
		private var txtAuthor:TextField = new TextField();
		private var txtCategory:TextField = new TextField();
		private var txtListTitle:TextField = new TextField();
		
		private var frmtTitle:TextFormat = new TextFormat();
		private var frmtCopy:TextFormat = new TextFormat();
		private var frmtListTitle:TextFormat = new TextFormat();
		private var frmtCellUnselect:TextFormat = new TextFormat();
		private var frmtCellSelect:TextFormat = new TextFormat();
		private var frmtAuthor:TextFormat = new TextFormat();
		private var frmtCategory:TextFormat = new TextFormat();
		
		private var listRecipes:List = new List();
		private var dpRecipeList:DataProvider = new DataProvider();
		private var masterRecipeList:DataProvider = new DataProvider();
		private var btnEdit:SimpleButton = new EditRecipeButton();
		private var btnPrint:SimpleButton = new PrintRecipeButton();
		private var btnShare:SimpleButton = new ShareRecipeButton();
		private var btnDelete:SimpleButton = new DeleteRecipeButton();
		private var sprSeperator:Sprite = new Sprite();
		private var sprIngredient:Sprite = new Sprite();
		private var sprStarRating:Rating = new Rating(false);
		private var sprConfirm:PopUp = new PopUp("Confirm");
		private var sprAlert:PopUp = new PopUp();
		private var sprSharePopUp:SharePopUp = new SharePopUp();
		
		private var isMultipleSelected:Boolean = false;
		private var isListInit:Boolean = false;
		private var numToCheck:uint;
		private var arrCards:Array = new Array();
		private var arrRecipesToDelete:Array;
		private var arrRecipient:Array = new Array();
		private var arrRecipeSelection:Array = new Array();
		private var objRecipe:Object = new Object();
		private var strSearchType:String = "name";
		private var strLastSearch:String = "";
		private var	RecipeTalk:Talk = new Talk();
		private var soManager:SOManager = new SOManager();
		
		public function DisplayRecipe():void {
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
			
			// List Title Format
			frmtListTitle.bold = true;
			frmtListTitle.color = 0x872301;
			frmtListTitle.size = 15;
			frmtListTitle.font = "Arial";
			
			// Cell Unselected Format
			frmtCellUnselect.bold = false;
			frmtCellUnselect.color = 0xCC3202;
			frmtCellUnselect.size = 12;
			frmtCellUnselect.font = "Tw Cen MT";
			
			// Cell Selected Format
			frmtCellSelect.bold = true;
			frmtCellSelect.color = 0xFFFFFF;
			frmtCellSelect.size = 12;
			frmtCellSelect.font = "Tw Cen MT";
			
			// Toolbar Format
			frmtTitle.bold = true;
			frmtTitle.color = 0x872301;
			frmtTitle.size = 25;
			frmtTitle.font = "Bookman Old Style";
			
			// Category Format
			frmtCategory.bold = true;
			frmtCategory.italic = true;
			frmtCategory.color = 0x872301;
			frmtCategory.size = 15;
			frmtCategory.font = "Bookman Old Style";
			
			// Author Format
			frmtAuthor.italic = true;
			frmtAuthor.color = 0x872301;
			frmtAuthor.size = 15;
			frmtAuthor.font = "Bell MT";
			
			// Toolbar Format
			frmtCopy.bold = false;
			frmtCopy.color = 0x872301;
			frmtCopy.size = 12;
			frmtCopy.font = "Arial";			
			
			soManager.open("aromaData");
			initRecipe();
			initTalk();
			
			sprSharePopUp.addEventListener("accept", onShareConfirm);
			sprConfirm.addEventListener("accept", onAcceptConfirm);
		}
		
		// PUBLIC //
		public function initList():void {
			// Title
			txtListTitle.x = 90;
			txtListTitle.y = 125;
			txtListTitle.text = "Recipes List";
			txtListTitle.width = 95;
			txtListTitle.autoSize = TextFieldAutoSize.LEFT;
			txtListTitle.antiAliasType = AntiAliasType.ADVANCED;
			txtListTitle.embedFonts = true;
			txtListTitle.setTextFormat(frmtListTitle);
			txtListTitle.filters = [filterDropShadow];
			addChild(txtListTitle);
			
			listRecipes.setStyle("scrollBarWidth", 5);
			listRecipes.setStyle("scrollArrowHeight", 0);
			listRecipes.setStyle("cellRenderer", RecipeCellRenderer);
			listRecipes.rowHeight = 17;
			listRecipes.move(5, 150);
			listRecipes.width = 287;
			listRecipes.height = 428;
			listRecipes.allowMultipleSelection = true;
			listRecipes.dataProvider = dpRecipeList;
			listRecipes.addEventListener(Event.CHANGE , onItemClickList);
			addChild(listRecipes);
			
			selectRecipe([listRecipes.getItemAt(0).data]);
			
			addChild(sprSharePopUp);
			
			addChild(sprAlert);
			addChild(sprConfirm);
		}
		
		public function searchType(str:String):void {
			strSearchType = str;
			searchRecipeList(strLastSearch);
		}
		
		public function searchRecipeList(strSearch:String):void {
			if(strSearch == "" || strSearch.length < 1) cancelListFilter();
			
			var dpTemp:DataProvider = getRecipeList();
			dpRecipeList = new DataProvider();
			strLastSearch = strSearch;
			for(var i:uint = 0; i < dpTemp.length; i++) {
				var curRecipe:Object = dpTemp.getItemAt(i);
				var pattern:RegExp = new RegExp(strSearch, "ig");
				var result:Object;
				
				if(strSearchType == "name") {
					result = pattern.exec(curRecipe.label);
				} else if(strSearchType == "ingredient") {
					for(var j:String in curRecipe.data.ingredients) {
						result = pattern.exec(curRecipe.data.ingredients[j].label);
						if(result != null) {
							dpRecipeList.addItem(curRecipe);
							result = null;
							break;
						}
					}
				} else if(strSearchType == "author") {
					result = pattern.exec(curRecipe.data.author);
				}
				if(result != null) dpRecipeList.addItem(curRecipe);
			}
			listRecipes.dataProvider = dpRecipeList;
			if(dpRecipeList.length > 0) {
				selectRecipe([listRecipes.getItemAt(0).data]);
			} else {
				removeAllChildren(sprIngredient);
				onSelectNone(true);
			}
		}
		
		public function cancelListFilter():void {
			dpRecipeList = getRecipeList();
			listRecipes.dataProvider = dpRecipeList;
			selectRecipe([listRecipes.getItemAt(0).data]);
		}
		
		public function setRecipeList(sqlData:Array):void {
			dpRecipeList = new DataProvider();
			masterRecipeList = new DataProvider();
			for (var i:String in sqlData) {
				masterRecipeList.addItem({label:sqlData[i].title, data:sqlData[i]});
			}
			dpRecipeList = masterRecipeList;
			
			if(isListInit == false) {
				isListInit = true;
				initList();
			} else {
				listRecipes.dataProvider = dpRecipeList;
			}
			selectRecipe([listRecipes.getItemAt(0).data]);
		}
		
		public function get editRecipeTarget():Object {
			return objRecipe;
		}
		
		public function get toDelete():Array {
			return arrRecipesToDelete;
		}
		
		// PRIVATE //
		private function initTalk():void {
			RecipeTalk.addEventListener(Talk.NAME_AVAIL, onNameAvail);
			RecipeTalk.addEventListener(Talk.NAME_TAKEN, onNameTaken);
			RecipeTalk.addEventListener(Talk.NAME_ERROR, onNameError);
			RecipeTalk.addEventListener(Talk.SEND_SUCCESS, onSendSuccess);
			RecipeTalk.addEventListener(Talk.SEND_FAIL, onSendFail);
			RecipeTalk.addEventListener(Talk.SEND_ERROR, onSendError);
		}
		
		private function initRecipe():void {
			// Title
			txtTitle.x = 304;
			txtTitle.y = 160;
			txtTitle.width = 330;
			txtTitle.antiAliasType = AntiAliasType.ADVANCED;
			txtTitle.autoSize = TextFieldAutoSize.LEFT;
			txtTitle.wordWrap = true;
			txtTitle.embedFonts = true;
			txtTitle.multiline = true;
			txtTitle.setTextFormat(frmtTitle);
			addChild(txtTitle);
			
			// Author
			txtAuthor.x = 304;
			txtAuthor.y = 190;
			txtAuthor.width = 330;
			txtAuthor.antiAliasType = AntiAliasType.ADVANCED;
			txtAuthor.autoSize = TextFieldAutoSize.LEFT;
			txtAuthor.embedFonts = true;
			txtAuthor.setTextFormat(frmtAuthor);
			addChild(txtAuthor);
			
			// Category
			txtCategory.x = 304;
			txtCategory.y = 208;
			txtCategory.width = 330;
			txtCategory.antiAliasType = AntiAliasType.ADVANCED;
			txtCategory.autoSize = TextFieldAutoSize.LEFT;
			txtCategory.embedFonts = true;
			txtCategory.setTextFormat(frmtCategory);
			txtCategory.alpha = .5;
			addChild(txtCategory);
			
			// Rating
			sprStarRating.x = 535;
			sprStarRating.y = 190;
			addChild(sprStarRating);
			
			// Instructions
			txtInstructions.multiline = true;
			txtInstructions.antiAliasType = AntiAliasType.ADVANCED;
			txtInstructions.autoSize = TextFieldAutoSize.LEFT;
			txtInstructions.embedFonts = true;
			txtInstructions.setTextFormat(frmtCopy);
			txtInstructions.wordWrap = true;
			txtInstructions.selectable = true;
			txtInstructions.width = 330;
			txtInstructions.height = 365;
			txtInstructions.x = 304;
			txtInstructions.y = 240;
			addChild(txtInstructions);
			
			// Seperator
			sprSeperator.graphics.lineStyle(1, 0xD77100, 1);
			sprSeperator.graphics.moveTo(0, 0);
			sprSeperator.graphics.lineTo(0, 310);
			sprSeperator.filters = [filterDropShadow];
			sprSeperator.x = 640;
			sprSeperator.y = 240;
			addChild(sprSeperator);
			
			// Edit Btn			
			btnEdit.x = 650;
			btnEdit.y = 160;
			btnEdit.alpha = .5;
			btnEdit.addEventListener(MouseEvent.CLICK, onClickEdit);
			btnEdit.addEventListener(MouseEvent.MOUSE_OVER, onRollOver);
			btnEdit.addEventListener(MouseEvent.MOUSE_OUT, onRollOut);
			addChild(btnEdit);
			
			// Print Btn
			btnPrint.x = 710;
			btnPrint.y = 160;
			btnPrint.alpha = .5;
			btnPrint.addEventListener(MouseEvent.CLICK, onClickPrint);
			btnPrint.addEventListener(MouseEvent.MOUSE_OVER, onRollOver);
			btnPrint.addEventListener(MouseEvent.MOUSE_OUT, onRollOut);
			addChild(btnPrint);
			
			// Share Btn
			btnShare.x = 770;
			btnShare.y = 160;
			btnShare.alpha = .5;
			btnShare.addEventListener(MouseEvent.CLICK, onClickShare);
			btnShare.addEventListener(MouseEvent.MOUSE_OVER, onRollOver);
			btnShare.addEventListener(MouseEvent.MOUSE_OUT, onRollOut);
			addChild(btnShare);
			
			// Delete Btn			
			btnDelete.x = 825;
			btnDelete.y = 160;
			btnDelete.alpha = .5;
			btnDelete.addEventListener(MouseEvent.CLICK, onClickDelete);
			btnDelete.addEventListener(MouseEvent.MOUSE_OVER, onRollOver);
			btnDelete.addEventListener(MouseEvent.MOUSE_OUT, onRollOut);
			addChild(btnDelete);
			
			// Ingredient Holder
			sprIngredient.x = 660;
			sprIngredient.y = 250;
			addChild(sprIngredient);
			
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
		
		private function drawIngredient(objIngredient:Object):Sprite {
			var sprTemp:Sprite = new Sprite();
			
			// Draw Bullet
			var sprBullet:Sprite = new Sprite();
			sprBullet.graphics.beginFill(0x872301, 1);
			sprBullet.graphics.drawCircle(0, 0, 3.5);
			sprBullet.graphics.endFill();
			sprBullet.filters = [filterDropShadow];
			sprBullet.x = 0;
			sprBullet.y = 8.5;
			sprTemp.addChild(sprBullet);
			
			// Draw TextField
			var txtLabel:TextField = new TextField();
			txtLabel.width = 200;
			txtLabel.height = 17;
			txtLabel.autoSize = TextFieldAutoSize.LEFT;
			txtLabel.multiline = true;
			txtLabel.wordWrap = true;
			txtLabel.selectable = true;
			txtLabel.text = returnIngredient(objIngredient);
			txtLabel.antiAliasType = AntiAliasType.ADVANCED;
			txtLabel.setTextFormat(frmtCopy);
			txtLabel.embedFonts = true;
			txtLabel.x = 15;
			txtLabel.y = 0;
			
			sprTemp.addChild(txtLabel);
			
			return sprTemp;
		}
		
		private function selectRecipe(arrRecipes:Array):void {
			var startY:uint = 0;
			var spacing:uint = 1.5;
			objRecipe = arrRecipes[0];
			arrRecipeSelection = arrRecipes;
			
			// Clear holder	
			removeAllChildren(sprIngredient);
			
			if(arrRecipes.length < 1) {
				onSelectNone(false);
			} else if(arrRecipes.length > 1) {
				isMultipleSelected = true;
				btnEdit.enabled = false;
				btnPrint.enabled = true;
				btnShare.enabled = true;
				btnDelete.enabled = true;
				TweenLite.to(btnEdit, .25, {alpha:0});
				TweenLite.to(btnPrint, .25, {alpha:.5});
				TweenLite.to(btnShare, .25, {alpha:.5});
				TweenLite.to(btnDelete, .25, {alpha:.5});
				
				// Populate recipe
				txtTitle.text = "Multiple recipes selected";
				txtInstructions.text = "";
				txtAuthor.text = "";
				txtCategory.text = "";
				sprStarRating.stars = 0;
			} else {
				isMultipleSelected = false;
				btnEdit.enabled = true;
				btnPrint.enabled = true;
				btnShare.enabled = true;
				btnDelete.enabled = true;
				TweenLite.to(btnEdit, .25, {alpha:.5});
				TweenLite.to(btnPrint, .25, {alpha:.5});
				TweenLite.to(btnShare, .25, {alpha:.5});
				TweenLite.to(btnDelete, .25, {alpha:.5});
				
				// Populate recipe
				txtTitle.text = objRecipe.title;
				txtInstructions.text = objRecipe.directions;
				txtAuthor.text = "from: " + objRecipe.author;
				txtCategory.text = objRecipe.category;
				sprStarRating.stars = objRecipe.rating;
				
				// Draw ingredients
				for(var j:String in objRecipe.ingredients) {
					var curIngredient:Sprite = drawIngredient(objRecipe.ingredients[j]);
					curIngredient.y = startY;
					startY += curIngredient.height + spacing;
					sprIngredient.addChild(curIngredient);
				}
			}
			
			// Reset formats
			txtTitle.setTextFormat(frmtTitle);
			txtInstructions.setTextFormat(frmtCopy);
			txtAuthor.setTextFormat(frmtAuthor);
			txtCategory.setTextFormat(frmtCategory);
		}
		
		private function returnIngredient(objIng:Object):String {
			var strDisplay:String = "";
			if(objIng.amount != " ") {
				strDisplay += objIng.amount;
			}
			if(objIng.fraction != " ") {
				strDisplay += objIng.fraction;
			}
			if(objIng.size != " ") {
				strDisplay += " " + objIng.size;
			}
			strDisplay += " " + objIng.label;
			return strDisplay;
		}
		
		private function removeAllChildren(obj:Sprite):void {
			if(obj.numChildren > 0) {
				var len:int = obj.numChildren;
				for(var i:int = 0; i < len; i++) {
					obj.removeChildAt(0);
				}
			}
		}
		
		private function printRecipe(arrRecipes:Array):void {
			var pj:PrintJob = new PrintJob;
			//var printSetting = "3x5";
			//var printSetting = "4x6";
			var printSetting = "Page";
			
			if(pj.start()) {
				for(var i in arrRecipes) {
					var arrPages:Array = new Array();
					if(printSetting == "3x5" || printSetting == "4x6") {
						arrPages = PrintCard.getPages(arrRecipes[i], printSetting, pj);
					} else {
						arrPages = PrintPage.getPages(arrRecipes[i], pj);
					}
					
					/*if(pj.orientation == PrintJobOrientation.PORTRAIT) {
						//sprAlert.appendText = "\n\n Error Printing";
						throw new Error("Without embedding fonts you must print the top half with an orientation of landscape.");
					}*/
					
					for(var j in arrPages) {
						try {
							pj.addPage(arrPages[j]);
						} catch(e:Error) {
							trace("Print Error: " + e);
						}
					}
				}
				
				pj.send();
			}
		}		
		
		private function deleteRecipe(arrRecipes:Array):void {
			arrRecipesToDelete = arrRecipes;
			dispatchEvent(new Event(DELETE_RECIPE));
		}
		
		/// On Event ///
		private function onClickEdit(e:MouseEvent):void {
			if(isMultipleSelected == false) {
				dispatchEvent(new Event(EDIT_RECIPE));
			}
		}		
		
		private function onClickPrint(e:MouseEvent):void {
			sprAlert.title = "Information";
			sprAlert.icon = "information";
			sprAlert.text = "Now printing recipes: \n\n";
			
			for(var i in arrRecipeSelection) {
				sprAlert.text += arrRecipeSelection[i].title + "\n";
			}
			
			printRecipe(arrRecipeSelection);
			sprAlert.show();
		}
		
		private function onClickShare(e:MouseEvent):void {
			if(soManager.data.userName && soManager.data.userName.length > 1) {
				sprSharePopUp.show();
			} else {
				sprAlert.title = "Warning";
				sprAlert.icon = "warning";
				sprAlert.text = "Please set your user name in the Preferences page before sharing.";
				sprAlert.show();
			}
		}
		
		private function onShareConfirm(e:Event):void {
			var strRec:String = sprSharePopUp.getRecipients();
			strRec = strRec.replace(" ", "");
			arrRecipient = new Array();
			
			if(strRec.length > 1) {
				arrRecipient = strRec.split(",");
				numToCheck = arrRecipient.length;
				
				for(var i:String in arrRecipient) {
					RecipeTalk.checkUserName(arrRecipient[i]);
				}
			} else {
				sprAlert.title = "Warning";
				sprAlert.icon = "warning";
				sprAlert.text = "You must enter atleast one recipient.";
				sprAlert.show();
			}
		}
		
		private function onClickDelete(e:MouseEvent):void {
			sprConfirm.title = "Warning";
			sprConfirm.icon = "warning";
			sprConfirm.text = "You are about to delete recipes: \n\n";
			
			for(var i in arrRecipeSelection) {
				sprConfirm.text += arrRecipeSelection[i].title + "\n";
			}
			
			sprConfirm.show();
		}
		
		private function onAcceptConfirm(e:Event):void {
			deleteRecipe(arrRecipeSelection);
		}
		
		private function onItemClickList(e:Event):void {
			if (listRecipes.selectedItems.length > 1) {
				var arrTemp:Array = new Array();
				var arrData:Array = listRecipes.selectedItems;
				
				for(var i in arrData) {
					arrTemp.push(arrData[i].data);
				}
				selectRecipe(arrTemp);
			} else if(listRecipes.selectedItems.length > 0){
				selectRecipe([listRecipes.selectedItem.data]);
			}
		}
		
		private function onRollOver(e:MouseEvent):void {
			e.target.alpha = 1;
		}
		
		private function onRollOut(e:MouseEvent):void {
			e.target.alpha = .5;
		}
		
		private function onNameAvail(e:Event):void {
			sprAlert.title = "Error";
			sprAlert.icon = "Error";
			sprAlert.text = "One of the recipients you entered entered does not exist.";
			sprAlert.show();
		}
		
		private function onNameTaken(e:Event):void {
			numToCheck--;
			if(numToCheck == 0) RecipeTalk.sendRecipes(arrRecipient, arrRecipeSelection);
		}
		
		private function onNameError(e:Event):void {
			trace("Error checking name2");
		}
		
		private function onSendSuccess(e:Event):void {
			sprAlert.title = "Information";
			sprAlert.icon = "information";
			sprAlert.text = "Recipe(s) sent successfully";
			sprAlert.show();
		}
		
		private function onSendFail(e:Event):void {
			sprAlert.title = "Error";
			sprAlert.icon = "Error";
			sprAlert.text = "Recipe(s) failed to send.";
			sprAlert.show();
		}
		
		private function onSendError(e:Event):void {
			sprAlert.title = "Error";
			sprAlert.icon = "Error";
			sprAlert.text = "There was an error sending your recipe(s). Try again at a later time.";
			sprAlert.show();
		}
		
		private function onSelectNone(isSearch:Boolean):void {
			isMultipleSelected = false;
			btnEdit.enabled = false;
			btnPrint.enabled = false;
			btnShare.enabled = false;
			btnDelete.enabled = false;
			TweenLite.to(btnEdit, .25, {alpha:0});
			TweenLite.to(btnPrint, .25, {alpha:0});
			TweenLite.to(btnShare, .25, {alpha:0});
			TweenLite.to(btnDelete, .25, {alpha:0});
			
			// Populate recipe
			if(isSearch == true) {
				txtTitle.text = "No recipes found";
			} else {
				txtTitle.text = "No recipes selected";
			}
			txtInstructions.text = "";
			txtAuthor.text = "";
			txtCategory.text = "";
			sprStarRating.stars = 0;
			txtTitle.setTextFormat(frmtTitle);
			txtInstructions.setTextFormat(frmtCopy);
			txtAuthor.setTextFormat(frmtAuthor);
			txtCategory.setTextFormat(frmtCategory);
		}
	}	
}
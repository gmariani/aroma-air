/**
* ...
* @author Default
* @version 0.1
*/

package com.recipehouse.display {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import fl.events.ListEvent;
	
	import flash.display.Sprite;
	
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	
	import flash.filters.DropShadowFilter;
	import fl.data.DataProvider;
	import fl.controls.List;
	import fl.controls.Button;
	
	import gs.TweenLite;
	import com.recipehouse.ui.PopUp;
	import com.recipehouse.net.Talk;
	import com.recipehouse.display.RecipeCellRenderer;
	

	public class ReceivePopUp extends PopUp {
		
		private var sprInputBG:Sprite = new Sprite();
		private var txtToInput:TextField = new TextField();
		private var strTitleDef:String = "Share Recipes";
		private var nRecipeCount:uint = 0;
		private var btnLater:Button = new Button();
		private var	RecipeTalk:Talk = new Talk();
		private var listRecipes:List = new List();
		private var dpRecipeList:DataProvider = new DataProvider();
		private var _data:Array;
		private var _recipeId:uint;
		private var _userName:String = "";
		
		public function ReceivePopUp() {
			super("Confirm");
			init();
		}
		
		private function init():void {
			btnOk.label = "Save Selected";
			btnOk.width = btnOk.width + 10;
			btnCancel.label = "Close & Discard";
			btnCancel.width = btnCancel.width + 10;
			
			// Later Buttons
			btnLater.label = "Decide Later";
			btnLater.addEventListener(MouseEvent.CLICK, onClickLater);
			addChild(btnLater);
			
			listRecipes.setStyle("scrollBarWidth", 5);
			listRecipes.setStyle("scrollArrowHeight", 0);
			listRecipes.setStyle("cellRenderer", RecipeCellRenderer);
			listRecipes.rowHeight = 17;
			listRecipes.move(12, 90);
			listRecipes.width = 325;
			listRecipes.height = 210;
			listRecipes.allowMultipleSelection = true;
			listRecipes.visible = false;
			addChild(listRecipes);
			
			RecipeTalk.addEventListener(Talk.GET_SUCCESS, onGetSuccess);
			RecipeTalk.addEventListener(Talk.GET_ERROR, onGetError);
			
			icon = "information";
			title = strTitleDef;
			text = "";
		}
		
		private function onClickLater(e:MouseEvent):void {
			hide();
		}
		
		public function setData(n:uint, data:DataProvider):void {
			nRecipeCount = n;
		}
		
		public function get selectedRecipes():Array {
			_data = new Array();
			
			if (listRecipes.selectedItems.length > 1) {
				var arrData:Array = listRecipes.selectedItems;
				for(var i in arrData) _data.push(arrData[i].data);
			} else if(listRecipes.selectedItems.length > 0){
				_data = [listRecipes.selectedItem.data];
			}
			
			return _data;
		}
		
		public function get recipeId():uint {
			return _recipeId;
		}
		
		override public function set title(strTitle:String):void {
			txtTitle.text = strTitle;
			txtTitle.embedFonts = true;
			txtTitle.setTextFormat(frmtTitle);
			txtTitle.filters = [filterDropShadow];
			
			txtMessage.y = txtTitle.y + txtTitle.height + 5;
			txtToInput.y = txtMessage.y + txtMessage.height + 5;
			sprInputBG.y = txtToInput.y - 2;
			var nIconY:uint = txtMessage.y;
			sprWarning.y = nIconY;
			sprError.y = nIconY;
			sprInfo.y = nIconY;
			
			update();
		}
		
		public function set userName(str:String):void {
			_userName = str;
		}
		
		override public function show():void {
			_shown = true;
			this.visible = true;
			this.alpha = 0;
			text = "Loading...";
			RecipeTalk.getRecipes(_userName);
			
			TweenLite.to(this, .25, {alpha:1});
			
			listRecipes.visible = false;
			btnOk.visible = false;
			btnCancel.visible = false;
			btnLater.visible = false;
		}
		
		private function onGetSuccess(e:Event):void {
			var arrData:Array = RecipeTalk.recipeData;
			_recipeId = RecipeTalk.recipeId;
			dpRecipeList = new DataProvider();
			for (var i:String in arrData) {
				dpRecipeList.addItem({label:arrData[i].title, data:arrData[i]});
			}
			listRecipes.dataProvider = dpRecipeList;
			listRecipes.visible = true;
			
			text = "Below are the recipes sent from <from>. Please select which recipes you would like to save, unselected recipes will be discarded. If you would like, click 'Later' to decide this at a later time.";
			
			btnOk.visible = true;
			btnCancel.visible = true;
			btnLater.visible = true;
		}
		
		private function onGetError(e:Event):void {
			text = "There was an error retrieving your recipes. Please try again later.";
			listRecipes.visible = false;
			btnOk.visible = false;
			btnCancel.visible = true;
			btnLater.visible = false;
		}
		
		override public function set text(strMessage:String):void {
			txtMessage.text = strMessage;
			txtMessage.setTextFormat(frmtCopy);
			txtToInput.y = txtMessage.y + txtMessage.height + 5;
			sprInputBG.y = txtToInput.y - 2;
			
			update();
		}
		
		override protected function update():void {
			var middleHeight:uint;
			if(txtMessage.height < 50) {
				middleHeight = 50;
			} else {
				middleHeight = txtMessage.height;
			}
			var startY:uint = txtTitle.height + 5 + middleHeight + 15;
			startY += listRecipes.height;
			
			btnOk.y = startY;
			btnCancel.y = startY;
			btnLater.y = startY;
			
			var totalW:uint = btnOk.width + 5 + btnCancel.width;
			var startX:uint = listRecipes.x;//(this.width / 2) - (totalW / 2);
			btnOk.x = startX;
			btnCancel.x = btnOk.x + btnOk.width + 5;
			btnLater.x = btnCancel.x + btnCancel.width + 5;

			setSize(_width, startY + btnOk.height + 5);
		}
		
		public function getRecipients():String {
			return txtToInput.text;
		}
	}
}
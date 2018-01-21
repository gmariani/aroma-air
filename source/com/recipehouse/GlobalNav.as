/**
*	Copyright (c) 2007 Course Vector.  All Rights Reserved.
*	#############################################################################
*	#	GlobalNav																#
*	#############################################################################
* 	
*	@author Gabriel Mariani
*/

package com.recipehouse {
	
	import com.recipehouse.ui.SearchDropDown;
	import flash.display.SimpleButton;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.AntiAliasType;
	import flash.text.TextFormat;
	
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.events.MouseEvent;
	
	import flash.filters.DropShadowFilter;
	import gs.TweenLite;
	
	public class GlobalNav extends Sprite {		
		
		public static const SEARCH:String = "search";
		public static const SEARCH_TYPE:String = "searchType";
		private var arrButtonList:Array = new Array();
		public var sprLogo:Sprite = new Logo();
		private var sprSearchDD:Sprite = new SearchDropDown(["Name", "Ingredient", "Author"]);
		private var sprSearch:Sprite = new SearchBox();
		private var txtSearch:TextField = new TextField();
		private var txtSearchTitle:TextField = new TextField();
		private var filterDropShadow:DropShadowFilter = new DropShadowFilter();
		private var filterDropShadow2:DropShadowFilter = new DropShadowFilter();
		private var frmtSearch:TextFormat = new TextFormat();
		private var frmtTitle:TextFormat = new TextFormat();
		private var _searchText:String;
		private var mcNameBtn:MovieClip = new NameButton();
		private var mcIngBtn:MovieClip = new IngredientButton();
		private var curSelected:String;
		
		public function GlobalNav():void {
			init();
		}
		
		private function init():void {
			
			// Init Inner Shadow
			filterDropShadow.color = 0x000000;
			filterDropShadow.alpha = 1;
			filterDropShadow.blurX = 4;
			filterDropShadow.blurY = 4;
			filterDropShadow.strength = .15;
			filterDropShadow.angle = 45 * (Math.PI/180);
			filterDropShadow.distance = 3;
			filterDropShadow.inner = true;
			filterDropShadow.quality = 3;
			
			// Init Shadow
			filterDropShadow2.color = 0x000000;
			filterDropShadow2.alpha = .25;
			filterDropShadow2.blurX = 2;
			filterDropShadow2.blurY = 2;
			filterDropShadow2.angle = 45 * (Math.PI/180);
			filterDropShadow2.distance = 2;
			filterDropShadow2.quality = 3;
			
			// Search Format
			frmtSearch.bold = false;
			frmtSearch.color = 0xD77100;
			frmtSearch.size = 13;
			frmtSearch.font = "Arial";
			
			// Search Format
			frmtTitle.bold = true;
			frmtTitle.color = 0xFFFFFF;
			frmtTitle.size = 15;
			frmtTitle.font = "Arial";
			
			// Logo
			sprLogo.x = -14.5;
			sprLogo.y = 6.5;
			addChild(sprLogo);
			initSearch();
		}
		
		private function initSearch():void {
			sprSearch.x = 665;
			sprSearch.y = 43;
			sprSearch.filters = [filterDropShadow];
			addChild(sprSearch);
			
			sprSearchDD.x = 675;
			sprSearchDD.y = 46.3;
			sprSearchDD.addEventListener(SearchDropDown.SELECTED, onSelected);
			addChild(sprSearchDD);
			
			txtSearchTitle.antiAliasType = AntiAliasType.ADVANCED;
			txtSearchTitle.y = 20;
			txtSearchTitle.x = 705;
			txtSearchTitle.selectable = false;
			txtSearchTitle.width = 160;
			txtSearchTitle.height = 20;
			txtSearchTitle.embedFonts = true;
			txtSearchTitle.filters = [filterDropShadow2];
			txtSearchTitle.text = "Search Recipes";
			txtSearchTitle.setTextFormat(frmtTitle);
			//addChild(txtSearchTitle);
			
			txtSearch.antiAliasType = AntiAliasType.ADVANCED;
			txtSearch.y = 45;
			txtSearch.x = 695;
			txtSearch.width = 160;
			txtSearch.height = 20;
			txtSearch.embedFonts = true;
			//txtSearch.filters = [filterDropShadow2];
			txtSearch.type = TextFieldType.INPUT;
			txtSearch.text = "Search";
			txtSearch.setTextFormat(frmtSearch);
			txtSearch.addEventListener(Event.CHANGE, onChangeSearch);
			addChild(txtSearch);
			
			curSelected = "name";
		}
		
		private function onSelected(e:Event):void {
			curSelected = e.target.curSelected;
			dispatchEvent(new Event("searchType"));
		}
		
		public function showButton(curButton:SimpleButton):void {
			curButton.enabled = true;
			TweenLite.to(curButton, .5, {alpha:1, y:30});
		}
		
		public function highlightButton(curButton:SimpleButton):void {
			curButton.enabled = true;
			TweenLite.to(curButton, .5, {alpha:1, y:30, onComplete:onFinishTween1, onCompleteParams:[curButton]});
		}
		
		private function onFinishTween1(curButton:SimpleButton):void { TweenLite.to(curButton, .15, {alpha:.2, onComplete:onFinishTween2, onCompleteParams:[curButton]}) }
		private function onFinishTween2(curButton:SimpleButton):void { TweenLite.to(curButton, .15, {alpha:1, onComplete:onFinishTween3, onCompleteParams:[curButton]}) }
		private function onFinishTween3(curButton:SimpleButton):void { TweenLite.to(curButton, .15, {alpha:.2, onComplete:onFinishTween4, onCompleteParams:[curButton]}) }
		private function onFinishTween4(curButton:SimpleButton):void { TweenLite.to(curButton, .15, {alpha:1, onComplete:onFinishTween5, onCompleteParams:[curButton]}) }
		private function onFinishTween5(curButton:SimpleButton):void { TweenLite.to(curButton, .15, {alpha:.2, onComplete:onFinishTween6, onCompleteParams:[curButton]}) }
		private function onFinishTween6(curButton:SimpleButton):void { TweenLite.to(curButton, .15, {alpha:1}) }
		
		public function hideButton(curButton:SimpleButton):void {
			curButton.enabled = false;
			TweenLite.to(curButton, .5, {alpha:0, y:35});
		}
		
		public function addButton(curButton:SimpleButton):void {
			curButton.x = 590;
			curButton.y = 30;
			addChild(curButton);
			
			var curIndex:uint = arrButtonList.push(curButton);

			if(arrButtonList.length > 0 && curIndex != 1) {
				var prevButton:SimpleButton = arrButtonList[curIndex - 2];
				curButton.x = prevButton.x - curButton.width;
			}
		}
		
		private function onChangeSearch(e:Event):void {
			_searchText = txtSearch.text;
			dispatchEvent(new Event("search"));
		}
		
		public function get searchText():String {
			return _searchText;
		}
		
		public function get searchType():String {
			return curSelected;
		}
	}	
}
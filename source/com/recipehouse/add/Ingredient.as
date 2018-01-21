/**
*	Copyright (c) 2007 Course Vector.  All Rights Reserved.
*	#############################################################################
*	#	Ingredient																#
*	#############################################################################
* 	
*	@author Gabriel Mariani
*/


package com.recipehouse.add {

	import fl.controls.ComboBox;
	import fl.managers.StyleManager;
	
	import flash.display.Sprite;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.EventDispatcher;
	
	import flash.text.TextField;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	
	import gs.TweenLite;

	public class Ingredient extends Sprite {

		public static var DELETE:String = "delete";
        private var _data:Object;
		private var txtNumber:TextField = new TextField();
		private var txtLabel:TextField = new TextField();
		private var sprNumberBG:Sprite = new Sprite();
		private var sprLabelBG:Sprite = new Sprite();
		private var ddFraction:ComboBox = new ComboBox();
		private var ddSize:ComboBox = new ComboBox();
		private var sprDelete:Sprite = new DeleteIcon();
		private var frmtCopy:TextFormat = new TextFormat();
		private var frmtComponent:TextFormat = new TextFormat();
		
		public function Ingredient() {
			init();
		}
		
		private function init():void {
			
			// Format
			frmtCopy.color = 0x872301;
			frmtCopy.size = 15;
			frmtCopy.font = "Arial";
			
			// Component Format
			frmtComponent.bold = false;
			frmtComponent.color = 0x872301;
			frmtComponent.size = 12;
			frmtComponent.font = "Tw Cen MT";
			
			StyleManager.setStyle("embedFonts", true);
			StyleManager.setStyle("textFormat", frmtComponent);
			StyleManager.setStyle("buttonWidth", 14);
			StyleManager.setStyle("scrollBarWidth", 5);
			StyleManager.setStyle("scrollArrowHeight", 0);
			
			this.graphics.beginFill(0xFFA40A, .3);
			this.graphics.drawRoundRect(0, 0, 430, 31, 5);
			this.graphics.endFill();
			
			// Add Number BG
			sprNumberBG.graphics.lineStyle(2, 0xE3880F, 1);
			sprNumberBG.graphics.beginFill(0xFFF3D5, 1);
			sprNumberBG.graphics.drawRoundRect(0, 0, 48, 20, 5);
			sprNumberBG.graphics.endFill();
			sprNumberBG.x = 10;
			sprNumberBG.y = 5.5;
			this.addChild(sprNumberBG);
			
			// Add Number Input
			txtNumber.antiAliasType = AntiAliasType.ADVANCED;
			txtNumber.x = 10;
			txtNumber.y = 5.5;
			txtNumber.width = 48;
			txtNumber.height = 20;
			txtNumber.embedFonts = true;
			txtNumber.type = TextFieldType.INPUT;
			txtNumber.text = " ";
			txtNumber.restrict = "0-9";
			txtNumber.setTextFormat(frmtCopy);
			txtNumber.addEventListener(Event.CHANGE, onDataChange);
			this.addChild(txtNumber);
			
			// Add Fraction DropDown
			ddFraction.x = 64;
			ddFraction.y = 4;
			ddFraction.width = 50;
			ddFraction.addItem({label:" ", data:" "});
			ddFraction.addItem({label:"1/2", data:"1/2"});
			ddFraction.addItem({label:"1/3", data:"1/3"});
			ddFraction.addItem({label:"1/4", data:"1/4"});
			ddFraction.addItem({label:"1/6", data:"1/6"});
			ddFraction.addItem({label:"1/8", data:"1/8"});
			ddFraction.addItem({label:"1/16", data:"1/16"});
			ddFraction.addItem({label:"2/3", data:"2/3"});
			ddFraction.addItem({label:"3/4", data:"3/4"});
			ddFraction.addItem({label:"3/8", data:"3/8"});
			ddFraction.addEventListener(Event.CHANGE, onDataChange);
			this.addChild(ddFraction);
			
			// Add Size DropDown
			ddSize.x = 121;
			ddSize.y = 4;
			ddSize.width = 50;
			ddSize.addItem({label:" ", data:" "});
			ddSize.addItem({label:"tsp", data:"tsp"});
			ddSize.addItem({label:"Tbsp", data:"Tbsp"});
			ddSize.addItem({label:"oz", data:"oz"});
			ddSize.addItem({label:"pkg", data:"pkg"});
			ddSize.addItem({label:"C", data:"C"});
			ddSize.addItem({label:"pt", data:"pt"});
			ddSize.addItem({label:"qt", data:"qt"});
			ddSize.addItem({label:"gal", data:"gal"});
			ddSize.addItem({label:"lb", data:"lb"});
			ddSize.addItem({label:"small", data:"small"});
			ddSize.addItem({label:"med", data:"med"});
			ddSize.addItem({label:"lg", data:"lg"});
			ddSize.addEventListener(Event.CHANGE, onDataChange);
			this.addChild(ddSize);
			
			// Add Ingredient BG
			sprLabelBG.graphics.lineStyle(2, 0xE3880F, 1);
			sprLabelBG.graphics.beginFill(0xFFF3D5, 1);
			sprLabelBG.graphics.drawRoundRect(0, 0, 223, 20, 5);
			sprLabelBG.graphics.endFill();
			sprLabelBG.x = 178;
			sprLabelBG.y = 5.5;
			this.addChild(sprLabelBG);
			
			// Add Ingredient Input
			txtLabel.antiAliasType = AntiAliasType.ADVANCED;
			txtLabel.x = 178;
			txtLabel.y = 5.5;
			txtLabel.width = 223;
			txtLabel.height = 20;
			txtLabel.embedFonts = true;
			txtLabel.type = TextFieldType.INPUT;
			txtLabel.text = " ";
			txtLabel.setTextFormat(frmtCopy);
			txtLabel.addEventListener(Event.CHANGE, onDataChange);
			this.addChild(txtLabel);
			
			// Add Delete Button
			sprDelete.x = 406;
			sprDelete.y = 6;
			sprDelete.addEventListener(MouseEvent.CLICK, onClickDelete);
			this.addChild(sprDelete);
			
			this.alpha = 0;
			TweenLite.to(this, .5, {alpha:1});
			
			updateData();
		}
		
		private function onClickDelete(e:MouseEvent):void {
			dispatchEvent(new Event(DELETE));
		}
		
		public function set data(d:Object):void {
			_data = d;
			txtNumber.text = _data.amount;
			txtNumber.setTextFormat(frmtCopy);
			
			for(var i:uint = 0; i < ddFraction.length; i++) {
				if(ddFraction.getItemAt(i).label == _data.fraction) {
					ddFraction.selectedIndex = i;
					break;
				}
			}
			
			for(var j:uint = 0; i < ddSize.length; j++) {
				if(ddSize.getItemAt(j).label == _data.size) {
					ddSize.selectedIndex = j;
					break;
				}
			}
			
			txtLabel.text = _data.label;
			txtLabel.setTextFormat(frmtCopy);
		}
		
		public function get data():Object {
			return _data;
		}
		
		private function onDataChange(e:Event):void {
			updateData();			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function updateData():void {
			if(_data == null) {
				_data = new Object();
			}
			
			_data.amount = txtNumber.text;
			_data.fraction = ddFraction.selectedLabel;
			_data.size = ddSize.selectedLabel;
			_data.label = txtLabel.text;
		}
	}
}
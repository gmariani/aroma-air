/**
*	Copyright (c) 2007 Course Vector.  All Rights Reserved.
*	#############################################################################
*	#	Ingredient																#
*	#############################################################################
* 	
*	@author Gabriel Mariani
*/


package com.coursevector.aroma.view.components {
	
	import cv.util.StringUtil;
	import flash.display.Sprite;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.EventDispatcher;
	
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import gs.TweenLite;

	public class Ingredient extends Sprite {

		public static var DELETE:String = "delete";
		public static var ADD:String = "add";
		private var txtLabel:TextField = new TextField();
		private var sprLabelBG:Sprite = new Sprite();
		private var sprDelete:Sprite = new DeleteIcon();
		private var frmtCopy:TextFormat = new TextFormat();
		
		public function Ingredient() {
			init();
		}
		
		public function get label():TextField {
			return txtLabel;
		}
		
		//430
		public function setWidth(w:Number):void {
			if (w < 220) w = 220;
			
			w -= sprDelete.width + 15;
			
			sprLabelBG.graphics.clear();
			sprLabelBG.graphics.beginFill(0xFFF3D5, 1);
			sprLabelBG.graphics.drawRoundRect(0, 0, w, 20, 5);
			sprLabelBG.graphics.endFill();
			txtLabel.width = w;
			
			sprDelete.x = sprLabelBG.x + sprLabelBG.width + 5;
		}
		
		private function init():void {
			
			// Format
			frmtCopy.color = 0x872301;
			frmtCopy.size = 15;
			frmtCopy.font = "Arial";
			
			// Add Ingredient BG
			//sprLabelBG.graphics.lineStyle(1, 0xE3880F, 1);
			sprLabelBG.graphics.beginFill(0xFFF3D5, 1);
			sprLabelBG.graphics.drawRoundRect(0, 0, 223, 20, 5);
			sprLabelBG.graphics.endFill();
			sprLabelBG.x = 10;
			sprLabelBG.y = 5.5;
			sprLabelBG.mouseEnabled = false;
			this.addChild(sprLabelBG);
			
			// Add Ingredient Input
			txtLabel.antiAliasType = AntiAliasType.ADVANCED;
			txtLabel.x = 10;
			txtLabel.y = 5.5;
			txtLabel.width = 223;
			txtLabel.height = 20;
			txtLabel.embedFonts = true;
			txtLabel.multiline = false;
			txtLabel.wordWrap = false;
			txtLabel.mouseWheelEnabled = false;
			txtLabel.type = TextFieldType.INPUT;
			txtLabel.defaultTextFormat = frmtCopy;
			txtLabel.addEventListener(Event.CHANGE, onDataChange);
			txtLabel.addEventListener(KeyboardEvent.KEY_DOWN, onReturn);
			this.addChild(txtLabel);
			
			// Add Delete Button
			sprDelete.x = 406;
			sprDelete.y = 6;
			sprDelete.addEventListener(MouseEvent.CLICK, onClickDelete);
			sprDelete.buttonMode = true;
			this.addChild(sprDelete);
			
			this.alpha = 0;
			TweenLite.to(this, .5, { alpha:1 } );
		}
		
		private function onReturn(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.ENTER) {
				dispatchEvent(new Event(ADD));
			}
		}
		
		private function onClickDelete(e:MouseEvent):void {
			dispatchEvent(new Event(DELETE));
		}
		
		public function set data(d:String):void {
			txtLabel.text = unescape(d);
			txtLabel.setTextFormat(frmtCopy);
		}
		
		public function get data():String {
			return escape(StringUtil.trimLeft(txtLabel.text));
		}
		
		private function onDataChange(e:Event):void {		
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}
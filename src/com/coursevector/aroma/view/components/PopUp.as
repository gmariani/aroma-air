/**
*	Copyright (c) 2007 Course Vector.  All Rights Reserved.
*	#############################################################################
*	#	Ingredient																#
*	#############################################################################
* 	
*	@author Gabriel Mariani
*/


package com.coursevector.aroma.view.components {

	import flash.display.NativeWindow;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	
	import fl.controls.Button;

	import flash.display.GradientType;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;

	public class PopUp extends NativeWindow {

		public static const ACCEPT:String = "accept";
		public static const DECLINE:String = "decline";
		public static const ALERT:String = "ALERT";
		public static const CONFIRM:String = "confirm";
		public static const WARNING:String = "warning";
		public static const INFORMATION:String = "information";
		public static const ERROR:String = "ERROR";
		
		// Assets
		protected var btnOk:Button = new Button();
		protected var btnCancel:Button = new Button();
		protected var txtMessage:TextField = new TextField();
		protected var sprWarning:Sprite = new WarningIcon();
		protected var sprBG:Sprite = new Sprite();
		protected var sprError:Sprite = new ErrorIcon();
		protected var sprInfo:Sprite = new ImportantIcon();
		
		// Variables
		protected var _type:String = ALERT;
		protected var _callee:String;
		protected var strIcon:String = INFORMATION;
		protected var frmtCopy:TextFormat = new TextFormat();
		protected var frmtComponent:TextFormat = new TextFormat();
		
		public function PopUp() {
			// Init Window
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.maximizable = false;
			winArgs.minimizable = false;
			winArgs.resizable = false;
			winArgs.type = NativeWindowType.NORMAL;
			super(winArgs);
			
			init();
		}
		
		public function get text():String {
			return txtMessage.text;
		}
		
		public function set text(strMessage:String):void {
			txtMessage.text = strMessage;
			txtMessage.setTextFormat(frmtCopy);
			
			update();
		}
		
		public function set icon(strId:String):void {
			strIcon = strId.toLowerCase();
			setIcon();
		}
		
		public function get icon():String {
			return strIcon;
		}
		
		public function set popupType(value:String):void {
			_type = value;
			
			btnCancel.visible = (_type == CONFIRM);
			update();
		}
		
		public function get popupType():String {
			return _type;
		}
		
		public function set callee(value:String):void {
			_callee = value;
		}
		
		public function get callee():String {
			return _callee;
		}
		
		private function init():void {
			// Copy Format
			frmtCopy.bold = false;
			frmtCopy.color = 0x872301;
			frmtCopy.size = 12;
			frmtCopy.font = "Arial";
			
			// Component Format
			frmtComponent.bold = false;
			frmtComponent.color = 0x872301;
			frmtComponent.size = 15;
			frmtComponent.font = "Tw Cen MT";
			
			this.width = 350;
			this.height = 150;
			_type = type;
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addChild(sprBG);
			
			// Message
			txtMessage.x = 70;
			txtMessage.y = 5;
			txtMessage.text = "Message";
			txtMessage.width = 275;
			txtMessage.height = 12;
			txtMessage.multiline = true;
			txtMessage.wordWrap = true;
			txtMessage.selectable = false;
			txtMessage.antiAliasType = AntiAliasType.ADVANCED;
			txtMessage.autoSize = TextFieldAutoSize.LEFT;
			//txtMessage.embedFonts = true;
			txtMessage.setTextFormat(frmtCopy);
			stage.addChild(txtMessage);
			
			// Add Buttons
			btnOk.label = "Ok";
			//btnOk.setStyle("embedFonts", true);
			btnOk.setStyle("textFormat", frmtComponent);
			btnOk.addEventListener(MouseEvent.CLICK, onClickOk);
			stage.addChild(btnOk);
			
			btnCancel.label = "Cancel";
			//btnCancel.setStyle("embedFonts", true);
			btnCancel.setStyle("textFormat", frmtComponent);
			btnCancel.addEventListener(MouseEvent.CLICK, onClickCancel);
			stage.addChild(btnCancel);
			
			var nIconX:uint = 15;
			var nIconY:uint = 5;
			addIcon(sprWarning, nIconX, nIconY);
			addIcon(sprError, nIconX, nIconY);
			addIcon(sprInfo, nIconX, nIconY);
			setIcon();
			update();
			
			var b:Rectangle = Screen.mainScreen.bounds;
			this.x = (b.width / 2) - (this.width / 2);
			this.y = (b.height / 2) - (this.height / 2);
		}
		
		private function onClickOk(e:MouseEvent):void {
			visible = false;
			dispatchEvent(new Event(ACCEPT));
		}
		
		private function onClickCancel(e:MouseEvent):void {
			visible = false;
			dispatchEvent(new Event(DECLINE));
		}
		
		private function addIcon(spr:Sprite, nX:uint, nY:uint):void {
			spr.x = nX;
			spr.y = nY;
			spr.width = 50;
			spr.height = 50;
			spr.visible = false;
			stage.addChild(spr);
		}
		
		protected function setSize(w:uint, h:uint):void {
			var colors:Array = [0xFF9B0D, 0xFFCB57];
			var alphas:Array = [100, 100];
			var ratios:Array = [0x00, 0xFF];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(w, h, Math.PI / 2, 0, 20);
			sprBG.graphics.clear();
			sprBG.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matr);
			sprBG.graphics.drawRect(0, 0, w, h);
			sprBG.graphics.endFill();
			
			this.width = w;
			this.height = h;
		}
		
		protected function update():void {
			var newHeight:Number = txtMessage.y + txtMessage.height + 5;
			var startY:uint = newHeight < 50 ? 50 : newHeight;
			btnOk.y = startY;
			btnCancel.y = startY;
			
			if(_type == CONFIRM) {
				var totalW:uint = btnOk.width + 5 + btnCancel.width;
				var startX:uint = (this.width / 2) - (totalW / 2);
				btnOk.x = startX;
				btnCancel.x = btnOk.x + btnOk.width + 5;
			} else {
				btnOk.x = (this.width / 2) - (btnOk.width / 2);
			}
			
			setSize(this.width, btnOk.y + btnOk.height + 35);
		}
		
		protected function setIcon() {
			sprWarning.visible = false;
			sprError.visible = false;
			sprInfo.visible = false;
			switch(strIcon) {
				case WARNING :
					sprWarning.visible = true;
					break;
				case INFORMATION :
					sprInfo.visible = true;
					break;
				case ERROR :
					sprError.visible = true;
					break;
				default :
					sprInfo.visible = true;
			}
		}
	}
}
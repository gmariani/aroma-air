package com.recipehouse.ui {
	
	import fl.controls.Button;

	import flash.display.Sprite;
	import flash.display.GradientType;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	
	import flash.filters.DropShadowFilter;
	import flash.filters.GradientGlowFilter;
	import flash.geom.Matrix;
	import gs.TweenLite;

	public class PopUp extends Sprite {

		public static const ACCEPT:String = "accept";
		public static const DECLINE:String = "decline";
		protected var _type:String = "Alert";
		protected var _shown:Boolean = false;
		protected var _height:uint = 100;
		protected var _width:uint = 350;
		protected var filterDropShadow:DropShadowFilter;
		protected var filterDropShadow2:DropShadowFilter;
		protected var btnOk:Button = new Button();
		protected var btnCancel:Button = new Button();
		protected var txtMessage:TextField = new TextField();
		protected var txtTitle:TextField = new TextField();
		protected var frmtTitle:TextFormat = new TextFormat();
		protected var frmtCopy:TextFormat = new TextFormat();
		protected var frmtComponent:TextFormat = new TextFormat();

		protected var strIcon:String = "information";
		protected var sprWarning:Sprite = new WarningIcon();
		protected var sprError:Sprite = new ErrorIcon();
		protected var sprInfo:Sprite = new ImportantIcon();
		
		public function PopUp(type:String="Alert"):void {
			_type = type;
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
			
			filterDropShadow2 = new DropShadowFilter(3, 82 * (Math.PI/180), 0x000000, .5, 4, 4, 1, 3, false, false, false);
			
			// Title Format
			frmtTitle.bold = true;
			frmtTitle.color = 0x872301;
			frmtTitle.size = 15;
			frmtTitle.font = "Arial";
			
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
			
			// Title
			txtTitle.x = 5;
			txtTitle.y = 5;
			txtTitle.text = "Title";
			txtTitle.width = 340;
			txtTitle.multiline = true;
			txtTitle.wordWrap = true;
			txtTitle.selectable = false;
			txtTitle.autoSize = TextFieldAutoSize.LEFT;
			txtTitle.antiAliasType = AntiAliasType.ADVANCED;
			txtTitle.embedFonts = true;
			txtTitle.setTextFormat(frmtTitle);
			txtTitle.filters = [filterDropShadow];
			addChild(txtTitle);
			
			// Message
			txtMessage.x = 70;
			txtMessage.y = 30;
			txtMessage.text = "Message";
			txtMessage.width = 275;
			txtMessage.height = 12;
			txtMessage.multiline = true;
			txtMessage.wordWrap = true;
			txtMessage.selectable = false;
			txtMessage.antiAliasType = AntiAliasType.ADVANCED;
			txtMessage.autoSize = TextFieldAutoSize.LEFT;
			txtMessage.embedFonts = true;
			txtMessage.setTextFormat(frmtCopy);
			addChild(txtMessage);
			
			// Add Buttons
			btnOk.label = "Ok";
			btnOk.setStyle("embedFonts", true);
			btnOk.setStyle("textFormat", frmtComponent);
			btnOk.addEventListener(MouseEvent.CLICK, onClickOk);
			addChild(btnOk);
			
			if(_type == "Confirm") {
				btnCancel.label = "Cancel";
				btnCancel.setStyle("embedFonts", true);
				btnCancel.setStyle("textFormat", frmtComponent);
				btnCancel.addEventListener(MouseEvent.CLICK, onClickCancel);
				addChild(btnCancel);
			}
			
			var nIconX:uint = 15;
			var nIconY:uint = 30;
			addIcon(sprWarning, nIconX, nIconY);
			addIcon(sprError, nIconX, nIconY);
			addIcon(sprInfo, nIconX, nIconY);
			setIcon();
			update();
			
			this.alpha = 0;
			this.visible = false;			
			this.filters = [filterDropShadow2];
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void {
			if(stage) {
				this.x = (stage.stageWidth / 2) - (this.width / 2);
				this.y = (stage.stageHeight / 2) - (this.height / 2);
			}
		}
		
		protected function setSize(w:uint, h:uint):void {
			graphics.clear();			
			var fillType:String = GradientType.LINEAR;
			var colors:Array = [0xFF9B0D, 0xFFCB57];
			var alphas:Array = [100, 100];
			var ratios:Array = [0x00, 0xFF];
			var matr:Matrix = new Matrix();
			matr.createGradientBox(w, h, Math.PI / 2, 0, 20);
			graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matr);
			//graphics.beginFill(0xff00ff, .75);
			graphics.drawRoundRect(0, 0, w, h, 15);
			graphics.endFill();
		}
		
		private function onClickOk(e:MouseEvent):void {
			hide();
			dispatchEvent(new Event(ACCEPT));
		}
		
		private function onClickCancel(e:MouseEvent):void {
			hide();
			dispatchEvent(new Event(DECLINE));
		}
		
		protected function update():void {
			var middleHeight:uint;
			if(txtMessage.height < 50) {
				middleHeight = 50;
			} else {
				middleHeight = txtMessage.height;
			}
			var startY:uint = txtTitle.height + 5 + middleHeight + 20;
			
			btnOk.y = startY;
			btnCancel.y = startY;
			
			if(_type == "Confirm") {
				var totalW:uint = btnOk.width + 5 + btnCancel.width;
				var startX:uint = (this.width / 2) - (totalW / 2);
				btnOk.x = startX;
				btnCancel.x = btnOk.x + btnOk.width + 5;
			} else {
				btnOk.x = (this.width / 2) - (btnOk.width / 2);
			}
			
			setSize(_width, startY + btnOk.height + 5);
		}
		
		public function set title(strTitle:String):void {
			txtTitle.text = strTitle;
			txtTitle.embedFonts = true;
			txtTitle.setTextFormat(frmtTitle);
			txtTitle.filters = [filterDropShadow];
			
			txtMessage.y = txtTitle.y + txtTitle.height + 5;
			var nIconY:uint = txtMessage.y;
			sprWarning.y = nIconY;
			sprError.y = nIconY;
			sprInfo.y = nIconY;
			
			update();
		}
		
		public function get title():String {
			return txtTitle.text;
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
		
		private function addIcon(spr:Sprite, nX:uint, nY:uint):void {
			spr.x = nX;
			spr.y = nY;
			spr.width = 50;
			spr.height = 50;
			spr.visible = false;
			addChild(spr);
		}
		
		protected function setIcon() {
			sprWarning.visible = false;
			sprError.visible = false;
			sprInfo.visible = false;
			switch(strIcon) {
				case "warning" :
					sprWarning.visible = true;
					break;
				case "information" :
					sprInfo.visible = true;
					break;
				case "error" :
					sprError.visible = true;
					break;
				default :
					sprInfo.visible = true;
			}
		}
		
		public function get text():String {
			return txtMessage.text;
		}
		
		public function show():void {
			_shown = true;
			this.visible = true;
			this.alpha = 0;
			TweenLite.to(this, .25, {alpha:1});
		}
		
		public function hide():void {
			_shown = false;
			TweenLite.to(this, .25, {alpha:0}, 0, setVisible);
		}
		
		private function setVisible():void {
			this.visible = false;
		}
		
		public function get shown():Boolean {
			return _shown;
		}
	}
}
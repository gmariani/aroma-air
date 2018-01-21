/**
* ...
* @author Default
* @version 0.1
*/

package com.recipehouse.display {
	
	import com.recipehouse.ui.PopUp;
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.filters.DropShadowFilter;

	public class SharePopUp extends PopUp {
		
		private var sprInputBG:Sprite = new Sprite();
		private var txtToInput:TextField = new TextField();
		private var strTitleDef:String = "Share Recipes";
		private var strMessageDef:String = "Please enter the user name of the person you would like to send the selected recipes to. Use commas to enter more than one recipient.";
		
		public function SharePopUp() {
			super("Confirm");
			init();
		}
		
		private function init():void {
			btnOk.label = "Send";
			btnCancel.label = "Cancel";
			
			// Input BG
			sprInputBG.graphics.lineStyle(2, 0xE3870E, 1);
			sprInputBG.graphics.beginFill(0xFFF3D5, 1);
			sprInputBG.graphics.drawRoundRect(0, 0, 270, 35, 5);
			sprInputBG.graphics.endFill();
			sprInputBG.x = 70;
			sprInputBG.y = 50;
			addChild(sprInputBG);
			
			// Input
			txtToInput.antiAliasType = AntiAliasType.ADVANCED;
			txtToInput.x = 70;
			txtToInput.y = 50;
			txtToInput.width = 265;
			txtToInput.height = 30;
			txtToInput.embedFonts = true;
			txtToInput.type = TextFieldType.INPUT;
			txtToInput.text = " ";
			txtToInput.setTextFormat(frmtCopy);
			addChild(txtToInput);
			
			icon = "information";
			title = strTitleDef;
			text = strMessageDef;
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
			var startY:uint = txtTitle.height + 5 + middleHeight + 20;
			startY += txtToInput.height;
			
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
		
		public function getRecipients():String {
			return txtToInput.text;
		}
	}
}
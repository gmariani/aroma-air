/**
* ...
* @author Default
* @version 0.1
*/

package com.recipehouse.ui {
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.text.TextField;

	public class InboxButton extends SimpleButton {
		
		private var txtUpNumber:TextField = new TextField();
		private var txtDownNumber:TextField = new TextField();
		private var txtOverNumber:TextField = new TextField();
		
		public function InboxButton() {	}
		
		public function setNumber(num:uint):void {
			//txtUpNumber.text = String(num);
			if(upState is Sprite) {
				var k:Sprite = upState as Sprite;
				var t:TextField = k.getChildByName("txtNumber") as TextField;
				
				//var test:* = upState;
				//var txtNumber:TextField = upState.getChildByName("txtNumber") as TextField;
				//txtNumber.text = String(num);
				//overState.getChildByName("txtNumber").text = String(num);
				//downState.getChildByName("txtNumber").text = String(num);
			}
		}
	}
}
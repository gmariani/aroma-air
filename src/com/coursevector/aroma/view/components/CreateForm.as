package com.coursevector.aroma.view.components {
	
	import fl.controls.Button;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import com.coursevector.aroma.interfaces.IForm;
	
	public class CreateForm extends MovieClip implements IForm {
		
		private var frmtComponent:TextFormat = new TextFormat();
		private var frmtCopy:TextFormat = new TextFormat();
		
		public function CreateForm() {
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
			
			txtUserName.text = "";
			txtPassword.text = "";
			txtUserName.addEventListener(Event.CHANGE, onChangeInput);
			txtPassword.addEventListener(Event.CHANGE, onChangeInput);
			
			btnCheck.setStyle("embedFonts", true);
			btnCheck.setStyle("textFormat", frmtComponent);
			btnCheck.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function get username():String {
			return txtUserName.text;
		}
		
		public function get password():String {
			return txtPassword.text;
		}
		
		public function reset():void {
			txtUserName.text = "";
			txtPassword.text = "";
			txtUserName.setTextFormat(frmtCopy);
			txtPassword.setTextFormat(frmtCopy);
		}
		
		private function onClick(event:MouseEvent):void {
			dispatchEvent(new Event("check"));
		}
		
		private function onChangeInput(e:Event):void {
			dispatchEvent(new Event("invalid"));
		}
	}
}
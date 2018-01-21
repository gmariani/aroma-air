package com.coursevector.aroma.view.components {
	
	import fl.controls.Button;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import com.coursevector.aroma.interfaces.IForm;
	
	public class LoginForm extends MovieClip implements IForm {
		
		private var frmtComponent:TextFormat = new TextFormat();
		private var frmtCopy:TextFormat = new TextFormat();
		
		public function LoginForm() {
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
			
			btnLogin.setStyle("embedFonts", true);
			btnLogin.setStyle("textFormat", frmtComponent);
			btnLogin.addEventListener(MouseEvent.CLICK, onClickLogin);
			
			btnSignUp.setStyle("embedFonts", true);
			btnSignUp.setStyle("textFormat", frmtComponent);
			btnSignUp.addEventListener(MouseEvent.CLICK, onClickSignUp);
		}
		
		public function get username():String {
			return txtUserName.text;
		}
		
		public function get password():String {
			return txtPassword.text;
		}
		
		public function reset():void {
			this.txtUserName.text = "";
			this.txtPassword.text = "";
			this.txtUserName.setTextFormat(frmtCopy);
			this.txtPassword.setTextFormat(frmtCopy);
		}
		
		private function onClickLogin(event:MouseEvent):void {
			dispatchEvent(new Event("login"));
		}
		
		private function onClickSignUp(event:MouseEvent):void {
			dispatchEvent(new Event("create"));
		}
	}
}
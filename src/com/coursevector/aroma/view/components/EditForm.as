package com.coursevector.aroma.view.components {
	
	import fl.controls.Button;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.text.TextFormat;
	import com.coursevector.aroma.interfaces.IForm;
	
	public class EditForm extends MovieClip implements IForm {
		
		private var frmtCopy:TextFormat = new TextFormat();
		
		public function EditForm() {
			// Copy Format
			frmtCopy.bold = false;
			frmtCopy.color = 0x872301;
			frmtCopy.size = 12;
			frmtCopy.font = "Arial";
			
			txtUserName.text = "";
			txtPassword.text = "";
			txtPasswordNew.text = "";
			txtPasswordNew2.text = "";
			txtUserName.addEventListener(Event.CHANGE, onChangeInput);
			txtPassword.addEventListener(Event.CHANGE, onChangeInput);
			txtPasswordNew.addEventListener(Event.CHANGE, onChangeInput);
			txtPasswordNew2.addEventListener(Event.CHANGE, onChangeInput);
		}
		
		public function get username():String {
			return txtUserName.text;
		}
		
		public function get password():String {
			return txtPassword.text;
		}
		
		public function get passwordNew():String {
			return txtPasswordNew.text;
		}
		
		public function get passwordNew2():String {
			return txtPasswordNew2.text;
		}
		
		public function reset():void {
			txtUserName.text = "";
			txtPassword.text = "";
			txtUserName.setTextFormat(frmtCopy);
			txtPassword.setTextFormat(frmtCopy);
			txtPasswordNew.text = "";
			txtPasswordNew2.text = "";
			txtPasswordNew.setTextFormat(frmtCopy);
			txtPasswordNew2.setTextFormat(frmtCopy);
		}
		
		public function setForm(strUser:String, strPass:String):void {
			txtUserName.text = strUser;
			txtPassword.text = strPass;
		}
		
		private function onChangeInput(e:Event):void {
			dispatchEvent(new Event("invalid"));
		}
	}
}
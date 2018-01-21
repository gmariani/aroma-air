/**
*	Copyright (c) 2007 Course Vector.  All Rights Reserved.
*	#############################################################################
*	#	GlobalFooter															#
*	#############################################################################
* 	
*	@author Gabriel Mariani
*/

package com.recipehouse {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import flash.text.TextField;
	import flash.text.AntiAliasType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.text.TextFieldAutoSize;
	import gs.TweenLite;

	public class  GlobalFooter extends Sprite {
		
		private var sprFooter:Sprite = new Footer();
		private var txtCopyRight:TextField = new TextField();
		private var txtName:TextField = new TextField();
		private var frmtCopy:TextFormat = new TextFormat();
		private var frmtUser:TextFormat = new TextFormat();
		private const STAGE_WIDTH:uint = 905;
		
		public function GlobalFooter():void {
			init();
		}
		
		private function init():void {
			
			// Footer Format
			frmtCopy.color = 0x872301;
			frmtCopy.size = 12;
			frmtCopy.font = "Arial";
			frmtCopy.align = TextFormatAlign.CENTER;
			
			// User Name Format
			frmtUser.color = 0xFFD2C4;
			frmtUser.size = 12;
			frmtUser.font = "Arial";
			frmtUser.align = TextFormatAlign.CENTER;
			
			sprFooter.x = 1.5;
			sprFooter.y = 577.8;
			addChild(sprFooter);
			
			txtName.htmlText = "My User Name: <b>(Please set in Preferences page)</b>";
			txtName.x = 20;
			txtName.y = 595;
			txtName.selectable = false;
			txtName.autoSize = TextFieldAutoSize.LEFT;
			txtName.embedFonts = true;
			txtName.antiAliasType = AntiAliasType.ADVANCED;
			txtName.setTextFormat(frmtUser);
			addChild(txtName);	
			
			txtCopyRight.text = new Date().fullYear + " Course Vector";
			txtCopyRight.x = (STAGE_WIDTH / 2) - (txtCopyRight.textWidth / 2);
			txtCopyRight.y = 595;
			txtCopyRight.selectable = false;
			txtCopyRight.autoSize = TextFieldAutoSize.CENTER;
			txtCopyRight.embedFonts = true;
			txtCopyRight.antiAliasType = AntiAliasType.ADVANCED;
			txtCopyRight.setTextFormat(frmtCopy);
			txtCopyRight.addEventListener(MouseEvent.CLICK, onClickLink);
			addChild(txtCopyRight);			
		}
		
		public function setUserName(strName:String):void {
			txtName.htmlText = "My User Name: <b>" + strName + "</b>";
			txtName.setTextFormat(frmtUser);
		}
		
		private function onClickLink(e:MouseEvent):void {
			navigateToURL(new URLRequest("http://www.coursevector.com/"));
		}
	}
}
/**
*	Copyright (c) 2007 Course Vector.  All Rights Reserved.
*	#############################################################################
*	#	Preferences																#
*	#############################################################################
* 	
*	@author Gabriel Mariani
*/
	
package com.recipehouse {
	
	import fl.controls.Button;
    import fl.controls.Label;
	import flash.display.MovieClip;
	
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	
	import flash.filters.DropShadowFilter;
	
	import gs.TweenLite;
	import com.recipehouse.ui.PopUp;
	import com.coursevector.data.SOManager;
	import com.recipehouse.net.Talk;
	
	public class Preferences extends Sprite {
		
		public static const SAVE:String = "save";
		public static const CANCEL:String = "cancel";
		private var filterDropShadow:DropShadowFilter;
		
		private var frmtTitle:TextFormat = new TextFormat();
		private var frmtInput:TextFormat = new TextFormat()
		private var frmtCopy:TextFormat = new TextFormat();
		private var frmtPageTitle:TextFormat = new TextFormat();
		private var frmtComponent:TextFormat = new TextFormat();
		
		private var txtPageTitle:TextField = new TextField();
		private var txtInst:TextField = new TextField();
		private var txtUserName:TextField = new TextField();
		private var txtInput:TextField = new TextField();
		
		private var innerColor:uint = 0xFFF3D5;
		private var borderColor:uint = 0xE3880F;
		
		private var sprUserNameBG:Sprite = new Sprite();
		private var sprForm:Sprite = new Sprite();
		private var sprGlobe:Sprite = new InternetIcon();
		private var btnBack:SimpleButton = new BackButton();
		private var btnSave:SimpleButton = new SaveButton();
		private var btnCheck:Button = new Button();
		
		private var strUser:String;
		private var soManager:SOManager = new SOManager();
		private var isChecking:Boolean = false;
		private var isValid:Boolean = false;
		private var isSaving:Boolean = false;
		private var RecipeTalk:Talk = new Talk();
		private var sprAlert:PopUp = new PopUp();
		private var mcLoading:MovieClip = new LoadingBar();
		
		public function Preferences():void {
			init();
		}
		
		private function init():void {
			// Init Shadow
			filterDropShadow = new DropShadowFilter();
			filterDropShadow.color = 0x000000;
			filterDropShadow.alpha = .5;
			filterDropShadow.blurX = 4;
			filterDropShadow.blurY = 4;
			filterDropShadow.angle = 45 * (Math.PI/180);
			filterDropShadow.distance = 2;
			filterDropShadow.quality = 3;
			
			// Page Title Format
			frmtPageTitle.bold = true;
			frmtPageTitle.color = 0x872301;
			frmtPageTitle.size = 25;
			frmtPageTitle.font = "Arial";
			
			// Title Format
			frmtTitle.bold = true;
			frmtTitle.color = 0x9D3F0D;
			frmtTitle.size = 15;
			frmtTitle.font = "Arial";
			
			// Input Format
			frmtInput.bold = false;
			frmtInput.color = 0x872301;
			frmtInput.size = 15;
			frmtInput.font = "Arial";
			
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
			
			initStage();
			
			soManager.open("aromaData");
			RecipeTalk.addEventListener(Talk.NAME_AVAIL, onNameAvail);
			RecipeTalk.addEventListener(Talk.NAME_TAKEN, onNameTaken);
			RecipeTalk.addEventListener(Talk.NAME_ERROR, onNameError);
			RecipeTalk.addEventListener(Talk.NAME_SUCCESS, onNameSuccess);
			RecipeTalk.addEventListener(Talk.NAME_FAIL, onNameFail);
			
			reset();
		}
		
		private function initStage():void {
			// Page Title
			txtPageTitle.x = 15;
			txtPageTitle.y = 160;
			txtPageTitle.autoSize = TextFieldAutoSize.LEFT;
			txtPageTitle.antiAliasType = AntiAliasType.ADVANCED;
			txtPageTitle.text = "Preferences";
			txtPageTitle.embedFonts = true;
			txtPageTitle.setTextFormat(frmtPageTitle);
			addChild(txtPageTitle);
			
			// Internet Icon
			sprGlobe.x = 150;
			sprGlobe.y = 210;
			addChild(sprGlobe);
			
			// Instructions
			txtInst.x = sprGlobe.x + sprGlobe.width + 25;
			txtInst.y = 210;
			//txtInst.htmlText = "<b>T</b>o share recipes, please enter a user name and click the <b>\"Check User Name\"</b> button. If the name is taken, you must choose a different one. Once you have found a name that is unique and available, click the <b>\"Save\"</b> button. This user name will be used for others to send you recipes and will be added as the <b>\"From\"</b> portion when you send recipes to your friends.";
			txtInst.htmlText = "<b>T</b>o share recipes, please enter a user name and click the <b>\"Check User Name\"</b> button. If the name is taken, you must choose a different one. Once you have found a name that is unique and available, click the <b>\"Save\"</b> button. This user name will be used for others to send you recipes.";
			txtInst.width = 500;
			txtInst.wordWrap = true;
			txtInst.multiline = true;
			txtInst.selectable = false;
			txtInst.autoSize = TextFieldAutoSize.LEFT;
			txtInst.antiAliasType = AntiAliasType.ADVANCED;
			txtInst.embedFonts = true;
			txtInst.setTextFormat(frmtCopy);
			addChild(txtInst);
			
			// Form
			addChild(sprForm);
			
			// User Name Text
			txtUserName.antiAliasType = AntiAliasType.ADVANCED;
			txtUserName.x = txtInst.x;
			txtUserName.y = txtInst.y + txtInst.textHeight + 10;
			txtUserName.autoSize = TextFieldAutoSize.LEFT;
			txtUserName.text = "Username:";
			txtUserName.embedFonts = true;
			txtUserName.selectable = false;
			txtUserName.setTextFormat(frmtTitle);
			sprForm.addChild(txtUserName);
			
			// User Name BG			
			sprUserNameBG.graphics.beginFill(innerColor, 1);
			sprUserNameBG.graphics.lineStyle(2, borderColor, 1);
			sprUserNameBG.graphics.drawRoundRect(0, 0, 300, 20, 5, 5);
			sprUserNameBG.graphics.endFill();
			sprUserNameBG.x = txtUserName.x + txtUserName.textWidth + 10;
			sprUserNameBG.y = txtUserName.y;
			sprForm.addChild(sprUserNameBG);
			
			// User Name Input
			txtInput.antiAliasType = AntiAliasType.ADVANCED;
			txtInput.x = sprUserNameBG.x + 3;
			txtInput.y = sprUserNameBG.y;
			txtInput.width = 295;
			txtInput.height = 30;
			txtInput.restrict = "A-Za-z0-9 @.";
			txtInput.type = TextFieldType.INPUT;
			txtInput.text = "";
			txtInput.embedFonts = true;
			txtInput.setTextFormat(frmtCopy);
			txtInput.addEventListener(Event.CHANGE, onChangeInput);
			sprForm.addChild(txtInput);
			
			// Check & Save
			btnCheck.label = "Check User Name";
			btnCheck.width = 150;
			btnCheck.setStyle("embedFonts", true);
			btnCheck.setStyle("textFormat", frmtComponent);
			btnCheck.x = sprUserNameBG.x + sprUserNameBG.width + 10;
			btnCheck.y = sprUserNameBG.y;
			btnCheck.addEventListener(MouseEvent.CLICK, onClickCheck);
			sprForm.addChild(btnCheck);
			
			// Cancel Button
			btnBack.x = 10;
			btnBack.y = 510;
			btnBack.addEventListener(MouseEvent.CLICK, onClickBack);
			addChild(btnBack);
			
			// Save Button
			btnSave.x = 85;
			btnSave.y = 510;
			btnSave.enabled = false;
			btnSave.alpha = 0;
			btnSave.addEventListener(MouseEvent.CLICK, onClickSave);
			addChild(btnSave);
			
			// Processing Icon
			mcLoading.x = 380;
			mcLoading.y = btnCheck.y + 40;
			mcLoading.alpha = 0;
			addChild(mcLoading);
			
			// PopUp
			addChild(sprAlert);
		}
		
		private function reset():void {
			if(soManager.data.userName) {
				txtInput.text = soManager.data.userName;
				isValid = true;
			} else {
				txtInput.text = "";
			}
			txtInput.setTextFormat(frmtCopy);
			
			btnSave.enabled = false;
			TweenLite.to(btnSave, .25, {alpha:0});
		}
		
		private function isProcessing(bool:Boolean):void {
			if(bool == true) {
				TweenLite.to(mcLoading, .25, {alpha:1});
				TweenLite.to(sprForm, .25, {alpha:.5});
			} else {
				TweenLite.to(mcLoading, .25, {alpha:0});
				TweenLite.to(sprForm, .25, {alpha:1});
			}
		}
		
		// On Events //
		private function onChangeInput(e:Event):void {
			if(soManager.data.userName) {
				if(txtInput.text == soManager.data.userName) {
					isValid = true;
				} else {
					isValid = false;
				}
			} else {
				isValid = false;
			}
			btnSave.enabled = false;
			TweenLite.to(btnSave, .25, {alpha:0});
		}
		
		private function onClickBack(e:MouseEvent):void {
			if(isChecking == false && isSaving == false) {
				reset();
				dispatchEvent(new Event(CANCEL));
			}
		}
		
		private function onClickSave(e:MouseEvent):void {
			btnSave.enabled = false;
			TweenLite.to(btnSave, .25, {alpha:.5});
			if(isChecking == false) {
				if(isValid == true) {
					var oldUserName:String = "NONE";
					if(soManager.data.userName) oldUserName = soManager.data.userName;
					isSaving = true;
					isProcessing(true);
					RecipeTalk.saveUserName(txtInput.text, oldUserName);
				} else {
					sprAlert.title = "Error";
					sprAlert.icon = "error";
					sprAlert.text = "Please validate name before saving.";
					sprAlert.show();
				}
			}
		}
		
		private function onClickCheck(e:MouseEvent):void {
			var strName:String = txtInput.text.replace(" ", "");
			isChecking = true;
			isValid = false;
			if(strName.length > 1 && strName != "NONE") {
				isProcessing(true);
				RecipeTalk.checkUserName(strName);
			} else {
				sprAlert.title = "Error";
				sprAlert.icon = "error";
				sprAlert.text = "Please enter a valid user name.";
				sprAlert.show();
			}
		}
		
		private function onNameAvail(e:Event):void {
			sprAlert.title = "Information";
			sprAlert.icon = "information";
			sprAlert.text = "User name is available!";
			sprAlert.show();
			isChecking = false;
			isValid = true;
			btnSave.enabled = true;
			TweenLite.to(btnSave, .25, {alpha:1});
			isProcessing(false);
		}
		
		private function onNameTaken(e:Event):void {
			sprAlert.title = "Information";
			sprAlert.icon = "information";
			sprAlert.text = "User name is not available, please choose a different user name.";
			sprAlert.show();
			isProcessing(false);
			isChecking = false;
			isValid = false;
		}
		
		private function onNameError(e:Event):void {
			sprAlert.title = "Error";
			sprAlert.icon = "error";
			sprAlert.text = "There was an error validating your user name. Please try again at a later time.";
			sprAlert.show();
			isProcessing(false);
			isChecking = false;
			isSaving = false;
		}
		
		private function onNameSuccess(e:Event):void {
			isSaving = false;
			soManager.save("userName", txtInput.text);
			btnSave.enabled = false;
			TweenLite.to(btnSave, .25, {alpha:0});
			isProcessing(false);
			sprAlert.title = "Information";
			sprAlert.icon = "information";
			sprAlert.text = "Your user name was successfully saved!";
			sprAlert.show();
			dispatchEvent(new Event(SAVE));
		}
		
		private function onNameFail(e:Event):void {
			isSaving = false;
			btnSave.enabled = true;
			TweenLite.to(btnSave, .25, {alpha:1});
			isProcessing(false);
			sprAlert.title = "Error";
			sprAlert.icon = "error";
			sprAlert.text = "Your user name failed to save. Please try again at a later time.";
			sprAlert.show();
		}
	}	
}
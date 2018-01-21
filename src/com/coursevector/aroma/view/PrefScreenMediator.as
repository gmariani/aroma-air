////////////////////////////////////////////////////////////////////////////////
//
//  COURSE VECTOR
//  Copyright 2008 Course Vector
//  All Rights Reserved.
//
//  NOTICE: Course Vector permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////
/**
* ...
* @author Gabriel Mariani
* @version 0.1
*/

package com.coursevector.aroma.view {

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

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
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	
	import gs.TweenLite;
	
	import com.coursevector.aroma.model.vo.LoginVO;
	import com.coursevector.aroma.model.LoginProxy;
	import com.coursevector.aroma.ApplicationFacade;
	import com.coursevector.aroma.view.components.LoginForm;
	import com.coursevector.aroma.view.components.CreateForm;
	import com.coursevector.aroma.view.components.EditForm;
	import com.coursevector.aroma.interfaces.IForm;

	// TODO: Allow user to enter password =p
	
	public class PrefScreenMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'PrefScreenMediator';
		
		// Assets
		private var txtInst:TextField;
		private var loginForm:LoginForm = new LoginForm();
		private var editForm:EditForm = new EditForm();
		private var createForm:CreateForm = new CreateForm();
		private var sprGlobe:Sprite;
		private var btnBack:SimpleButton;
		private var btnSave:SimpleButton;
		private var btnCheck:Button;
		private var mcLoading:MovieClip;
		
		private var currentForm:IForm;
		
		// Variables
		//private var _loginProxy:LoginProxy;
		public static const SAVE:String = "save";
		public static const CANCEL:String = "cancel";
		private var frmtCopy:TextFormat = new TextFormat();
		private var strUser:String;
		private var isChecking:Boolean = false;
		private var isValid:Boolean = false;
		private var isSaving:Boolean = false;
		private var isLogging:Boolean = false;
		
		public function PrefScreenMediator(viewComponent:Object) {
			super(NAME, viewComponent);
			
			init();
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		/*private function get loginProxy():LoginProxy {
			if(_loginProxy == null) _loginProxy = facade.retrieveProxy(LoginProxy.NAME) as LoginProxy;
			return _loginProxy;
		}*/
		
		private function get root():DisplayObjectContainer {
			return viewComponent as DisplayObjectContainer;
		}
		
		public function get y():Number {
			return root.y;
		}
		
		public function set y(value:Number):void {
			root.y = value;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function resize(bounds:Rectangle):void {
			root.x = ApplicationFacade.GRIPPER_SIZE;
			//root.y = y;
			// TODO: Resize to fit within bounds
		}
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		override public function listNotificationInterests():Array {
			return [ApplicationFacade.NAME_AVAIL, 
					ApplicationFacade.NAME_TAKEN, 
					ApplicationFacade.NAME_ERROR,
					ApplicationFacade.CREATE_SUCCESS,
					ApplicationFacade.CREATE_FAIL,
					ApplicationFacade.UPDATE_SUCCESS,
					ApplicationFacade.UPDATE_FAIL,
					ApplicationFacade.LOGIN_SUCCESS,
					ApplicationFacade.LOGIN_FAIL
					];
		}
		
		override public function handleNotification(note:INotification):void {
			switch (note.getName())	{
				case ApplicationFacade.NAME_AVAIL :
					isChecking = false;
					isLogging = false;
					isValid = true;
					btnSave.enabled = true;
					TweenLite.to(btnSave, .25, {autoAlpha:1});
					isProcessing(false);
					sendNotification(ApplicationFacade.ALERT, {title:"Information", icon:ApplicationFacade.INFORMATION, message:"User name is available!" } );
					break;
				case ApplicationFacade.NAME_TAKEN :
					isProcessing(false);
					isChecking = false;
					isLogging = false;
					isValid = false;
					sendNotification(ApplicationFacade.ALERT, {title:"Information", icon:ApplicationFacade.INFORMATION, message:"User name is not available, please choose a different user name." } );
					break;
				case ApplicationFacade.NAME_ERROR :
					isProcessing(false);
					isChecking = false;
					isLogging = false;
					isSaving = false;
					sendNotification(ApplicationFacade.ALERT, {title:"Error", icon:ApplicationFacade.ERROR, message:"There was an error validating your user name. Please try again at a later time." } );
					break;
				case ApplicationFacade.CREATE_SUCCESS :
					sendNotification(ApplicationFacade.ALERT, {title:"Information", icon:ApplicationFacade.INFORMATION, message:"Your profile was successfully saved!" } );
					break;
				case ApplicationFacade.CREATE_FAIL :
					isSaving = false;
					isLogging = false;
					isChecking = false;
					btnSave.enabled = true;
					TweenLite.to(btnSave, .25, {autoAlpha:1});
					isProcessing(false);
					sendNotification(ApplicationFacade.ALERT, {title:"Error", icon:ApplicationFacade.ERROR, message:"Your profile failed to save. Please try again at a later time." } );
					break;
				case ApplicationFacade.UPDATE_SUCCESS :
					sendNotification(ApplicationFacade.ALERT, {title:"Information", icon:ApplicationFacade.INFORMATION, message:"Your profile was successfully updated!" } );
					break;
				case ApplicationFacade.UPDATE_FAIL :
					isSaving = false;
					isLogging = false;
					isChecking = false;
					btnSave.enabled = true;
					TweenLite.to(btnSave, .25, {autoAlpha:1});
					isProcessing(false);
					sendNotification(ApplicationFacade.ALERT, {title:"Error", icon:ApplicationFacade.ERROR, message:"Your profile failed to update. Please try again at a later time." } );
					break;
				case ApplicationFacade.LOGIN_SUCCESS :
					isLogging = false;
					isSaving = false;
					isChecking = false;
					isProcessing(false);
					reset();
					break;
			}
		}
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
			
			reset();
		}
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function init():void {
			
			sprGlobe = root.getChildByName("sprGlobe") as Sprite;
			txtInst = root.getChildByName("txtInst") as TextField;
			btnBack = root.getChildByName("btnBack") as SimpleButton;
			btnSave = root.getChildByName("btnSave") as SimpleButton;
			mcLoading = root.getChildByName("mcLoading") as MovieClip;
			
			// Instructions
			txtInst.x = sprGlobe.x + sprGlobe.width + 25;
			//txtInst.htmlText = "<b>T</b>o share recipes, please enter a user name and click the <b>\"Check User Name\"</b> button. If the name is taken, you must choose a different one. Once you have found a name that is unique and available, click the <b>\"Save\"</b> button. This user name will be used for others to send you recipes and will be added as the <b>\"From\"</b> portion when you send recipes to your friends.";
			txtInst.htmlText = "<b>T</b>o share recipes, please enter a user name and click the <b>\"Check User Name\"</b> button. If the name is taken, you must choose a different one. Once you have found a name that is unique and available, click the <b>\"Save\"</b> button. This user name will be used for others to send you recipes.";
			txtInst.autoSize = TextFieldAutoSize.LEFT;
			
			// Login Form
			//loginForm = root.getChildByName("loginForm") as LoginForm;
			root.addChild(loginForm);
			loginForm.x = 232.6; //centered
			loginForm.y = txtInst.y + txtInst.textHeight + 10;
			loginForm.addEventListener("login", onClickLogin);
			loginForm.addEventListener("create", onClickCreate);
			
			// Create Form
			//createForm = root.getChildByName("createForm") as CreateForm;
			root.addChild(createForm);
			createForm.addEventListener("check", onClickCheck);
			createForm.addEventListener("invalid", onChangeInput);
			createForm.x = 232.6; //centered
			createForm.y = txtInst.y + txtInst.textHeight + 10;
			createForm.alpha = 0;
			createForm.visible = false;
			
			// Edit Form
			//editForm = root.getChildByName("editForm") as EditForm;
			root.addChild(editForm);
			editForm.addEventListener("invalid", onChangeInput);
			editForm.x = 233.1; //centered
			editForm.y = txtInst.y + txtInst.textHeight + 10;
			editForm.alpha = 0;
			editForm.visible = false;
			
			// Cancel Button
			btnBack.addEventListener(MouseEvent.CLICK, onClickBack);
			
			// Save Button
			btnSave.enabled = false;
			btnSave.alpha = 0;
			btnSave.addEventListener(MouseEvent.CLICK, onClickSave);
			
			// Processing Icon
			mcLoading.alpha = 0;
		}
		
		private function reset():void {
			editForm.reset();
			createForm.reset();
			loginForm.reset();
			
			if (loginProxy.loggedIn) {
				currentForm = editForm;
				TweenLite.to(createForm, .25, { autoAlpha:0 } );
				TweenLite.to(loginForm, .25, { autoAlpha:0 } );
				TweenLite.to(editForm, .25, { autoAlpha:1 } );
				editForm.setForm(loginProxy.loginVO.username, loginProxy.loginVO.password);
				isValid = true;
			} else {
				currentForm = loginForm;
				TweenLite.to(loginForm, .25, { autoAlpha:1 } );
				TweenLite.to(createForm, .25, { autoAlpha:0 } );
				TweenLite.to(editForm, .25, { autoAlpha:0 } );
			}
			
			isSaving = false;
			isChecking = false;
			isProcessing(false);
			
			btnSave.enabled = false;
			TweenLite.to(btnSave, .25, {autoAlpha:0});
		}
		
		private function isProcessing(bool:Boolean):void {
			if(bool) {
				TweenLite.to(mcLoading, .25, {autoAlpha:1});
				TweenLite.to(currentForm, .25, {autoAlpha:.5});
			} else {
				TweenLite.to(mcLoading, .25, {autoAlpha:0});
				TweenLite.to(currentForm, .25, {autoAlpha:1});
			}
		}
		
		// On Events //
		private function onChangeInput(e:Event):void {
			isValid = false;
			btnSave.enabled = false;
			TweenLite.to(btnSave, .25, {autoAlpha:0});
		}
		
		private function onClickLogin(event:Event):void {
			// Login
			isLogging = true;
			isProcessing(true);
			loginProxy.loginUser(loginForm.username, loginForm.password);
		}
		
		private function onClickCreate(event:Event):void {
			// Show Create Form
			TweenLite.to(loginForm, .25, { autoAlpha:0 } );
			TweenLite.to(createForm, .25, { autoAlpha:1 } );
			currentForm = createForm;
		}
		
		private function onClickBack(e:MouseEvent):void {
			if(isChecking == false && isSaving == false && isLogging == false) {
				reset();
				sendNotification(ApplicationFacade.DISPLAY_CHANGE);
			}
		}
		
		private function onClickSave(e:MouseEvent):void {
			if(isChecking == false) {
				if (isValid == true) {
					if (loginProxy.loggedIn) {
						if (editForm.password == loginProxy.loginVO.password) {
							var strUserName:String = loginProxy.loginVO.username;
							var strPass:String = loginProxy.loginVO.password;
							
							// Is user changing username?
							if (editForm.username != loginProxy.loginVO.username) {
								strUserName = editForm.username;
							}
							
							// Is user changing password?
							if(validatePassword(editForm.passwordNew) && validatePassword(editForm.passwordNew2)) {
								if (editForm.passwordNew == editForm.passwordNew2) {
									strPass = editForm.passwordNew;
								} else {
									sendNotification(ApplicationFacade.ALERT, {title:"Error", icon:ApplicationFacade.ERROR, message:"New passwords do not match." } );
									return;
								}
							}
							
							isSaving = true;
							isProcessing(true);
							btnSave.enabled = false;
							TweenLite.to(btnSave, .25, {autoAlpha:.5});
							loginProxy.updateUser(loginProxy.loginVO.username, strUserName, strPass);
						} else {
							sendNotification(ApplicationFacade.ALERT, {title:"Error", icon:ApplicationFacade.ERROR, message:"Please enter correct password." } );
						}
					} else {
						isSaving = true;
						isProcessing(true);
						btnSave.enabled = false;
						TweenLite.to(btnSave, .25, {autoAlpha:.5});
						loginProxy.createUser(createForm.username, createForm.password);
					}
				} else {
					sendNotification(ApplicationFacade.ALERT, {title:"Error", icon:ApplicationFacade.ERROR, message:"Please validate name before saving." } );
				}
			}
		}
		
		private function validatePassword(str:String):Boolean {
			if (!str) {
				return false;
			}
			
			if (str.length <= 0) {
				return false;
			}
			if (str == "") {
				return false;
			}
			
			return true;
		}
		
		private function onClickCheck(event:Event):void {
			var strName:String = createForm.username.replace(" ", "");
			isChecking = true;
			isValid = false;
			if(currentForm.username.length > 1 && currentForm.username != "NONE") {
				isProcessing(true);
				loginProxy.checkUserName(currentForm.username);
			} else {
				sendNotification(ApplicationFacade.ALERT, {title:"Error", icon:ApplicationFacade.ERROR, message:"Please enter a valid user name." } );
			}
		}
	}
}
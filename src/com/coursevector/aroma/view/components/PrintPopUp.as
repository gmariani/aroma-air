/**
*	Copyright (c) 2007 Course Vector.  All Rights Reserved.
*	#############################################################################
*	#	Ingredient																#
*	#############################################################################
* 	
*	@author Gabriel Mariani
*/


package com.coursevector.aroma.view.components {

	import fl.controls.Button;

	import flash.display.MovieClip;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import gs.TweenLite;
	
	import com.coursevector.aroma.ApplicationFacade;

	public class PrintPopUp extends NativeWindow {

		public static const DECLINE:String = "decline";
		
		// Assets
		private var btnCancel:Button;
		private var txtMessage:TextField = new TextField();
		private var btn3x5:MovieClip;
		private var btn4x6:MovieClip;
		private var btnFull:MovieClip;
		
		// Variables
		private var frmtComponent:TextFormat = new TextFormat();
		
		public function PrintPopUp() {
			// Init Window
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.maximizable = false;
			winArgs.minimizable = false;
			winArgs.resizable = false;
			winArgs.type = NativeWindowType.NORMAL;
			super(winArgs);
			
			init();
		}
		
		private function init():void {
			
			// Component Format
			frmtComponent.bold = false;
			frmtComponent.color = 0x872301;
			frmtComponent.size = 15;
			frmtComponent.font = "Tw Cen MT";
			
			this.width = 365;
			this.height = 225;
			this.title = "Print Options";
			
			var root:MovieClip = new PrintOptionsScreen();
			stage.addChild(root);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			btn3x5 = root.getChildByName("btn3x5") as MovieClip;
			btn4x6 = root.getChildByName("btn4x6") as MovieClip;
			btnFull = root.getChildByName("btnFull") as MovieClip;
			btnCancel = root.getChildByName("btnCancel") as Button;
			
			//btnCancel.setStyle("embedFonts", true);
			btnCancel.setStyle("textFormat", frmtComponent);
			btnCancel.addEventListener(MouseEvent.CLICK, onClickCancel);
			
			btn3x5.addEventListener(MouseEvent.CLICK, optionHandler);
			btn3x5.addEventListener(MouseEvent.ROLL_OVER, optionHandler);
			btn3x5.addEventListener(MouseEvent.ROLL_OUT, optionHandler);
			btn3x5.buttonMode = true;
			btn3x5.mouseChildren = false;
			
			btn4x6.addEventListener(MouseEvent.CLICK, optionHandler);
			btn4x6.addEventListener(MouseEvent.ROLL_OVER, optionHandler);
			btn4x6.addEventListener(MouseEvent.ROLL_OUT, optionHandler);
			btn4x6.buttonMode = true;
			btn4x6.mouseChildren = false;
			
			btnFull.addEventListener(MouseEvent.CLICK, optionHandler);
			btnFull.addEventListener(MouseEvent.ROLL_OVER, optionHandler);
			btnFull.addEventListener(MouseEvent.ROLL_OUT, optionHandler);
			btnFull.buttonMode = true;
			btnFull.mouseChildren = false;
			
			var b:Rectangle = Screen.mainScreen.bounds;
			this.x = (b.width / 2) - (this.width / 2);
			this.y = (b.height / 2) - (this.height / 2);
		}
		
		private function optionHandler(event:MouseEvent):void {
			if (event.type == MouseEvent.CLICK) {
				close();
				
				switch(event.currentTarget) {
					case btn3x5 :
						dispatchEvent(new Event(ApplicationFacade.CARD_3X5));
						break;
					case btn4x6 :
						dispatchEvent(new Event(ApplicationFacade.CARD_4X6));
						break;
					case btnFull :
						dispatchEvent(new Event(ApplicationFacade.PAGE));
						break;
					default:
						trace("PrintPopUp::optionHandler - Error: No match");
				}
			} else if (event.type == MouseEvent.ROLL_OVER) {
				TweenLite.to(event.currentTarget, 0.5, { alpha:1 } );
			} else {
				TweenLite.to(event.currentTarget, 0.5, { alpha:.5 } );
			}
		}
		
		private function onClickCancel(e:MouseEvent):void {
			dispatchEvent(new Event(DECLINE));
			close();
		}
		
		private function addIcon(spr:Sprite, nX:uint, nY:uint):void {
			spr.x = nX;
			spr.y = nY;
			spr.width = 50;
			spr.height = 50;
			spr.visible = false;
			stage.addChild(spr);
		}
	}
}
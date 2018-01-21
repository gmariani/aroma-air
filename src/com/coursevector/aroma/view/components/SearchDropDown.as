/**
* ...
* @author Default
* @version 0.1
*/

package com.coursevector.aroma.view.components {
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.DisplayObject;

	import com.coursevector.aroma.ApplicationFacade;
	
	public class SearchDropDown extends Sprite {
		
		public static const SELECTED:String = "selected";
		private var sprDropDown:Sprite = new Sprite();
		private var sprCheck:Sprite = new Checkmark();
		private var _data:Array;
		private var arrButtonList:Array = new Array();
		private var _curSelected:String = ApplicationFacade.SEARCH_TYPE_NAME;
		
		public function SearchDropDown():void {
			init();
		}
		
		private function init():void {
			sprDropDown.y = 20;
			addChild(sprDropDown);
			
			sprCheck.x = 5;
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			this.buttonMode = true;
		}
		
		public function set dataProvider(dp:Array):void {
			_data = dp;
			removeAllChildren(sprDropDown);
			
			var startY:uint = 0;
			for(var i:uint = 0; i < _data.length; i++) {
				var curBtn:DropDownButton = new DropDownButton(_data[i]);
				arrButtonList.push(curBtn);
				curBtn.y = startY;
				curBtn.x = 0;
				curBtn.addEventListener(MouseEvent.CLICK, onOptionClick);
				startY += curBtn.height;
				sprDropDown.addChild(curBtn);
			}
			
			sprDropDown.addChild(sprCheck);
			selectOption(arrButtonList[0]);
		}
		
		public function get dataProvider():Array {
			return _data;
		}
		
		private function onClick(e:MouseEvent):void {
			if(e.currentTarget != this) {
				sprDropDown.visible = false;
				if(this.stage) stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageClick);
			} else {
				sprDropDown.visible = true;
				if(this.stage) stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageClick, false, 0, true);
			}
		}
		
		protected function onStageClick(event:MouseEvent):void {
			if (!sprDropDown.visible) return;
			if (!contains(event.target as DisplayObject) && !sprDropDown.contains(event.target as DisplayObject)) {
				sprDropDown.visible = false;
			}
		}
		
		private function removeAllChildren(obj:Sprite):void {
			if(obj.numChildren > 0) {
				var len:int = obj.numChildren;
				for(var i:int = 0; i < len; i++) {
					obj.removeChildAt(0);
				}
			}
		}
		
		private function onOptionClick(e:MouseEvent):void {
			selectOption(e.currentTarget as DropDownButton);
		}
		
		private function selectOption(btn:DropDownButton):void {
			// highlight button
				// move icon to that y
			sprCheck.y = btn.y + 3.5;
			
			sprDropDown.visible = false;
			_curSelected = btn.label;
			dispatchEvent(new Event(SELECTED));
		}
		
		public function get curSelected():String {
			return _curSelected;
		}
	}
}

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.AntiAliasType;
import flash.text.TextFormat;

class DropDownButton extends SimpleButton {
    private var sizeW:uint = 95;
    private var sizeH:uint = 20;
	private var txtLabel:String;

    public function DropDownButton(strLabel:String) {
		this.txtLabel = strLabel;
        downState = new ButtonDisplayState(strLabel, "down", sizeW, sizeH);
        overState = new ButtonDisplayState(strLabel, "over", sizeW, sizeH);
        upState = new ButtonDisplayState(strLabel, "up", sizeW, sizeH);
        hitTestState = new ButtonDisplayState(strLabel, "hit", sizeW, sizeH);
        useHandCursor = true;
    }
	
	public function get label():String {
		return txtLabel;
	}
}

class ButtonDisplayState extends Sprite {
	
    private var bgColor:uint;
    private var sizeW:uint;
    private var sizeH:uint;
	private var state:String;
	private var frmtUnselect:TextFormat = new TextFormat();
	private var frmtSelect:TextFormat = new TextFormat();

    public function ButtonDisplayState(txtLabel:String, state:String, sizeW:uint, sizeH:uint) {
        this.sizeH = sizeH;
        this.sizeW = sizeW;
		this.state = state;
        draw();
		
		// Unselected Title Format
		frmtUnselect.bold = false;
		frmtUnselect.color = 0xCC3202;
		frmtUnselect.size = 12;
		frmtUnselect.font = "Tw Cen MT";
		
		// Selected Title Format
		frmtSelect.bold = true;
		frmtSelect.color = 0xFFFFFF;
		frmtSelect.size = 12;
		frmtSelect.font = "Tw Cen MT";
		
		var txt:TextField = new TextField();
		txt.autoSize = "left";
		txt.antiAliasType = AntiAliasType.ADVANCED;
		txt.autoSize = TextFieldAutoSize.LEFT;
		txt.selectable = false;
		txt.y = 3;
		txt.x = 17;
		txt.text = txtLabel;
		if(state == "up") {
			txt.setTextFormat(frmtUnselect);
		} else {
			txt.setTextFormat(frmtSelect);
		}
		txt.embedFonts = true;
		addChild(txt);
    }

    private function draw():void {
		var skin:Sprite;
		switch(state) {
			case "over" :
				skin = new DropDown_OverSkin();
				break;
			case "up" :
				skin = new DropDown_upSkin();
				break;
			case "down" :
				skin = new DropDown_DownSkin();
				break;
			case "hit" :
				skin = new DropDown_upSkin();
				break;
		}
		
		skin.width = sizeW;
		skin.height = sizeH;
		addChild(skin);
    }
}

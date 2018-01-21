/**
*	Copyright (c) 2007 Course Vector.  All Rights Reserved.
*	#############################################################################
*	#	Recipe Cell Renderer													#
*	#############################################################################
* 	
*	@author Gabriel Mariani
*/

package com.coursevector.aroma.view.components {
	
    import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.GradientType;
	
	import flash.events.MouseEvent;
	import flash.events.Event;
	
    import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.AntiAliasType;
	import flash.text.TextFormat;
	
    import fl.controls.listClasses.ICellRenderer;
    import fl.controls.listClasses.ListData;	
	import flash.geom.Matrix;
	import flash.filters.DropShadowFilter;
	
    public class RecipeCellRenderer extends MovieClip implements ICellRenderer {
        private var _listData:ListData;
        private var _data:Object;
        private var _selected:Boolean;
		
		private var filterDropShadow:DropShadowFilter;
		//private var isShared:Boolean = false;
		private var arrayFilters:Array;
		//private var sprGlobe:Sprite = new InternetIconforCell();
		private var sprStarRating:Rating = new Rating(false);
		private var txtLabel:TextField = new TextField();
		private var frmtUnselect:TextFormat = new TextFormat();
		private var frmtSelect:TextFormat = new TextFormat();
		private var _width:uint = 280;
		private var _label:String;
		
        public function RecipeCellRenderer() {
			
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
			
			// DropShadow			
			filterDropShadow = new DropShadowFilter();
			filterDropShadow.color = 0x000000;
			filterDropShadow.alpha = .25;
			filterDropShadow.blurX = 4;
			filterDropShadow.blurY = 4;
			filterDropShadow.angle = 45 * (Math.PI/180);
			filterDropShadow.distance = 2;
			filterDropShadow.quality = 3;
			
			// Add Rating
			sprStarRating.x = 5;
			sprStarRating.y = 3;
			sprStarRating.width = 55;
			sprStarRating.height = 11;
			sprStarRating.alpha = .75;
			addChild(sprStarRating);
			
			// Add Globe
			/*sprGlobe.x = 5;
			sprGlobe.y = 3;
			addChild(sprGlobe);
			share(false);*/
			
			//sprGlobe.addEventListener(MouseEvent.CLICK, onClickGlobe);
			
			// Set Title
			txtLabel.antiAliasType = AntiAliasType.ADVANCED;
			txtLabel.autoSize = TextFieldAutoSize.LEFT;
			txtLabel.selectable = false;
			txtLabel.multiline = false;
			txtLabel.wordWrap = false;
			txtLabel.x = 65;
			txtLabel.y = 1;
			txtLabel.text = "";
			txtLabel.setTextFormat(frmtUnselect);
			txtLabel.embedFonts = true;
			addChild(txtLabel);
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        }
		
		/*private function onClickGlobe(e:MouseEvent):void {
			// Toggle share
			share(!isShared);
		}
		
		public function share(isSharing:Boolean):void {
			isShared = isSharing;			

			if(isShared == true) {
				// Share this recipe
				
				sprGlobe.alpha = 1;
				sprGlobe.filters = [filterDropShadow];
			} else {
				sprGlobe.alpha = .5;
				sprGlobe.filters = [];
			}
		}*/
		
		private function onMouseDown(event:MouseEvent):void {
			this.dispatchEvent(new Event("itemDown", true, true));
		}
		
        public function set data(d:Object):void {
            _data = d;
			_label = d.label;
            txtLabel.text = d.label;
			txtLabel.setTextFormat(frmtUnselect);
			
			sprStarRating.stars = d.data.rating;
        }
		
        public function get data():Object {
            return _data;
        }
		
        public function set listData(ld:ListData):void {
            _listData = ld;
        }
		
        public function get listData():ListData {
            return _listData;
        }
		
        public function set selected(s:Boolean):void {
            _selected = s;
			
			if(s == true) {
				txtLabel.setTextFormat(frmtSelect);
			} else {
				txtLabel.setTextFormat(frmtUnselect);
			}
			
			// Update BG
			updateGraphics();        }
		
		private function updateGraphics():void {
			graphics.clear();
			graphics.lineStyle(1, 0xD77100, 1);
			if(_selected == true) {
				var matr:Matrix = new Matrix();
				matr.createGradientBox(60, 60, Math.PI / 2, 0, -43);
				graphics.beginGradientFill(GradientType.LINEAR, [0xB76000, 0xFF9113], [1, 1], [0, 255], matr);
			} else {
				graphics.beginFill(0xFFBC3F, 1);				
			}
			graphics.drawRect(0, 0, _width - 7, 17);
			graphics.endFill();
			
			var txtWid:Number = _width - txtLabel.x - 10;
			var concatText:String = "...";
			if (_label != null) txtLabel.text = _label;
			txtLabel.setTextFormat(frmtUnselect);
			
			if (txtLabel.textWidth > txtWid) {
				var initWidth:Number = txtLabel.textWidth;
				txtLabel.appendText(concatText);
				var concatWidth:Number = txtLabel.textWidth - initWidth;
				var activeWidth:Number = txtWid - concatWidth;
				
				//change back to initial text 
				txtLabel.text = txtLabel.text.substr(0, (txtLabel.text.length - concatText.length));
				
				//loop until size is right 
				for (var i:int = 0; i < initWidth; i++){
					if(txtLabel.textWidth > activeWidth){
						txtLabel.text = txtLabel.text.substr(0, (txtLabel.text.length - 1));
					}else{
						txtLabel.appendText(concatText);
						break;
					}
				}
				txtLabel.setTextFormat(frmtUnselect);
			}
		}
		
        public function get selected():Boolean {
            return _selected;
        }
		
        public function setSize(width:Number, height:Number):void {
			_width = width;
			updateGraphics();
        }
		
        public function setStyle(style:String, value:Object):void {
			//
        }
		
        public function setMouseState(state:String):void{
			//
        }		
    }
}
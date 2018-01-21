/**
* ...
* @author Default
* @version 0.1
*/

package com.recipehouse.ui {
	
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Rating extends Sprite {
		
		private var star1:Sprite = new StarIcon();
		private var star2:Sprite = new StarIcon();
		private var star3:Sprite = new StarIcon();
		private var star4:Sprite = new StarIcon();
		private var star5:Sprite = new StarIcon();
		
		private var unstar1:Sprite = new UnlitStarIcon();
		private var unstar2:Sprite = new UnlitStarIcon();
		private var unstar3:Sprite = new UnlitStarIcon();
		private var unstar4:Sprite = new UnlitStarIcon();
		private var unstar5:Sprite = new UnlitStarIcon();
		
		private var nSpacing:uint = 0;
		private var nRating:uint = 1;
		private var arrStar:Array = new Array();
		
		public function Rating(hasRollOver:Boolean) {
			init(hasRollOver);
		}
		
		private function init(hasRollOver:Boolean):void {
			arrStar = [star1, star2, star3, star4, star5];
			var curStar:Sprite;
			var curUnStar:Sprite
			
			for(var i:uint = 1; i <= 5; i++) {
				curStar = this["star" + i];
				curUnStar = this["unstar" + i];
				curStar.name = "star" + i;
				if(i != 1) curStar.alpha = 0;
				curStar.width = 20;
				curStar.height = 20;
				addChild(curUnStar);
				addChild(curStar);
				if(hasRollOver) {
					curStar.addEventListener(MouseEvent.CLICK, onStarClick);
					curStar.addEventListener(MouseEvent.MOUSE_OVER, onStarOver);
					curStar.addEventListener(MouseEvent.MOUSE_OUT, onStarOut);
				}
			}
			
			star1.x = 0;
			star2.x = star1.width + nSpacing;
			star3.x = star2.x + star2.width + nSpacing;
			star4.x = star3.x + star3.width + nSpacing;
			star5.x = star4.x + star4.width + nSpacing;
			
			for(var j:uint = 1; j <= 5; j++) {
				curStar = this["star" + j];
				curUnStar = this["unstar" + j];
				curUnStar.width = 20;
				curUnStar.height = 20;
				curUnStar.x = curStar.x;
				curUnStar.y = curStar.y;
			}
		}
		
		private function onStarClick(e:MouseEvent):void {
			var str:String = e.currentTarget.name;
			var nTempRating:uint = uint(str.substr(str.length - 1, 1));
			setStarRating(nTempRating);
			dispatchEvent(new Event(Event.CHANGE, false));
		}
		
		private function onStarOver(e:MouseEvent):void {
			var str:String = e.currentTarget.name;
			var nTempRating:uint = uint(str.substr(str.length - 1, 1));
			setStarDisplay(nTempRating);
		}
		
		private function onStarOut(e:MouseEvent):void {
			setStarDisplay(nRating);
		}
		
		private function setStarDisplay(num:uint):void {
			checkStar(star1, num);
			checkStar(star2, num);
			checkStar(star3, num);
			checkStar(star4, num);
			checkStar(star5, num);
		}
		
		private function checkStar(spr:Sprite, num:uint):void {
			var str:String = spr.name;
			var nTempRating:uint = uint(str.substr(str.length - 1, 1));
			spr.alpha = 0;
			if(nTempRating <= num) spr.alpha = 1;
		}
		
		public function set stars(num:uint):void {
			setStarRating(num);
		}
		
		private function setStarRating(num:uint):void {
			nRating = num;
			setStarDisplay(nRating);
		}
		
		public function get stars():uint {
			return nRating;
		}
	}
}
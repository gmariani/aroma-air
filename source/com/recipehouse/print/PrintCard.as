/**
*	Copyright (c) 2007 Course Vector.  All Rights Reserved.
*	#############################################################################
*	#	Print Card																#
*	#############################################################################
* 	
*	@author Gabriel Mariani
*/

package com.recipehouse.print {
	
	import com.recipehouse.print.Card;
	import flash.display.Sprite;
	import flash.printing.PrintJob;

	public class PrintCard {
		
		private static var arrPages:Array = new Array();
		private static var sprPage:Sprite = new Sprite();
		private static var nIngLen:uint;
		private static var ingCount:uint;
		private static var screenCount:uint;
		private static var sprCurCard:Card;
		private static var cardCount:uint;
		private static var maxLines:uint = 11;
		private static var maxCards:uint = 4;
		private static var cardType:String = "3x5";
		
		public function PrintCard() {
			// TODO figure out margins
		}
		
		public static function getPages(objData:Object, cardSize:String, pj:PrintJob):Array {
			
			cardCount = 1;
			if(cardSize == "3x5") {
				maxLines = 11;
				maxCards = 4;
			} else if(cardSize == "4x6") {
				maxLines = 16;
				maxCards = 3;
			}
			cardType = cardSize;
			sprPage = new Sprite();
			arrPages = new Array();
			arrPages.push(sprPage);
			sprCurCard = addCard(objData.title, "", pj);
			nIngLen = objData.ingredients.length;
			ingCount = 1;
			screenCount = 0;			
			
			for (var i:uint = 0; i < nIngLen; i++) {
				ingCount++;
				
				if (ingCount >= maxLines) {
					ingCount -= maxLines;
					checkNewPage();
					sprCurCard = addCard(objData.title, "", pj);
				}
				sprCurCard.txtCopy.appendText(returnIngredient(objData.ingredients[i]) + "\n");
			}
			
			checkNewPage();
			sprCurCard = addCard(objData.title, objData.directions, pj);
			
			if (sprCurCard.txtCopy.numLines > maxLines) {
				var lineDelta = sprCurCard.txtCopy.numLines - maxLines;
				screenCount = Math.ceil(lineDelta / maxLines);
			}
			
			for (var j:uint = 1; j <= screenCount; j++) {
				checkNewPage();
				sprCurCard = addCard(objData.title, objData.directions, pj);
				sprCurCard.txtCopy.scrollV = (j * maxLines) - 1;
			}
			
			return arrPages;
		}
		
		private static function addCard(strTitle:String, strCopy:String, pj:PrintJob):Card {
			var spr:Card;
			if(cardType == "3x5") {
				spr = new Card3x5();
			} else if(cardType == "4x6") {
				spr = new Card4x6();
			}
			spr.txtTitle.text = strTitle;
			spr.txtCardCount.text = String(cardCount);
			spr.txtCopy.text = strCopy;
			spr.y = spr.height * (cardCount - 1) + (15 * cardCount);
			cardCount++;
			sprPage.addChild(spr);
			return spr;
		}
		
		private static function checkNewPage():void {
			if(cardCount % maxCards == 0) {
				sprPage = new Sprite();
				arrPages.push(sprPage);
			}
		}
		
		private static function returnIngredient(objIng:Object):String {
			var strDisplay:String = "";
			if(objIng.amount != " ") {
				strDisplay += objIng.amount;
			}
			if(objIng.fraction != " ") {
				strDisplay += objIng.fraction;
			}
			if(objIng.size != " ") {
				strDisplay += " " + objIng.size;
			}
			strDisplay += " " + objIng.label;
			return strDisplay;
		}
	}	
}
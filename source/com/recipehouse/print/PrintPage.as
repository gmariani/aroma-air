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
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.AntiAliasType;

	public class PrintPage {
		
		private static var arrPages:Array = new Array();
		private static var sprCurPage:Page = new Page();
		private static var nIngLen:uint;
		private static var ingCount:uint;
		private static var screenCount:uint;
		private static var frmtTitle:TextFormat = new TextFormat();
		private static var frmtCopy:TextFormat = new TextFormat();
		
		public function PrintPage() {
			// TODO figure out margins
			// TODO add star rating
			
			init();
		}
		
		private function init():void {
			// Title Format
			frmtTitle.bold = true;
			frmtTitle.color = 0x000000;
			frmtTitle.size = 15;
			frmtTitle.font = "Arial";
			
			// Copy Format
			frmtCopy.bold = false;
			frmtCopy.color = 0x000000;
			frmtCopy.size = 11;
			frmtCopy.font = "Arial";
		}
		
		public static function getPages(objData:Object, pj:PrintJob):Array {
			arrPages = new Array();
			sprCurPage = addPage(objData, pj);			
			nIngLen = objData.ingredients.length;
			ingCount = 1;
			
			for (var i:uint = 0; i < nIngLen; i++) {
				sprCurPage.txtCopy.appendText(returnIngredient(objData.ingredients[i]) + "\n");
			}
			
			sprCurPage.txtCopy.appendText("\n\n" + objData.directions);
			sprCurPage.txtCopy.setTextFormat(frmtCopy);
			return arrPages;
		}
		
		private static function addPage(objData:Object, strpj:PrintJob):Page {
			var spr:Page = new Page();
			spr.txtTitle.embedFonts = true;
			spr.txtTitle.antiAliasType = AntiAliasType.ADVANCED;
			spr.txtTitle.text = objData.title + "\n";
			spr.txtTitle.appendText(objData.author + "\n");
			spr.txtTitle.appendText(objData.category);
			spr.txtTitle.setTextFormat(frmtTitle);
			spr.txtCopy.embedFonts = true;
			spr.txtCopy.antiAliasType = AntiAliasType.ADVANCED;
			spr.txtCopy.text = "";
			arrPages.push(spr);
			return spr;
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
/**
*	Copyright (c) 2007 Course Vector.  All Rights Reserved.
*	#############################################################################
*	#	Card																	#
*	#############################################################################
* 	
*	@author Gabriel Mariani
*/

package com.recipehouse.print {
	
	import flash.text.TextField;
	import flash.display.Sprite;

	public class Card extends Sprite {
		
		private var _txtTitle:TextField;
		private var _txtCardCount:TextField;
		private var _txtCopy:TextField;
		
		public function Card() {
			_txtTitle = this.getChildByName("txtTitle") as TextField;
			_txtCardCount = this.getChildByName("txtCardCount") as TextField;
			_txtCopy = this.getChildByName("txtCopy") as TextField;	
		}
	}	
}
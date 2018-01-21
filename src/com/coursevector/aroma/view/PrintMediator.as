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
 * @author Gabriel Mariani
 * @version 0.1
 */

package com.coursevector.aroma.view {
	
	import flash.text.TextFieldAutoSize;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import com.coursevector.aroma.ApplicationFacade;
	import com.coursevector.aroma.view.components.PrintPopUp;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.printing.PrintJobOrientation;
	import flash.display.Stage;
	import flash.display.DisplayObjectContainer;
	import flash.text.TextField;
	import flash.system.System;
	
	public class PrintMediator extends Mediator implements IMediator {
		
		public static const NAME:String = 'PrintMediator';
		
		private var printStyle:String = ApplicationFacade.CARD_3X5;
		private var cardCount:uint = 0;
		private var arrPages:Array;
		private var isError:Boolean = false;
		private var spacing:uint = 5;
		private var popUp:PrintPopUp;
		
		public function PrintMediator(viewComponent:Object) {
            super(NAME, viewComponent);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		private function get stage():Stage {
			return root.stage;
		}
		
		private function get root():DisplayObjectContainer {
			return viewComponent as DisplayObjectContainer;
		}
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function showPopUp():void {
			popUp = new PrintPopUp();
			popUp.addEventListener(PrintPopUp.DECLINE, popupHandler);
			popUp.addEventListener(ApplicationFacade.PAGE, popupHandler);
			popUp.addEventListener(ApplicationFacade.CARD_3X5, popupHandler);
			popUp.addEventListener(ApplicationFacade.CARD_4X6, popupHandler);
			popUp.activate();
		}
		
		public function printRecipes(style:String, arr:Array):void {
			
			// Validation
			switch(style) {
				case ApplicationFacade.PAGE:
				case ApplicationFacade.CARD_3X5:
				case ApplicationFacade.CARD_4X6:
					break;
				default:
					return;
			}
			
			var str:String = "Now printing recipes: \n\n";
			for(var j:String in arr) {
				str += arr[j].title + "\n";
			}
			isError = false;
			printStyle = style;
			arrPages = new Array();
			var l:uint = arr.length;
			var pj:PrintJob = new PrintJob();
			var i:uint;
			
			if (pj.start()) {
				for (i = 0; i < l; i++) {
					addRecipe(pj, arr[i]);
				}
				
				// Add to print job
				for (var p:String  in arrPages) {
					var spr:Sprite = arrPages[p];
					if(spr.numChildren >= 1) {
						spr.y = 3000;
						stage.addChild(spr);
						pj.addPage(spr, spr.getRect(spr));
						stage.removeChild(spr);
					}
				}
				
				pj.send();
				
				if(!isError) {
					sendNotification(ApplicationFacade.ALERT, { title:"Information", icon:ApplicationFacade.INFORMATION, message:str } );
				}
			}
			
			// Delete pages
			for (i = 0; i < l; i++) {
				delete arrPages[i];
			}
			arrPages = new Array();
			// Call Garbage Collector
			System.gc();
		}
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		//
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function popupHandler(event:Event):void {
			popUp.removeEventListener(PrintPopUp.DECLINE, popupHandler);
			popUp.removeEventListener(ApplicationFacade.PAGE, popupHandler);
			popUp.removeEventListener(ApplicationFacade.CARD_3X5, popupHandler);
			popUp.removeEventListener(ApplicationFacade.CARD_4X6, popupHandler);
			popUp = null;
			
			switch(event.type) {
				case ApplicationFacade.PAGE :
					sendNotification(ApplicationFacade.PRINT_SPOOL, ApplicationFacade.PAGE);
					break;
				case ApplicationFacade.CARD_3X5 :
					sendNotification(ApplicationFacade.PRINT_SPOOL, ApplicationFacade.CARD_3X5);
					break;
				case ApplicationFacade.CARD_4X6 :
					sendNotification(ApplicationFacade.PRINT_SPOOL, ApplicationFacade.CARD_4X6);
					break;
				default :
					// Nothing
			}
		}
		
		private function addRecipe(pj:PrintJob, objRecipe:Object):void {
			try {
				var maxCards:uint;
				var sprPage:Sprite;
				var lineIndex:int = 0;
				var strContent:String = recipeToString(objRecipe);
				var startCardY:Number = 0;
				var yMargin:Number;
				cardCount = 0;
				
				if (printStyle == ApplicationFacade.CARD_3X5) {
					maxCards = 3;
				} else if (printStyle == ApplicationFacade.CARD_4X6) {
					maxCards = 2;
				}
				
				while (lineIndex >= 0) {
					if (printStyle == ApplicationFacade.PAGE) {
						sprPage = new Page();
						lineIndex = populatePage(sprPage, objRecipe.title, strContent, lineIndex);
						if(lineIndex != -2) {
							arrPages.push(sprPage);
						}
					} else {
						var sprCard:Sprite;
						var cardIndex:uint = cardCount % maxCards;
						if (printStyle == ApplicationFacade.CARD_3X5) {
							sprCard = new Card3x5();
						} else if (printStyle == ApplicationFacade.CARD_4X6) {
							sprCard = new Card4x6();
						}
						
						if (cardIndex == 0) {
							sprPage = new Sprite();
							sprPage.graphics.beginFill(0xFFFFFF, 1);
							sprPage.graphics.drawRect(0, 0, pj.paperWidth, pj.paperHeight);
							sprPage.graphics.endFill();
							
							// Save a reference to it somewhere so GC doesn't get it
							arrPages.push(sprPage);
							if (!yMargin) {
								var totalHeight:Number = maxCards * (sprCard.height + spacing);
								yMargin = (pj.paperHeight / 2) - (totalHeight / 2);
							}
							startCardY = yMargin;
						}
						
						lineIndex = populateCard(sprCard, objRecipe.title, strContent, lineIndex);
						if(lineIndex != -2) {
							sprCard.y = startCardY;
							sprCard.x = (pj.paperWidth / 2) - (sprCard.width / 2);
							startCardY += sprCard.height + spacing;
							sprPage.addChild(sprCard);
						}
					}
				}
			} catch (e:Error) {
				trace("PrintMediator::addRecipe - " + e.message);
				isError = true;
				sendNotification(ApplicationFacade.ALERT, {title:"Error", icon:ApplicationFacade.ERROR, message:"There was an error printing.\n" + e.message } );
			}
		}
		
		private function recipeToString(obj:Object):String {
			var strReturn:String = "";
			
			if(obj.author.length > 0) {
				strReturn += "<font face='Bell MT' size='12'>Courtesy of " + obj.author;
			} else {
				strReturn += "<font face='Bell MT' size='12'>Courtesy of Unknown";
			}
			strReturn += (obj.source.length > 0) ? " (" + obj.source + ")</font><br>" : "</font><br>";
			
			for (var i:String in obj.ingredients) {
				strReturn += "<li>" + unescape(obj.ingredients[i]) + "</li>";
			}
			
			strReturn += "<br>Notes:<br>" + obj.notes + "<br><br>";
			strReturn += obj.directions + "<br><br><br><br><br><br><br><br><br><br>";
			return strReturn;
		}
		
		private function populateCard(spr:Sprite, strTitle:String, strContent:String, lineIndex:int):int {
			var txtTitle:TextField = spr.getChildByName("txtTitle") as TextField;
			txtTitle.embedFonts = true;
			txtTitle.wordWrap = true;
			txtTitle.multiline = true;
			txtTitle.autoSize = TextFieldAutoSize.LEFT;
			txtTitle.htmlText = "<font face='Bookman Old Style' size='15'><b>" + strTitle + "</b></font>";
			
			var txtCardCount:TextField = spr.getChildByName("txtCardCount") as TextField;
			cardCount++;
			txtCardCount.htmlText = "<b>" + String(cardCount) + "</b>";
			
			var txtCopy:TextField = spr.getChildByName("txtCopy") as TextField;
			txtCopy.embedFonts = true;
			txtCopy.htmlText = strContent;
			var origY:Number = txtCopy.y;
			txtCopy.y = txtTitle.y + txtTitle.height + 6;
			txtCopy.height -= txtCopy.y - origY;
			var newScrollV:int = lineIndex + 1;
			txtCopy.scrollV = newScrollV;
			if (txtCopy.scrollV != newScrollV) {
				// delete this card since we're at the end
				return -2;
			}
			
			var txtFooter:TextField = spr.getChildByName("txtFooter") as TextField;
			txtFooter.text = "Copyright " + new Date().fullYear + " Course Vector, All Rights Reserved";
			
			// Get remaining content
			var intReturn:int = -1;
			if (txtCopy.numLines > txtCopy.bottomScrollV) {
				intReturn = txtCopy.bottomScrollV;
				var lineLength:int = txtCopy.getLineLength(intReturn);
				if(lineLength == 0) intReturn = -1;
			}
			
			return intReturn;
		}
		
		private function populatePage(spr:Sprite, strTitle:String, strContent:String, lineIndex:int):int {
			var txtTitle:TextField = spr.getChildByName("txtTitle") as TextField;
			txtTitle.embedFonts = true;
			txtTitle.wordWrap = true;
			txtTitle.multiline = true;
			txtTitle.autoSize = TextFieldAutoSize.LEFT;
			txtTitle.htmlText = "<font face='Bookman Old Style' size='25'><b>" + strTitle + "</b></font>";
			
			var txtCopy:TextField = spr.getChildByName("txtCopy") as TextField;
			txtCopy.embedFonts = true;
			txtCopy.htmlText = strContent;
			var origY:Number = txtCopy.y;
			txtCopy.y = txtTitle.y + txtTitle.height + 6;
			txtCopy.height -= txtCopy.y - origY;
			var newScrollV:int = lineIndex + 1;
			txtCopy.scrollV = newScrollV;
			if (txtCopy.scrollV != newScrollV) {
				// delete this card since we're at the end
				return -2;
			}
			
			var txtFooter:TextField = spr.getChildByName("txtFooter") as TextField;
			txtFooter.text = "Copyright " + new Date().fullYear + " Course Vector, All Rights Reserved";
			
			// Get remaining content
			var intReturn:int = -1;
			if (txtCopy.numLines > txtCopy.bottomScrollV) {
				intReturn = txtCopy.bottomScrollV;
				var lineLength:int = txtCopy.getLineLength(intReturn);
				if(lineLength == 0) intReturn = -1;
			}
			
			return intReturn;
		}
	}
}
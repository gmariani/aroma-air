package cv.text {
	
	/**
	* TextFlowLite by Grant Skinner. Sep 9, 2007
	* Visit www.gskinner.com/blog for documentation, updates and more free code.
	*
	*
	* Copyright (c) 2007 Grant Skinner
	* 
	* Permission is hereby granted, free of charge, to any person
	* obtaining a copy of this software and associated documentation
	* files (the "Software"), to deal in the Software without
	* restriction, including without limitation the rights to use,
	* copy, modify, merge, publish, distribute, sublicense, and/or sell
	* copies of the Software, and to permit persons to whom the
	* Software is furnished to do so, subject to the following
	* conditions:
	* 
	* The above copyright notice and this permission notice shall be
	* included in all copies or substantial portions of the Software.
	* 
	* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
	* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
	* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
	* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
	* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	* OTHER DEALINGS IN THE SOFTWARE.
	**/
	
	/**
	* Inspired by TextFlowLite, modified to handle HTML by Gabriel Mariani
	*/
	
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class TextFlow {
		
		protected var flds:Array;
		protected var _text:String;
		protected var _curText:String;
		
		public function TextFlow(textFields:Array, text:String = null) {
			flds = textFields;
			_text = text == null ? flds[0].text : text;
			reflow();
		}
		
		public function get text():String { return _text; }
		public function set text(value:String):void {
			_text = value;
			reflow();
		}
		
		public function reflow():void {
			flds[0].htmlText = _text;
			_curText = _text;
			
			var l:int = flds.length - 1;
			for (var i:int = 0; i < l; i++) {
				flowField(flds[i], flds[i + 1]);
			}
		}
		
		protected function flowField(fld1:TextField, fld2:TextField):void {
			fld1.scrollV = 1;
			fld2.htmlText = "";
			if (fld1.maxScrollV <= 1) return;
			
			try { // this is to get around issues with Flash's reporting of maxScrollV.
				
				// Get text index
				var nextCharIndex:int = fld1.getLineOffset(fld1.bottomScrollV);
				
				// Get html index
				var htmlCharIndex:int = findCharIndexInHTML(nextCharIndex, _curText);
				
				// Fix Textformats
				var nextTF:TextFormat = fld1.getTextFormat(nextCharIndex);
				var tagStart:String = "";
				
				var hasFont:Boolean = (nextTF.font != null) || (nextTF.size != null) || (nextTF.color != null) || (nextTF.letterSpacing != null) || (nextTF.kerning != null);
				if (hasFont) tagStart += "<font ";
				if (nextTF.font != null) tagStart += "face='" + nextTF.font + "' ";
				if (nextTF.size != null) tagStart += "size='" + nextTF.size + "' ";
				if (nextTF.color != null) tagStart += "color='" + nextTF.color + "' ";
				if (nextTF.letterSpacing != null) tagStart += "letterspacing='" + nextTF.letterSpacing + "' ";
				if (nextTF.kerning != null) tagStart += "kerning='" + nextTF.kerning + "' ";
				if (hasFont) tagStart += ">";
				
				var hasTextFormat:Boolean = (nextTF.leading != null) || (nextTF.blockIndent != null) || (nextTF.indent != null) || (nextTF.leftMargin != null) || nextTF.rightMargin != null || nextTF.tabStops != null;
				if (hasTextFormat) tagStart += "<textformat ";
				if (nextTF.leading != null) tagStart += "leading='" + nextTF.leading + "' ";
				if (nextTF.blockIndent != null) tagStart += "blockindent='" + nextTF.blockIndent + "' ";
				if (nextTF.indent != null) tagStart += "indent='" + nextTF.indent + "' ";
				if (nextTF.leftMargin != null) tagStart += "leftmargin='" + nextTF.leftMargin + "' ";
				if (nextTF.rightMargin != null) tagStart += "rightmargin='" + nextTF.rightMargin + "' ";
				if (nextTF.tabStops != null) tagStart += "tabstops='" + nextTF.tabStops + "' ";
				if (hasTextFormat) tagStart += ">";
				
				if (nextTF.italic) tagStart += "<i>";
				if (nextTF.bold) tagStart += "<b>";
				
				var tagEnd:String = "";
				if (nextTF.bold) tagEnd += "</b>";
				if (nextTF.italic) tagEnd += "</i>";
				if (hasTextFormat) tagEnd += "</textformat>";
				if (hasFont) tagEnd += "</font>";
				
				// Assign text
				fld2.htmlText = tagStart + _curText.substr(htmlCharIndex).replace(/^\s+/, '');
				fld1.htmlText = _curText.substr(0, htmlCharIndex).replace(/\s+$/, '') + tagEnd;
				
				_curText = _curText.substr(htmlCharIndex);
			} catch (e:*) { }
		}
		
		protected function findCharIndexInHTML(charIndex:int, str:String):int {
			var htmlIndex:int = 0;
			var textIndex:int = 0;
			var isHTML:Boolean = false;
			var char:String;
			var loop:Boolean = true;
			while(loop) {
				char = str.charAt(htmlIndex);
				if(char == "<") {
					isHTML = true;
				} else if(char == ">" && isHTML) {
					isHTML = false;
				} else if(isHTML == false) {
					textIndex++;
				}
				htmlIndex++;
				if (textIndex >= charIndex && isHTML == false) loop = false;
			}
			
			var correctedTextIndex:int = textIndex - str.substr(0, htmlIndex).match(/<\s*\/?\s*br\s*\/?\s*>/g).length;
			isHTML = false; // Force it to not break inside an HTML tag
			loop = true;
			var isSpace:Boolean = false; // Force it to break at a space and not in the middle of a word
			while(loop) {
				char = str.charAt(htmlIndex);
				isSpace = (char == " ");
				if(char == ">") {
					isHTML = true;
				} else if(char == "<" && isHTML) {
					isHTML = false;
				} else if(isHTML == false) {
					textIndex--;
				}
				htmlIndex--;
				if (correctedTextIndex >= textIndex && isHTML == false && isSpace == true) loop = false;
			}
			
			htmlIndex++; // Correct for the last loop
			return htmlIndex;
		}
	}
}
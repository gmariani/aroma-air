package com.coursevector.aroma.model.vo {
	
	// Map this AS3 VO to the following remote class
	[RemoteClass(alias = "com.coursevector.aroma.model.vo.IngredientVO")]

	[Bindable]
	public class IngredientVO {
		
		public var recipeId:int;
		public var amount:int;
		public var _fraction:String;
		public var _size:String;
		public var _label:String;
		
		public function set fraction(str:String):void { _fraction = checkVal(str) }
		public function get fraction():String { return _fraction }
		
		public function set size(str:String):void { _size = checkVal(str) }
		public function get size():String { return _size }
		
		public function set label(str:String):void { _label = checkVal(str) }
		public function get label():String { return _label }
		
		private function checkVal(val:String):String {
			if(val == null || val == "null") return " ";
			return val;
		}
	}
}
package com.coursevector.aroma.model.vo {
	
	// Map this AS3 VO to the following remote class
	[RemoteClass(alias = "com.coursevector.aroma.model.vo.LoginVO")]

	[Bindable]
	public class LoginVO {
		
		public var username:String;
		public var password:String;
		public var authToken:String; // set by the server if credentials are valid
		
	}
}
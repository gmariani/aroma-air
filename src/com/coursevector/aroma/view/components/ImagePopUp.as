package com.coursevector.aroma.view.components {

	import cv.util.ScaleUtil;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.Screen;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;

	public class ImagePopUp extends NativeWindow {
		
		private var ldrPicture:Loader = new Loader();
		
		public function ImagePopUp(baImage:ByteArray) {
			// Init Window
			var winArgs:NativeWindowInitOptions = new NativeWindowInitOptions();
			winArgs.maximizable = false;
			winArgs.minimizable = false;
			winArgs.resizable = true;
			winArgs.type = NativeWindowType.NORMAL;
			super(winArgs);
			
			this.width = 100;
			this.height = 100;
			this.title = "Recipe Picture";
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			ldrPicture.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			ldrPicture.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
			stage.addChild(ldrPicture);
			
			try {
				baImage.inflate();
			} catch (e:Error) {
				//trace("ImagePopUp - " + e.message);
			}
			try {
				ldrPicture.loadBytes(baImage);
			} catch (e:Error) {
				//trace("ImagePopUp - " + e.message);
			}
		}
		
		private function onLoaderComplete(e:Event):void {
			var b:Rectangle = Screen.mainScreen.bounds;
			var bitmap:Bitmap = ldrPicture.content as Bitmap;
			bitmap.smoothing = true;
			
			ScaleUtil.toFit(bitmap, new Rectangle(0, 0, b.width - 100, b.height - 100));
			
			this.width = bitmap.width;
			this.height = bitmap.height;
			this.x = (b.width / 2) - (this.width / 2);
			this.y = (b.height / 2) - (this.height / 2);
			this.addEventListener(Event.RESIZE, onWindowResize);
			this.activate();
		}
		
		private function onError(e:IOErrorEvent):void {
			throw Error("ImagePopUp::ldrPicture : " + e.text);
		}
		
		private function onWindowResize(e:NativeWindowBoundsEvent):void	{
			var bitmap:Bitmap = ldrPicture.content as Bitmap;
			ScaleUtil.toFit(bitmap, new Rectangle(0, 0, e.afterBounds.width, e.afterBounds.height));
			this.removeEventListener(Event.RESIZE, onWindowResize);
			this.width = bitmap.width;
			this.height = bitmap.height;
			this.addEventListener(Event.RESIZE, onWindowResize);
		}
	}
}
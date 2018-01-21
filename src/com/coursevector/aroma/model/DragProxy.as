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

 // Handles files being dropped, dragged, imported, exported

package com.coursevector.aroma.model {
	
	import flash.display.DisplayObject;
	import org.puremvc.as3.multicore.interfaces.IProxy;
    import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	import com.coursevector.aroma.ApplicationFacade;
	
	import flash.desktop.NativeDragManager;
	import flash.desktop.NativeDragActions;
	import flash.desktop.NativeDragOptions;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardTransferMode;
	import flash.desktop.ClipboardFormats;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.events.NativeDragEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.printing.PrintJobOrientation;
	import flash.system.System;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	public class DragProxy extends Proxy implements IProxy {
		
		public static const NAME:String = 'DragProxy';
		private var arrRecipes:Array;
		private var stage:Stage;
		
		public function DragProxy() {
            super(NAME);
		}
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		//
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function dragExport(arr:Array, initiator:DisplayObject):void {
			stage = initiator.stage;
			//stage.addEventListener(NativeDragEvent.NATIVE_DRAG_START, dragHandler);
			//stage.addEventListener(NativeDragEvent.NATIVE_DRAG_UPDATE, dragHandler);
			//stage.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, dragHandler);
			//stage.addEventListener(NativeDragEvent.NATIVE_DRAG_OVER, dragHandler);
			//stage.addEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, dragHandler);
			//stage.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, dragHandler);
			stage.addEventListener(NativeDragEvent.NATIVE_DRAG_COMPLETE, dragHandler);
			
			arrRecipes = arr;
			
			var transfer:Clipboard = new Clipboard();
			transfer.setData(ClipboardFormats.FILE_LIST_FORMAT, exportRecipes());
			var ndo:NativeDragOptions = new NativeDragOptions();
			ndo.allowCopy = false;
			ndo.allowLink = false;
			NativeDragManager.doDrag(stage, transfer, null, null, ndo);
		}
		
		public function fileExport(arr:Array, newFile:File):void {
			arrRecipes = arr;
			if (!newFile.exists) {
				var fs:FileStream = new FileStream();
				fs.open(newFile, FileMode.WRITE);
				fs.writeObject(arrRecipes[0]);
				fs.close();
			}
			arrRecipes = new Array();
		}
		
		public function dragImport(arr:Array):void {
			var recipe:Object = new Object();
			var fs:FileStream;
			for each(var f:File in arr) {
				if(f.extension == "rcpe") {
					fs = new FileStream();
					fs.open(f, FileMode.READ);
					recipe = fs.readObject();
					fs.close();
					delete recipe.rowid; // So this is added as a new recipe doesn't overwrite any current ones
					sendNotification(ApplicationFacade.SQL_SAVE, recipe);
				}
			}
		}
		
		// Invalid name
		public function fileImport(arr:Array):void {
			dragImport(arr);
		}
		
		//--------------------------------------
		//  PureMVC
		//--------------------------------------
		
		//
		
		//--------------------------------------
		//  Private
		//--------------------------------------
		
		private function dragHandler(event:NativeDragEvent):void {
			if (event.type == NativeDragEvent.NATIVE_DRAG_COMPLETE) {
				// Clean up
				//stage.removeEventListener(NativeDragEvent.NATIVE_DRAG_START, dragHandler);
				//stage.removeEventListener(NativeDragEvent.NATIVE_DRAG_UPDATE, dragHandler);
				//stage.removeEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, dragHandler);
				//stage.removeEventListener(NativeDragEvent.NATIVE_DRAG_OVER, dragHandler);
				//stage.removeEventListener(NativeDragEvent.NATIVE_DRAG_EXIT, dragHandler);
				//stage.removeEventListener(NativeDragEvent.NATIVE_DRAG_DROP, dragHandler);
				stage.removeEventListener(NativeDragEvent.NATIVE_DRAG_COMPLETE, dragHandler);
			}
		}
		
		private function exportRecipes():Array {
			var arrFiles:Array = new Array();
			for each(var recipe:Object in arrRecipes) {
				var f:File = File.applicationStorageDirectory;
				f = f.resolvePath(recipe.title + ".rcpe");
				var fs:FileStream = new FileStream();
				fs.open(f, FileMode.WRITE);
				fs.writeObject(recipe);
				fs.close();
				arrFiles.push(f);
			}
			arrRecipes = new Array();
			
			return arrFiles;
		}
	}
}
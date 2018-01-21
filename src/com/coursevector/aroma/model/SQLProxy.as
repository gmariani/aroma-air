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
 * Manages the selected playlist
 * 
 * @author Gabriel Mariani
 * @version 0.1
 */

package com.coursevector.aroma.model {
	
    import org.puremvc.as3.multicore.interfaces.IProxy;
    import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	import com.coursevector.aroma.ApplicationFacade;
	//import cv.formats.JSON;
	
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.errors.SQLError;
	import flash.events.SQLEvent;
	import flash.events.SQLErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.Responder;

    public class SQLProxy extends Proxy implements IProxy {
        public static const NAME:String = 'SQLProxy';
		
		private var dbConn:SQLConnection;
		private var dbFile:File;
		private var dbStatement:SQLStatement;
		private var recipeData:Array;
		private var objRecipe:Object;
		private var isOnline:Boolean = false;
		private var objDefaultRecipe:Object = new Object();
		
		private var statements:Array = new Array();
		
		public function SQLProxy() {
            super(NAME);
			
			objDefaultRecipe.title = "Rainbow Slaw";
			objDefaultRecipe.directions = "Combine the salad, seeds, and fruit. Mix up the dressing (vinegar, canola oil, seasoning, sugar) and pour over the salad. DO NOT ADD the crushed noodles until about an hour ahead of serving time.";
			objDefaultRecipe.ingredients = new Object();
			objDefaultRecipe.ingredients[0] = "2 pkg of rainbow salad or broccoli salad";
			objDefaultRecipe.ingredients[1] = "2 pkg of Ramen noodles (chicken or oriental)";
			objDefaultRecipe.ingredients[2] = "1 can of crushed pineapple (drained)";
			objDefaultRecipe.ingredients[3] = "1 pkg of sunflower seeds (keep leftovers in freezer)";
			objDefaultRecipe.ingredients[4] = "1/3C vinegar";
			objDefaultRecipe.ingredients[5] = "3/4C of canola oil";
			objDefaultRecipe.ingredients[6] = "2 seasoning packs from Ramen noodles";
			objDefaultRecipe.ingredients[7] = "1/2C of sugar";
			objDefaultRecipe.rating = 5;
			objDefaultRecipe.author = "Jennifer Mariani";
			objDefaultRecipe.source = "Family Recipe";
			objDefaultRecipe.category = "Side Dish";
			objDefaultRecipe.picture = null;
			objDefaultRecipe.yields = '4 Servings';
			objDefaultRecipe.notes = "";
			objDefaultRecipe.difficulty = 1;
        }
		
		//--------------------------------------
		//  Properties
		//--------------------------------------
		
		//--------------------------------------
		//  Methods
		//--------------------------------------
		
		public function deleteRecipe(arr:Array):void {
			var strDeleteIds:String = "";
			for(var i:String in arr) {
				strDeleteIds += arr[i].rowid;
				if(int(i) != arr.length - 1) {
					strDeleteIds += ", ";
				}
			}
			
			dbStatement.text = "DELETE FROM recipes WHERE rowid IN (" + strDeleteIds + ")";
			sendNotification(ApplicationFacade.SQL_START, "Deleting Recipe...");
			dbStatement.execute(-1, new Responder(updateDBHandler, errorDBHandler));
		}
		
		public function getRecipes():Array {
			return recipeData;
		}
		
		override public function initializeNotifier(key:String):void {
			super.initializeNotifier(key);
			init();
		}
		
		/*
		// Used when recieving multiple recipes from inbox, useful for import?
		public function saveMultiRecipe(a:Array):void {
			isOnline = true;
			for(var i:String in a) {
				saveRecipe(a[i]);
			}
			isOnline = false;
		}
		*/
		
		public function saveRecipe(o:Object):void {
			objRecipe = new Object();
			objRecipe = o;
			var sql:String;
			
			if(objRecipe.rowid != null && isOnline == false) {
				// update
				sql = "UPDATE recipes SET " +
						"title = :title, " +
						"directions = :directions," +
						"ingredients = :ingredients," +
						"rating = :rating," +
						"author = :author," +
						"source = :source," +
						"category = :category," +
						"picture = :picture," +
						"yields = :yields," +
						"notes = :notes," +
						"difficulty = :difficulty " +
						"WHERE rowid = " + objRecipe.rowid;
			} else {
				// add
				sql = "INSERT INTO recipes (" +
						"title," +
						"directions," +
						"ingredients," +
						"rating," +
						"author," +
						"source," +
						"category," +
						"picture," +
						"yields," +
						"notes," +
						"difficulty) " +
						"VALUES (" +
						":title," +
						":directions," +
						":ingredients," +
						":rating," +
						":author," +
						":source," +
						":category," +
						":picture," +
						":yields," +
						":notes," +
						":difficulty)";
			}
			
			dbStatement.text = sql;
			dbStatement.parameters[":title"] = escape(objRecipe.title);
			dbStatement.parameters[":directions"] = escape(objRecipe.directions);
			dbStatement.parameters[":ingredients"] = JSON.stringify(objRecipe.ingredients);
			dbStatement.parameters[":rating"] = objRecipe.rating;
			dbStatement.parameters[":author"] = escape(objRecipe.author);
			dbStatement.parameters[":source"] = escape(objRecipe.source);
			dbStatement.parameters[":category"] = objRecipe.category;
			dbStatement.parameters[":picture"] = objRecipe.picture;
			dbStatement.parameters[":yields"] = escape(objRecipe.yields);
			dbStatement.parameters[":notes"] = escape(objRecipe.notes);
			dbStatement.parameters[":difficulty"] = 1;
			
			//trace(sql);
			sendNotification(ApplicationFacade.SQL_START, "Saving Recipe...");
			dbStatement.execute(-1, new Responder(updateDBHandler, errorDBHandler));
		}
		
		public function close():void {
			dbConn.close();
			//dbConn.close(new Responder(closeDBHandler, errorDBHandler));
		}
		
		private function updateRecords():void {
			getRecords();
		}
		
		private function dbHandler(event:SQLEvent):void {
			dbStatement = new SQLStatement();
			dbStatement.sqlConnection = dbConn;
			dbStatement.text = "CREATE TABLE IF NOT EXISTS recipes(" +
		   " title VARCHAR(150) NOT NULL, " +
		   " directions TEXT NOT NULL, " +
		   " ingredients TEXT NULL, " +
		   " rating INTEGER DEFAULT 1 NOT NULL, " +
		   " author VARCHAR(75) NULL, " +
		   " source VARCHAR(75) NULL, " +
		   " category VARCHAR(75) NULL, " +
		   " picture BLOB NULL, " +
		   " yields VARCHAR(150) DEFAULT '1 Serving' NOT NULL, " +
		   " notes TEXT NULL, " +
		   " difficulty INTEGER DEFAULT 1 NOT NULL" +
		   ");";
			dbStatement.execute(-1, new Responder(readyDBHandler, errorDBHandler));
		}
		
		private function getRecords():void {
			dbStatement = new SQLStatement();
			dbStatement.sqlConnection = dbConn;
			dbStatement.text = "SELECT rowid, * FROM recipes";
			sendNotification(ApplicationFacade.SQL_START, "Load Recipes...");
			dbStatement.execute(-1, new Responder(selectDBHandler, errorDBHandler));
		}
		
		private function init():void {
			//dbFile = new File("app:/recipes.db");
			dbFile = File.documentsDirectory.resolvePath("Aroma Recipes/");
			dbFile.createDirectory(); // Ensures directory exists
			dbFile = dbFile.resolvePath("recipes.ckbk");
			
			dbConn = new SQLConnection();
			sendNotification(ApplicationFacade.SQL_START, "Opening Cook Book...");
			dbConn.openAsync(dbFile, SQLMode.CREATE, new Responder(dbHandler, errorDBHandler));
		}
		
		private function errorDBHandler(error:SQLError):void {
			sendNotification(ApplicationFacade.SQL_ERROR, "Error : " + error.operation + " - " + error.details);
			throw Error("SQLProxy::" + error.operation + " : " + error.errorID + " : " + error.details);
		}
		
		private function updateDBHandler(result:SQLResult):void {
			sendNotification(ApplicationFacade.SQL_FINISH);
			if (dbConn.totalChanges >= 1) updateRecords();
		}
		
		private function readyDBHandler(result:SQLResult):void {
			sendNotification(ApplicationFacade.SQL_FINISH);
			sendNotification(ApplicationFacade.SQL_OPEN);
			
			// Add default recipe if non-existant
			checkDefault();
		}
		
		private function checkDefault():void {
			dbStatement = new SQLStatement();
			dbStatement.sqlConnection = dbConn;
			dbStatement.text = "SELECT * FROM recipes";
			dbStatement.execute(1, new Responder(checkDBHandler, errorDBHandler));
		}
		
		private function checkDBHandler(result:SQLResult):void {
			if (!result.data) {
				saveRecipe(objDefaultRecipe);
			} else {
				getRecords();
			}
		}
		
		private function selectDBHandler(result:SQLResult):void {
			sendNotification(ApplicationFacade.SQL_FINISH);
			if (result != null)	{
				recipeData = result.data;
				for (var i:String in recipeData) {
					recipeData[i].title = unescape(recipeData[i].title);
					recipeData[i].directions = unescape(recipeData[i].directions);
					recipeData[i].ingredients = JSON.parse(recipeData[i].ingredients);
					recipeData[i].author = unescape(recipeData[i].author);
					recipeData[i].source = unescape(recipeData[i].source);
					recipeData[i].yields = unescape(recipeData[i].yields);
					recipeData[i].notes = unescape(recipeData[i].notes);
				}
			}
			
			sendNotification(ApplicationFacade.SQL_RESULT);
		}
	}
}
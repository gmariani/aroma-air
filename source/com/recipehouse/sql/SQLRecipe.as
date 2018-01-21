package com.recipehouse.sql {
	
	import flash.data.SQLResult;
	import flash.display.Sprite;
	
	import flash.filesystem.File;
	
	import flash.data.SQLStatement;
	import flash.data.SQLConnection;
	
	import flash.events.SQLEvent;
	import flash.events.SQLErrorEvent;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	
	import com.recipehouse.sql.SQLIngredient;
	import com.coursevector.data.JSON;
	
	public class SQLRecipe extends Sprite{
		
		private var dbConn:SQLConnection;
		private var dbFile:File;
		private var dbStatement:SQLStatement;
		private var recipeData:Array;
		private var dispatchCount:uint = 0;
		private var dataType:String = "result";
		
		public static const RESULT:String = "result";
		public static const UPDATE:String = "update";
		
		private var savedRecipeId:uint;
		private var strDeleteIds:String;
		private var objRecipe:Object;
		private var isOnline:Boolean = false;
		
		public function SQLRecipe() {
			init();
		}
		
		private function init():void {
			//dbFile = new File("app-resource:/Aroma.db");
			dbFile = new File("Aroma.db");
			dbConn = new SQLConnection();
			dbConn.addEventListener(SQLEvent.OPEN, onDBOpened);
			dbConn.addEventListener(SQLErrorEvent.ERROR, onDBError);
			dbConn.open(dbFile);
		}
		
		private function onDBOpened(e:SQLEvent):void {
			if (e.type == "open") getRecords();
		}
		
		private function onDBError(e:SQLEvent):void { }
		
		public function updateRecords():void {
			dataType = UPDATE;
			getRecords();
		}
		
		public function getRecipes():Array {
			return recipeData;
		}
		
		// LOAD RECIPES FUNCTIONS //
		private function getRecords():void {
			dbStatement = new SQLStatement();
			dbStatement.sqlConnection = dbConn;
			dbStatement.text = "SELECT rowid, title, directions, ingredients, rating, author, category FROM recipes";
			dbStatement.addEventListener(SQLEvent.RESULT, onDBRecipeSelectResult);
			dbStatement.execute();
		}
		
		private function onDBRecipeSelectResult(e:SQLEvent):void {
			var result:SQLResult = dbStatement.getResult();
			if (result != null)	{
				recipeData = result.data;
				for(var i in recipeData) {
					recipeData[i].ingredients = JSON.deserialize(recipeData[i].ingredients);
				}
			}
			dbStatement.removeEventListener(SQLEvent.RESULT, onDBRecipeSelectResult);
			dispatchEvent(new Event(dataType));
		}
		
		// SAVE RECIPES FUNCTIONS //
		public function saveRecipe(o:Object):void {
			objRecipe = new Object();
			objRecipe = o;
			var sqlInsert:String;
			
			if(objRecipe.rowid != null && isOnline == false) {
				// update
				sqlInsert = "UPDATE recipes SET ";
				sqlInsert += "title = '" + objRecipe.title + "', ";
				sqlInsert += "directions = '" + objRecipe.directions + "', ";
				sqlInsert += "ingredients = '" + JSON.serialize(objRecipe.ingredients) + "', ";
				sqlInsert += "rating = " + objRecipe.rating + ", ";
				sqlInsert += "author = '" + objRecipe.author + "', ";
				sqlInsert += "category = '" + objRecipe.category + "' ";
				sqlInsert += "WHERE rowid = " + objRecipe.rowid;
			} else {
				// add
				sqlInsert = "INSERT INTO recipes VALUES";
				sqlInsert += "('" + objRecipe.title + "', ";
				sqlInsert += "'" + objRecipe.directions + "', ";
				sqlInsert += "'" + JSON.serialize(objRecipe.ingredients) + "', ";
				sqlInsert += objRecipe.rating + ", ";
				sqlInsert += "'" + objRecipe.author + "', ";
				sqlInsert += "'" + objRecipe.category + "');";
			}
			
			dbStatement.text = sqlInsert;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBRecipeInsertResult);
			dbStatement.execute();
		}
		
		public function saveMultiRecipe(a:Array):void {
			isOnline = true;
			for(var i:String in a) {
				saveRecipe(a[i]);
			}
			isOnline = false;
		}
		
		private function onDBRecipeInsertResult(e:SQLEvent):void {
			if (dbConn.totalChanges >= 1) updateRecords();
		}
		
		// DELETE RECIPES FUNCTIONS //
		public function deleteRecipe(arr:Array):void {
			strDeleteIds = "";
			for(var i:String in arr) {
				strDeleteIds += arr[i].rowid;
				if(int(i) != arr.length - 1) {
					strDeleteIds += ", ";
				}
			}
			var sqlDelete:String = "DELETE FROM recipes ";
			sqlDelete += "WHERE recipes.rowid IN (" + strDeleteIds + ")";
			dbStatement.text = sqlDelete;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBRecipeDeleteResult);
			dbStatement.execute();
		}
		
		private function onDBRecipeDeleteResult(e:SQLEvent):void {
			if (dbConn.totalChanges >= 1) updateRecords();
		}	
	}	
}
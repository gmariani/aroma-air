<?php
/////////////////////////////////////////////////////////////////
/// Aroma() by Gabriel Mariani <www.coursevector.com> 
//  available at http://labs.coursevector.com/projects/aroma 
// 
/////////////////////////////////////////////////////////////////
// 
// Please see readme.txt for more information 
// 
/////////////////////////////////////////////////////////////////

// Defines
define('VERSION', '2.0.0');

class Aroma {
	
	var $host = "DB_URL"; // Host name
	var $username = "DB_USER"; // Mysql username
	var $password = "DB_PASS"; // Mysql password
	var $db_name = "DB_NAME"; // Database name
	var $tbl_members = "members"; // Table name
	var $tbl_inbox = "inbox"; // Table name
	
	function Aroma() {
		mysql_connect("$this->host", "$this->username", "$this->password") or die("cannot connect");
		mysql_select_db("$this->db_name") or die("cannot select DB");
	}
	
	function checkUserName($userName) {
		$sql = "SELECT userName FROM $this->tbl_members WHERE userName = '$userName'";
		$result = mysql_query($sql);
		$count = mysql_num_rows($result);
		$result = ($count == 0) ? "true" : "false";
		echo "isAvail=$result";
	}
	
	function deleteUserName($userName) {
		$sql = "DELETE FROM $this->tbl_members WHERE userName = '$userName'";
		$result = mysql_query($sql);
		echo "success=$result";
	}
	
	function createUser($userName, $password) {
		$sql = "INSERT INTO $this->tbl_members (userName, password) VALUES";
		$sql .= "('" . $userName . "', ";
		$sql .= "'" . $password . "')";
		$result = mysql_query($sql);
		echo "success=$result";
	}
	
	function updateUser($oldName, $userName, $password) {
		/*$sql = "INSERT INTO $this->tbl_members (userName) VALUES";
		$sql .= "('" . $userName . "')";
		$result = mysql_query($sql);
		echo "success=$result";*/
		echo "success=false";
	}
	
	function loginUser($userName, $password) {
		$sql = "SELECT userName, password FROM $this->tbl_members WHERE userName = '$userName' AND password = '$password'";
		$result = mysql_query($sql);
		$count = mysql_num_rows($result);
		$result = ($count == 0) ? true : false;
		echo "success=$result";
	}
	
	function checkRecipes($userName) {
		$sql = "SELECT userName FROM $this->tbl_inbox WHERE userName = '$userName'";
		$result = mysql_query($sql);
		$count = mysql_num_rows($result);
		echo "hasRecipes=$count";
	}
	
	function deleteRecipe($id) {
		$sql = "DELETE FROM $this->tbl_inbox WHERE id = '$id'";
		$result = mysql_query($sql);
		echo "success=$result";
	}
	
	function saveRecipes($strTo, $jsonData) {
		if(strstr($strTo, ',') != false) {
			$arrTo = split(',', $strTo);
		} else {
			$arrTo = array();
			$arrTo[0] = $strTo;
		}
		
		$nLen = count($arrTo);
		for($i = 0; $i < $nLen; $i++) {
			$sql = "INSERT INTO $this->tbl_inbox (userName, data) VALUES";
			$sql .= "('" . $arrTo[$i] . "', ";
			$sql .= "'" . $jsonData . "')";
			$result = mysql_query($sql);
			if(!$result) {
				echo "success=false";
				return;
			}
		}
		
		echo "success=true";
	}
	
	function getRecipes($userName) {
		$sql = "SELECT * FROM $this->tbl_inbox WHERE userName = '$userName' LIMIT 1";
		$result = mysql_query($sql);
		$data = "";
		$id = "";
		while ($row = mysql_fetch_assoc($result)) {
			$data .= $row["data"];
			$id .= $row["id"];
		}
		echo "messageData=$data&messageId=$id";
	}
}

$aroma = new Aroma;
switch($_POST["action"]) {
	case "checkUserName" :
		$aroma->checkUserName($_POST["userName"]);
		break;
	/*case "deleteUserName" :
		$aroma->deleteUserName($_POST['oldName']);
		break;*/
	case "createUser" :
		$aroma->createUser($_POST['userName']);
		break;
	case "updateUser" :
		$aroma->updateUser($_POST['oldName'], $_POST['userName'], $_POST['password']);
		break;
	case "loginUser" :
		$aroma->loginUser($_POST['userName'], $_POST['password']);
		break;
	case "checkRecipes" :
		$aroma->checkRecipes($_POST["userName"]);
		break;
	case "deleteRecipe" :
		$aroma->deleteRecipe($_POST["id"]);
		break;
	case "saveRecipes" :
		$aroma->saveRecipes($_POST["sendTo"], $_POST["sendData"]);
		break;
	case "getRecipes" :
		$aroma->getRecipes($_POST["userName"]);
		break;
	default :
		echo "success=false";
}

?>
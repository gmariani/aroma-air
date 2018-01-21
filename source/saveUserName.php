<?

include("connect.php");
$newName = $_POST['newName'];
$oldName = $_POST['oldName'];

function saveName($strName) {
	$sql = "INSERT INTO $GLOBALS[tbl_name] (userName) VALUES";
	$sql .= "('" . $strName . "')";
	$result = mysql_query($sql);
	if(!$result) return "false";
	return "true";
}

function deleteName($strName) {
	$sql = "DELETE FROM $GLOBALS[tbl_name] WHERE userName = '$strName'";
	$result = mysql_query($sql);
	if(!$result) return "false";
	return "true";
}

function init() {
	if(isSet($GLOBALS["newName"])) {
		makeConnection();
		
		if(isSet($GLOBALS["oldName"])) {
			deleteName($GLOBALS["oldName"]);
		}
		
		$saveResult = saveName($GLOBALS["newName"]);
		print "success=$saveResult";
	} else {
		print "success='Required parameters missing.'";
	}
}

init();

?>
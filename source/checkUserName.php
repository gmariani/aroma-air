<?

include("connect.php");
$clientUserName = $_POST['UserName'];

function checkUserID($id) {
	$sql = "SELECT userName FROM $GLOBALS[tbl_name] WHERE userName = '$id'";
	$result = mysql_query($sql);
	$count = mysql_num_rows($result);
	if($count == 0) return "true";
	return "false";
}

function init() {
	if(isSet($GLOBALS["clientUserName"])) {
		makeConnection();
		$isAvail = checkUserID($GLOBALS["clientUserName"]);
		print "isAvail=$isAvail";
	} else {
		print "msg=Required parameters missing.";
	}
}

init();

?>
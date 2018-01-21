<?

include("connect.php");
$tbl_name = "inbox"; // Table name
$msgId = $_POST['id'];

function eraseRecipe($id) {
	$sql = "DELETE FROM inbox WHERE id = '$id'";
	$result = mysql_query($sql);
	if(!$result) return "false";
	return "true";
}

function init() {
	if(isSet($GLOBALS["msgId"])) {
		makeConnection();
		$saveResult = eraseRecipe($GLOBALS["msgId"]);
		print "success=$saveResult";
	} else {
		print "msg=Required parameters missing.";
	}
}

init();

?>
<?

include("connect.php");
$clientUserName = $_POST['UserName'];

function init() {
	if(isSet($GLOBALS["clientUserName"])) {
		makeConnection();
		$id = $GLOBALS["clientUserName"];
		$sql = "SELECT userName FROM inbox WHERE userName = '$id'";
		$result = mysql_query($sql);
		$count = mysql_num_rows($result);
		print "hasRecipes=$count";
	} else {
		print "msg=Required parameters missing.";
	}
}

init();

?>
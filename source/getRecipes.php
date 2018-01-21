<?

include("connect.php");
$clientUserName = $_POST['UserName'];

function init() {
	if(isSet($GLOBALS["clientUserName"])) {
		makeConnection();
		$userName = $GLOBALS["clientUserName"];
		$sql = "SELECT * FROM inbox WHERE userName = '$userName' LIMIT 1";
		$result = mysql_query($sql);
		$data = "";
		$id = "";
		while ($row = mysql_fetch_assoc($result)) {
			$data .= $row["data"];
			$id .= $row["id"];
		}
		print "messageData=$data&messageId=$id";
	} else {
		print "msg=Required parameters missing.";
	}
}

init();

?>
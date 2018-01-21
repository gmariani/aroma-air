<?
$host = "DB_URL:3306"; // Host name
$username = "DB_USER"; // Mysql username
$password = "DB_PASS"; // Mysql password
$db_name = "DB_NAME"; // Database name
$tbl_name = "members"; // Table name

function makeConnection() {
	// Connect to server and select databse.
	mysql_connect("$GLOBALS[host]", "$GLOBALS[username]", "$GLOBALS[password]") or die("cannot connect");
	mysql_select_db("$GLOBALS[db_name]") or die("cannot select DB");
}
?>
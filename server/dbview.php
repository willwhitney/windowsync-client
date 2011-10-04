<?php
error_reporting(E_ALL);

$dbh = mysql_connect('sql.mit.edu', 'wwhitney', 'william') or die('Could not connect: ' . mysql_error() . '<br />');
mysql_select_db('wwhitney+windowsync') or die('No database selected.');

$query = sprintf("SELECT * FROM will ORDER BY tabindex");
$result = mysql_query($query);
// echo $result;
$rows = mysql_num_rows($result);
$json = array(); 

for ($i=0; $i < $rows; $i++) {
    $json[strval($i)]['tabindex'] = mysql_result($result, $i, 'tabindex'); 
    $json[strval($i)]['url'] = mysql_result($result, $i, 'url');
}

echo json_encode($json);

?>

<script>
setTimeout("location.reload()", 5000)
</script>
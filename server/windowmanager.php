<?php
// error_reporting(E_ALL);

// echo "fuck";

$dbh = mysql_connect('sql.mit.edu', 'wwhitney', 'william') or die('Could not connect: ' . mysql_error() . '<br />');
mysql_select_db('wwhitney+windowsync') or die('No database selected.');


// $query = sprintf("UPDATE will SET tabindex=tabindex+1 WHERE tabindex>='0'");
// echo $query;
// echo mysql_query($query);


// $query = sprintf("INSERT INTO will (id, url, tabnum) VALUES (NULL, 'violet2', '3')");
// mysql_query($query);

if($_GET['type'] == "add") {
    $query = sprintf("SELECT * FROM will WHERE url='" . $_GET['url'] . "' AND tabindex='" . $_GET['tabindex'] . "'");
    $result = mysql_query($query);

    if(mysql_num_rows($result) == 0) {

        $query = sprintf("UPDATE will SET tabindex=tabindex+1 WHERE tabindex>=" . $_GET['tabindex']);
        // echo $query;
        mysql_query($query);
        $query = sprintf("INSERT INTO will (id, url, tabindex) VALUES (NULL, '" . $_GET['url'] . "', ". $_GET['tabindex'] . ")");
        echo mysql_query($query);
        
    } else {
        echo 0;
    }



    // $query = sprintf("INSERT INTO will (id, url, tabnum) VALUES (NULL, '" . $_GET['url'] . "', ". $_GET['tabindex'] . ")");
    

} else if($_GET['type'] == "update") {
    // echo "fuckyeah";
    $query = sprintf("UPDATE will SET url='" . $_GET['newurl'] . "' WHERE url='" . $_GET['oldurl'] . "' AND tabindex='" . $_GET['tabindex'] . "'");
    // echo $query;
    $result = mysql_query($query);
    echo $result;




    
} else if($_GET['type'] == "move") {
    // echo "fuckyeah";
    $max = NULL;
    $min = NULL;
    if ($_GET['toindex'] > $_GET['fromindex']) {
        $query = sprintf("UPDATE will SET tabindex=tabindex-1 WHERE tabindex>" . $_GET['fromindex'] . " AND tabindex<" . $_GET['fromindex']);
        mysql_query($query);
        // $query = sprintf("UPDATE will SET tabindex=tabindex+1 WHERE tabindex>" . $_GET['toindex']);
        // mysql_query($query);
    } else if ($_GET['toindex'] < $_GET['fromindex']) {
        // $query = sprintf("UPDATE will SET tabindex=tabindex-1 WHERE tabindex>" . $_GET['fromindex']);
        // mysql_query($query);
        $query = sprintf("UPDATE will SET tabindex=tabindex+1 WHERE tabindex>=" . $_GET['toindex'] . " AND tabindex<" . $_GET['fromindex']);
        mysql_query($query);
    }

    $query = sprintf("UPDATE will SET tabindex='" . $_GET['toindex'] . "' WHERE url='" . $_GET['url'] . "' AND tabindex='" . $_GET['fromindex'] . "'");
    // echo $query;
    $result = mysql_query($query);
    echo $result;


    
}  else if($_GET['type'] == "remove") {
    // echo "fuckyeah";
    $query = sprintf("DELETE FROM will WHERE url='" . $_GET['url'] . "' AND tabindex='" . $_GET['tabindex'] . "'");
    mysql_query($query);
    $query = sprintf("UPDATE will SET tabindex=tabindex-1 WHERE tabindex>" . $_GET['tabindex']);
    mysql_query($query);
    $result = mysql_query($query);
    echo $result;





} else if($_GET['type'] == "get") {
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

}

?>










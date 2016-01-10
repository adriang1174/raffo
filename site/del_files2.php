<?php
$path = './archivos/';

$directorio = opendir($path);  

$link =  mysql_connect('localhost', 'uv1510', 'dije164fruto');
if (!$link) {
    echo 'No pudo conectarse: ' . mysql_error();
    exit;
}
mysql_select_db('uv1510_certi'); 

//Agregar tabla de log y loguear ejec

while ($archivo = readdir($directorio)) {  
		echo $archivo;
		$str = '';
		if (!($archivo=="." || $archivo=="..")) {  
						//Chequear archivo contra base de datos a ver si está cargado
						$query = "delete from certificados where archivo ='".$archivo."'"; 
						//echo $query;
						$result = mysql_query($query);
		}
} 
mysql_close($link);
?>

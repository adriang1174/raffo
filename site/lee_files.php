#!/usr/bin/php
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
						//Chequear archivo contra base de datos a ver si est� cargado
						$query = "select count(*) as existe from certificados where archivo ='".$archivo."'"; 
						//echo $query;
						$result = mysql_query($query);
						//var_dump($result);
						$res = mysql_fetch_assoc($result);
						//var_dump($res);
						if($res['existe'] == '0')					
						{
									$str = file_get_contents($path.$archivo);
									//Insertar en la BD
									$nombre 				=  substr($str,457,33);
									$orden          =  substr($str,500,8);
									$solicitado     =  substr($str,531,33);
									$fecha          =  substr($str,574,10);
									$observaciones  =  substr($str,607,33);
									$sexo 				  =  substr($str,724,1);
									$tipodoc				=  substr($str,726,1);			
									$documento			=  substr($str,728,8);	
									//$str						=  preg_replace("/[\x1B\x21\x08\x00\x0D\x0A]/", " ", $str);
									$str = StrTr($str,"\x21", " ");
									$str = StrTr($str,"\x10", "");
									$str = StrTr($str,"\x1B", " ");
									$str = StrTr($str,"\x08", " ");
									$str = StrTr($str,"\x00", " ");
									$str = StrTr($str,"\x0A", " ");
									$str = StrTr($str,"\x82", "�");
									$str = StrTr($str,"\xA2", "�");
									$str = StrTr($str,"\xA4", "�");
									$str = Str_replace("\x12", " ",$str);
									$str = StrTr($str,"\x0D", chr(10));
									//var_dump($str);
						
									$sql = "INSERT INTO certificados (nro,nombre,fecha,sexo,tipodoc,nrodoc,observaciones,archivo,txt_archivo)
									        VALUES('".$orden."','".$nombre."','".date("Y-m-d", strtotime($fecha))."','".$sexo."','".$tipodoc."','".$documento."','".$observaciones."','".$archivo."','".$str."')";
									//echo $sql;
									mysql_query($sql);
									//echo mysql_error();
						}
		}
} 
mysql_close($link);
?>

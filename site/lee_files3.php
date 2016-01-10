<?php
$path = './archivos/';

$link =  mysql_connect('localhost', 'uv1510', 'dije164fruto');
if (!$link) {
    echo 'No pudo conectarse: ' . mysql_error();
    exit;
}
mysql_select_db('uv1510_certi'); 

//Agregar tabla de log y loguear ejec

$archivo = $_REQUEST['nro'].'.TXT';
echo $archivo.'  -   ';
						//Chequear archivo contra base de datos a ver si está cargado
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
									$pos = strpos($str, 'Paciente');
									$nombre 				=  substr($str,$pos+17,33);
									$pos = strpos($str, 'Orden');
									$orden          =  substr($str,$pos+8,8);
									$pos = strpos($str, 'Solicitado por');
									$solicitado     =  substr($str,$pos+17,33);
									$pos = strpos($str, 'Fecha :');
									$fecha          =  substr($str,$pos+8,10);
									$pos = strpos($str, 'Observaciones  :');
									$observaciones  =  substr($str,$pos+17,33);
									$pos = strpos($str, 'Hoja  :');
									$sexo 				  =  trim(substr($str,$pos+81,2));
									$tipodoc				=  trim(substr($str,$pos+83,2));			
									$documento			=  trim(substr($str,$pos+85,9));	
									//$str						=  preg_replace("/[\x1B\x21\x08\x00\x0D\x0A]/", " ", $str);
									$str = StrTr($str,"\x0D", chr(10));
									$str = StrTr($str,"\x21", " ");
									//$str = StrTr($str,"\x10", "");
									//$str = StrTr($str,"\x1B", " ");
									//$str = StrTr($str,"\x08", " ");
									//$str = StrTr($str,"\x00", " ");
									//$str = StrTr($str,"\x0A", " ");
									$str = StrTr($str,"\x82", "é");
									$str = StrTr($str,"\xA2", "ó");
									$str = StrTr($str,"\xA4", "ñ");
									$str = Str_replace("(s3B", "",$str);
									$str = Str_replace("(s11H", "",$str);
									$str = Str_replace("(s0S", "",$str);
									$str = Str_replace("(s0B", "",$str);
									$str = Str_replace("(s7B", "",$str);
									$str = Str_replace("\x12", " ",$str);
									//var_dump($sexo);
																		
									if (strlen(trim($fecha)) < 10)
									{
												$sql = "INSERT INTO certificados (nro,nombre,fecha,sexo,tipodoc,nrodoc,observaciones,archivo,txt_archivo)
									        VALUES('".$orden."','".$nombre."',null,'".$sexo."','".$tipodoc."','".$documento."','".$observaciones."','".$archivo."','".$str."')";
			 									//echo '\n\n'.$sql.'\n\n';									      
									}
									else
									{
												$var = explode('/',str_replace('-','/',$fecha));
			 									$fecha = "$var[2]-$var[1]-$var[0]";
			 									//var_dump($fecha);
												$sql = "INSERT INTO certificados (nro,nombre,fecha,sexo,tipodoc,nrodoc,observaciones,archivo,txt_archivo)
									        VALUES('".$orden."','".$nombre."','".date("Y-m-d", strtotime($fecha))."','".$sexo."','".$tipodoc."','".$documento."','".$observaciones."','".$archivo."','".$str."')";
									}
									//echo $sql;
									mysql_query($sql);
									//echo mysql_error();
									echo "El archivo se ha actualizado exitosamente";
						}
						else
						{	
									echo "El protocolo ya se encuentra en la base de datos";
									/*
									//Acá hay que hacer update
									$str = file_get_contents($path.$archivo);
									//Update en la BD
									$pos = strpos($str, 'Paciente');
									$nombre 				=  substr($str,$pos+17,33);
									$pos = strpos($str, 'Orden');
									$orden          =  substr($str,$pos+8,8);
									$pos = strpos($str, 'Solicitado por');
									$solicitado     =  substr($str,$pos+17,33);
									$pos = strpos($str, 'Fecha :');
									$fecha          =  substr($str,$pos+8,10);
									$pos = strpos($str, 'Observaciones  :');
									$observaciones  =  substr($str,$pos+17,33);
									$pos = strpos($str, 'Hoja  :');
									$sexo 				  =  trim(substr($str,$pos+81,2));
									$tipodoc				=  trim(substr($str,$pos+83,2));			
									$documento			=  trim(substr($str,$pos+85,9));	
									$str = StrTr($str,"\x0D", chr(10));
									$str = StrTr($str,"\x21", " ");
									//$str = StrTr($str,"\x10", "");
									//$str = StrTr($str,"\x1B", " ");
									//$str = StrTr($str,"\x08", " ");
									//$str = StrTr($str,"\x00", " ");
									//$str = StrTr($str,"\x0A", " ");
									$str = StrTr($str,"\x82", "é");
									$str = StrTr($str,"\xA2", "ó");
									$str = StrTr($str,"\xA4", "ñ");
									$str = Str_replace("(s3B", "",$str);
									$str = Str_replace("(s11H", "",$str);
									$str = Str_replace("(s0S", "",$str);
									$str = Str_replace("(s0B", "",$str);
									$str = Str_replace("(s7B", "",$str);
									$str = Str_replace("\x12", " ",$str);
									
									
									var_dump($str);
									if (strlen(trim($fecha)) < 10)						
															$sql = "UPDATE certificados 
																			set nombre  			= '".$nombre."',
																			    fecha   			= null,
																			    sexo    			= '".$sexo."',
																			    tipodoc 			=	'".$tipodoc."',
																			    nrodoc				= '".$documento."',
																			    observaciones	= '".$observaciones."',
																			    archivo				= '".$archivo."',
																			    txt_archivo		= '".$str."'
																			 WHERE nro = '".$orden."'";
									else
									{
															$var = explode('/',str_replace('-','/',$fecha));
			 												$fecha = "$var[2]-$var[1]-$var[0]";															
															$sql = "UPDATE certificados 
																			set nombre  			= '".$nombre."',
																			    fecha   			= '".date("Y-m-d", strtotime($fecha))."',
																			    sexo    			= '".$sexo."',
																			    tipodoc 			=	'".$tipodoc."',
																			    nrodoc				= '".$documento."',
																			    observaciones	= '".$observaciones."',
																			    archivo				= '".$archivo."',
																			    txt_archivo		= '".$str."'
																			 WHERE nro = '".$orden."'";
									
									}
									
									echo $sql;
									mysql_query($sql);
									*/
						}
mysql_close($link);
//echo "El archivo se ha actualizado exitosamente".'\n';
?>

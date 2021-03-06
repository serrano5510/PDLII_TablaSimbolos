%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "tablaSimbolos.h" //A�adimos la tabla de simbolos

/*Declaraci�n de para usar yylval*/
typedef struct{
	int token; 		/*C�digo del token*/
	char *cadena; 	/*Nombre del token*/
	tDato tipo; 	/*Tipo del token*/
}atributos;

#define YYSTYPE atributos
	/*Fin Declaraci�n*/
	int linea_actual = 1;	 //Almacena la l�nea por la que vamos
	tDato tipoAux; 			 //Almacenamos el tipo para las declaraciones de VARIABLES
	int compruebaParam = 0;  //Comprueba si tenemos que validar los par�metros o no
	int numParametros;		 //N�mero de par�metros para los procedimientos
	int linea_if;			 //L�nea que nos indica la linea de la cabecera del id
	int linea_aux;			 //L�nea actual auxiliar para el if
	int contadorErrores = 0; //Contador de errores
	char cad[250];
	char cad1[250];
	char n_f[250];

	/* Se debe modificar la implementaci�n la funci�n yyerror. En este caso simplemente se escribe el mensaje en pantalla, por lo que habr� que a�adir previamente la declaraci�n de la variable global asociada al n�mero de l�nea (declarada en la pr�ctica anterior en el fichero fuente del flex) y modificar yyerror para que se muestre dicho n�mero de l�nea */
	void yyerror (char *msg){
		char buffer[50];
		sprintf(buffer,"%s %d",msg,linea_actual);
		fprintf(stderr, "\n");
		fprintf(stderr,buffer);
	}

%}

/* A continuaci�n declaramos los nombres simb�licos de los tokens, as� como el s�mbolo inicial de la gram�tica (axioma). Byacc se encarga de asociar a cada uno un c�digo */
%start prog

%token CAB1 CAB2 CASE ID
%token NUM BREAK
%token INT FLOAT CHAR SET TYPEDEF REAL 
%token STRING BOOL TRUE FALSE CARACTER
%token OP_INOUT EMPTY
%token LENGTH VOID SWITCH
%token WHILE INCLUDE DEFINE
%token IF IN OUT DEFAULT ELSE
%token CREATE INSERT MAIN EXTRACT DELETE
%token MINUS UNION INTERSECTION NEG

%token PIZ PDE COMEN ERR IMPRIMIR_TABLA

%token CORI CORD PUNTOS LLIZ LLDE PYC COMA

%left ASI
%left MAYORIQ MENORIQ MAYORQ MENORQ DIST II
%left SUM RES
%left MUL DIV
%left AND OR
%left ADDC MINC COMPC
%left NEGEXP

%%

/* Secci�n de producciones que definen la gram�tica */

prog : dec1 dec2 {
					if(contadorErrores == 0){
						printf("\n\n-------------------------------\n");
						printf(" -- Generacion correcta.\n");
						printf("\n-------------------------------\n\n");
					}else{
						printf("\n\n-------------------------------\n");
						printf("\n-- Se ha encontrado %d errores.\n", contadorErrores);
						printf("\n-------------------------------\n\n");
					}
				 }
| dec2 {
			if(contadorErrores == 0){
				printf("\n\n-------------------------------\n");
				printf(" -- Generacion correcta.\n");
				printf("\n-------------------------------\n\n");
			}else{
				printf("\n\n-------------------------------\n");
				printf("\n--Se ha encontrado %d errores.\n", contadorErrores);
				printf("\n-------------------------------\n\n");
			}
	   }
;
dec1 : incs_s defs_s tipos_s
| defs_s tipos_s 
| incs_s tipos_s
| incs_s defs_s
| incs_s
| defs_s
| tipos_s
;
dec2 : vars_s procs_s main
| vars_s main
| procs_s main
| main
;
incs_s : incs_s incs | incs
;
defs_s : defs_s defs defs 
;
tipos_s : tipos_s tipos | tipos
;
vars_s : vars_s vars | vars
;
procs_s : procs_s proc | proc   
;
incs : INCLUDE cabeceras
;
cabeceras : CAB1 | CAB2
;
defs : DEFINE ID NUM
;
tipos : TYPEDEF tipo ID PYC {	
								if(existeEntradaLocal($3.cadena) == 0){
									pushTS(rellenaEntrada(linea_actual,$3.cadena,$2.tipo,defTipo,0));
								}else{
									printf("\n* Error linea: %d. El identificador \" %s \" de la refinicion de tipo ya existe.\n",linea_actual, $3.cadena);
									$$.tipo = errorTipo;
									contadorErrores++;
								}
							}
;

tipo : INT {$$.tipo = entero;}
| FLOAT {$$.tipo = real;}
| CHAR {$$.tipo = caracter;}
| SET {$$.tipo = conjunto;}
| ID {
		if((tipoAux = existeEntradaDefTipo($1.cadena)) != 0){
		 $$.tipo = tipoAux;
		}else{
			printf("\n* Error linea: %d. Tipo \" %s \" propio no definido.\n",linea_actual, $1.cadena);
			tipoAux = errorTipo;
			$$.tipo = errorTipo;
			contadorErrores++;
		}
	 }
| BOOL {$$.tipo = booleano;}
| STRING {$$.tipo = cadena;}
;

vars : tipo {tipoAux = $1.tipo;} variables PYC 
;

variables : variables COMA variables_s
| variables_s 
;

variables_s : variable
| variable ASI expresion { 				   
						   if(tipoAux != $3.tipo && $3.tipo != errorTipo){
								printf("\n* Error linea: %d. Asignacion de tipo incorrecta en la declaracion de la variable \" %s\". Variable de tipo %s y asignacion de tipo %s.\n",linea_actual, $1.cadena, $1.tipo==1?"entero":$1.tipo==2?"real":$1.tipo==3?"booleano":$1.tipo==4?"caracter":$1.tipo==5?"cadena":"conjunto",$3.tipo==1?"entero":$3.tipo==2?"real":$3.tipo==3?"booleano":$3.tipo==4?"caracter":$3.tipo==5?"cadena":"conjunto");
								$$.tipo = errorTipo;
								contadorErrores++;
						   }
						   
						   if($3.tipo == errorTipo){ //Subimos el error
								$$.tipo = errorTipo;
						   }
						   
						 }
;

variable : ID { if(existeEntradaLocal($1.cadena) == 0){
					pushTS(rellenaEntrada(linea_actual,$1.cadena,tipoAux,var,0));
					$$.tipo = tipoAux;
			    }else{
					printf("\n* Error linea: %d. Identificador \" %s \" declarado anteriormente.\n",linea_actual, $1.cadena);
					$$.tipo = errorTipo;
					contadorErrores++;
				}
			  }
;


proc : VOID ID PIZ{if(existeEntradaLocal($2.cadena) != 0){
						printf("\n* Error linea: %d. Funcion \" %s \" ya declarada.\n",linea_actual, $2.cadena);
						$$.tipo = errorTipo;
						contadorErrores++;
					  }else{
						pushTS(rellenaEntrada(linea_actual,$2.cadena,sinTipo,proc,0));
					  }
				   } params PDE {
									pushTS(rellenaEntrada(linea_actual,"marca",sinTipo,marca,0));
									copiaParametrosFormales();
								} cuerpo {borrarHastaMarcaTS();}
				   
| VOID ID PIZ {if(existeEntradaLocal($2.cadena) != 0){
					printf("\n* Error linea: %d. Funcion \" %s \" ya declarada.",linea_actual, $2.cadena);
					$$.tipo = errorTipo;
					contadorErrores++;
				  }else{
					pushTS(rellenaEntrada(linea_actual,$2.cadena,sinTipo,proc,0));
				  }
			   } PDE {
						pushTS(rellenaEntrada(linea_actual,"marca",sinTipo,marca,0));
						copiaParametrosFormales();
					 }cuerpo {borrarHastaMarcaTS();}
;

params : params COMA tipo ID {
								if(!pushTSParametroFormal(linea_actual, $4.cadena, $3.tipo)){
									printf("\n* Error linea: %d. El parametro formal \" %s \" existente.\n",linea_actual, $4.cadena);
									$$.tipo = errorTipo;
									contadorErrores++;
								}
							 }
| tipo ID {
				if(!pushTSParametroFormal(linea_actual, $2.cadena, $1.tipo)){
					printf("\n* Error linea: %d. Parametro formal \" %s \" existente.\n",linea_actual, $2.cadena);
					$$.tipo  = errorTipo;
					contadorErrores++;
				}
		  }
;

sentencia : switch 
| if 
| while 
| in 
| out 
| proc
| llamada_proc 
| llamada_conjunto PYC 
| expresion PYC
| imprimir_tabla
;

imprimir_tabla: IMPRIMIR_TABLA PYC {imprimirTS();}
;

switch : SWITCH PIZ ID PDE LLIZ casos_s caso_defecto LLDE { if((tipoAux = existeEntradaLocal($3.cadena)) != 0 && tipoAux == $6.tipo){
																$$.tipo = tipoAux;
																	if(tipoAux != entero && tipoAux != caracter){ 
																		printf("\n* Error linea: %d. Expresion en switch es distinto a entero o caracter.\n",linea_actual);
																		contadorErrores++;
																	}
															   }else{
																if((tipoAux = existeEntrada($3.cadena)) != 0 && tipoAux == $6.tipo){
																 $$.tipo = tipoAux;
																	 if(tipoAux != entero && tipoAux != caracter){
																		printf("\n* Error linea: %d. Expresion en switch es distinto a entero o caracter.\n",linea_actual);
																		contadorErrores++;
																	 }
																}else{
																	if(tipoAux == $6.tipo){
																		printf("\n* Error linea: %d. Variable \" %s \" no declarada\n",linea_actual, $3.cadena);
																		contadorErrores++;
																	}else{
																		printf("\n* Error linea: %d. Tipo de los CASES no corresponde con el tipo del SWITCH.\n",linea_actual);
																		contadorErrores++;
																	}
																}
															   }
															  } 
| SWITCH PIZ ID PDE LLIZ caso_defecto LLDE { if((tipoAux = existeEntradaLocal($3.cadena)) != 0){
												$$.tipo = tipoAux;
													if(tipoAux != entero && tipoAux != caracter){ 
														printf("\n* Error linea: %d. Expresion en switch es distinto a entero o caracter.\n",linea_actual);
														contadorErrores++;
													}
											   }else{
												if((tipoAux = existeEntrada($3.cadena)) != 0){
												 $$.tipo = tipoAux;
													 if(tipoAux != entero && tipoAux != caracter){
														printf("\n* Error linea: %d. Expresion en switch es distinto a entero o caracter.\n",linea_actual);
														contadorErrores++;
													 }
												}else{
													printf("\n* Error linea: %d. Variable \" %s \" no declarada.\n",linea_actual, $3.cadena);
													contadorErrores++;
												}
											   }
											  }
| SWITCH PIZ ID PDE LLIZ casos_s LLDE{ 	if((tipoAux = existeEntradaLocal($3.cadena)) != 0 && tipoAux == $6.tipo){
											$$.tipo = tipoAux;
												if(tipoAux != entero && tipoAux != caracter){
													printf("\n* Error linea: %d. Expresion en switch es distinto a entero o caracter.\n",linea_actual);
													contadorErrores++;
												}
										   }else{
											if((tipoAux = existeEntrada($3.cadena)) != 0 && tipoAux == $6.tipo){
											 $$.tipo = tipoAux;
												 if(tipoAux != entero && tipoAux != caracter){
													printf("\n* Error linea: %d. Expresion en switch es distinto a entero o caracter.\n",linea_actual);
													contadorErrores++;
												 }
											}else{
												if(tipoAux == $6.tipo){
													printf("\n* Error linea: %d. Variable \" %s \" no declarada.\n",linea_actual, $3.cadena);
													contadorErrores++;
												}else{
													printf("\n* Error linea: %d. Tipo de los CASES no corresponde con el tipo del SWITCH.\n",linea_actual);
													contadorErrores++;
												}
											}
										   }
										  } 
| SWITCH PIZ ID PDE LLIZ LLDE { if((tipoAux = existeEntradaLocal($3.cadena)) != 0){
									$$.tipo = tipoAux;
									if(tipoAux != entero && tipoAux != caracter){
										printf("\n* Error linea: %d. Expresion en switch es distinto a entero o caracter.\n",linea_actual);
										contadorErrores++;
									}
										
								   }else{
									if((tipoAux = existeEntrada($3.cadena)) != 0){
										 $$.tipo = tipoAux;
										 if(tipoAux != entero && tipoAux != caracter){
											printf("\n* Error linea: %d. Expresion en switch es distinto a entero o caracter",linea_actual);
											contadorErrores++;
										 }
									}else{
										printf("\n* Error linea: %d. Variable \" %s \" no declarada.\n",linea_actual, $3.cadena);
										
									}
								   }
								  }
;

casos_s : casos_s CASE literal PUNTOS sentencias BREAK PYC {	
																if($1.tipo != $3.tipo){ 
																	printf("\n* Error linea: %d. CASEs del Switch con diferente tipo.\n",linea_actual);
																	contadorErrores++;
																}else{
																	$$.tipo = $3.tipo;
																}
														    }
| CASE literal PUNTOS sentencias BREAK PYC {$$.tipo = $2.tipo;}
| casos_s CASE literal PUNTOS BREAK PYC {	if($1.tipo != $3.tipo){
												printf("\n* Error linea: %d. CASEs del Switch con diferente tipo.\n",linea_actual);
												contadorErrores++;
											}else{
												$$.tipo = $3.tipo;
											}
										}
| CASE literal PUNTOS BREAK PYC {$$.tipo = $2.tipo;}
;

literal : NUM {$$.tipo = $1.tipo;} 
| CARACTER {$$.tipo = $1.tipo;}
;

sentencias : sentencias sentencia | sentencia
;

caso_defecto : DEFAULT PUNTOS sentencias | DEFAULT PUNTOS
;

bloque : LLIZ {linea_aux = linea_actual - 1;} sentencias LLDE 
| {linea_aux = linea_actual - 1;} sentencia 
| LLIZ {linea_aux = linea_actual - 1;} LLDE
;


if : IF expresion bloque ELSE {linea_if = linea_aux;} bloque {
																if($2.tipo != booleano && $2.tipo != errorTipo){ 
																	printf("\n* Error linea: %d. Expresion en if no es booleana.\n",linea_if);
																	$$.tipo = errorTipo;
																	contadorErrores++;
																}
																
																if($2.tipo == errorTipo){
																	$$.tipo = errorTipo;
																}
															}
| IF expresion bloque {
							if($2.tipo != booleano && $2.tipo != errorTipo){ 
								printf("\n* Error linea: %d. Expresion en if no es booleana.\n",linea_aux);
								$$.tipo = errorTipo;
								contadorErrores++;
							}
							
							if($2.tipo == errorTipo){
								$$.tipo = errorTipo;
							}
					  }
;


expresion : expresion SUM expresion { 
									  if($1.tipo != errorTipo && $3.tipo != errorTipo){
										  if($1.tipo == $3.tipo && ($1.tipo == entero || $1.tipo == real || $1.tipo == cadena || $1.tipo == conjunto /*UNION*/)){
											$$.tipo = $1.tipo;
										  }else{
											printf("\n* Error en la linea: %d. Expresion con tipos distintos en la operacion suma. %s - %s\n",linea_actual,$1.tipo==1?"entero":$1.tipo==2?"real":$1.tipo==3?"booleano":$1.tipo==4?"caracter":$1.tipo==5?"cadena":"conjunto",$3.tipo==1?"entero":$3.tipo==2?"real":$3.tipo==3?"booleano":$3.tipo==4?"caracter":$3.tipo==5?"cadena":"conjunto");
											$$.tipo = errorTipo;
											contadorErrores++;
										  }
									  }else{
										$$.tipo = errorTipo;
									  }
									}
| expresion RES expresion{ 
							if($1.tipo != errorTipo && $3.tipo != errorTipo){
								if($1.tipo == $3.tipo && ($1.tipo == entero || $1.tipo == real || $1.tipo == conjunto /*DIFERENCIA*/)){
									$$.tipo = $1.tipo;
								  }else{
									printf("\n* Error en la linea: %d. Expresion con tipos distintos en la operacion resta. %s - %s\n",linea_actual,$1.tipo==1?"entero":$1.tipo==2?"real":$1.tipo==3?"booleano":$1.tipo==4?"caracter":$1.tipo==5?"cadena":"conjunto",$3.tipo==1?"entero":$3.tipo==2?"real":$3.tipo==3?"booleano":$3.tipo==4?"caracter":$3.tipo==5?"cadena":"conjunto");
									$$.tipo = errorTipo;
									contadorErrores++;
								  }
							}else{
								$$.tipo = errorTipo;
							}
						 }
| expresion MUL expresion { 
							if($1.tipo != errorTipo && $3.tipo != errorTipo){
								  if($1.tipo == $3.tipo && ($1.tipo == entero || $1.tipo == real)){
									$$.tipo = $1.tipo;
								  }else{
									printf("\n* Error en la linea: %d. Expresion con tipos distintos en la operacion de multiplicacion. %s - %s\n",linea_actual,$1.tipo==1?"entero":$1.tipo==2?"real":$1.tipo==3?"booleano":$1.tipo==4?"caracter":$1.tipo==5?"cadena":"conjunto",$3.tipo==1?"entero":$3.tipo==2?"real":$3.tipo==3?"booleano":$3.tipo==4?"caracter":$3.tipo==5?"cadena":"conjunto");
									$$.tipo = errorTipo;
									contadorErrores++;
								  }
							}else{
								$$.tipo = errorTipo;
							}
						  }
| expresion DIV expresion { 
							if($1.tipo != errorTipo && $3.tipo != errorTipo){
								  if($1.tipo == $3.tipo && ($1.tipo == entero || $1.tipo == real || $1.tipo == conjunto /*INTERSECCION*/)){
									$$.tipo = $1.tipo;
								  }else{
									printf("\n* Error en la linea: %d. Expresion con tipos distintos en la  operacion de dividir. %s - %s\n",linea_actual,$1.tipo==1?"entero":$1.tipo==2?"real":$1.tipo==3?"booleano":$1.tipo==4?"caracter":$1.tipo==5?"cadena":"conjunto",$3.tipo==1?"entero":$3.tipo==2?"real":$3.tipo==3?"booleano":$3.tipo==4?"caracter":$3.tipo==5?"cadena":"conjunto");
									$$.tipo = errorTipo;
									contadorErrores++;
								  }
							  }else{
								$$.tipo = errorTipo;
							  }
							}
| expresion AND expresion 	{ 
							  if($1.tipo != errorTipo && $3.tipo != errorTipo){
								  if($1.tipo == $3.tipo && $1.tipo == booleano){
									$$.tipo = $1.tipo;
								  }else{
									printf("\n* Error en la linea: %d. Expresion con tipos distintos en la operacion booleana AND. %s - %s\n",linea_actual,$1.tipo==1?"entero":$1.tipo==2?"real":$1.tipo==3?"booleano":$1.tipo==4?"caracter":$1.tipo==5?"cadena":"conjunto",$3.tipo==1?"entero":$3.tipo==2?"real":$3.tipo==3?"booleano":$3.tipo==4?"caracter":$3.tipo==5?"cadena":"conjunto");
									$$.tipo = errorTipo;
									contadorErrores++;
								  }
							  }else{
								$$.tipo = errorTipo;
							  }
							}
| expresion OR expresion 	{ 
							   if($1.tipo != errorTipo && $3.tipo != errorTipo){
								   if($1.tipo == $3.tipo && $1.tipo == booleano){
										$$.tipo = $1.tipo;
								   }else{
										printf("\n* Error en la linea: %d. Expresion con tipos distintos en la operacion booleana OR. %s - %s\n",linea_actual,$1.tipo==1?"entero":$1.tipo==2?"real":$1.tipo==3?"booleano":$1.tipo==4?"caracter":$1.tipo==5?"cadena":"conjunto",$3.tipo==1?"entero":$3.tipo==2?"real":$3.tipo==3?"booleano":$3.tipo==4?"caracter":$3.tipo==5?"cadena":"conjunto");
										$$.tipo = errorTipo;
										contadorErrores++;
								   }
							   }else{
									$$.tipo = errorTipo;
							   }
							}
| expresion MAYORIQ expresion 	{ 
								  if($1.tipo != errorTipo && $3.tipo != errorTipo){
									  if($1.tipo == $3.tipo && ($1.tipo == entero || $1.tipo == real)){
										$$.tipo = booleano;
									  }else{
										printf("\n* Error en la linea: %d. Expresion con tipos distintos en la comparacion. %s - %s\n",linea_actual,$1.tipo==1?"entero":$1.tipo==2?"real":$1.tipo==3?"booleano":$1.tipo==4?"caracter":$1.tipo==5?"cadena":"conjunto",$3.tipo==1?"entero":$3.tipo==2?"real":$3.tipo==3?"booleano":$3.tipo==4?"caracter":$3.tipo==5?"cadena":"conjunto");
										$$.tipo = errorTipo;
										contadorErrores++;
									  }
								   }else{
										$$.tipo = errorTipo;
								   }
								}
| expresion MENORIQ expresion 	{ 
								  if($1.tipo != errorTipo && $3.tipo != errorTipo){
									  if($1.tipo == $3.tipo && ($1.tipo == entero || $1.tipo == real)){
										$$.tipo = booleano;
									  }else{
										printf("\n* Error en la linea: %d. Expresion con tipos distintos en la comparacion. %s - %s\n",linea_actual,$1.tipo==1?"entero":$1.tipo==2?"real":$1.tipo==3?"booleano":$1.tipo==4?"caracter":$1.tipo==5?"cadena":"conjunto",$3.tipo==1?"entero":$3.tipo==2?"real":$3.tipo==3?"booleano":$3.tipo==4?"caracter":$3.tipo==5?"cadena":"conjunto");
										$$.tipo = errorTipo;
										contadorErrores++;
									  }
								   }else{
										$$.tipo = errorTipo;
								   }
								}
| expresion MAYORQ expresion	{ 
								  if($1.tipo != errorTipo && $3.tipo != errorTipo){
									  if($1.tipo == $3.tipo && ($1.tipo == entero || $1.tipo == real)){
										$$.tipo = booleano;
									  }else{
										printf("\n* Error en la linea: %d. Expresion con tipos distintos en la comparacion. %s - %s\n",linea_actual,$1.tipo==1?"entero":$1.tipo==2?"real":$1.tipo==3?"booleano":$1.tipo==4?"caracter":$1.tipo==5?"cadena":"conjunto",$3.tipo==1?"entero":$3.tipo==2?"real":$3.tipo==3?"booleano":$3.tipo==4?"caracter":$3.tipo==5?"cadena":"conjunto");
										$$.tipo = errorTipo;
										contadorErrores++;
									  }
								  }else{
									$$.tipo = errorTipo;
								  }
								}
| expresion MENORQ expresion	{ 
								  if($1.tipo != errorTipo && $3.tipo != errorTipo){
									  if($1.tipo == $3.tipo && ($1.tipo == entero || $1.tipo == real)){
										$$.tipo = booleano;
									  }else{
										printf("\n* Error en la linea: %d. Expresion con tipos distintos en la comparacion. %s - %s\n",linea_actual,$1.tipo==1?"entero":$1.tipo==2?"real":$1.tipo==3?"booleano":$1.tipo==4?"caracter":$1.tipo==5?"cadena":"conjunto",$3.tipo==1?"entero":$3.tipo==2?"real":$3.tipo==3?"booleano":$3.tipo==4?"caracter":$3.tipo==5?"cadena":"conjunto");
										$$.tipo = errorTipo;
										contadorErrores++;
									  }
								  }else{
									$$.tipo = errorTipo;
								  }
								}
| expresion DIST expresion 	{ 
							  if($1.tipo != errorTipo && $3.tipo != errorTipo){
								  if($1.tipo == $3.tipo && ($1.tipo == entero || $1.tipo == real || $1.tipo == booleano)){
									$$.tipo = booleano;
								  }else{
									printf("\n* Error en la linea: %d. Expresion con tipos distintos en la comparacion. %s - %s\n",linea_actual,$1.tipo==1?"entero":$1.tipo==2?"real":$1.tipo==3?"booleano":$1.tipo==4?"caracter":$1.tipo==5?"cadena":"conjunto",$3.tipo==1?"entero":$3.tipo==2?"real":$3.tipo==3?"booleano":$3.tipo==4?"caracter":$3.tipo==5?"cadena":"conjunto");
									$$.tipo = errorTipo;
									contadorErrores++;
								  }
							  }else{
									$$.tipo = errorTipo;
							  }
							}
| expresion II expresion 	{ 
							  if($1.tipo != errorTipo && $3.tipo != errorTipo){
								  if($1.tipo == $3.tipo && ($1.tipo == entero || $1.tipo == real || $1.tipo == booleano)){
									$$.tipo = booleano;
								  }else{
									printf("\n* Error en la linea: %d. Expresion con tipos distintos en la comparacion. %s - %s\n",linea_actual,$1.tipo==1?"entero":$1.tipo==2?"real":$1.tipo==3?"booleano":$1.tipo==4?"caracter":$1.tipo==5?"cadena":"conjunto",$3.tipo==1?"entero":$3.tipo==2?"real":$3.tipo==3?"booleano":$3.tipo==4?"caracter":$3.tipo==5?"cadena":"conjunto");
									$$.tipo = errorTipo;
									contadorErrores++;
								  }
							  }else{
									$$.tipo = errorTipo;
							  }
							}
| NUM
| PIZ expresion PDE {$$.tipo = $2.tipo;}
| NEGEXP expresion	{ 
					   if($2.tipo != errorTipo){
						   if($2.tipo == booleano){
								$$.tipo = booleano;
						   }else{
								printf("\n* Error linea: %d. Expresion con tipos distintos en el operador booleano de negacion. %s - %s\n",linea_actual,$2.tipo==1?"entero":$2.tipo==2?"real":$2.tipo==3?"booleano":$2.tipo==4?"caracter":$2.tipo==5?"cadena":"conjunto");
								$$.tipo = errorTipo;
								contadorErrores++;
						   }
					    }else{
							$$.tipo = errorTipo;
						}
					}
| ID { 
	   if($1.tipo != errorTipo){
		   if((tipoAux = existeEntradaLocal($1.cadena)) != 0){
			$$.tipo = tipoAux;
		   }else{
			if((tipoAux = existeEntrada($1.cadena)) != 0){
				$$.tipo = tipoAux;
			}else{
				printf("\n* Error linea: %d. La variable \" %s \" no declarada.\n",linea_actual,$1.cadena);
				$$.tipo = errorTipo;
				contadorErrores++;
			}
		   }
	   }else{
		 $$.tipo = errorTipo;
	   }
     }
| REAL
| TRUE
| FALSE
| CARACTER
| STRING
| crea_conjunto {$$.tipo = $1.tipo;}
| llamada_complementario 
| llamada_sivacio {$$.tipo = $1.tipo;}
| llamada_length {$$.tipo = $1.tipo;}
| ID ASI expresion { 
						 
						 if((tipoAux = existeEntradaLocal($1.cadena)) != 0){
							$$.tipo = tipoAux;
						   }else{
							if((tipoAux = existeEntrada($1.cadena)) != 0){
							 $$.tipo = tipoAux;
							}else{
								printf("\n* Error linea: %d. Variable \" %s \" no declarada.\n",linea_actual,$1.cadena);
								$$.tipo = errorTipo;
								contadorErrores++;
							}
						 }
							 
						if($3.tipo != errorTipo){
							   if(tipoAux != $3.tipo && tipoAux != errorTipo){
									printf("\n* Error linea: %d. Asignacion de tipo incorrecto. ID con tipo %s y asignacion con tipo %s\n",linea_actual,$1.tipo==1?"entero":$1.tipo==2?"real":$1.tipo==3?"booleano":$1.tipo==4?"caracter":$1.tipo==5?"cadena":"conjunto",$3.tipo==1?"entero":$3.tipo==2?"real":$3.tipo==3?"booleano":$3.tipo==4?"caracter":$3.tipo==5?"cadena":"conjunto");
									$$.tipo = errorTipo;
									contadorErrores++;
							   }
							   
							   if(tipoAux == errorTipo){
								 $$.tipo = errorTipo;
							   }
						 }else{
							$$.tipo = errorTipo;
						 }
					}
;

while : WHILE PIZ expresion PDE bloque { 
											if($3.tipo != booleano && $3.tipo != errorTipo){ 
												printf("\n* Error linea: %d. Expresion en while no es booleana.\n",linea_actual);
												$$.tipo = errorTipo;
												contadorErrores++;
											}
											
											if($3.tipo == errorTipo){
												$$.tipo = errorTipo;
											}
									   }
| WHILE PIZ expresion PDE PYC {
								if($3.tipo != booleano && $3.tipo != errorTipo){
									printf("\n* Error linea: %d. Expresion en while no es booleana.\n",linea_actual);
									$$.tipo = errorTipo;
									contadorErrores++;
								}
								
								if($3.tipo == errorTipo){
									$$.tipo = errorTipo;
								}
							  }
;

out : OUT PIZ STRING COMA ids PDE PYC
| OUT PIZ STRING PDE PYC
;

ids : ids COMA ID | ID
;

in : IN PIZ OP_INOUT COMA ID PDE PYC
;

llamada_proc : ID PIZ {  if((compruebaParam = existeEntrada($1.cadena)) != sinTipo){
							printf("\n* Error linea: %d. Llamada a procedimiento no declarada con anterioridad.\n",linea_actual);
							$$.tipo = errorTipo;
							contadorErrores++;
						 }
						 
					  } params_llamada {	
											if(compruebaParam != 0){
												if(compruebaNumeroParametros($1.cadena, numParametros) == 0){ //Error en tipo
													printf("\n* Error linea: %d. El numero de parametros no coindicen en la llamada al procedimiento.\n", linea_actual);
													$$.tipo = errorTipo;
													contadorErrores++;
												}
											}else{
												$$.tipo = errorTipo;
											}
									   }  PDE PYC

| ID PIZ PDE PYC { if(existeEntrada($1.cadena) != sinTipo){
					  printf("\n* Error linea: %d. Llamada a procedimiento \" %s \" no declarada con anterioridad.\n",linea_actual, $1.cadena);
					  $$.tipo = errorTipo;
					  contadorErrores++;
				   }
				 }
;

params_llamada : params_llamada COMA expresion { 	
													if($3.tipo != errorTipo && compruebaParam != 0){
														numParametros++;
														if(compruebaParametroProcedimiento($-1.cadena, $3.tipo, numParametros) == 0){
															printf("\n* Error linea: %d. Parametro del procedimiento no coinciden en tipo.\n", linea_actual);
															$$.tipo = errorTipo;
															contadorErrores++;
														}
														
														if(compruebaParametroProcedimiento($-1.cadena, $3.tipo, numParametros) == 2){
															printf("\n* Error linea: %d. Numero de parametros excedido en la llamada a procedimiento.\n", linea_actual);
															$$.tipo = errorTipo;
															contadorErrores++;
														}
													}else{
														$$.tipo = errorTipo;
													}
												}
| expresion {	
				if($1.tipo != errorTipo && compruebaParam != 0){
					numParametros = 1;
					if(compruebaParametroProcedimiento($-1.cadena, $1.tipo, numParametros) == 0){
						printf("\n* Error linea: %d. Parametro del procedimiento no coinciden en tipo.\n", linea_actual);
						$$.tipo = errorTipo;
						contadorErrores++;
					}
				}else{
					$$.tipo = errorTipo;
				}
			}
;

main : VOID MAIN {
					pushTS(rellenaEntrada(linea_actual,"marca",sinTipo,marca,0));
				 }  PIZ PDE cuerpo {borrarHastaMarcaTS();}
;

cuerpo : LLIZ vars_s sentencias LLDE
| LLIZ sentencias LLDE
| LLIZ vars_s LLDE
| LLIZ LLDE
;

llamada_conjunto : inserta_conjunto
| saca_conjunto 
| destruye_conjunto
;

crea_conjunto : CREATE PIZ PDE {
									$$.tipo = conjunto;
							   }
;
destruye_conjunto : DELETE PIZ ID PDE { 
										if($3.tipo != errorTipo){
											if( existeEntradaLocal($3.cadena) != conjunto && existeEntrada($3.cadena) != conjunto){
												printf("\n* Error linea: %d. Identificador \" %s \" no declarado.\n",linea_actual, $3.cadena);
												contadorErrores++;
											}
										}
									  }
;
llamada_sivacio : EMPTY PIZ ID PDE {  	
										if($3.tipo != errorTipo){
											if( (tipoAux = existeEntradaLocal($3.cadena)) != conjunto && (tipoAux = existeEntrada($3.cadena)) != conjunto){
												if(tipoAux == 0){
													printf("\n* Error linea. %d. Identificador \" %s \" no declarado",linea_actual, $3.cadena);
												}else{
													printf("\n* Error linea. %d. El identificador \" %s \" no es de tipo SET (conjunto).\n",linea_actual, $3.cadena);
												}
												$$.tipo = errorTipo;
												contadorErrores++;
											}else{
												$$.tipo = booleano;
											}
										}else{
											$$.tipo = errorTipo;
										}
								   }
;

llamada_length : LENGTH PIZ ID PDE{
									if($3.tipo != errorTipo){
										if( (tipoAux = existeEntradaLocal($3.cadena)) != conjunto && (tipoAux = existeEntrada($3.cadena)) != conjunto){
											if(tipoAux == 0){
												printf("\n* Error linea. %d. Identificador \" %s \" no declarado.\n",linea_actual, $3.cadena);
											}else{
												printf("\n* Error linea. %d. El identificador \" %s \" no es de tipo SET (conjunto).\n",linea_actual, $3.cadena);
											}
											$$.tipo = errorTipo;
											contadorErrores++;
										}else{
											$$.tipo = entero;
										}
									}else{
										$$.tipo = errorTipo;
									}
								  }
;

inserta_conjunto : ID ADDC expresion {
										if($1.tipo != errorTipo && $3.tipo != errorTipo){
											if( (tipoAux = existeEntradaLocal($1.cadena)) != conjunto && (tipoAux = existeEntrada($1.cadena)) != conjunto){
												if(tipoAux == 0){
													printf("\n* Error linea: %d. Identificador \" %s \" no declarado.\n",linea_actual, $1.cadena);
												}else{
													printf("\n* Error linea. %d. El identificador \" %s \" no es de tipo SET (conjunto).\n",linea_actual, $1.cadena);
												}
												$$.tipo = errorTipo;
												contadorErrores++;
											}
										}else{
											$$.tipo = errorTipo;
										}
									 }
;

saca_conjunto : ID MINC expresion{
									if($1.tipo != errorTipo && $3.tipo != errorTipo){
										if( (tipoAux = existeEntradaLocal($1.cadena)) != conjunto && (tipoAux = existeEntrada($1.cadena)) != conjunto){
											if(tipoAux == 0){
												printf("\n* Error linea: %d. Identificador \" %s \" no declarado",linea_actual, $1.cadena);
											}else{
												printf("\n* Error linea. %d. El identificador \" %s \" no es de tipo SET (conjunto).\n",linea_actual, $1.cadena);
											}
											$$.tipo = errorTipo;
											contadorErrores++;
										}
									}else{
										$$.tipo = errorTipo;
									}
								 }
;


llamada_complementario : COMPC ID {
									if($2.tipo != errorTipo){
										if( (tipoAux = existeEntradaLocal($2.cadena)) != conjunto && (tipoAux = existeEntrada($2.cadena)) != conjunto){
											if(tipoAux == 0){
												printf("\n* Error linea: %d. Identificador \" %s \" no declarado",linea_actual, $2.cadena);
											}else{
												printf("\n* Error linea. %d. El identificador \" %s \" no es de tipo SET (conjunto).\n",linea_actual, $2.cadena);
											}
											$$.tipo = errorTipo;
											contadorErrores++;
										}else{
											$$.tipo = conjunto;
										}
									}else{
										$$.tipo = errorTipo;
									}
								  }
;

%%
/* Aqu� incluimos el fichero generado por el Flex, que implementa la funci�n yylex() */
#include "lexyy.c"

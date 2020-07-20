PROCEDURE P_GENERA_REPORTE_EXCEL IS 

  lf_arch            CLIENT_TEXT_IO.FILE_TYPE;
  vRutaReportes      VARCHAR2(500);
  
	lv_Line            VARCHAR2(32767) := Null;
	lv_Line_01         VARCHAR2(32767) := Null;
	lv_Line_02         VARCHAR2(32767) := Null;
	
  lv_LineaDato       VARCHAR2(32767) := Null;
  
  lv_flag            NUMBER := 0;
	vAlerta            PLS_INTEGER;
	lnombrearchivo     VARCHAR2(500);
	lnombrearchivoxls  VARCHAR2(500); 
	lv_ruta_serv       VARCHAR2(200):= RTRIM(LTRIM(BD_Syst900(50, 12, 1))); --Ruta carpeta compartida para la generación de archivos excel.
	l_success          BOOLEAN;
	  
  cNombArch          VARCHAR2(100):= RTRIM(LTRIM(:REPORTE.NOMARCHIVO))||'_'||
                                     TO_CHAR(SYSDATE,'YYYYMMDD')||'_'||
                                     TO_CHAR(SYSDATE,'HH24MISS');
  
  nContador NUMBER:=0;
  
  nCantCamposRep    NUMBER:=PKG_REPORTE.FUN_CANT_CAMPOS(:REPORTE.CODREPORTE); 
  nTipDatoCol       COLUMNA_REPORTE.TIPDATO%TYPE;
  cFecSinDatos      VARCHAR2(50):=' <Cell ss:StyleID="s67"/>  ';
  
  Function fun_conv_caracter( 
    pv_cadena Varchar2 
    ) Return Varchar2 
  is
    lv_conver Varchar2(256);
  Begin
    ----
    lv_conver := replace(replace(replace(replace(replace(pv_cadena,chr(193),'&Aacute;'),chr(201),'&Eacute;'),chr(205),'&Iacute;'),chr(211),'&Oacute;'),chr(218),'&Uacute;');
    lv_conver := replace(replace(replace(replace(replace(pv_cadena,chr(225),'&aacute;'),chr(233),'&eacute;'),chr(237),'&iacute;'),chr(243),'&oacute;'),chr(250),'&uacute;');
    ----
    Return(lv_conver);
    ----
  End;
   
BEGIN

  Set_application_property(cursor_style,'busy');
  vRutaReportes := ADM08010.CARPETATEMPFISICA;
  lf_arch := Client_Text_IO.FOPEN(RTRIM(LTRIM(lv_ruta_serv))||RTRIM(LTRIM(cNombArch))||'.xml','W');
      
  lnombrearchivo:=RTRIM(LTRIM(lv_ruta_serv))||RTRIM(LTRIM(cNombArch));
  lnombrearchivoxls:=RTRIM(LTRIM(lv_ruta_serv))||RTRIM(LTRIM(cNombArch));
    
  P_ENC_REPORTE(lv_line,lv_Line_01);
  Client_Text_IO.Put_Line(lf_arch,lv_line);
  Client_Text_IO.Put_Line(lf_arch,lv_Line_01);

  
  FOR X IN (SELECT * FROM TMP_REPORTENUEVO) LOOP  
		 	nContador:= nContador+1;
	    lv_LineaDato:=NULL;
    
      IF 1 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,1);
	       IF nTipDatoCol = 1 THEN 
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO1))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO1))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =3 THEN   
			      	 IF X.CAMPO1 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO1,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF; 	
	      	END IF;
      END IF; 
      IF 2 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,2);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO2))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO2))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN   
			         IF X.CAMPO2 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO2,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF; 
         END IF;	
      END IF; 
      IF 3 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,3);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO3))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO3))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN 
		           IF X.CAMPO3 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO3,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      		 END IF; 
         END IF;	
      END IF;
      IF 4 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,4); 
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO4))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO4))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN   
			         IF X.CAMPO4 IS NOT NULL THEN        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO4,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;       		
         END IF;	
      END IF; 
      IF 5 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,5);
         IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO5))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO5))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       	
			         IF X.CAMPO5 IS NOT NULL THEN        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO5,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;       		
         END IF;	
      END IF; 
      IF 6 <= nCantCamposRep THEN  
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,6);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO6))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO6))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       		
			         IF X.CAMPO6 IS NOT NULL THEN        	        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO6,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;   
         END IF;	
      END IF; 
      IF 7 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,7);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO7))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO7))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN     
		        	 IF X.CAMPO7 IS NOT NULL THEN         	
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO7,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;  
         END IF;	
      END IF; 
      IF 8 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,8);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO8))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO8))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN  
			         IF X.CAMPO8 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO8,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;  
         END IF;
      END IF; 
      IF 9 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,9);  
      	 IF nTipDatoCol = 1 THEN  
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO9))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =2 THEN 
      	  	   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO9))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =3 THEN     
			         IF X.CAMPO9 IS NOT NULL THEN         	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO9,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;  
         END IF;
      END IF; 
      IF 10 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,10);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO10))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO10))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       		
		        	 IF X.CAMPO10 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO10,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
		      	   ELSE 
		      		     lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;  
      	 END IF;        
      END IF; 
      IF 11 <= nCantCamposRep THEN 
         nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,11);
         IF nTipDatoCol = 1 THEN       	      	      	
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO11))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      	       lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO11))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO11 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO11,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;  
         END IF;        
      END IF; 
      IF 12 <= nCantCamposRep THEN 
         nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,12);
         IF nTipDatoCol = 1 THEN       	      	      	      	
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO12))||'</Data></Cell> '||chr(10);          
         ELSIF nTipDatoCol =2 THEN 
      	     	 lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO12))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN  
			         IF X.CAMPO12 IS NOT NULL THEN         	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO12,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
         END IF; 
      END IF; 
      IF 13 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,13); 
	       IF nTipDatoCol = 1 THEN 
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO13))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =2 THEN  
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO13))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN  
			         IF X.CAMPO13 IS NOT NULL THEN         	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO13,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;        
      END IF; 
      IF 14 <= nCantCamposRep THEN  
         nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,14); 
         IF nTipDatoCol = 1 THEN       	
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO14))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN  
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO14))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =3 THEN  
		        	IF X.CAMPO14 IS NOT NULL THEN         	
		             lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO14,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
		      	  ELSE 
		      			  lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	  END IF;
         END IF;        
      END IF; 
      IF 15 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,15); 
	       IF nTipDatoCol = 1 THEN       	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO15))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO15))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN          	
	        	IF X.CAMPO15 IS NOT NULL THEN         	
	             lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO15,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
	      	  ELSE 
	      			  lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
	      	  END IF;
	       END IF;        
      END IF; 
      IF 16 <= nCantCamposRep THEN  
         nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,16); 
         IF nTipDatoCol = 1 THEN       	      	
      	    lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO16))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO16))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =3 THEN          	    
		        	 IF X.CAMPO16 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO16,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
		      	   ELSE 
		      		     lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;
         END IF;        
      END IF; 
      IF 17 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,17); 
	       IF nTipDatoCol = 1 THEN       	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO17))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO17))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
		        	 IF X.CAMPO17 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO17,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;
	       END IF;        
      END IF; 
      IF 18 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,18); 
	       IF nTipDatoCol = 1 THEN       	      	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO18))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO18))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN      
			         IF X.CAMPO18 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO18,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;                
      END IF; 
      IF 19 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,19); 
	       IF nTipDatoCol = 1 THEN       	      	      	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO19))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO19))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
		        	 IF X.CAMPO19 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO19,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;
	       END IF;                
      END IF; 
      IF 20 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,20); 
	       IF nTipDatoCol = 1 THEN       	      	      	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO20))||'</Data></Cell>  '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO20))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO20 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO20,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;                
      END IF; 
      IF 21 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,21); 
	       IF nTipDatoCol = 1 THEN       	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO21))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      	     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO21))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO21 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO21,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;                
      END IF; 
      IF 22 <= nCantCamposRep THEN 
         nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,22); 
         IF nTipDatoCol = 1 THEN       	      	
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO22))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO22))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =3 THEN       
			         IF X.CAMPO22 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO22,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
         END IF;                
      END IF; 
      IF 23 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,23);        
	       IF nTipDatoCol = 1 THEN 
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO23))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =2 THEN  
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO23))||'</Data></Cell> '||chr(10);  
	       ELSIF nTipDatoCol =3 THEN      
			         IF X.CAMPO23 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO23,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 24 <= nCantCamposRep THEN  
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,24);        
	       IF nTipDatoCol = 1 THEN       	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO24))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =2 THEN  
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO24))||'</Data></Cell> '||chr(10);  
	       ELSIF nTipDatoCol =3 THEN      
			         IF X.CAMPO24 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO24,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 25 <= nCantCamposRep THEN  
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,25);        
	       IF nTipDatoCol = 1 THEN       	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO25))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =2 THEN  
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO25))||'</Data></Cell> '||chr(10);  
	       ELSIF nTipDatoCol =3 THEN      
			         IF X.CAMPO25 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO25,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 26 <= nCantCamposRep THEN 
         nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,26);
         IF nTipDatoCol = 1 THEN       	      	      	
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO26))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =2 THEN  
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO26))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =3 THEN 
		        	 IF X.CAMPO26 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO26,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;
         END IF;
      END IF; 
      IF 27 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,27); 
	       IF nTipDatoCol = 1 THEN 
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO27))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO27))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO27 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO27,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 28 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,28); 
	       IF nTipDatoCol = 1 THEN       	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO28))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      	   	 lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO28))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO28 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO28,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      	  	 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF; 
	       END IF;
      END IF; 
      IF 29 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,29); 
	       IF nTipDatoCol = 1 THEN       	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO29))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO29))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO29 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO29,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF; 
	       END IF;
      END IF; 
      IF 30 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,30); 
	       IF nTipDatoCol = 1 THEN       	      	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO30))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO30))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
		        	 IF X.CAMPO30 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO30,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF; 
	       END IF;
      END IF; 
      IF 31 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,31); 
	       IF nTipDatoCol = 1 THEN       	      	      	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO31))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO31))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
		        	 IF X.CAMPO31 IS NOT NULL THEN         		
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO31,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF; 
	       END IF;
      END IF;  
      IF 32 <= nCantCamposRep THEN  
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,32); 
	       IF nTipDatoCol = 1 THEN       	      	      	      	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO32))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO32))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO32 IS NOT NULL THEN         		
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO32,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF;  
      IF 33 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,33); 
	       IF nTipDatoCol = 1 THEN       	      	      	      	      	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO33))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO33))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
		        	 IF X.CAMPO33 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO33,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;
	       END IF;
      END IF; 
      IF 34 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,34);
	       IF nTipDatoCol = 1 THEN   	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO34))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO34))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO34 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO34,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 35 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,35);        
	       IF nTipDatoCol = 1 THEN   	      	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO35))||'</Data></Cell> '||chr(10);          
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO35))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO35 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO35,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 36 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,36);        
	       IF nTipDatoCol = 1 THEN   	      	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO36))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO36))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
		        	 IF X.CAMPO36 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO36,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;
	       END IF;
      END IF; 
      IF 37 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,37);        
	       IF nTipDatoCol = 1 THEN   	      	      	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO37))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO37))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO37 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO37,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF;
      IF 38 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,38); 
	       IF nTipDatoCol = 1 THEN     	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO38))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO38))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO38 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO38,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 39 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,39); 
	       IF nTipDatoCol = 1 THEN     	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO39))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO39))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO39 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO39,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 40 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,40); 
	       IF nTipDatoCol = 1 THEN 
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO40))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO40))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO40 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO40,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 41 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,41); 
	       IF nTipDatoCol = 1 THEN 
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO41))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	       		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO41))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO41 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO41,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 42 <= nCantCamposRep THEN  
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,42); 
	       IF nTipDatoCol = 1 THEN 	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO42))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO42))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO42 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO42,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 43 <= nCantCamposRep THEN  
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,43); 
	       IF nTipDatoCol = 1 THEN 	      
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO43))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO43))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO43 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO43,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 44 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,44); 
	       IF nTipDatoCol = 1 THEN 
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO44))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO44))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO44 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO44,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 45 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,45); 
	       IF nTipDatoCol = 1 THEN 
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO45))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO45))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO45 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO45,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 46 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,46); 
	       IF nTipDatoCol = 1 THEN       	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO46))||'</Data></Cell> '||chr(10); 
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO46))||'</Data></Cell> '||chr(10);  
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO46 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO46,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 47 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,47); 
	       IF nTipDatoCol = 1 THEN       	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO47))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO47))||'</Data></Cell> '||chr(10);  
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO47 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO47,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 48 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,48); 
	       IF nTipDatoCol = 1 THEN       	      	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO48))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO48))||'</Data></Cell> '||chr(10);  
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO48 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO48,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 49 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,49); 
	       IF nTipDatoCol = 1 THEN       	      	      	      	
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO49))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO49))||'</Data></Cell> '||chr(10);  
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO49 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO49,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF; 
      IF 50 <= nCantCamposRep THEN 
	       nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,50); 
	       IF nTipDatoCol = 1 THEN 
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO50))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO50))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =3 THEN 
			         IF X.CAMPO50 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO50,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;
	       END IF;
      END IF;
     -----
     
      IF 51 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,51);
	       IF nTipDatoCol = 1 THEN 
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO51))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO51))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =3 THEN   
			      	 IF X.CAMPO51 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO51,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF; 	
	      	END IF;
      END IF; 
      IF 52 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,52);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO52))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO52))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN   
			         IF X.CAMPO52 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO52,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF; 
         END IF;	
      END IF; 
      IF 53 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,53);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO53))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO53))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN 
		           IF X.CAMPO53 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO53,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      		 END IF; 
         END IF;	
      END IF;
      IF 54 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,54); 
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO54))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO54))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN   
			         IF X.CAMPO54 IS NOT NULL THEN        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO54,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;       		
         END IF;	
      END IF; 
      IF 55 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,55);
         IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO55))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO55))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       	
			         IF X.CAMPO55 IS NOT NULL THEN        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO55,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;       		
         END IF;	
      END IF; 
      IF 56 <= nCantCamposRep THEN  
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,56);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO56))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO56))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       		
			         IF X.CAMPO56 IS NOT NULL THEN        	        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO56,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;   
         END IF;	
      END IF; 
      IF 57 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,57);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO57))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO57))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN     
		        	 IF X.CAMPO57 IS NOT NULL THEN         	
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO57,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;  
         END IF;	
      END IF; 
      IF 58 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,58);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO58))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO58))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN  
			         IF X.CAMPO58 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO58,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;  
         END IF;
      END IF; 
      IF 59 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,59);  
      	 IF nTipDatoCol = 1 THEN  
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO59))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =2 THEN 
      	  	   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO59))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =3 THEN     
			         IF X.CAMPO59 IS NOT NULL THEN         	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO59,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;  
         END IF;
      END IF; 
      
      IF 60 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,60);  
      	 IF nTipDatoCol = 1 THEN  
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO60))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =2 THEN 
      	  	   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO60))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =3 THEN     
			         IF X.CAMPO60 IS NOT NULL THEN         	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO60,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;  
         END IF;
      END IF; 
      
      IF 61 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,61);
	       IF nTipDatoCol = 1 THEN 
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO61))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO61))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =3 THEN   
			      	 IF X.CAMPO61 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO61,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF; 	
	      	END IF;
      END IF; 
      IF 62 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,62);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO62))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO62))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN   
			         IF X.CAMPO62 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO62,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF; 
         END IF;	
      END IF; 
      IF 63 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,63);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO63))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO63))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN 
		           IF X.CAMPO63 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO63,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      		 END IF; 
         END IF;	
      END IF;
      IF 64 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,64); 
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO64))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO64))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN   
			         IF X.CAMPO64 IS NOT NULL THEN        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO64,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;       		
         END IF;	
      END IF; 
      IF 65 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,65);
         IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO65))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO65))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       	
			         IF X.CAMPO65 IS NOT NULL THEN        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO65,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;       		
         END IF;	
      END IF; 
      IF 66 <= nCantCamposRep THEN  
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,66);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO66))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO66))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       		
			         IF X.CAMPO66 IS NOT NULL THEN        	        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO66,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;   
         END IF;	
      END IF; 
      IF 67 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,67);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO67))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO67))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN     
		        	 IF X.CAMPO67 IS NOT NULL THEN         	
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO67,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;  
         END IF;	
      END IF; 
      IF 68 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,68);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO68))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO68))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN  
			         IF X.CAMPO68 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO68,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;  
         END IF;
      END IF; 
      IF 69 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,69);  
      	 IF nTipDatoCol = 1 THEN  
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO69))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =2 THEN 
      	  	   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO69))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =3 THEN     
			         IF X.CAMPO69 IS NOT NULL THEN         	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO69,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;  
         END IF;
      END IF; 
      IF 70 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,70);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO70))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO70))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       		
		        	 IF X.CAMPO70 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO70,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
		      	   ELSE 
		      		     lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;  
      	 END IF;        
      END IF; 
      --
      IF 71 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,71);
	       IF nTipDatoCol = 1 THEN 
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO71))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO71))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =3 THEN   
			      	 IF X.CAMPO71 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO71,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF; 	
	      	END IF;
      END IF; 
      IF 72 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,72);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO72))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO72))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN   
			         IF X.CAMPO72 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO72,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF; 
         END IF;	
      END IF; 
      IF 73 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,73);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO73))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO73))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN 
		           IF X.CAMPO73 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO73,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      		 END IF; 
         END IF;	
      END IF;
      IF 74 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,74); 
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO74))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO74))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN   
			         IF X.CAMPO74 IS NOT NULL THEN        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO74,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;       		
         END IF;	
      END IF; 
      IF 75 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,75);
         IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO75))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO75))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       	
			         IF X.CAMPO75 IS NOT NULL THEN        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO75,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;       		
         END IF;	
      END IF; 
      IF 76 <= nCantCamposRep THEN  
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,76);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO76))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO76))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       		
			         IF X.CAMPO76 IS NOT NULL THEN        	        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO76,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;   
         END IF;	
      END IF; 
      IF 77 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,77);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO77))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO77))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN     
		        	 IF X.CAMPO77 IS NOT NULL THEN         	
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO77,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;  
         END IF;	
      END IF; 
      IF 78 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,78);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO78))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO78))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN  
			         IF X.CAMPO78 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO78,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;  
         END IF;
      END IF; 
      IF 79 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,79);  
      	 IF nTipDatoCol = 1 THEN  
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO79))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =2 THEN 
      	  	   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO79))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =3 THEN     
			         IF X.CAMPO79 IS NOT NULL THEN         	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO79,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;  
         END IF;
      END IF; 
      IF 80 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,10);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO80))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO80))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       		
		        	 IF X.CAMPO10 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO80,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
		      	   ELSE 
		      		     lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;  
      	 END IF;        
      END IF; 
      --
      IF 81 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,81);
	       IF nTipDatoCol = 1 THEN 
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO81))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO81))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =3 THEN   
			      	 IF X.CAMPO81 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO81,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF; 	
	      	END IF;
      END IF; 
      IF 82 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,82);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO82))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO82))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN   
			         IF X.CAMPO82 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO82,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF; 
         END IF;	
      END IF; 
      IF 83 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,83);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO83))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO83))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN 
		           IF X.CAMPO83 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO83,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      		 END IF; 
         END IF;	
      END IF;
      IF 84 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,84); 
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO84))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO84))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN   
			         IF X.CAMPO84 IS NOT NULL THEN        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO84,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;       		
         END IF;	
      END IF; 
      IF 85 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,85);
         IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO85))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO85))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       	
			         IF X.CAMPO85 IS NOT NULL THEN        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO85,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;       		
         END IF;	
      END IF; 
      IF 86 <= nCantCamposRep THEN  
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,86);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO86))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO86))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       		
			         IF X.CAMPO86 IS NOT NULL THEN        	        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO86,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;   
         END IF;	
      END IF; 
      IF 87 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,87);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO87))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO87))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN     
		        	 IF X.CAMPO87 IS NOT NULL THEN         	
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO87,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;  
         END IF;	
      END IF; 
      IF 88 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,88);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO88))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO88))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN  
			         IF X.CAMPO88 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO88,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;  
         END IF;
      END IF; 
      IF 89 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,89);  
      	 IF nTipDatoCol = 1 THEN  
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO89))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =2 THEN 
      	  	   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO89))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =3 THEN     
			         IF X.CAMPO89 IS NOT NULL THEN         	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO89,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;  
         END IF;
      END IF; 
      IF 90 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,90);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO90))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO90))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       		
		        	 IF X.CAMPO90 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO90,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
		      	   ELSE 
		      		     lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;  
      	 END IF;        
      END IF; 
      --
      IF 91 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,91);
	       IF nTipDatoCol = 1 THEN 
	          lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO91))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =2 THEN 
	      		   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO91))||'</Data></Cell> '||chr(10);
	       ELSIF nTipDatoCol =3 THEN   
			      	 IF X.CAMPO91 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO91,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF; 	
	      	END IF;
      END IF; 
      IF 92 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,92);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO92))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO92))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN   
			         IF X.CAMPO92 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO92,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF; 
         END IF;	
      END IF; 
      IF 93 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,93);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO93))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO93))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN 
		           IF X.CAMPO93 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO93,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      		 END IF; 
         END IF;	
      END IF;
      IF 94 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,94); 
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO94))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO94))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN   
			         IF X.CAMPO94 IS NOT NULL THEN        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO94,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;       		
         END IF;	
      END IF; 
      IF 95 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,95);
         IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO95))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO95))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       	
			         IF X.CAMPO95 IS NOT NULL THEN        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO95,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;       		
         END IF;	
      END IF; 
      IF 96 <= nCantCamposRep THEN  
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,96);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO96))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO96))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       		
			         IF X.CAMPO96 IS NOT NULL THEN        	        	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO96,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;   
         END IF;	
      END IF; 
      IF 97 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,97);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO97))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO97))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN     
		        	 IF X.CAMPO97 IS NOT NULL THEN         	
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO97,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
		      	   ELSE 
		      			   lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;  
         END IF;	
      END IF; 
      IF 98 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,98);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO98))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO98))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN  
			         IF X.CAMPO98 IS NOT NULL THEN 
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO98,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;  
         END IF;
      END IF; 
      IF 99 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,99);  
      	 IF nTipDatoCol = 1 THEN  
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO99))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =2 THEN 
      	  	   lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO99))||'</Data></Cell> '||chr(10); 
         ELSIF nTipDatoCol =3 THEN     
			         IF X.CAMPO99 IS NOT NULL THEN         	
			            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO99,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		
			      	 ELSE 
			      			 lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
			      	 END IF;  
         END IF;
      END IF; 
      IF 100 <= nCantCamposRep THEN 
      	 nTipDatoCol:=PKG_REPORTE.FUN_COD_TIPDATOCOL(:REPORTE.CODREPORTE,100);
      	 IF nTipDatoCol = 1 THEN 
            lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s64"><Data ss:Type="String">'||RTRIM(LTRIM(X.CAMPO100))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =2 THEN 
      		     lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s66"><Data ss:Type="Number">'||RTRIM(LTRIM(X.CAMPO100))||'</Data></Cell> '||chr(10);
         ELSIF nTipDatoCol =3 THEN       		
		        	 IF X.CAMPO100 IS NOT NULL THEN 
		              lv_LineaDato:=lv_LineaDato||' <Cell ss:StyleID="s67"><Data ss:Type="DateTime">'||RTRIM(LTRIM(TO_CHAR(TO_DATE(X.CAMPO100,'DD/MM/YYYY'), 'YYYY-MM-DD')))||'T00:00:00.000</Data></Cell> '||chr(10);		      		
		      	   ELSE 
		      		     lv_LineaDato:=lv_LineaDato||cFecSinDatos||chr(10);
		      	   END IF;  
      	 END IF;        
      END IF; 
      --
	    lv_Line:= NULL;
	   	lv_Line :='<Row>'||chr(10)||
	   	          lv_LineaDato||chr(10)||
						    '</Row>'||chr(10);
						     
			CLIENT_TEXT_IO.PUT_LINE(lf_arch, lv_Line);
						  		
			IF MOD(nContador, 5000 ) = 0 THEN 
				Synchronize;
			END IF;
  END LOOP;
  --Cerrando la tabla de reporte. 
  lv_Line:=NULL;  
  lv_Line:=' </Table>'||chr(10)||
					'  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'||chr(10)||
					'   <PageSetup>'||chr(10)||
					'    <Header x:Margin="0.3"/>'||chr(10)||
					'    <Footer x:Margin="0.3"/>'||chr(10)||
					'    <PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>'||chr(10)||
					'   </PageSetup>'||chr(10)||
					'   <Selected/>'||chr(10)||
					'   <Panes>'||chr(10)||
					'    <Pane>'||chr(10)||
					'     <Number>3</Number>'||chr(10)||
					'     <ActiveRow>3</ActiveRow>'||chr(10)||
					'     <ActiveCol>1</ActiveCol>'||chr(10)||
					'    </Pane>'||chr(10)||
					'   </Panes>'||chr(10)||
					'   <ProtectObjects>False</ProtectObjects>'||chr(10)||
					'   <ProtectScenarios>False</ProtectScenarios>'||chr(10)||
					'  </WorksheetOptions>'||chr(10)||
					' </Worksheet>'||chr(10)||
					' </Workbook>'||chr(10);
												
    CLIENT_TEXT_IO.PUT_LINE(lf_arch, lv_Line); 
					
		Client_Text_IO.Fclose(lf_arch);
		set_application_property(cursor_style,'default');
	 
		Synchronize;
						
	  --Genera el archivo.
	  Lb_Excel.Iniciar(FALSE, FALSE, FALSE);
	  Lb_Excel.Abrir(RTRIM(LTRIM(lnombrearchivo))||'.xml');
    Synchronize;  --1
	  Lb_Excel.Guardar_xlsx( RTRIM(LTRIM(lnombrearchivoxls))||'.xlsx');
	  l_success := webutil_file.copy_file(RTRIM(LTRIM(lnombrearchivoxls))||'.xlsx',RTRIM(LTRIM(vRutaReportes))||RTRIM(LTRIM(cNombArch))||'.xlsx');
	  Synchronize;  --2
	  Lb_Excel.Salir;
	  Synchronize;  --3
	  Lb_Excel.Terminar;
	  Synchronize;  --4
	  
	  --Eliminando archivos del repositorio
	  /*
	  l_success:=WebUtil_File.Delete_File( RTRIM(LTRIM(lnombrearchivoxls))||'.xml');
	  l_success:=WebUtil_File.Delete_File( RTRIM(LTRIM(lnombrearchivoxls))||'.xlsx');
	  */	      
    SET_ALERT_PROPERTY( 'AVISO', ALERT_MESSAGE_TEXT, 'Archivo en excel Generado.. : '||vRutaReportes||cNombArch||'.xlsx');
    vAlerta := SHOW_ALERT('AVISO');
EXCEPTION WHEN OTHERS THEN 
				  Client_Text_IO.Fclose(lf_arch);	
			    Lb_Excel.Terminar; 
				  Set_Application_property(cursor_style,'default');
			    SET_ALERT_PROPERTY( 'AVISO', ALERT_MESSAGE_TEXT, 'Error al generar archivo excel. '||sqlerrm); 
			    vAlerta := SHOW_ALERT('AVISO'); 
END;
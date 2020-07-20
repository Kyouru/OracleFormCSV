PROCEDURE P_GENERA_REPORTE_EXCEL IS 

    lf_arch            CLIENT_TEXT_IO.FILE_TYPE;
    vRutaReportes      VARCHAR2(500) := TRIM(ADM08010.CARPETATEMPFISICA);
  
    vStrQ              VARCHAR2(10000);
    
  lv_Line            VARCHAR2(32767) := Null;
  lv_Line_01         VARCHAR2(32767) := Null;
  
  vAlerta            PLS_INTEGER;
  
    cNombArch          VARCHAR2(100):= TRIM(:REPORTE.NOMARCHIVO)||'_'||
                                     TO_CHAR(SYSDATE,'YYYYMMDD')||'_'||
                                     TO_CHAR(SYSDATE,'HH24MISS');
  
  mi_cursor     INTEGER;
  dato_concatenado    VARCHAR2 (32767);
  filas_procesadas  INTEGER;
  i           NUMBER;
  synceach      INTEGER := 6000;
  
BEGIN

    Set_application_property(cursor_style,'busy');
  
    lf_arch := Client_Text_IO.FOPEN(vRutaReportes||cNombArch||'.csv','W');
  
  vStrQ           := 'SELECT ';
    
    FOR X IN (
        SELECT CR.TITULO, CR.SECCOLUMNA, CR.TIPDATO FROM COLUMNA_REPORTE CR WHERE CR.CODREPORTE = CODIGOREPORTE ORDER BY CR.SECCOLUMNA
        )
  LOOP
    lv_Line_01 := lv_Line_01 || TRIM(X.TITULO) || ',';

    CASE X.TIPDATO
    WHEN 1 THEN 
            vStrQ := vStrQ || '''"''||REPLACE(REPLACE(TRIM(CAMPO' || X.SECCOLUMNA|| '),CHR(10),''''),CHR(13),'''')||''",''||';
    WHEN 2 THEN 
            vStrQ := vStrQ || '''"''||REPLACE(REPLACE(TRIM(CAMPO' || X.SECCOLUMNA|| '),CHR(10),''''),CHR(13),'''')||''",''||';
    WHEN 3 THEN 
            vStrQ := vStrQ || '''"''||TO_CHAR(TO_DATE(CAMPO' || X.SECCOLUMNA|| ',''DD/MM/YYYY''),''YYYY-MM-DD'')||''",''||';
        ELSE
            vStrQ := vStrQ || '''"''||REPLACE(REPLACE(TRIM(CAMPO' || X.SECCOLUMNA|| '),CHR(10),''''),CHR(13),'''')||''",''||';
        END CASE;
  END LOOP;
  
    vStrQ := LPAD(vStrQ, LENGTH(vStrQ) - 2) || ' AS FILACONCATENADA FROM TMP_REPORTENUEVO';
  
    CLIENT_TEXT_IO.PUT_LINE(lf_arch, lv_Line_01); 
  
    --Inicio Filas datos
  mi_cursor := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE(mi_cursor, vStrQ , 1);
  DBMS_SQL.DEFINE_COLUMN(mi_cursor, 1, dato_concatenado, 32767);
  filas_procesadas := DBMS_SQL.EXECUTE(mi_cursor);
  i := 0;
  LOOP
    IF DBMS_SQL.FETCH_ROWS(mi_cursor) <> 0 THEN
      DBMS_SQL.COLUMN_VALUE(mi_cursor, 1, dato_concatenado);
      CLIENT_TEXT_IO.PUT_LINE(lf_arch, dato_concatenado);
      i := i + 1;
      IF MOD(i, synceach) = 0 THEN
        Synchronize;
      END IF;
    ELSE
      EXIT;
    END IF;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR (mi_cursor);
  
    Synchronize;
  Client_Text_IO.Fclose(lf_arch);
  
  set_application_property(cursor_style,'default');
  
    SET_ALERT_PROPERTY( 'AVISO', ALERT_MESSAGE_TEXT, 'Archivo en excel Generado.. : '||vRutaReportes||cNombArch||'.csv');
    vAlerta := SHOW_ALERT('AVISO');
EXCEPTION WHEN OTHERS THEN 
        Client_Text_IO.Fclose(lf_arch);
        Set_Application_property(cursor_style,'default');
          SET_ALERT_PROPERTY( 'AVISO', ALERT_MESSAGE_TEXT, 'Error al generar archivo excel. '||sqlerrm); 
          vAlerta := SHOW_ALERT('AVISO'); 
END;
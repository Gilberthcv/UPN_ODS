--Nombres_Programa_
WITH NOMBRES_PROGRAMA AS (
SELECT PROGRAM AS CARRERA, TERM_CODE_EFF AS PERIODO_CATALOGO
	, TRIM(MAX(CASE WHEN PRNT_CODE = 'LNAME1' THEN TEXT END) || MAX(CASE WHEN PRNT_CODE = 'LNAME2' THEN TEXT ELSE ' ' END)) AS NOMBRE
	, TRIM(MAX(CASE WHEN PRNT_CODE = 'GRADE1' THEN TEXT END) || MAX(CASE WHEN PRNT_CODE = 'GRADE2' THEN TEXT ELSE ' ' END)) AS GRADO
	, TRIM(MAX(CASE WHEN PRNT_CODE = 'TITLE1' THEN TEXT END) || MAX(CASE WHEN PRNT_CODE = 'TITLE2' THEN TEXT ELSE ' ' END)) AS TITULO
FROM ODSMGR.LOE_PROGRAM_TEXT
WHERE PRNT_CODE IN ('LNAME1', 'LNAME2', 'GRADE1', 'GRADE2', 'TITLE1', 'TITLE2')
GROUP BY PROGRAM, TERM_CODE_EFF
--ORDER BY PROGRAM, TERM_CODE_EFF
)
SELECT * FROM NOMBRES_PROGRAMA
WHERE (NOMBRE = UPPER(NOMBRE) OR GRADO = UPPER(GRADO) OR TITULO = UPPER(TITULO)) AND SUBSTR(CARRERA,4,1) = '-'	--VALIDAR_MAYUSCULAS
ORDER BY CARRERA, PERIODO_CATALOGO
;

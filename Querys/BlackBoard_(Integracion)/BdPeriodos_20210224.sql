--Periodos_
SELECT 'EXTERNAL_TERM_KEY|NAME|DURATION|START_DATE|END_DATE|DATA_SOURCE_KEY' FROM DUAL;
    SELECT
        A.TERM_CODE
        ||'|'|| B.STVTERM_DESC
        ||'|R'
        ||'|'|| TO_CHAR(A.START_DATE,'YYYYMMDD')
        ||'|'|| TO_CHAR(A.END_DATE,'YYYYMMDD')
        ||'|'|| 'UPN.Periodos.Banner' --'UPN.<Instancia>.Banner.<Nivel>'
    FROM ODSMGR.LOE_SECTION_PART_OF_TERM A
    		INNER JOIN ODSMGR.STVTERM B ON A.TERM_CODE = B.STVTERM_CODE
    WHERE A.TERM_CODE <> '999996'
        AND CURRENT_DATE BETWEEN TO_DATE(A.START_DATE)-14 AND TO_DATE(A.END_DATE)+10
	;
	SPOOL OFF
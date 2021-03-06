--BdPeriodos_
USE DATABASE UPN_RPT_DM_PROD;
USE SCHEMA ODSMGR;

--CREATE OR REPLACE VIEW BdPeriodos AS
SELECT A.TERM_CODE AS EXTERNAL_TERM_KEY
    , B.STVTERM_DESC AS NAME
    , 'R' AS DURATION
    , TO_CHAR(A.START_DATE,'YYYYMMDD') AS START_DATE
    , TO_CHAR(A.END_DATE,'YYYYMMDD') AS END_DATE
    , 'UPN.Periodos.Banner' AS DATA_SOURCE_KEY --'UPN.<Instancia>.Banner.<Nivel>'
FROM ODSMGR.LOE_SECTION_PART_OF_TERM A
		INNER JOIN ODSMGR.LOE_STVTERM B ON A.TERM_CODE = B.STVTERM_CODE
WHERE A.TERM_CODE <> '999996'
    AND CURRENT_DATE BETWEEN TO_DATE(A.START_DATE)-14 AND TO_DATE(A.END_DATE)+10
;
select 'EXTERNAL_NODE_KEY|NAME|PARENT_NODE_KEY|DATA_SOURCE_KEY' from dual;
WITH NODOS AS (
SELECT DISTINCT 'PEPN01' AS PEPN01, 'UPN' AS UPN
    , CASE SUBSTR(SSBSECT_TERM_CODE,4,1)
          WHEN '3' THEN 'PN'
          WHEN '4' THEN 'UG'
          WHEN '5' THEN 'WA'
      ELSE 'EP' END AS COD_NIVEL
    , CASE SUBSTR(SSBSECT_TERM_CODE,4,1)
          WHEN '3' THEN 'Programa de Nivelacion'
          WHEN '4' THEN 'Pregrado Regular'
          WHEN '5' THEN 'Working Adult'
      ELSE 'Escuela de Posgrado' END AS NIVEL
    , CASE WHEN SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'TRU' ELSE SSBSECT_CAMP_CODE END AS COD_CAMPUS
    , CASE WHEN SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'Trujillo' ELSE STVCAMP_DESC END AS CAMPUS
    , SSRATTR_ATTR_CODE, STVATTR_DESC, SSBSECT_TERM_CODE, 'Banner' AS Banner
FROM SSBSECT, SSRATTR, STVCAMP, STVATTR
WHERE SSBSECT_TERM_CODE = SSRATTR_TERM_CODE AND SSBSECT_CRN = SSRATTR_CRN
    AND SSBSECT_CAMP_CODE = STVCAMP_CODE AND SSRATTR_ATTR_CODE = STVATTR_CODE
    AND SSBSECT_SSTS_CODE = 'A' AND SUBSTR(SSBSECT_TERM_CODE,4,1) <> '7'
    AND SSBSECT_TERM_CODE IN (SELECT DISTINCT SOBPTRM_TERM_CODE FROM SOBPTRM
                              WHERE SOBPTRM_START_DATE <= SYSDATE AND SOBPTRM_END_DATE >= SYSDATE))

SELECT DISTINCT PEPN01||'.'||UPN
    ||'|'||UPN
    ||'|'||PEPN01
    ||'|'||Banner FROM NODOS
UNION
SELECT DISTINCT PEPN01||'.'||UPN||'.'||COD_NIVEL
    ||'|'||NIVEL
    ||'|'||PEPN01||'.'||UPN
    ||'|'||Banner FROM NODOS
UNION
SELECT DISTINCT PEPN01||'.'||UPN||'.'||COD_NIVEL||'.'||COD_CAMPUS
    ||'|'||CAMPUS
    ||'|'||PEPN01||'.'||UPN||'.'||COD_NIVEL
    ||'|'||Banner FROM NODOS
UNION
SELECT DISTINCT PEPN01||'.'||UPN||'.'||COD_NIVEL||'.'||COD_CAMPUS||'.'||SSRATTR_ATTR_CODE
    ||'|'||STVATTR_DESC
    ||'|'||PEPN01||'.'||UPN||'.'||COD_NIVEL||'.'||COD_CAMPUS
    ||'|'||Banner FROM NODOS
UNION
SELECT DISTINCT PEPN01||'.'||UPN||'.'||COD_NIVEL||'.'||COD_CAMPUS||'.'||SSRATTR_ATTR_CODE||'.'||SSBSECT_TERM_CODE
    ||'|'||SSBSECT_TERM_CODE
    ||'|'||PEPN01||'.'||UPN||'.'||COD_NIVEL||'.'||COD_CAMPUS||'.'||SSRATTR_ATTR_CODE
    ||'|'||Banner FROM NODOS;
  spool off
select 'EXTERNAL_NODE_KEY|NAME|PARENT_NODE_KEY|DATA_SOURCE_KEY' from dual;
    WITH NODOS AS (
    SELECT DISTINCT 'PEPN01' AS PEPN01, 'UPN' AS UPN
        , CASE SUBSTR(SSBSECT_TERM_CODE,4,1)
              WHEN '3' THEN 'PN'
              WHEN '4' THEN 'UG'
              WHEN '5' THEN 'WA'
              WHEN '7' THEN 'IN'
          ELSE 'EP' END AS COD_NIVEL
        , CASE SUBSTR(SSBSECT_TERM_CODE,4,1)
              WHEN '3' THEN 'Programa de Nivelacion'
              WHEN '4' THEN 'Pregrado Regular'
              WHEN '5' THEN 'Working Adult'
              WHEN '7' THEN 'Ingles'
          ELSE 'Escuela de Posgrado' END AS NIVEL
        , CASE WHEN SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'TRU' ELSE SSBSECT_CAMP_CODE END AS COD_CAMPUS
        , CASE WHEN SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'Trujillo' ELSE STVCAMP_DESC END AS CAMPUS
        , SSRATTR_ATTR_CODE, STVATTR_DESC, SSBSECT_TERM_CODE
        , CASE SUBSTR(SSBSECT_TERM_CODE,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
              WHEN '3' THEN 'UPN.Nodos.Banner.PDN'
              WHEN '4' THEN 'UPN.Nodos.Banner.UG'
              WHEN '5' THEN 'UPN.Nodos.Banner.WA'
              WHEN '7' THEN 'UPN.Nodos.Banner.Ingles'
            ELSE 'UPN.Nodos.Banner.EPEC' END AS DATA_SOURCE_KEY
    FROM SSBSECT,
         SSRATTR,
         STVCAMP,
         STVATTR
    WHERE SSBSECT_TERM_CODE = SSRATTR_TERM_CODE AND SSBSECT_CRN = SSRATTR_CRN
        AND SSBSECT_CAMP_CODE = STVCAMP_CODE AND SSRATTR_ATTR_CODE = STVATTR_CODE
        AND SSBSECT_SSTS_CODE = 'A'
        AND SSBSECT_PTRM_START_DATE <= SYSDATE +7 AND SSBSECT_PTRM_END_DATE >= SYSDATE -16
        AND SSBSECT_TERM_CODE IN (SELECT DISTINCT TERM_CODE FROM LOE_SECTION_PART_OF_TERM
                                  WHERE START_DATE <= SYSDATE +7 AND END_DATE >= SYSDATE -16))
    
    SELECT DISTINCT PEPN01||'.'||UPN
        ||'|'||UPN
        ||'|'||PEPN01
        ||'|'||DATA_SOURCE_KEY FROM NODOS
    UNION
    SELECT DISTINCT PEPN01||'.'||UPN||'.'||COD_NIVEL
        ||'|'||NIVEL
        ||'|'||PEPN01||'.'||UPN
        ||'|'||DATA_SOURCE_KEY FROM NODOS
    UNION
    SELECT DISTINCT PEPN01||'.'||UPN||'.'||COD_NIVEL||'.'||COD_CAMPUS
        ||'|'||CAMPUS
        ||'|'||PEPN01||'.'||UPN||'.'||COD_NIVEL
        ||'|'||DATA_SOURCE_KEY FROM NODOS
    UNION
    SELECT DISTINCT PEPN01||'.'||UPN||'.'||COD_NIVEL||'.'||COD_CAMPUS||'.'||SSRATTR_ATTR_CODE
        ||'|'||STVATTR_DESC
        ||'|'||PEPN01||'.'||UPN||'.'||COD_NIVEL||'.'||COD_CAMPUS
        ||'|'||DATA_SOURCE_KEY FROM NODOS
    UNION
    SELECT DISTINCT PEPN01||'.'||UPN||'.'||COD_NIVEL||'.'||COD_CAMPUS||'.'||SSRATTR_ATTR_CODE||'.'||SSBSECT_TERM_CODE
        ||'|'||SSBSECT_TERM_CODE
        ||'|'||PEPN01||'.'||UPN||'.'||COD_NIVEL||'.'||COD_CAMPUS||'.'||SSRATTR_ATTR_CODE
        ||'|'||DATA_SOURCE_KEY FROM NODOS;
  spool off
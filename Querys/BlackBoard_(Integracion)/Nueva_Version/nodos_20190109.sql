select 'EXTERNAL_NODE_KEY|NAME|PARENT_NODE_KEY|DATA_SOURCE_KEY' from dual;
    SELECT 'PEPN01'||'.'||'UPN'
        ||'|'||'UPN'
        ||'|'||'PEPN01'
        ||'|'||'UPN.Nodos.Banner'
    FROM DUAL
    UNION
    SELECT DISTINCT 'PEPN01'||'.'||'UPN'
        ||'.'||CASE SUBSTR(a.SSBSECT_TERM_CODE,4,1)
                  WHEN '3' THEN 'PN'
                  WHEN '4' THEN 'UG'
                  WHEN '5' THEN 'WA'
                  WHEN '7' THEN 'IN'
              ELSE 'EP' END
        ||'|'||CASE SUBSTR(a.SSBSECT_TERM_CODE,4,1)
                  WHEN '3' THEN 'Programa de Nivelacion'
                  WHEN '4' THEN 'Pregrado Regular'
                  WHEN '5' THEN 'Working Adult'
                  WHEN '7' THEN 'Ingles'
              ELSE 'Escuela de Posgrado' END
        ||'|'||'PEPN01'||'.'||'UPN'
        ||'|'||'UPN.Nodos.Banner'
    FROM SSBSECT a,
         SSRATTR b,
         STVCAMP c,
         STVATTR d,
         (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
              , MIN(SSRMEET_START_DATE) AS START_DATE
              , MAX(SSRMEET_END_DATE) AS END_DATE
          FROM SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN) e
    WHERE a.SSBSECT_TERM_CODE = b.SSRATTR_TERM_CODE AND a.SSBSECT_CRN = b.SSRATTR_CRN
        AND a.SSBSECT_CAMP_CODE = c.STVCAMP_CODE AND b.SSRATTR_ATTR_CODE = d.STVATTR_CODE
        AND a.SSBSECT_TERM_CODE = e.SSRMEET_TERM_CODE AND a.SSBSECT_CRN = e.SSRMEET_CRN
        AND a.SSBSECT_SSTS_CODE = 'A'
        AND e.START_DATE <= SYSDATE +7 AND e.END_DATE >= SYSDATE -16
        AND a.SSBSECT_TERM_CODE IN (SELECT DISTINCT TERM_CODE FROM LOE_SECTION_PART_OF_TERM
                                  WHERE START_DATE <= SYSDATE +7 AND END_DATE >= SYSDATE -16)
    UNION
    SELECT DISTINCT 'PEPN01'||'.'||'UPN'
        ||'.'||CASE SUBSTR(a.SSBSECT_TERM_CODE,4,1)
                  WHEN '3' THEN 'PN'
                  WHEN '4' THEN 'UG'
                  WHEN '5' THEN 'WA'
                  WHEN '7' THEN 'IN'
              ELSE 'EP' END
        ||'.'||CASE WHEN a.SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'TRU' ELSE a.SSBSECT_CAMP_CODE END
        ||'|'||CASE WHEN a.SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'Trujillo' ELSE c.STVCAMP_DESC END
        ||'|'||'PEPN01'||'.'||'UPN'
        ||'.'||CASE SUBSTR(a.SSBSECT_TERM_CODE,4,1)
                  WHEN '3' THEN 'PN'
                  WHEN '4' THEN 'UG'
                  WHEN '5' THEN 'WA'
                  WHEN '7' THEN 'IN'
              ELSE 'EP' END
        ||'|'||'UPN.Nodos.Banner'
    FROM SSBSECT a,
         SSRATTR b,
         STVCAMP c,
         STVATTR d,
         (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
              , MIN(SSRMEET_START_DATE) AS START_DATE
              , MAX(SSRMEET_END_DATE) AS END_DATE
          FROM SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN) e
    WHERE a.SSBSECT_TERM_CODE = b.SSRATTR_TERM_CODE AND a.SSBSECT_CRN = b.SSRATTR_CRN
        AND a.SSBSECT_CAMP_CODE = c.STVCAMP_CODE AND b.SSRATTR_ATTR_CODE = d.STVATTR_CODE
        AND a.SSBSECT_TERM_CODE = e.SSRMEET_TERM_CODE AND a.SSBSECT_CRN = e.SSRMEET_CRN
        AND a.SSBSECT_SSTS_CODE = 'A'
        AND e.START_DATE <= SYSDATE +7 AND e.END_DATE >= SYSDATE -16
        AND a.SSBSECT_TERM_CODE IN (SELECT DISTINCT TERM_CODE FROM LOE_SECTION_PART_OF_TERM
                                  WHERE START_DATE <= SYSDATE +7 AND END_DATE >= SYSDATE -16)
    UNION
    SELECT DISTINCT 'PEPN01'||'.'||'UPN'
        ||'.'||CASE SUBSTR(a.SSBSECT_TERM_CODE,4,1)
                  WHEN '3' THEN 'PN'
                  WHEN '4' THEN 'UG'
                  WHEN '5' THEN 'WA'
                  WHEN '7' THEN 'IN'
              ELSE 'EP' END
        ||'.'||CASE WHEN a.SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'TRU' ELSE a.SSBSECT_CAMP_CODE END
        ||'.'||b.SSRATTR_ATTR_CODE
        ||'|'||d.STVATTR_DESC
        ||'|'||'PEPN01'||'.'||'UPN'
        ||'.'||CASE SUBSTR(a.SSBSECT_TERM_CODE,4,1)
                  WHEN '3' THEN 'PN'
                  WHEN '4' THEN 'UG'
                  WHEN '5' THEN 'WA'
                  WHEN '7' THEN 'IN'
              ELSE 'EP' END
        ||'.'||CASE WHEN a.SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'TRU' ELSE a.SSBSECT_CAMP_CODE END
        ||'|'||'UPN.Nodos.Banner'
    FROM SSBSECT a,
         SSRATTR b,
         STVCAMP c,
         STVATTR d,
         (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
              , MIN(SSRMEET_START_DATE) AS START_DATE
              , MAX(SSRMEET_END_DATE) AS END_DATE
          FROM SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN) e
    WHERE a.SSBSECT_TERM_CODE = b.SSRATTR_TERM_CODE AND a.SSBSECT_CRN = b.SSRATTR_CRN
        AND a.SSBSECT_CAMP_CODE = c.STVCAMP_CODE AND b.SSRATTR_ATTR_CODE = d.STVATTR_CODE
        AND a.SSBSECT_TERM_CODE = e.SSRMEET_TERM_CODE AND a.SSBSECT_CRN = e.SSRMEET_CRN
        AND a.SSBSECT_SSTS_CODE = 'A'
        AND e.START_DATE <= SYSDATE +7 AND e.END_DATE >= SYSDATE -16
        AND a.SSBSECT_TERM_CODE IN (SELECT DISTINCT TERM_CODE FROM LOE_SECTION_PART_OF_TERM
                                  WHERE START_DATE <= SYSDATE +7 AND END_DATE >= SYSDATE -16)
    UNION
    SELECT DISTINCT 'PEPN01'||'.'||'UPN'
        ||'.'||CASE SUBSTR(a.SSBSECT_TERM_CODE,4,1)
                  WHEN '3' THEN 'PN'
                  WHEN '4' THEN 'UG'
                  WHEN '5' THEN 'WA'
                  WHEN '7' THEN 'IN'
              ELSE 'EP' END
        ||'.'||CASE WHEN a.SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'TRU' ELSE a.SSBSECT_CAMP_CODE END
        ||'.'||b.SSRATTR_ATTR_CODE
        ||'.'||a.SSBSECT_TERM_CODE
        ||'|'||a.SSBSECT_TERM_CODE
        ||'|'||'PEPN01'||'.'||'UPN'
        ||'.'||CASE SUBSTR(a.SSBSECT_TERM_CODE,4,1)
                  WHEN '3' THEN 'PN'
                  WHEN '4' THEN 'UG'
                  WHEN '5' THEN 'WA'
                  WHEN '7' THEN 'IN'
              ELSE 'EP' END
        ||'.'||CASE WHEN a.SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'TRU' ELSE a.SSBSECT_CAMP_CODE END
        ||'.'||b.SSRATTR_ATTR_CODE
        ||'|'||'UPN.Nodos.Banner'
    FROM SSBSECT a,
         SSRATTR b,
         STVCAMP c,
         STVATTR d,
         (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
              , MIN(SSRMEET_START_DATE) AS START_DATE
              , MAX(SSRMEET_END_DATE) AS END_DATE
          FROM SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN) e
    WHERE a.SSBSECT_TERM_CODE = b.SSRATTR_TERM_CODE AND a.SSBSECT_CRN = b.SSRATTR_CRN
        AND a.SSBSECT_CAMP_CODE = c.STVCAMP_CODE AND b.SSRATTR_ATTR_CODE = d.STVATTR_CODE
        AND a.SSBSECT_TERM_CODE = e.SSRMEET_TERM_CODE AND a.SSBSECT_CRN = e.SSRMEET_CRN
        AND a.SSBSECT_SSTS_CODE = 'A'
        AND e.START_DATE <= SYSDATE +7 AND e.END_DATE >= SYSDATE -16
        AND a.SSBSECT_TERM_CODE IN (SELECT DISTINCT TERM_CODE FROM LOE_SECTION_PART_OF_TERM
                                  WHERE START_DATE <= SYSDATE +7 AND END_DATE >= SYSDATE -16);
  spool off
select 'EXTERNAL_ASSOCIATION_KEY|EXTERNAL_NODE_KEY|EXTERNAL_USER_KEY|DATA_SOURCE_KEY' from dual;
    SELECT DISTINCT
        e.SPRIDEN_ID ||'.PEPN01.UPN.'||
            CASE SUBSTR(a.SFRSTCR_TERM_CODE,4,1)
                WHEN '3' THEN 'PN'
                WHEN '4' THEN 'UG'
                WHEN '5' THEN 'WA'
                WHEN '7' THEN 'IN'
              ELSE 'EP' END ||'.'||
            CASE WHEN b.SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'TRU' ELSE b.SSBSECT_CAMP_CODE END ||'.'||
            c.SSRATTR_ATTR_CODE  ||'.'|| a.SFRSTCR_TERM_CODE ||'|'||
        'PEPN01.UPN.' ||
            CASE SUBSTR(a.SFRSTCR_TERM_CODE,4,1)
                WHEN '3' THEN 'PN'
                WHEN '4' THEN 'UG'
                WHEN '5' THEN 'WA'
                WHEN '7' THEN 'IN'
              ELSE 'EP' END ||'.'||
            CASE WHEN b.SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'TRU' ELSE b.SSBSECT_CAMP_CODE END ||'.'||
            c.SSRATTR_ATTR_CODE  ||'.'|| a.SFRSTCR_TERM_CODE ||'|'||
        a.SFRSTCR_PIDM ||'|'||
        CASE SUBSTR(a.SFRSTCR_TERM_CODE,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
            WHEN '3' THEN 'UPN.UsuarioNodo.Banner.PDN'
            WHEN '4' THEN 'UPN.UsuarioNodo.Banner.UG'
            WHEN '5' THEN 'UPN.UsuarioNodo.Banner.WA'
            WHEN '7' THEN 'UPN.UsuarioNodo.Banner.Ingles'
          ELSE 'UPN.UsuarioNodo.Banner.EPEC' END
    FROM SFRSTCR a,
         SSBSECT b,
         SSRATTR c,
         (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
              , MIN(SSRMEET_START_DATE) AS START_DATE
              , MAX(SSRMEET_END_DATE) AS END_DATE
          FROM SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN) d,
         SPRIDEN e
    WHERE a.SFRSTCR_TERM_CODE = b.SSBSECT_TERM_CODE AND a.SFRSTCR_CRN = b.SSBSECT_CRN
        AND b.SSBSECT_TERM_CODE = c.SSRATTR_TERM_CODE AND b.SSBSECT_CRN = c.SSRATTR_CRN
        AND b.SSBSECT_TERM_CODE = d.SSRMEET_TERM_CODE AND b.SSBSECT_CRN = d.SSRMEET_CRN
        AND a.SFRSTCR_PIDM = e.SPRIDEN_PIDM AND e.SPRIDEN_CHANGE_IND IS NULL
        AND a.SFRSTCR_RSTS_CODE IN ('RE','RW','RA')
        AND b.SSBSECT_SSTS_CODE = 'A' AND b.SSBSECT_MAX_ENRL > 0 AND b.SSBSECT_ENRL > 0
        AND b.SSBSECT_SUBJ_CODE NOT IN ('ACAD','REPS','TEST','XPEN','XSER')
        AND d.START_DATE <= SYSDATE +7 AND d.END_DATE >= SYSDATE -16
        AND b.SSBSECT_TERM_CODE IN (SELECT DISTINCT TERM_CODE FROM LOE_SECTION_PART_OF_TERM
                                  WHERE START_DATE <= SYSDATE +7 AND END_DATE >= SYSDATE -16)
    UNION
    SELECT DISTINCT
        e.SPRIDEN_ID ||'.PEPN01.UPN.'||
            CASE SUBSTR(a.SIRASGN_TERM_CODE,4,1)
                WHEN '3' THEN 'PN'
                WHEN '4' THEN 'UG'
                WHEN '5' THEN 'WA'
                WHEN '7' THEN 'IN'
              ELSE 'EP' END ||'.'||
            CASE WHEN b.SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'TRU' ELSE b.SSBSECT_CAMP_CODE END ||'.'||
            c.SSRATTR_ATTR_CODE  ||'.'|| a.SIRASGN_TERM_CODE ||'|'||
        'PEPN01.UPN.' ||
            CASE SUBSTR(a.SIRASGN_TERM_CODE,4,1)
                WHEN '3' THEN 'PN'
                WHEN '4' THEN 'UG'
                WHEN '5' THEN 'WA'
                WHEN '7' THEN 'IN'
              ELSE 'EP' END ||'.'||
            CASE WHEN b.SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'TRU' ELSE b.SSBSECT_CAMP_CODE END ||'.'||
            c.SSRATTR_ATTR_CODE  ||'.'|| a.SIRASGN_TERM_CODE ||'|'||
        a.SIRASGN_PIDM ||'|'||
        CASE SUBSTR(a.SIRASGN_TERM_CODE,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
            WHEN '3' THEN 'UPN.UsuarioNodo.Banner.PDN'
            WHEN '4' THEN 'UPN.UsuarioNodo.Banner.UG'
            WHEN '5' THEN 'UPN.UsuarioNodo.Banner.WA'
            WHEN '7' THEN 'UPN.UsuarioNodo.Banner.Ingles'
          ELSE 'UPN.UsuarioNodo.Banner.EPEC' END
    FROM SIRASGN a,
         SSBSECT b,
         SSRATTR c,
         (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
              , MIN(SSRMEET_START_DATE) AS START_DATE
              , MAX(SSRMEET_END_DATE) AS END_DATE
          FROM SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN) d,
         SPRIDEN e
    WHERE a.SIRASGN_TERM_CODE = b.SSBSECT_TERM_CODE AND a.SIRASGN_CRN = b.SSBSECT_CRN
        AND b.SSBSECT_TERM_CODE = c.SSRATTR_TERM_CODE AND b.SSBSECT_CRN = c.SSRATTR_CRN
        AND b.SSBSECT_TERM_CODE = d.SSRMEET_TERM_CODE AND b.SSBSECT_CRN = d.SSRMEET_CRN
        AND a.SIRASGN_PIDM = e.SPRIDEN_PIDM AND e.SPRIDEN_CHANGE_IND IS NULL
        AND b.SSBSECT_SSTS_CODE = 'A' AND b.SSBSECT_MAX_ENRL > 0 AND b.SSBSECT_ENRL > 0
        AND b.SSBSECT_SUBJ_CODE NOT IN ('ACAD','REPS','TEST','XPEN','XSER')
        AND d.START_DATE <= SYSDATE +7 AND d.END_DATE >= SYSDATE -16
        AND b.SSBSECT_TERM_CODE IN (SELECT DISTINCT TERM_CODE FROM LOE_SECTION_PART_OF_TERM
                                  WHERE START_DATE <= SYSDATE +7 AND END_DATE >= SYSDATE -16);
  spool off
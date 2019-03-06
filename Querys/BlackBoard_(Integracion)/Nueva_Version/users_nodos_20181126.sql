select 'EXTERNAL_ASSOCIATION_KEY|EXTERNAL_NODE_KEY|EXTERNAL_USER_KEY|DATA_SOURCE_KEY' from dual;
    SELECT DISTINCT
        SPRIDEN_ID ||'.PEPN01.UPN.'||
            CASE SUBSTR(SFRSTCR_TERM_CODE,4,1)
                WHEN '3' THEN 'PN'
                WHEN '4' THEN 'UG'
                WHEN '5' THEN 'WA'
                WHEN '7' THEN 'IN'
              ELSE 'EP' END ||'.'||
            CASE WHEN SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'TRU' ELSE SSBSECT_CAMP_CODE END ||'.'||
            SSRATTR_ATTR_CODE  ||'.'|| SFRSTCR_TERM_CODE ||'|'||
        'PEPN01.UPN.' ||
            CASE SUBSTR(SFRSTCR_TERM_CODE,4,1)
                WHEN '3' THEN 'PN'
                WHEN '4' THEN 'UG'
                WHEN '5' THEN 'WA'
                WHEN '7' THEN 'IN'
              ELSE 'EP' END ||'.'||
            CASE WHEN SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'TRU' ELSE SSBSECT_CAMP_CODE END ||'.'||
            SSRATTR_ATTR_CODE  ||'.'|| SFRSTCR_TERM_CODE ||'|'||
        SPRIDEN_ID ||'|'||
        CASE SUBSTR(SFRSTCR_TERM_CODE,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
            WHEN '3' THEN 'UPN.UsuarioNodo.Banner.PDN'
            WHEN '4' THEN 'UPN.UsuarioNodo.Banner.UG'
            WHEN '5' THEN 'UPN.UsuarioNodo.Banner.WA'
            WHEN '7' THEN 'UPN.UsuarioNodo.Banner.Ingles'
          ELSE 'UPN.UsuarioNodo.Banner.EPEC' END
    FROM SFRSTCR,
         SSBSECT,
         SSRATTR,
         SPRIDEN
    WHERE SFRSTCR_TERM_CODE = SSBSECT_TERM_CODE AND SFRSTCR_CRN = SSBSECT_CRN
        AND SSBSECT_TERM_CODE = SSRATTR_TERM_CODE AND SSBSECT_CRN = SSRATTR_CRN
        AND SFRSTCR_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
        AND SFRSTCR_RSTS_CODE IN ('RE','RW','RA')
        AND SSBSECT_SSTS_CODE = 'A' AND SSBSECT_MAX_ENRL > 0 AND SSBSECT_ENRL > 0
        AND SSBSECT_SUBJ_CODE NOT IN ('ACAD','REPS','TEST','XPEN','XSER')
        AND SSBSECT_PTRM_START_DATE <= SYSDATE +7 AND SSBSECT_PTRM_END_DATE >= SYSDATE -16
        AND SSBSECT_TERM_CODE IN (SELECT DISTINCT TERM_CODE FROM LOE_SECTION_PART_OF_TERM
                                  WHERE START_DATE <= SYSDATE +7 AND END_DATE >= SYSDATE -16)
    UNION
    SELECT DISTINCT
        SPRIDEN_ID ||'.PEPN01.UPN.'||
            CASE SUBSTR(SIRASGN_TERM_CODE,4,1)
                WHEN '3' THEN 'PN'
                WHEN '4' THEN 'UG'
                WHEN '5' THEN 'WA'
                WHEN '7' THEN 'IN'
              ELSE 'EP' END ||'.'||
            CASE WHEN SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'TRU' ELSE SSBSECT_CAMP_CODE END ||'.'||
            SSRATTR_ATTR_CODE  ||'.'|| SIRASGN_TERM_CODE ||'|'||
        'PEPN01.UPN.' ||
            CASE SUBSTR(SIRASGN_TERM_CODE,4,1)
                WHEN '3' THEN 'PN'
                WHEN '4' THEN 'UG'
                WHEN '5' THEN 'WA'
                WHEN '7' THEN 'IN'
              ELSE 'EP' END ||'.'||
            CASE WHEN SSBSECT_CAMP_CODE IN ('TML','TSI') THEN 'TRU' ELSE SSBSECT_CAMP_CODE END ||'.'||
            SSRATTR_ATTR_CODE  ||'.'|| SIRASGN_TERM_CODE ||'|'||
        SPRIDEN_ID ||'|'||
        CASE SUBSTR(SIRASGN_TERM_CODE,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
            WHEN '3' THEN 'UPN.UsuarioNodo.Banner.PDN'
            WHEN '4' THEN 'UPN.UsuarioNodo.Banner.UG'
            WHEN '5' THEN 'UPN.UsuarioNodo.Banner.WA'
            WHEN '7' THEN 'UPN.UsuarioNodo.Banner.Ingles'
          ELSE 'UPN.UsuarioNodo.Banner.EPEC' END
    FROM SIRASGN,
         SSBSECT,
         SSRATTR,
         SPRIDEN
    WHERE SIRASGN_TERM_CODE = SSBSECT_TERM_CODE AND SIRASGN_CRN = SSBSECT_CRN
        AND SSBSECT_TERM_CODE = SSRATTR_TERM_CODE AND SSBSECT_CRN = SSRATTR_CRN
        AND SIRASGN_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
        AND SSBSECT_SSTS_CODE = 'A' AND SSBSECT_MAX_ENRL > 0 AND SSBSECT_ENRL > 0
        AND SSBSECT_SUBJ_CODE NOT IN ('ACAD','REPS','TEST','XPEN','XSER')
        AND SSBSECT_PTRM_START_DATE <= SYSDATE +7 AND SSBSECT_PTRM_END_DATE >= SYSDATE -16
        AND SSBSECT_TERM_CODE IN (SELECT DISTINCT TERM_CODE FROM LOE_SECTION_PART_OF_TERM
                                  WHERE START_DATE <= SYSDATE +7 AND END_DATE >= SYSDATE -16);
  spool off
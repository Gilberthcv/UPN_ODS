select 'EXTERNAL_COURSE_KEY|COURSE_ID|COURSE_NAME|AVAILABLE_IND|ROW_STATUS|DURATION|START_DATE|END_DATE|TERM_KEY|DATA_SOURCE_KEY|PRIMARY_EXTERNAL_NODE_KEY|EXTERNAL_ASSOCIATION_KEY' from dual;
    SELECT DISTINCT
        case when a.SSBSECT_SCHD_CODE = 'VIR' OR a.ssbsect_insm_code = 'V'
            then a.ssbsect_subj_code ||'.'|| a.ssbsect_crse_numb ||'.'|| a.ssbsect_term_code ||'.'|| a.ssbsect_crn ||'.'|| 'V'
          else a.ssbsect_subj_code ||'.'|| a.ssbsect_crse_numb ||'.'|| a.ssbsect_term_code ||'.'|| a.ssbsect_crn ||'.'|| 'P' end ||'|'||
        case when a.SSBSECT_SCHD_CODE = 'VIR' OR a.ssbsect_insm_code = 'V'
            then a.ssbsect_subj_code ||'.'|| a.ssbsect_crse_numb ||'.'|| a.ssbsect_term_code ||'.'|| a.ssbsect_crn ||'.'|| 'V'
          else a.ssbsect_subj_code ||'.'|| a.ssbsect_crse_numb ||'.'|| a.ssbsect_term_code ||'.'|| a.ssbsect_crn ||'.'|| 'P' end ||'|'||
        case when a.SSBSECT_SCHD_CODE = 'VIR' OR a.ssbsect_insm_code = 'V'
            then b.scbcrse_title ||'(Virtual)'
          else b.scbcrse_title ||'(Presencial)' end ||'|'||
        CASE WHEN a.ssbsect_ssts_code = 'A' THEN 'Y' ELSE 'N' END ||'|'||
        CASE WHEN a.ssbsect_ssts_code = 'A' THEN 'ENABLED' ELSE 'DISABLED' END ||'|'||
        'R|'||
        to_char(d.START_DATE -7,'YYYYMMDD') ||'|'||
        to_char(d.END_DATE +16,'YYYYMMDD') ||'|'||
        a.ssbsect_term_code ||'|'||
        CASE SUBSTR(a.ssbsect_term_code,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
            WHEN '3' THEN 'UPN.Cursos.Banner.PDN'
            WHEN '4' THEN 'UPN.Cursos.Banner.UG'
            WHEN '5' THEN 'UPN.Cursos.Banner.WA'
            WHEN '7' THEN 'UPN.Cursos.Banner.Ingles'
          ELSE 'UPN.Cursos.Banner.EPEC' END ||'|'||
        'PEPN01.UPN.' ||
            CASE SUBSTR(a.ssbsect_term_code,4,1)
                WHEN '3' THEN 'PN'
                WHEN '4' THEN 'UG'
                WHEN '5' THEN 'WA'
                WHEN '7' THEN 'IN'
              ELSE 'EP' END ||'.'||
            CASE WHEN a.ssbsect_camp_code IN ('TML','TSI') THEN 'TRU' ELSE a.ssbsect_camp_code END ||'.'||
            c.ssrattr_attr_code ||'.'|| a.ssbsect_term_code ||'|'||
        a.ssbsect_crn || '.PEPN01.UPN.' ||
            CASE SUBSTR(a.ssbsect_term_code,4,1)
                WHEN '3' THEN 'PN'
                WHEN '4' THEN 'UG'
                WHEN '5' THEN 'WA'
                WHEN '7' THEN 'IN'
              ELSE 'EP' END ||'.'||
            CASE WHEN a.ssbsect_camp_code IN ('TML','TSI') THEN 'TRU' ELSE a.ssbsect_camp_code END ||'.'||
            c.ssrattr_attr_code ||'.'|| a.ssbsect_term_code
    FROM ssbsect a,
         (SELECT SCBCRSE_SUBJ_CODE, SCBCRSE_CRSE_NUMB, SCBCRSE_EFF_TERM, SCBCRSE_CSTA_CODE, SCBCRSE_TITLE
            , MAX(SCBCRSE_EFF_TERM) OVER(PARTITION BY SCBCRSE_SUBJ_CODE, SCBCRSE_CRSE_NUMB) AS MAX_TERM FROM scbcrse) b,
         ssrattr c,
         (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
              , MIN(SSRMEET_START_DATE) AS START_DATE
              , MAX(SSRMEET_END_DATE) AS END_DATE
          FROM SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN) d
    WHERE a.ssbsect_crse_numb = b.scbcrse_crse_numb AND a.ssbsect_subj_code = b.scbcrse_subj_code
        AND b.SCBCRSE_EFF_TERM = b.MAX_TERM
        AND a.ssbsect_term_code = c.ssrattr_term_code AND a.ssbsect_crn = c.ssrattr_crn
        AND a.ssbsect_term_code = d.ssrmeet_term_code AND a.ssbsect_crn = d.ssrmeet_crn
        AND a.SSBSECT_SSTS_CODE = 'A' AND a.SSBSECT_MAX_ENRL > 0 AND a.SSBSECT_ENRL > 0
        AND a.ssbsect_subj_code not in ('ACAD','REPS','TEST','XPEN','XSER')
        AND d.START_DATE <= SYSDATE +7 AND d.END_DATE >= SYSDATE -16
        AND a.ssbsect_term_code in (SELECT DISTINCT sobptrm_term_code FROM sobptrm
                                    WHERE sobptrm_start_date <= SYSDATE +7 AND sobptrm_end_date >= SYSDATE -16);
  spool off
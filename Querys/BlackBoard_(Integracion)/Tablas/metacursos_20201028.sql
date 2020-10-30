select 'EXTERNAL_COURSE_KEY|COURSE_ID|COURSE_NAME|AVAILABLE_IND|ROW_STATUS|DURATION|START_DATE|END_DATE|TERM_KEY|DATA_SOURCE_KEY|PRIMARY_EXTERNAL_NODE_KEY|EXTERNAL_ASSOCIATION_KEY|MASTER_COURSE_KEY' from dual;
    SELECT DISTINCT
        case when f.SSBSECT_SCHD_CODE = 'VIR' OR f.ssbsect_insm_code = 'V'
            then f.ssbsect_subj_code ||'.'|| f.ssbsect_crse_numb ||'.'|| f.ssbsect_term_code ||'.'|| f.ssbsect_crn ||'.'|| 'V'
          else f.ssbsect_subj_code ||'.'|| f.ssbsect_crse_numb ||'.'|| f.ssbsect_term_code ||'.'|| f.ssbsect_crn ||'.'|| 'P' end ||'|'||
        case when f.SSBSECT_SCHD_CODE = 'VIR' OR f.ssbsect_insm_code = 'V'
            then f.ssbsect_subj_code ||'.'|| f.ssbsect_crse_numb ||'.'|| f.ssbsect_term_code ||'.'|| f.ssbsect_crn ||'.'|| 'V'
          else f.ssbsect_subj_code ||'.'|| f.ssbsect_crse_numb ||'.'|| f.ssbsect_term_code ||'.'|| f.ssbsect_crn ||'.'|| 'P' end ||'|'||
        case when f.SSBSECT_SCHD_CODE = 'VIR' OR f.ssbsect_insm_code = 'V'
            then f.scbcrse_title ||'(Virtual)'
          else f.scbcrse_title ||'(Presencial)' end ||'|'||
        CASE WHEN f.ssbsect_ssts_code = 'A' THEN 'Y' ELSE 'N' END ||'|'||
        CASE WHEN f.ssbsect_ssts_code = 'A' THEN 'ENABLED' ELSE 'DISABLED' END ||'|'||
        'R|'||
        to_char(f.START_DATE -7,'YYYYMMDD') ||'|'||
        to_char(f.END_DATE +16,'YYYYMMDD') ||'|'||
        f.ssbsect_term_code ||'|'||
        CASE SUBSTR(f.ssbsect_term_code,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
            WHEN '3' THEN 'UPN.Cursos.Banner.PDN'
            WHEN '4' THEN 'UPN.Cursos.Banner.UG'
            WHEN '5' THEN 'UPN.Cursos.Banner.WA'
            WHEN '7' THEN 'UPN.Cursos.Banner.Ingles'
          ELSE 'UPN.Cursos.Banner.EPEC' END ||'|'||
        'PEPN01.UPN.' ||
            CASE SUBSTR(f.ssbsect_term_code,4,1)
                WHEN '3' THEN 'PN'
                WHEN '4' THEN 'UG'
                WHEN '5' THEN 'WA'
                WHEN '7' THEN 'IN'
              ELSE 'EP' END ||'.'||
            CASE WHEN f.ssbsect_camp_code IN ('TML','TSI') THEN 'TRU' ELSE f.ssbsect_camp_code END ||'.'||
            f.ssrattr_attr_code ||'.'|| f.ssbsect_term_code ||'|'||
        f.ssbsect_crn || '.PEPN01.UPN.' ||
            CASE SUBSTR(f.ssbsect_term_code,4,1)
                WHEN '3' THEN 'PN'
                WHEN '4' THEN 'UG'
                WHEN '5' THEN 'WA'
                WHEN '7' THEN 'IN'
              ELSE 'EP' END ||'.'||
            CASE WHEN f.ssbsect_camp_code IN ('TML','TSI') THEN 'TRU' ELSE f.ssbsect_camp_code END ||'.'||
            f.ssrattr_attr_code ||'.'|| f.ssbsect_term_code ||'|'||
        g.ssbsect_subj_code ||'.'|| g.ssbsect_crse_numb ||'.'|| f.ssbsect_term_code ||'.'|| f.nrc_madre ||'.'|| 'M'
	FROM ( SELECT DISTINCT
		        a.ssbsect_term_code, a.ssbsect_crn, a.ssbsect_subj_code, a.ssbsect_crse_numb, b.scbcrse_title, a.SSBSECT_SCHD_CODE, a.ssbsect_insm_code
		        , a.ssbsect_ssts_code, a.ssbsect_camp_code, d.START_DATE, d.END_DATE, c.ssrattr_attr_code, e.ssrxlst_xlst_group
		        , MIN(a.ssbsect_crn) OVER(PARTITION BY a.ssbsect_term_code, e.ssrxlst_xlst_group) AS nrc_madre
		    FROM ssbsect a,
		         (SELECT SCBCRSE_SUBJ_CODE, SCBCRSE_CRSE_NUMB, SCBCRSE_EFF_TERM, SCBCRSE_CSTA_CODE, SCBCRSE_TITLE
		            , MAX(SCBCRSE_EFF_TERM) OVER(PARTITION BY SCBCRSE_SUBJ_CODE, SCBCRSE_CRSE_NUMB) AS MAX_TERM FROM scbcrse) b,
		         ssrattr c,
		         (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
		              , MIN(SSRMEET_START_DATE) AS START_DATE
		              , MAX(SSRMEET_END_DATE) AS END_DATE
		          FROM SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN) d,
		         ssrxlst e
		    WHERE a.ssbsect_crse_numb = b.scbcrse_crse_numb AND a.ssbsect_subj_code = b.scbcrse_subj_code
		        AND b.SCBCRSE_EFF_TERM = b.MAX_TERM
		        AND a.ssbsect_term_code = c.ssrattr_term_code AND a.ssbsect_crn = c.ssrattr_crn
		        AND a.ssbsect_term_code = d.ssrmeet_term_code AND a.ssbsect_crn = d.ssrmeet_crn
		        AND a.ssbsect_term_code = e.ssrxlst_term_code AND a.ssbsect_crn = e.ssrxlst_crn
		        AND a.SSBSECT_SSTS_CODE = 'A' AND a.SSBSECT_MAX_ENRL > 0 AND a.SSBSECT_ENRL > 0
		        AND a.ssbsect_subj_code not in ('ACAD','REPS','TEST','XPEN','XSER')
		        AND d.START_DATE <= SYSDATE +7 AND d.END_DATE >= SYSDATE -16
		        AND a.ssbsect_term_code in (SELECT DISTINCT sobptrm_term_code FROM sobptrm
		                                    WHERE sobptrm_start_date <= SYSDATE +7 AND sobptrm_end_date >= SYSDATE -16)
			) f, ssbsect g
	WHERE f.ssbsect_term_code = g.ssbsect_term_code AND f.nrc_madre = g.ssbsect_crn
		AND f.ssbsect_crn <> f.nrc_madre;
  spool off
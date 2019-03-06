select 'EXTERNAL_PERSON_KEY|USER_ID|FIRSTNAME|LASTNAME|EMAIL|ROW_STATUS|AVAILABLE_IND|DATA_SOURCE_KEY|M_PHONE' from dual;
    SELECT DISTINCT
        a.EXTERNAL_PERSON_KEY ||'|'||
        b.spriden_id ||'|'||
        b.spriden_first_name ||'|'||
        REPLACE(b.spriden_last_name,'/',' ') ||'|'||
        CASE WHEN MAX(a.PREFERENCIA) OVER(PARTITION BY a.EXTERNAL_PERSON_KEY) = 'DOCENTE'
          THEN c.GOREMAL_EMAIL_ADDRESS ELSE b.spriden_id ||'@upn.pe' END ||'|'||
        a.ROW_STATUS ||'|'||
        a.AVAILABLE_IND ||'|'||
        'UPN.Usuarios.Banner' ||'|'||
        MAX(case when d.sprtele_tele_code = 'CP' then d.sprtele_phone_number else null end) OVER(PARTITION BY d.sprtele_pidm)
    FROM (SELECT DISTINCT
              a.sfrstcr_pidm AS EXTERNAL_PERSON_KEY
              , CASE WHEN c.sfbetrm_ests_code = 'EL' THEN 'ENABLED'
                  ELSE 'DISABLED' END AS ROW_STATUS
              , CASE WHEN c.sfbetrm_ests_code = 'EL' THEN 'Y'
                  ELSE 'N' END AS AVAILABLE_IND
              , NULL AS PREFERENCIA
          FROM sfrstcr a,
               ssbsect b,
               sfbetrm c,
               (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
                    , MIN(SSRMEET_START_DATE) AS START_DATE
                    , MAX(SSRMEET_END_DATE) AS END_DATE
                FROM SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN) d
          WHERE a.sfrstcr_term_code = b.ssbsect_term_code AND a.sfrstcr_crn = b.ssbsect_crn
              AND a.sfrstcr_pidm = c.sfbetrm_pidm AND a.sfrstcr_term_code = c.sfbetrm_term_code
              AND b.ssbsect_term_code = d.ssrmeet_term_code AND b.ssbsect_crn = d.ssrmeet_crn
              AND a.sfrstcr_rsts_code IN ('RE','RW','RA')
              AND c.sfbetrm_ests_code IS NOT NULL
              AND b.ssbsect_subj_code not in ('ACAD','REPS','TEST','XPEN','XSER')
              AND d.START_DATE <= SYSDATE +7 AND d.END_DATE >= SYSDATE -16
              AND b.ssbsect_term_code in (SELECT DISTINCT sobptrm_term_code FROM sobptrm
                                          WHERE sobptrm_start_date <= SYSDATE +7 AND sobptrm_end_date >= SYSDATE -16)
          UNION
          SELECT DISTINCT
              a.sirasgn_pidm AS EXTERNAL_PERSON_KEY
              , CASE WHEN c.sibinst_fcst_code = 'AC' THEN 'ENABLED' ELSE 'DISABLED' END AS ROW_STATUS
              , CASE WHEN c.sibinst_fcst_code = 'AC' THEN 'Y' ELSE 'N' END AS AVAILABLE_IND
              , 'DOCENTE' AS PREFERENCIA
          FROM sirasgn a,
               ssbsect b,
               (SELECT SIBINST_PIDM, SIBINST_TERM_CODE_EFF, SIBINST_FCST_CODE, MAX(SIBINST_TERM_CODE_EFF) OVER(PARTITION BY SIBINST_PIDM) AS MAX_PERIOD
                FROM SIBINST WHERE SIBINST_TERM_CODE_EFF <> '999996') c,
               (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
                    , MIN(SSRMEET_START_DATE) AS START_DATE
                    , MAX(SSRMEET_END_DATE) AS END_DATE
                FROM SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN) d
          WHERE a.sirasgn_term_code = b.ssbsect_term_code AND a.sirasgn_crn = b.ssbsect_crn
              AND a.sirasgn_pidm = c.sibinst_pidm
              AND b.ssbsect_term_code = d.ssrmeet_term_code AND b.ssbsect_crn = d.ssrmeet_crn
              AND c.SIBINST_TERM_CODE_EFF = c.MAX_PERIOD
              AND c.sibinst_fcst_code = 'AC'
              AND d.START_DATE <= SYSDATE +7 AND d.END_DATE >= SYSDATE -16
              AND b.ssbsect_term_code in (SELECT DISTINCT sobptrm_term_code FROM sobptrm
                                          WHERE sobptrm_start_date <= SYSDATE +7 AND sobptrm_end_date >= SYSDATE -16)) a, 
         spriden b, 
         (SELECT GOREMAL_PIDM, GOREMAL_EMAIL_ADDRESS
          FROM (SELECT GOREMAL_PIDM, GOREMAL_EMAIL_ADDRESS, GOREMAL_ACTIVITY_DATE, MAX(GOREMAL_ACTIVITY_DATE) OVER(PARTITION BY GOREMAL_PIDM) AS MAX_DATE FROM GOREMAL
                WHERE GOREMAL_STATUS_IND = 'A' AND GOREMAL_EMAL_CODE = 'UNIV')
          WHERE GOREMAL_ACTIVITY_DATE = MAX_DATE) c, 
         SPRTELE d
    WHERE a.EXTERNAL_PERSON_KEY = b.spriden_pidm AND b.spriden_change_ind IS NULL
        AND a.EXTERNAL_PERSON_KEY = c.GOREMAL_PIDM(+)
        AND a.EXTERNAL_PERSON_KEY = d.sprtele_pidm(+)
        AND d.sprtele_tele_code(+) = 'CP';
  spool off
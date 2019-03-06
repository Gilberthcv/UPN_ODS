select 'EXTERNAL_PERSON_KEY|USER_ID|FIRSTNAME|LASTNAME|EMAIL|ROW_STATUS|AVAILABLE_IND|DATA_SOURCE_KEY|M_PHONE' from dual;
    SELECT DISTINCT
        a.sfrstcr_pidm ||'|'||
        d.spriden_id ||'|'||
        d.spriden_first_name || d.spriden_mi ||'|'||
        REPLACE(d.spriden_last_name,'/',' ') ||'|'||
        d.spriden_id ||'@upn.pe'||'|'|| --bannerID@upn.pe
        CASE WHEN c.sfbetrm_ests_code = 'EL' THEN 'ENABLED'
          ELSE 'DISABLED' END ||'|'||
        CASE WHEN c.sfbetrm_ests_code = 'EL' THEN 'Y'
          ELSE 'N' END ||'|'||
        CASE SUBSTR(a.sfrstcr_term_code,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
            WHEN '3' THEN 'UPN.Usuarios.Banner.PDN'
            WHEN '4' THEN 'UPN.Usuarios.Banner.UG'
            WHEN '5' THEN 'UPN.Usuarios.Banner.WA'
            WHEN '7' THEN 'UPN.Usuarios.Banner.Ingles'
          ELSE 'UPN.Usuarios.Banner.EPEC' END ||'|'||
        MAX(case when e.sprtele_tele_code = 'CP' then e.sprtele_phone_number else null end) OVER(PARTITION BY e.sprtele_pidm)
    FROM sfrstcr a,
         ssbsect b,
         sfbetrm c,
         spriden d,
         sprtele e
    WHERE a.sfrstcr_term_code = b.ssbsect_term_code AND a.sfrstcr_crn = b.ssbsect_crn
        AND a.sfrstcr_pidm = c.sfbetrm_pidm AND a.sfrstcr_term_code = c.sfbetrm_term_code
        AND a.sfrstcr_pidm = d.spriden_pidm AND d.spriden_change_ind IS NULL
        AND a.sfrstcr_pidm = e.sprtele_pidm(+) AND e.sprtele_tele_code(+) = 'CP'
        AND a.sfrstcr_rsts_code IN ('RE','RW','RA')
        AND c.sfbetrm_ests_code IS NOT NULL
        AND b.ssbsect_subj_code not in ('ACAD','REPS','TEST','XPEN','XSER')
        AND b.ssbsect_ptrm_start_date <= SYSDATE +7 AND b.ssbsect_ptrm_end_date >= SYSDATE -16
        AND b.ssbsect_term_code in (SELECT DISTINCT term_code FROM LOE_SECTION_PART_OF_TERM
                                    WHERE start_date <= SYSDATE +7 AND end_date >= SYSDATE -16)
    UNION
    SELECT DISTINCT
        a.sirasgn_pidm ||'|'||
        d.spriden_id ||'|'||
        d.spriden_first_name || d.spriden_mi ||'|'||
        REPLACE(d.spriden_last_name,'/',' ') ||'|'||
        f.GOREMAL_EMAIL_ADDRESS ||'|'||
        CASE WHEN c.sibinst_fcst_code = 'AC' THEN 'ENABLED' ELSE 'DISABLED' END ||'|'||
        CASE WHEN c.sibinst_fcst_code = 'AC' THEN 'Y' ELSE 'N' END ||'|'||
        CASE SUBSTR(a.sirasgn_term_code,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
            WHEN '3' THEN 'UPN.Usuarios.Banner.PDN'
            WHEN '4' THEN 'UPN.Usuarios.Banner.UG'
            WHEN '5' THEN 'UPN.Usuarios.Banner.WA'
            WHEN '7' THEN 'UPN.Usuarios.Banner.Ingles'
          ELSE 'UPN.Usuarios.Banner.EPEC' END ||'|'||
        MAX(case when e.sprtele_tele_code = 'CP' then e.sprtele_phone_number else null end) OVER(PARTITION BY e.sprtele_pidm)
    FROM sirasgn a,
         ssbsect b,
         (SELECT SIBINST_PIDM, SIBINST_TERM_CODE_EFF, SIBINST_FCST_CODE, MAX(SIBINST_TERM_CODE_EFF) OVER(PARTITION BY SIBINST_PIDM) AS MAX_PERIOD
          FROM SIBINST WHERE SIBINST_TERM_CODE_EFF <> '999996') c,
         spriden d,
         SPRTELE e,
         (SELECT GOREMAL_PIDM, GOREMAL_EMAIL_ADDRESS
          FROM (SELECT GOREMAL_PIDM, GOREMAL_EMAIL_ADDRESS, GOREMAL_ACTIVITY_DATE, MAX(GOREMAL_ACTIVITY_DATE) OVER(PARTITION BY GOREMAL_PIDM) AS MAX_DATE FROM GOREMAL
                WHERE GOREMAL_STATUS_IND = 'A' AND GOREMAL_EMAL_CODE = 'UNIV')
          WHERE GOREMAL_ACTIVITY_DATE = MAX_DATE) f
    WHERE a.sirasgn_term_code = b.ssbsect_term_code AND a.sirasgn_crn = b.ssbsect_crn
        AND a.sirasgn_pidm = c.sibinst_pidm
        AND c.SIBINST_TERM_CODE_EFF = c.MAX_PERIOD
        AND a.sirasgn_pidm = d.spriden_pidm
        AND d.spriden_change_ind IS NULL        
        AND a.sirasgn_pidm = e.sprtele_pidm(+)
        AND a.sirasgn_pidm = f.GOREMAL_PIDM(+)
        AND c.sibinst_fcst_code = 'AC'
        AND e.sprtele_tele_code(+) = 'CP'
        AND b.ssbsect_ptrm_start_date <= SYSDATE +7 AND b.ssbsect_ptrm_end_date >= SYSDATE -16
        AND b.ssbsect_term_code in (SELECT DISTINCT term_code FROM LOE_SECTION_PART_OF_TERM
                                    WHERE start_date <= SYSDATE +7 AND end_date >= SYSDATE -16);
  spool off
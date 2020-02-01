--users
select 'EXTERNAL_PERSON_KEY|USER_ID|FIRSTNAME|LASTNAME|EMAIL|ROW_STATUS|AVAILABLE_IND|DATA_SOURCE_KEY|M_PHONE' from dual;
    SELECT DISTINCT
        a.sfrstcr_pidm ||'|'||
        f.spriden_id ||'|'||
        f.spriden_first_name ||'|'||
        REPLACE(f.spriden_last_name,'/',' ') ||'|'||
        f.spriden_id ||'@upn.pe' ||'|'||
        CASE WHEN c.sfbetrm_ests_code = 'EL' THEN 'ENABLED'
            ELSE 'DISABLED' END ||'|'||
        CASE WHEN c.sfbetrm_ests_code = 'EL' THEN 'Y'
            ELSE 'N' END ||'|'||
        'UPN.Usuarios.Banner' ||'|'||
        MAX(case when g.sprtele_tele_code = 'CP' then g.sprtele_phone_number else null end) OVER(PARTITION BY g.sprtele_pidm)
    FROM sfrstcr a,
         ssbsect b,
         sfbetrm c,
         SORLCUR e,
         spriden f,
         SPRTELE g
    WHERE a.sfrstcr_term_code = b.ssbsect_term_code AND a.sfrstcr_crn = b.ssbsect_crn
        AND a.sfrstcr_pidm = c.sfbetrm_pidm AND a.sfrstcr_term_code = c.sfbetrm_term_code
        AND a.sfrstcr_rsts_code IN ('RE','RW','RA')
        AND c.sfbetrm_ests_code IS NOT NULL
        AND a.SFRSTCR_PIDM = e.SORLCUR_PIDM
        AND e.SORLCUR_LMOD_CODE = 'LEARNER' AND e.SORLCUR_CACT_CODE = 'ACTIVE'
        AND e.SORLCUR_LEVL_CODE = 'UG' AND e.SORLCUR_TERM_CODE_END IS NULL
        AND e.SORLCUR_STYP_CODE = 'N'
        AND a.sfrstcr_pidm = f.spriden_pidm AND f.spriden_change_ind IS NULL
        AND a.sfrstcr_pidm = g.sprtele_pidm(+) AND g.sprtele_tele_code(+) = 'CP'
        AND b.ssbsect_subj_code not in ('ACAD','REPS','TEST','XPEN','XSER')
        AND b.ssbsect_term_code in ('220413','220513');
  spool off

--enrollments
select 'EXTERNAL_COURSE_KEY|EXTERNAL_PERSON_KEY|ROLE|DATA_SOURCE_KEY' from dual;
    SELECT DISTINCT
        case when b.SSBSECT_SCHD_CODE = 'VIR' OR b.ssbsect_insm_code = 'V'
            then b.ssbsect_subj_code ||'.'|| b.ssbsect_crse_numb ||'.'|| b.ssbsect_term_code ||'.'|| b.ssbsect_crn ||'.'|| 'V'
          else b.ssbsect_subj_code ||'.'|| b.ssbsect_crse_numb ||'.'|| b.ssbsect_term_code ||'.'|| b.ssbsect_crn ||'.'|| 'P' end ||'|'||
        a.sfrstcr_pidm ||
        '|S|' ||
        CASE SUBSTR(a.sfrstcr_term_code,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
            WHEN '3' THEN 'UPN.Matriculas.Banner.PDN'
            WHEN '4' THEN 'UPN.Matriculas.Banner.UG'
            WHEN '5' THEN 'UPN.Matriculas.Banner.WA'
            WHEN '7' THEN 'UPN.Matriculas.Banner.Ingles'
          ELSE 'UPN.Matriculas.Banner.EPEC' END
    FROM sfrstcr a,
         ssbsect b,
         SORLCUR d
    WHERE a.sfrstcr_term_code = b.ssbsect_term_code AND a.sfrstcr_crn = b.ssbsect_crn
        AND a.sfrstcr_rsts_code in ('RE','RW','RA')
        AND b.SSBSECT_SSTS_CODE = 'A' AND b.SSBSECT_MAX_ENRL > 0 AND b.SSBSECT_ENRL > 0
        AND a.SFRSTCR_PIDM = d.SORLCUR_PIDM
        AND d.SORLCUR_LMOD_CODE = 'LEARNER' AND d.SORLCUR_CACT_CODE = 'ACTIVE'
        AND d.SORLCUR_LEVL_CODE = 'UG' AND d.SORLCUR_TERM_CODE_END IS NULL
        AND d.SORLCUR_STYP_CODE = 'N'
        AND b.ssbsect_subj_code not in ('ACAD','REPS','TEST','XPEN','XSER')
        AND b.ssbsect_term_code in ('220413','220513');
  spool off

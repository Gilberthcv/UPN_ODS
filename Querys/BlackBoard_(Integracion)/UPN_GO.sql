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
        'UPN.Usuarios.UPNGO' ||'|'||
        MAX(case when g.sprtele_tele_code = 'CP' then g.sprtele_phone_number else null end) OVER(PARTITION BY g.sprtele_pidm)
    FROM sfrstcr a,
         ssbsect b,
         sfbetrm c,
         LOE_SOVLCUR e,
         spriden f,
         SPRTELE g
    WHERE a.sfrstcr_term_code = b.ssbsect_term_code AND a.sfrstcr_crn = b.ssbsect_crn
        AND a.sfrstcr_pidm = c.sfbetrm_pidm AND a.sfrstcr_term_code = c.sfbetrm_term_code
        AND a.sfrstcr_rsts_code IN ('RE','RW','RA')
        AND c.sfbetrm_ests_code IS NOT NULL
        AND a.SFRSTCR_PIDM = e.SOVLCUR_PIDM
        AND e.SOVLCUR_LMOD_CODE = 'LEARNER' AND e.SOVLCUR_CACT_CODE = 'ACTIVE'
        AND e.SOVLCUR_LEVL_CODE = 'UG' AND e.SOVLCUR_TERM_CODE_END IS NULL
        AND e.SOVLCUR_STYP_CODE = 'N'
        AND a.sfrstcr_pidm = f.spriden_pidm AND f.spriden_change_ind IS NULL
        AND a.sfrstcr_pidm = g.sprtele_pidm(+) AND g.sprtele_tele_code(+) = 'CP'
        AND b.ssbsect_subj_code not in ('ACAD','REPS','TEST','XPEN','XSER')
        AND b.ssbsect_term_code in ('220413');
  spool off

--enrollments
select 'EXTERNAL_COURSE_KEY|EXTERNAL_PERSON_KEY|ROLE|DATA_SOURCE_KEY' from dual;
    SELECT DISTINCT
        'UPN.GO.' || a.sfrstcr_term_code ||'.'|| 
            CASE SOVLCUR_CAMP_CODE 
                WHEN 'CAJ' THEN 'CAJAMARCA' 
                WHEN 'LC0' THEN 'BRENA' 
                WHEN 'LE0' THEN 'SJL' 
                WHEN 'LN0' THEN 'LOSOLIVOS' 
                WHEN 'LN1' THEN 'COMAS' 
                WHEN 'LS0' THEN 'CHORRILLOS' 
                WHEN 'TML' THEN 'TRUJILLO' 
                WHEN 'TSI' THEN 'TRUJILLOSI' 
            ELSE NULL END ||'|'||
        a.sfrstcr_pidm ||
        '|S|' ||
        CASE SUBSTR(a.sfrstcr_term_code,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
            WHEN '3' THEN 'UPN.Matriculas.UPNGO.PDN'
            WHEN '4' THEN 'UPN.Matriculas.UPNGO.UG'
            WHEN '5' THEN 'UPN.Matriculas.UPNGO.WA'
            WHEN '7' THEN 'UPN.Matriculas.UPNGO.Ingles'
          ELSE 'UPN.Matriculas.UPNGO.EPEC' END
    FROM sfrstcr a,
         ssbsect b,
         LOE_SOVLCUR d
    WHERE a.sfrstcr_term_code = b.ssbsect_term_code AND a.sfrstcr_crn = b.ssbsect_crn
        AND a.sfrstcr_rsts_code in ('RE','RW','RA')
        AND b.SSBSECT_SSTS_CODE = 'A' AND b.SSBSECT_MAX_ENRL > 0 AND b.SSBSECT_ENRL > 0
        AND a.SFRSTCR_PIDM = d.SOVLCUR_PIDM
        AND d.SOVLCUR_LMOD_CODE = 'LEARNER' AND d.SOVLCUR_CACT_CODE = 'ACTIVE'
        AND d.SOVLCUR_LEVL_CODE = 'UG' AND d.SOVLCUR_TERM_CODE_END IS NULL
        AND d.SOVLCUR_STYP_CODE = 'N'
        AND b.ssbsect_subj_code not in ('ACAD','REPS','TEST','XPEN','XSER')
        AND b.ssbsect_term_code in ('220413');
  spool off

--courses
select 'EXTERNAL_COURSE_KEY|COURSE_ID|COURSE_NAME|AVAILABLE_IND|ROW_STATUS|DURATION|START_DATE|END_DATE|TERM_KEY|DATA_SOURCE_KEY|PRIMARY_EXTERNAL_NODE_KEY|EXTERNAL_ASSOCIATION_KEY' from dual;
    SELECT
        'UPN.GO.' || TERM_CODE ||'.'|| 
            CASE STVCAMP_CODE 
                WHEN 'CAJ' THEN 'CAJAMARCA' 
                WHEN 'LC0' THEN 'BRENA' 
                WHEN 'LE0' THEN 'SJL' 
                WHEN 'LN0' THEN 'LOSOLIVOS' 
                WHEN 'LN1' THEN 'COMAS' 
                WHEN 'LS0' THEN 'CHORRILLOS' 
                WHEN 'TML' THEN 'TRUJILLO' 
                WHEN 'TSI' THEN 'TRUJILLOSI' 
            ELSE NULL END ||'|'||
        'UPN.GO.' || TERM_CODE ||'.'|| 
            CASE STVCAMP_CODE 
                WHEN 'CAJ' THEN 'CAJAMARCA' 
                WHEN 'LC0' THEN 'BRENA' 
                WHEN 'LE0' THEN 'SJL' 
                WHEN 'LN0' THEN 'LOSOLIVOS' 
                WHEN 'LN1' THEN 'COMAS' 
                WHEN 'LS0' THEN 'CHORRILLOS' 
                WHEN 'TML' THEN 'TRUJILLO' 
                WHEN 'TSI' THEN 'TRUJILLOSI' 
            ELSE NULL END ||'|'||
        'JUEGA Y APRENDE' ||'|'||
        'Y' ||'|'||
        'ENABLED' ||'|'||
        'R|'||
        TO_CHAR(START_DATE -7,'YYYYMMDD') ||'|'||
        TO_CHAR(END_DATE +16,'YYYYMMDD') ||'|'||
        TERM_CODE ||'|'||
        CASE SUBSTR(TERM_CODE,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
            WHEN '3' THEN 'UPN.Cursos.UPNGO.PDN'
            WHEN '4' THEN 'UPN.Cursos.UPNGO.UG'
            WHEN '5' THEN 'UPN.Cursos.UPNGO.WA'
            WHEN '7' THEN 'UPN.Cursos.UPNGO.Ingles'
          ELSE 'UPN.Cursos.UPNGO.EPEC' END ||'|'||
        'PEPN01.UPN.UPNGO.' || TERM_CODE ||'|'||
        STVCAMP_CODE || '.PEPN01.UPN.UPNGO.' || TERM_CODE
    FROM LOE_SECTION_PART_OF_TERM, STVCAMP
    WHERE STVCAMP_CODE NOT IN ('M','VIR')
        AND TERM_CODE IN ('220413');
  spool off

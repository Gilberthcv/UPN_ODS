--users
--select 'EXTERNAL_PERSON_KEY|USER_ID|FIRSTNAME|LASTNAME|EMAIL|ROW_STATUS|AVAILABLE_IND|DATA_SOURCE_KEY|M_PHONE' from dual;
    SELECT DISTINCT
        a.sfrstcr_pidm AS EXTERNAL_PERSON_KEY
        , c.spriden_id AS USER_ID
        , c.spriden_first_name AS FIRSTNAME
        , REPLACE(c.spriden_last_name,'/',' ') AS LASTNAME
        , c.spriden_id ||'@upn.pe' AS EMAIL
        , CASE WHEN b.sfbetrm_ests_code = 'EL' THEN 'ENABLED'
            ELSE 'DISABLED' END AS ROW_STATUS
        , CASE WHEN b.sfbetrm_ests_code = 'EL' THEN 'Y'
            ELSE 'N' END AS AVAILABLE_IND
        , 'UPN.Usuarios.Banner' AS DATA_SOURCE_KEY
        , MAX(case when d.sprtele_tele_code = 'CP' then d.sprtele_phone_number else null end) OVER(PARTITION BY d.sprtele_pidm) AS M_PHONE
    FROM ( SELECT DISTINCT SFRSTCR_PIDM, SFRSTCR_TERM_CODE, SOVLCUR_CAMP_CODE, NVL(SOVLCUR_STYP_CODE,'C') AS SOVLCUR_STYP_CODE
                , COHORT, CASE WHEN SSBSECT_SUBJ_CODE = 'RRHH' AND SSBSECT_CRSE_NUMB = '1101' THEN 'RRHH1101' END AS CURSO
            FROM ODSMGR.SFRSTCR, ODSMGR.LOE_SSBSECT, ODSMGR.LOE_SOVLCUR, ODSMGR.STUDENT_COHORT
            WHERE SFRSTCR_TERM_CODE = SSBSECT_TERM_CODE AND SFRSTCR_CRN = SSBSECT_CRN
                AND SSBSECT_SUBJ_CODE NOT IN ('ACAD','REPS','TEST','XPEN','XSER')
                AND SFRSTCR_PIDM = SOVLCUR_PIDM
                AND SOVLCUR_LMOD_CODE = 'LEARNER' AND SOVLCUR_CACT_CODE = 'ACTIVE'
                AND SOVLCUR_LEVL_CODE = 'UG' AND SOVLCUR_TERM_CODE_END IS NULL
                AND SFRSTCR_PIDM = PERSON_UID(+) AND SFRSTCR_TERM_CODE = ACADEMIC_PERIOD(+)
                AND COHORT(+) = 'NEW_REING' AND COHORT_ACTIVE_IND(+) = 'Y'
                AND SFRSTCR_RSTS_CODE IN ('RE','RW','RA')                
                AND SSBSECT_TERM_CODE IN ('220435','220534') ) a,
         ODSMGR.sfbetrm b,
         ODSMGR.LOE_SPRIDEN c,
         ODSMGR.SPRTELE d
    WHERE a.sfrstcr_pidm = b.sfbetrm_pidm AND a.sfrstcr_term_code = b.sfbetrm_term_code        
        AND b.sfbetrm_ests_code IS NOT NULL
        AND a.sfrstcr_pidm = c.spriden_pidm AND c.spriden_change_ind IS NULL
        AND a.sfrstcr_pidm = d.sprtele_pidm(+) AND d.sprtele_tele_code(+) = 'CP'
        AND a.SOVLCUR_STYP_CODE = 'N';
  spool off

--enrollments
--select 'EXTERNAL_COURSE_KEY|EXTERNAL_PERSON_KEY|ROLE|DATA_SOURCE_KEY' from dual;
    SELECT DISTINCT
        'UPN.GO.' || a.sfrstcr_term_code ||'.'|| 
            CASE a.SOVLCUR_CAMP_CODE 
                WHEN 'CAJ' THEN 'CAJAMARCA' 
                WHEN 'LC0' THEN 'BRENA' 
                WHEN 'LE0' THEN 'SJL' 
                WHEN 'LN0' THEN 'LOSOLIVOS' 
                WHEN 'LN1' THEN 'COMAS' 
                WHEN 'LS0' THEN 'CHORRILLOS' 
                WHEN 'TML' THEN 'TRUJILLO' 
                WHEN 'TSI' THEN 'TRUJILLOSI' 
            ELSE NULL END AS EXTERNAL_COURSE_KEY
        , a.sfrstcr_pidm AS EXTERNAL_PERSON_KEY
        , 'S' AS ROLE
        , CASE SUBSTR(a.sfrstcr_term_code,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
            WHEN '3' THEN 'UPN.Matriculas.UPNGO.PDN'
            WHEN '4' THEN 'UPN.Matriculas.UPNGO.UG'
            WHEN '5' THEN 'UPN.Matriculas.UPNGO.WA'
            WHEN '7' THEN 'UPN.Matriculas.UPNGO.Ingles'
          ELSE 'UPN.Matriculas.UPNGO.EPEC' END AS DATA_SOURCE_KEY
    FROM ( SELECT DISTINCT SFRSTCR_PIDM, SFRSTCR_TERM_CODE, SOVLCUR_CAMP_CODE, NVL(SOVLCUR_STYP_CODE,'C') AS SOVLCUR_STYP_CODE
                , COHORT, CASE WHEN SSBSECT_SUBJ_CODE = 'RRHH' AND SSBSECT_CRSE_NUMB = '1101' THEN 'RRHH1101' END AS CURSO
            FROM ODSMGR.SFRSTCR, ODSMGR.LOE_SSBSECT, ODSMGR.LOE_SOVLCUR, ODSMGR.STUDENT_COHORT
            WHERE SFRSTCR_TERM_CODE = SSBSECT_TERM_CODE AND SFRSTCR_CRN = SSBSECT_CRN
                AND SSBSECT_SSTS_CODE = 'A' AND SSBSECT_MAX_ENRL > 0 AND SSBSECT_ENRL > 0
                AND SSBSECT_SUBJ_CODE NOT IN ('ACAD','REPS','TEST','XPEN','XSER')
                AND SFRSTCR_PIDM = SOVLCUR_PIDM
                AND SOVLCUR_LMOD_CODE = 'LEARNER' AND SOVLCUR_CACT_CODE = 'ACTIVE'
                AND SOVLCUR_LEVL_CODE = 'UG' AND SOVLCUR_TERM_CODE_END IS NULL
                AND SFRSTCR_PIDM = PERSON_UID(+) AND SFRSTCR_TERM_CODE = ACADEMIC_PERIOD(+)
                AND COHORT(+) = 'NEW_REING' AND COHORT_ACTIVE_IND(+) = 'Y'
                AND SFRSTCR_RSTS_CODE IN ('RE','RW','RA')                
                AND SSBSECT_TERM_CODE IN ('220435','220534') ) a
    WHERE a.SOVLCUR_STYP_CODE = 'N';
  spool off

--courses
--select 'EXTERNAL_COURSE_KEY|COURSE_ID|COURSE_NAME|AVAILABLE_IND|ROW_STATUS|DURATION|START_DATE|END_DATE|TERM_KEY|DATA_SOURCE_KEY|PRIMARY_EXTERNAL_NODE_KEY|EXTERNAL_ASSOCIATION_KEY' from dual;
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
            ELSE NULL END AS EXTERNAL_COURSE_KEY
        , 'UPN.GO.' || TERM_CODE ||'.'|| 
            CASE STVCAMP_CODE 
                WHEN 'CAJ' THEN 'CAJAMARCA' 
                WHEN 'LC0' THEN 'BRENA' 
                WHEN 'LE0' THEN 'SJL' 
                WHEN 'LN0' THEN 'LOSOLIVOS' 
                WHEN 'LN1' THEN 'COMAS' 
                WHEN 'LS0' THEN 'CHORRILLOS' 
                WHEN 'TML' THEN 'TRUJILLO' 
                WHEN 'TSI' THEN 'TRUJILLOSI' 
            ELSE NULL END AS COURSE_ID
        , 'JUEGA Y APRENDE' AS COURSE_NAME
        , 'Y' AS AVAILABLE_IND
        , 'ENABLED' AS ROW_STATUS
        , 'R' AS DURATION
        , TO_CHAR(TO_DATE(START_DATE) -7,'YYYYMMDD') AS START_DATE
        , TO_CHAR(TO_DATE(END_DATE) +16,'YYYYMMDD') AS END_DATE
        , TERM_CODE AS TERM_KEY
        , CASE SUBSTR(TERM_CODE,4,1) --'UPN.<Instancia>.Banner.<Nivel>'
            WHEN '3' THEN 'UPN.Cursos.UPNGO.PDN'
            WHEN '4' THEN 'UPN.Cursos.UPNGO.UG'
            WHEN '5' THEN 'UPN.Cursos.UPNGO.WA'
            WHEN '7' THEN 'UPN.Cursos.UPNGO.Ingles'
          ELSE 'UPN.Cursos.UPNGO.EPEC' END AS DATA_SOURCE_KEY
        , 'PEPN01.UPN.UPNGO.' || TERM_CODE AS PRIMARY_EXTERNAL_NODE_KEY
        , STVCAMP_CODE || '.PEPN01.UPN.UPNGO.' || TERM_CODE AS EXTERNAL_ASSOCIATION_KEY
    FROM ODSMGR.LOE_SECTION_PART_OF_TERM, ODSMGR.STVCAMP
    WHERE STVCAMP_CODE NOT IN ('M','VIR')
        AND TERM_CODE IN ('220435','220534');
  spool off

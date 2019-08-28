
SELECT DISTINCT a.SFRSTCR_TERM_CODE, a.SFRSTCR_PIDM, SPRIDEN_ID, SOVLCUR_CAMP_CODE, a.SFRSTCR_CRN, b.SSBSECT_SUBJ_CODE, b.SSBSECT_CRSE_NUMB
    , COALESCE(f.TITLE_SHORT_DESC,f.TITLE_LONG_DESC) AS CURSO, a.SFRSTCR_RSTS_CODE, a.SFRSTCR_RSTS_DATE
	, a.SFRSTCR_ADD_DATE, a.SFRSTCR_LEVL_CODE, a.SFRSTCR_CAMP_CODE, c.REQUISITOS, d.SFRSTCR_CRN, d.SSBSECT_SUBJ_CODE, d.SSBSECT_CRSE_NUMB
    , COALESCE(g.TITLE_SHORT_DESC,g.TITLE_LONG_DESC) AS CURSO_1, h.PERMIT_OVERRIDE_USER, SFRREGP_USER_ID
FROM SFRSTCR a, SSBSECT b, SPRIDEN, LOE_SOVLCUR, COURSE_CATALOG f, COURSE_CATALOG g, LOE_REGIS_PERMIT_OVERRIDE h, SFRREGP, 
    (SELECT SCRRTST_TERM_CODE_EFF, SCRRTST_SUBJ_CODE, SCRRTST_CRSE_NUMB
        , LISTAGG(TRIM(SCRRTST_CONNECTOR ||' '|| SCRRTST_LPAREN || SCRRTST_TESC_CODE || SCRRTST_TEST_SCORE || SCRRTST_SUBJ_CODE_PREQ || SCRRTST_CRSE_NUMB_PREQ || SCRRTST_RPAREN),' ') 
            WITHIN GROUP (ORDER BY SCRRTST_SEQNO) AS REQUISITOS
       	, MAX(SCRRTST_TERM_CODE_EFF) OVER(PARTITION BY SCRRTST_SUBJ_CODE,SCRRTST_CRSE_NUMB) AS MAX_TERM
    FROM LOE_SCRRTST WHERE SCRRTST_TERM_CODE_EFF <= '219534'
    GROUP BY SCRRTST_TERM_CODE_EFF, SCRRTST_SUBJ_CODE, SCRRTST_CRSE_NUMB) c, 
    (SELECT DISTINCT SFRSTCR_TERM_CODE, SFRSTCR_PIDM, SFRSTCR_CRN, SSBSECT_SUBJ_CODE, SSBSECT_CRSE_NUMB
	FROM SFRSTCR, SSBSECT
	WHERE SFRSTCR_TERM_CODE = SSBSECT_TERM_CODE AND SFRSTCR_CRN = SSBSECT_CRN
	    AND SFRSTCR_TERM_CODE IN ('219435','219534') AND SFRSTCR_RSTS_CODE IN ('RE','RW','RA')) d
WHERE a.SFRSTCR_TERM_CODE = b.SSBSECT_TERM_CODE AND a.SFRSTCR_CRN = b.SSBSECT_CRN
    AND b.SSBSECT_TERM_CODE >= c.SCRRTST_TERM_CODE_EFF(+) AND b.SSBSECT_SUBJ_CODE = c.SCRRTST_SUBJ_CODE(+) AND b.SSBSECT_CRSE_NUMB = c.SCRRTST_CRSE_NUMB(+)
    AND (SCRRTST_TERM_CODE_EFF = MAX_TERM OR SCRRTST_TERM_CODE_EFF IS NULL)
    AND a.SFRSTCR_TERM_CODE = d.SFRSTCR_TERM_CODE(+) AND a.SFRSTCR_PIDM = d.SFRSTCR_PIDM(+) AND c.REQUISITOS LIKE '%'||d.SSBSECT_SUBJ_CODE||d.SSBSECT_CRSE_NUMB||'%'
    AND a.SFRSTCR_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
     AND a.SFRSTCR_PIDM = SOVLCUR_PIDM(+) AND a.SFRSTCR_LEVL_CODE = SOVLCUR_LEVL_CODE(+) AND SOVLCUR_LMOD_CODE(+) = 'LEARNER' AND SOVLCUR_CACT_CODE(+) = 'ACTIVE'
        AND a.SFRSTCR_TERM_CODE < NVL(SOVLCUR_TERM_CODE_END(+),'999996') AND a.SFRSTCR_TERM_CODE >= SOVLCUR_TERM_CODE(+)
    AND b.SSBSECT_TERM_CODE >= f.ACADEMIC_PERIOD_START(+) AND b.SSBSECT_TERM_CODE < f.ACADEMIC_PERIOD_END(+)
        AND b.SSBSECT_SUBJ_CODE = f.SUBJECT(+) AND b.SSBSECT_CRSE_NUMB = f.COURSE_NUMBER(+)
    AND b.SSBSECT_TERM_CODE >= g.ACADEMIC_PERIOD_START(+) AND b.SSBSECT_TERM_CODE < g.ACADEMIC_PERIOD_END(+)
        AND d.SSBSECT_SUBJ_CODE = g.SUBJECT(+) AND d.SSBSECT_CRSE_NUMB = g.COURSE_NUMBER(+) 
    AND a.SFRSTCR_PIDM = h.PERSON_UID(+) AND a.SFRSTCR_TERM_CODE = h.ACADEMIC_PERIOD(+)
        AND b.SSBSECT_SUBJ_CODE = h.SUBJECT(+) AND b.SSBSECT_CRSE_NUMB = h.COURSE_NUMBER(+)
    AND a.SFRSTCR_PIDM = SFRREGP_PIDM(+) AND a.SFRSTCR_TERM_CODE = SFRREGP_TERM_CODE(+)
        AND b.SSBSECT_SUBJ_CODE = SFRREGP_SUBJ_CODE(+) AND b.SSBSECT_CRSE_NUMB = SFRREGP_CRSE_NUMB_LOW(+)
        AND SFRREGP_MAINT_IND(+) = 'U' AND (a.SFRSTCR_CRN = SFRREGP_CRN_SCHEDULE OR SFRREGP_CRN_SCHEDULE IS NULL)
    AND a.SFRSTCR_TERM_CODE IN ('219435','219534') AND a.SFRSTCR_RSTS_CODE IN ('RE','RW','RA')
ORDER BY a.SFRSTCR_TERM_CODE, a.SFRSTCR_PIDM, a.SFRSTCR_CRN;

---------------

SELECT DISTINCT a.SFRSTCR_TERM_CODE, a.SFRSTCR_PIDM, e.SPRIDEN_ID, SOVLCUR_PROGRAM, SOVLCUR_TERM_CODE_CTLG, j.ACT_CREDITS_OVERALL, a.SFRSTCR_CRN
    , b.SSBSECT_SUBJ_CODE, b.SSBSECT_CRSE_NUMB, COALESCE(f.TITLE_SHORT_DESC,f.TITLE_LONG_DESC) AS CURSO, a.SFRSTCR_RSTS_CODE, a.SFRSTCR_RSTS_DATE
    , a.SFRSTCR_ADD_DATE, a.SFRSTCR_LEVL_CODE, a.SFRSTCR_CAMP_CODE, c.REQUISITOS, d.SFRSTCR_CRN, d.SSBSECT_SUBJ_CODE, d.SSBSECT_CRSE_NUMB
    , COALESCE(g.TITLE_SHORT_DESC,g.TITLE_LONG_DESC) AS CURSO_1, h.PERMIT_OVERRIDE_USER, i.SPRIDEN_LAST_NAME, i.SPRIDEN_FIRST_NAME
FROM SFRSTCR a, SSBSECT b, SPRIDEN e, LOE_SOVLCUR, COURSE_CATALOG f, COURSE_CATALOG g, LOE_REGIS_PERMIT_OVERRIDE h, SPRIDEN i, 
    (SELECT SCRRTST_TERM_CODE_EFF, SCRRTST_SUBJ_CODE, SCRRTST_CRSE_NUMB
        , LISTAGG(TRIM(SCRRTST_CONNECTOR ||' '|| SCRRTST_LPAREN || SCRRTST_TESC_CODE || SCRRTST_TEST_SCORE || SCRRTST_SUBJ_CODE_PREQ || SCRRTST_CRSE_NUMB_PREQ || SCRRTST_RPAREN),' ') 
            WITHIN GROUP (ORDER BY SCRRTST_SEQNO) OVER(PARTITION BY SCRRTST_TERM_CODE_EFF, SCRRTST_SUBJ_CODE, SCRRTST_CRSE_NUMB) AS REQUISITOS
       	, MAX(SCRRTST_TERM_CODE_EFF) OVER(PARTITION BY SCRRTST_SUBJ_CODE,SCRRTST_CRSE_NUMB) AS MAX_TERM
    FROM LOE_SCRRTST WHERE SCRRTST_TERM_CODE_EFF <= '219534') c, 
    (SELECT DISTINCT SFRSTCR_TERM_CODE, SFRSTCR_PIDM, SFRSTCR_CRN, SSBSECT_SUBJ_CODE, SSBSECT_CRSE_NUMB
	FROM SFRSTCR, SSBSECT
	WHERE SFRSTCR_TERM_CODE = SSBSECT_TERM_CODE AND SFRSTCR_CRN = SSBSECT_CRN
	    AND SFRSTCR_TERM_CODE IN ('219435','219534') AND SFRSTCR_RSTS_CODE IN ('RE','RW','RA')) d, 
    (SELECT
        PERSON_UID, SEQUENCE_NUMBER, MAX(SEQUENCE_NUMBER) OVER(PARTITION BY PERSON_UID,PROGRAM) AS MAX_SEQ
        , PROGRAM, LEVL_CODE, CAMP_CODE, ACTIVITY_DATE, REQ_CREDITS_OVERALL, ACT_CREDITS_OVERALL
    FROM LOE_PROGRAM_OVERALL_RESULTS
    WHERE PROGRAM <> 'PREREQ' AND LEVL_CODE = 'UG') j
WHERE a.SFRSTCR_TERM_CODE = b.SSBSECT_TERM_CODE AND a.SFRSTCR_CRN = b.SSBSECT_CRN
    AND b.SSBSECT_TERM_CODE >= c.SCRRTST_TERM_CODE_EFF(+) AND b.SSBSECT_SUBJ_CODE = c.SCRRTST_SUBJ_CODE(+) AND b.SSBSECT_CRSE_NUMB = c.SCRRTST_CRSE_NUMB(+)
    AND (c.SCRRTST_TERM_CODE_EFF = c.MAX_TERM OR c.SCRRTST_TERM_CODE_EFF IS NULL)
    AND a.SFRSTCR_TERM_CODE = d.SFRSTCR_TERM_CODE(+) AND a.SFRSTCR_PIDM = d.SFRSTCR_PIDM(+) AND c.REQUISITOS LIKE '%'||d.SSBSECT_SUBJ_CODE||d.SSBSECT_CRSE_NUMB||'%'
    AND a.SFRSTCR_PIDM = e.SPRIDEN_PIDM AND e.SPRIDEN_CHANGE_IND IS NULL
    AND a.SFRSTCR_PIDM = SOVLCUR_PIDM(+) AND a.SFRSTCR_LEVL_CODE = SOVLCUR_LEVL_CODE(+) AND SOVLCUR_LMOD_CODE(+) = 'LEARNER' AND SOVLCUR_CACT_CODE(+) = 'ACTIVE'
        AND a.SFRSTCR_TERM_CODE < NVL(SOVLCUR_TERM_CODE_END(+),'999996') AND a.SFRSTCR_TERM_CODE >= SOVLCUR_TERM_CODE(+)
    AND b.SSBSECT_TERM_CODE >= f.ACADEMIC_PERIOD_START(+) AND b.SSBSECT_TERM_CODE < f.ACADEMIC_PERIOD_END(+)
        AND b.SSBSECT_SUBJ_CODE = f.SUBJECT(+) AND b.SSBSECT_CRSE_NUMB = f.COURSE_NUMBER(+)
    AND b.SSBSECT_TERM_CODE >= g.ACADEMIC_PERIOD_START(+) AND b.SSBSECT_TERM_CODE < g.ACADEMIC_PERIOD_END(+)
        AND d.SSBSECT_SUBJ_CODE = g.SUBJECT(+) AND d.SSBSECT_CRSE_NUMB = g.COURSE_NUMBER(+) 
    AND a.SFRSTCR_PIDM = h.PERSON_UID(+) AND a.SFRSTCR_TERM_CODE = h.ACADEMIC_PERIOD(+)
        AND b.SSBSECT_SUBJ_CODE = h.SUBJECT(+) AND b.SSBSECT_CRSE_NUMB = h.COURSE_NUMBER(+)
    AND SUBSTR(h.PERMIT_OVERRIDE_USER,2) = i.SPRIDEN_ID(+)
    AND a.SFRSTCR_PIDM = j.PERSON_UID(+) AND SOVLCUR_PROGRAM = j.PROGRAM(+) AND SOVLCUR_LEVL_CODE = j.LEVL_CODE(+)
    AND (j.SEQUENCE_NUMBER = j.MAX_SEQ OR j.SEQUENCE_NUMBER IS NULL)
    AND a.SFRSTCR_TERM_CODE IN ('219435','219534') AND a.SFRSTCR_RSTS_CODE IN ('RE','RW','RA')
ORDER BY a.SFRSTCR_TERM_CODE, a.SFRSTCR_PIDM, a.SFRSTCR_CRN;

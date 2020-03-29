
SELECT DISTINCT A.PERSON_UID, A.ID, A.NAME, A.ACADEMIC_PERIOD_ADMITTED, A.PROGRAM, A.PROGRAM_DESC, A.CAMPUS, A.CAMPUS_DESC, A.ENROLLMENT_STATUS
    , MAX(B.RECRUITER) OVER(PARTITION BY B.PERSON_UID,B.ACADEMIC_PERIOD,B.STUDENT_LEVEL,B.CAMPUS,B.PROGRAM) AS RECRUITER
    , MAX(B.RECRUITER_DESC) OVER(PARTITION BY B.PERSON_UID,B.ACADEMIC_PERIOD,B.STUDENT_LEVEL,B.CAMPUS,B.PROGRAM) AS RECRUITER_DESC
    , C.SUBJECT, C.COURSE_NUMBER, C.COURSE_REFERENCE_NUMBER, C.COURSE_TITLE_SHORT, C.REGISTRATION_STATUS
    , CASE WHEN D.SOVLCUR_STYP_CODE = 'N' THEN 'NUEVO' ELSE 'CONTINUO' END AS TIPO_ESTUDIANTE
    , SUM(E.AMOUNT) OVER(PARTITION BY E.ACCOUNT_UID,E.ACADEMIC_PERIOD) AS CUOTA_INICIAL_CONTADO
    , F.TBBESTU_EXEMPTION_CODE, G.TBBEXPT_DESC
FROM ACADEMIC_STUDY A, ADMISSIONS_APPLICATION B, STUDENT_COURSE C, LOE_SOVLCUR D
    , RECEIVABLE_ACCOUNT_DETAIL E, LOE_EXEMPTION_STU_AUTHOR F, LOE_TBBEXPT G
WHERE A.ACADEMIC_PERIOD_ADMITTED = B.ACADEMIC_PERIOD(+) AND A.PROGRAM = B.PROGRAM(+)
    AND A.CAMPUS = B.CAMPUS(+) AND A.PERSON_UID = B.PERSON_UID(+)
    AND A.STUDENT_LEVEL = B.STUDENT_LEVEL(+)
    AND A.PERSON_UID = C.PERSON_UID(+) AND A.ACADEMIC_PERIOD_ADMITTED = C.ACADEMIC_PERIOD(+)
    AND C.SUBJECT(+) = 'IDIO' AND C.REGISTRATION_STATUS(+) IN ('RE','RW','RA')
    AND A.PERSON_UID = D.SOVLCUR_PIDM
    AND D.SOVLCUR_SEQNO = (SELECT MAX(D1.SOVLCUR_SEQNO) FROM LOE_SOVLCUR D1
                            WHERE D1.SOVLCUR_PIDM = A.PERSON_UID AND D1.SOVLCUR_PROGRAM = A.PROGRAM
                                AND D1.SOVLCUR_CAMP_CODE = A.CAMPUS AND D1.SOVLCUR_LEVL_CODE = 'CR'
                                AND D1.SOVLCUR_LMOD_CODE = 'LEARNER' AND D1.SOVLCUR_CACT_CODE = 'ACTIVE'
                                AND A.ACADEMIC_PERIOD_ADMITTED >= D1.SOVLCUR_TERM_CODE
                                AND A.ACADEMIC_PERIOD_ADMITTED < NVL(D1.SOVLCUR_TERM_CODE_END,'999996'))
    AND A.PERSON_UID = E.ACCOUNT_UID(+) AND A.ACADEMIC_PERIOD_ADMITTED = E.ACADEMIC_PERIOD(+)
    AND SUBSTR(E.DETAIL_CODE(+),1,2) IN ('T1','TF')
    AND A.PERSON_UID = F.TBBESTU_PIDM(+) AND A.ACADEMIC_PERIOD_ADMITTED = F.TBBESTU_TERM_CODE(+)
    AND F.TBBESTU_DEL_IND(+) IS NULL
    AND F.TBBESTU_TERM_CODE = G.TBBEXPT_TERM_CODE(+) AND F.TBBESTU_EXEMPTION_CODE = G.TBBEXPT_EXEMPTION_CODE(+)
    AND A.ACADEMIC_PERIOD = A.ACADEMIC_PERIOD_ADMITTED AND A.STUDENT_LEVEL = 'CR'
    AND A.ENROLLMENT_STATUS IN ('EL','RF')
    AND A.ACADEMIC_PERIOD_ADMITTED IN ('220714','220715');

SELECT A.BUSINESS_UNIT, A.INVOICE, A.BILL_TO_CUST_ID, A.BILL_STATUS, A.BILL_TYPE_ID, A.BILLING_FREQUENCY, A.NAME1, A.INVOICE_AMOUNT
    , A.INVOICE_DT, A.PO_REF, A.ADD_DTTM, B.DESCR, B.NET_EXTENDED_AMT
    , CASE WHEN ( UPPER(B.DESCR) LIKE '%CUOTA%INI%' OR UPPER(B.DESCR) LIKE '%CUOTA 0%' OR UPPER(B.DESCR) LIKE '%CUOTA 1%' ) THEN 'T1'
            WHEN UPPER(B.DESCR) LIKE '%ARANCEL%CONTADO%' THEN 'TF' ELSE NULL END AS TIPO_CARGO
FROM PS_BI_HDR A, PS_BI_LINE B
WHERE A.BUSINESS_UNIT = B.BUSINESS_UNIT AND A.INVOICE = B.INVOICE
    AND (UPPER(B.DESCR) LIKE '%CUOTA%INI%' OR UPPER(B.DESCR) LIKE '%CUOTA 0%' OR UPPER(B.DESCR) LIKE '%CUOTA 1%'
        OR UPPER(B.DESCR) LIKE '%ARANCEL%CONTADO%')
    AND A.BUSINESS_UNIT = 'PER03' AND A.BILL_STATUS = 'INV' AND A.BILL_TYPE_ID IN ('B1','F1') AND A.BILLING_FREQUENCY = 'ONC'
    AND A.PO_REF IN ('220714','220715')

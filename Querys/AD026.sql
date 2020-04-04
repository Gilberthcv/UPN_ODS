SELECT DISTINCT BN.ACADEMIC_PERIOD, BN.CAMPUS_DESC, BN.PROGRAM_DESC, BN.PERSON_UID, BN.ID, BN.NAME, BN.HISTORIA_INGLES, BN.PERIODO_ADMISION
    , BN.DECISION_35, BN.DECISION_45, BN.CUOTA_INICIAL_CONTADO, BN.TBBEXPT_DESC, BN.TIPO_ESTUDIANTE
    , CASE WHEN BN.COURSE_REFERENCE_NUMBER IS NOT NULL THEN 'SI' ELSE 'NO' END AS REGISTRO_CURSO
    , CASE WHEN NVL(PS.CREATEDTTM,PS.LAST_ACTIVITY_DT) IS NOT NULL THEN 'SI' ELSE 'NO' END AS PAGO
    , CASE WHEN BN.COURSE_REFERENCE_NUMBER IS NOT NULL AND NVL(PS.CREATEDTTM,PS.LAST_ACTIVITY_DT) IS NOT NULL THEN 'MATRICULADO' ELSE 'NO MATRICULADO' END AS ESTADO
    , BN.RECRUITER_DESC, NVL(PS.CREATEDTTM,PS.LAST_ACTIVITY_DT) AS FECHA_PAGO, BN.COURSE_TITLE_SHORT
    , MAX(T.SPRTELE_PHONE_NUMBER) OVER(PARTITION BY T.SPRTELE_PIDM) AS CELULAR, C.GOREMAL_EMAIL_ADDRESS
FROM (((SELECT DISTINCT A.PERSON_UID, A.ID, A.NAME, A.ACADEMIC_PERIOD, CASE WHEN J.SHRTCKN_SUBJ_CODE IS NOT NULL THEN 'SI' ELSE 'NO' END AS HISTORIA_INGLES
            , MAX(A.ACADEMIC_PERIOD_ADMITTED) OVER(PARTITION BY A.PERSON_UID,A.ACADEMIC_PERIOD,A.PROGRAM,A.CAMPUS) AS PERIODO_ADMISION
            , H.DECISION AS DECISION_35, I.DECISION AS DECISION_45, A.PROGRAM, A.PROGRAM_DESC, A.CAMPUS, A.CAMPUS_DESC, A.ENROLLMENT_STATUS
            , MAX(B.RECRUITER) OVER(PARTITION BY B.PERSON_UID,B.ACADEMIC_PERIOD,B.STUDENT_LEVEL,B.CAMPUS,B.PROGRAM) AS RECRUITER
            , MAX(B.RECRUITER_DESC) OVER(PARTITION BY B.PERSON_UID,B.ACADEMIC_PERIOD,B.STUDENT_LEVEL,B.CAMPUS,B.PROGRAM) AS RECRUITER_DESC
            , C.SUBJECT, C.COURSE_NUMBER, C.COURSE_REFERENCE_NUMBER, C.COURSE_TITLE_SHORT, C.REGISTRATION_STATUS
            , CASE WHEN D.SOVLCUR_STYP_CODE = 'N' THEN 'NUEVO' ELSE 'CONTINUO' END AS TIPO_ESTUDIANTE
            , SUM(E.AMOUNT) OVER(PARTITION BY E.ACCOUNT_UID,E.ACADEMIC_PERIOD) AS CUOTA_INICIAL_CONTADO
            , F.TBBESTU_EXEMPTION_CODE, G.TBBEXPT_DESC
        FROM ACADEMIC_STUDY A, ADMISSIONS_APPLICATION B, STUDENT_COURSE C, LOE_SOVLCUR D, RECEIVABLE_ACCOUNT_DETAIL E
            , LOE_EXEMPTION_STU_AUTHOR F, LOE_TBBEXPT G, ADMISSIONS_DECISION H, ADMISSIONS_DECISION I, SHRTCKN J
        WHERE A.ACADEMIC_PERIOD = B.ACADEMIC_PERIOD(+) AND A.PROGRAM = B.PROGRAM(+)
            AND A.CAMPUS = B.CAMPUS(+) AND A.PERSON_UID = B.PERSON_UID(+)
            AND A.STUDENT_LEVEL = B.STUDENT_LEVEL(+)
            AND A.PERSON_UID = C.PERSON_UID(+) AND A.ACADEMIC_PERIOD = C.ACADEMIC_PERIOD(+)
            AND C.SUBJECT(+) = 'IDIO' AND C.REGISTRATION_STATUS(+) IN ('RE','RW','RA')
            AND A.PERSON_UID = D.SOVLCUR_PIDM
            AND D.SOVLCUR_SEQNO = (SELECT MAX(D1.SOVLCUR_SEQNO) FROM LOE_SOVLCUR D1
                                    WHERE D1.SOVLCUR_PIDM = A.PERSON_UID AND D1.SOVLCUR_PROGRAM = A.PROGRAM
                                        AND D1.SOVLCUR_CAMP_CODE = A.CAMPUS AND D1.SOVLCUR_LEVL_CODE = 'CR'
                                        AND D1.SOVLCUR_LMOD_CODE = 'LEARNER' AND D1.SOVLCUR_CACT_CODE = 'ACTIVE'
                                        AND A.ACADEMIC_PERIOD >= D1.SOVLCUR_TERM_CODE
                                        AND A.ACADEMIC_PERIOD < NVL(D1.SOVLCUR_TERM_CODE_END,'999996'))
            AND A.PERSON_UID = E.ACCOUNT_UID(+) AND A.ACADEMIC_PERIOD = E.ACADEMIC_PERIOD(+)
            AND SUBSTR(E.DETAIL_CODE(+),1,2) IN ('T1','TF')
            AND A.PERSON_UID = F.TBBESTU_PIDM(+) AND A.ACADEMIC_PERIOD = F.TBBESTU_TERM_CODE(+)
            AND F.TBBESTU_DEL_IND(+) IS NULL
            AND F.TBBESTU_TERM_CODE = G.TBBEXPT_TERM_CODE(+) AND F.TBBESTU_EXEMPTION_CODE = G.TBBEXPT_EXEMPTION_CODE(+)
            AND A.ACADEMIC_PERIOD = H.ACADEMIC_PERIOD(+) AND A.PERSON_UID = H.PERSON_UID(+)
            AND H.DECISION(+) = '35'
            AND A.ACADEMIC_PERIOD = I.ACADEMIC_PERIOD(+) AND A.PERSON_UID = I.PERSON_UID(+)
            AND I.DECISION(+) = '45'
            AND A.PERSON_UID = J.SHRTCKN_PIDM(+) AND J.SHRTCKN_SUBJ_CODE(+) = 'IDIO'
            --AND A.ACADEMIC_PERIOD = A.ACADEMIC_PERIOD_ADMITTED
            AND A.STUDENT_LEVEL = 'CR'
            AND A.ENROLLMENT_STATUS IN ('EL','RF')
            AND A.ACADEMIC_PERIOD IN ('220714','220715')) BN
    LEFT JOIN (
        SELECT C.INVOICE, SPRIDEN_PIDM, C.BILL_TO_CUST_ID, C.NAME1, C.INVOICE_AMOUNT, C.INVOICE_DT, C.PO_REF, C.ADD_DTTM, C.TIPO_CARGO
            , MAX(C.ADD_DTTM) OVER(PARTITION BY C.BILL_TO_CUST_ID,C.PO_REF) AS MAX_ADD_DTTM, D.ITEM_STATUS, D.BAL_AMT
            , D.LAST_ACTIVITY_DT, E.CREATEDTTM, MAX(E.CREATEDTTM) OVER(PARTITION BY E.INVOICE) MAX_CREATEDTTM
        FROM PS_ITEM D, PS_LI_GBL_ARPY_REF E, LOE_SPRIDEN, 
            (SELECT A.BUSINESS_UNIT, A.INVOICE, A.BILL_TO_CUST_ID, A.BILL_STATUS, A.BILL_TYPE_ID, A.BILLING_FREQUENCY, A.NAME1, A.INVOICE_AMOUNT
                , A.INVOICE_DT, A.PO_REF, A.ADD_DTTM, B.DESCR, B.NET_EXTENDED_AMT
                , CASE WHEN ( UPPER(B.DESCR) LIKE '%CUOTA%INI%' OR UPPER(B.DESCR) LIKE '%CUOTA 0%' OR UPPER(B.DESCR) LIKE '%CUOTA 1%' ) THEN 'T1'
                        WHEN UPPER(B.DESCR) LIKE '%ARANCEL%CONTADO%' THEN 'TF' ELSE NULL END AS TIPO_CARGO
            FROM PS_BI_HDR A, PS_BI_LINE B
            WHERE A.BUSINESS_UNIT = B.BUSINESS_UNIT AND A.INVOICE = B.INVOICE
                AND (UPPER(B.DESCR) LIKE '%CUOTA%INI%' OR UPPER(B.DESCR) LIKE '%CUOTA 0%' OR UPPER(B.DESCR) LIKE '%CUOTA 1%'
                    OR UPPER(B.DESCR) LIKE '%ARANCEL%CONTADO%')
                AND A.BUSINESS_UNIT = 'PER03' AND A.BILL_STATUS = 'INV' AND A.BILL_TYPE_ID IN ('B1','F1') AND A.BILLING_FREQUENCY = 'ONC'
                AND A.PO_REF IN ('220714','220715')) C
        WHERE C.BUSINESS_UNIT = D.BUSINESS_UNIT AND C.INVOICE = D.ITEM
            AND (D.DEDUCTION_STATUS <> 'REGU' OR D.DEDUCTION_STATUS IS NULL)
            AND C.BUSINESS_UNIT = E.DEPOSIT_BU(+) AND C.INVOICE = E.INVOICE(+)
            AND C.BILL_TO_CUST_ID = SPRIDEN_ID AND SPRIDEN_CHANGE_IND IS NULL) PS ON
                BN.PERSON_UID = PS.SPRIDEN_PIDM AND BN.ACADEMIC_PERIOD = PS.PO_REF
                AND PS.ADD_DTTM = PS.MAX_ADD_DTTM AND PS.CREATEDTTM = PS.MAX_CREATEDTTM)
    LEFT JOIN SPRTELE T ON
                BN.PERSON_UID = T.SPRTELE_PIDM AND T.SPRTELE_TELE_CODE = 'CP')
    LEFT JOIN (SELECT GOREMAL_PIDM, GOREMAL_EMAIL_ADDRESS
              FROM (SELECT GOREMAL_PIDM, GOREMAL_EMAIL_ADDRESS, GOREMAL_ACTIVITY_DATE
                        , MAX(GOREMAL_ACTIVITY_DATE) OVER(PARTITION BY GOREMAL_PIDM) AS MAX_DATE
                    FROM GOREMAL WHERE GOREMAL_STATUS_IND = 'A' AND GOREMAL_EMAL_CODE = 'PERS')
              WHERE GOREMAL_ACTIVITY_DATE = MAX_DATE) C ON
                BN.PERSON_UID = C.GOREMAL_PIDM;

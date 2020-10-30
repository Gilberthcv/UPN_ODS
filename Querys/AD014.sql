SELECT DISTINCT
    a.PERSON_UID, j.SPRIDEN_ID, CONCAT(CONCAT(j.SPRIDEN_LAST_NAME, ', '), j.SPRIDEN_FIRST_NAME) AS ESTUDIANTE
    , a.ACADEMIC_PERIOD, a.PROGRAM, a.PROGRAM_DESC, a.STUDENT_LEVEL, a.CAMPUS, a.ACADEMIC_PERIOD_ADMITTED, a.ENROLLMENT_STATUS
    , CASE a.STUDENT_POPULATION
        WHEN 'N'
            THEN CASE 
                    WHEN a.ADMISSIONS_POPULATION = 'II' THEN 'INTERCAMBIO IN'
                    ELSE 'NUEVO'
                END
        WHEN 'C'
            THEN CASE 
                    WHEN a.STUDENT_LEVEL = 'UG' AND
                        b.COHORT = 'NEW_REING'
                        THEN 'NUEVO REINGRESO'
                    WHEN a.STUDENT_LEVEL = 'UG' AND
                        b.COHORT = 'REINGRESO'
                        THEN 'REINGRESO'
                    WHEN a.ADMISSIONS_POPULATION = 'II' THEN 'INTERCAMBIO IN'
                    WHEN a.ADMISSIONS_POPULATION <> 'RE' AND
                        c.STUDENT_ATTRIBUTE = 'TINT'
                        THEN 'INTERCAMBIO OUT'
                    WHEN d.ACTIVITY = 'ITO' THEN 'INTERCAMBIO OUT'
                    ELSE 'CONTINUO'
                END
        ELSE a.STUDENT_POPULATION
    END AS TIPO_ESTUDIANTE
    , f_35.DECISION AS DECISION_35, f_45.DECISION AS DECISION_45
    , MAX(h_campus.VALUE2) OVER(PARTITION BY a.PERSON_UID, a.ACADEMIC_PERIOD) AS CAMPUS_TSA, i.ACTIVE_HOLD_IND
    , k.BILL_STATUS, l.ITEM_STATUS, l.BAL_AMT
FROM
    ((((((((((((ACADEMIC_STUDY a 
        LEFT JOIN STUDENT_COHORT b ON 
            a.PERSON_UID = b.PERSON_UID AND 
            a.ACADEMIC_PERIOD = b.ACADEMIC_PERIOD AND 
            b.COHORT_ACTIVE_IND = 'Y' AND 
            b.COHORT in ( 'NEW_REING', 'REINGRESO' ) )
        LEFT JOIN STUDENT_ATTRIBUTE c ON 
            a.PERSON_UID = c.PERSON_UID AND 
            a.ACADEMIC_PERIOD = c.ACADEMIC_PERIOD AND 
            c.STUDENT_ATTRIBUTE = 'TINT' )
        LEFT JOIN STUDENT_ACTIVITY d ON 
            a.PERSON_UID = d.PERSON_UID AND 
            a.ACADEMIC_PERIOD = d.ACADEMIC_PERIOD AND 
            d.ACTIVITY = 'ITO' )
        LEFT JOIN ADMISSIONS_APPLICATION e ON
            a.PERSON_UID = e.PERSON_UID AND
            a.ACADEMIC_PERIOD_ADMITTED = e.ACADEMIC_PERIOD AND
            a.CAMPUS = e.CAMPUS AND
            a.PROGRAM = e.PROGRAM AND
            a.STUDENT_LEVEL = e.STUDENT_LEVEL )
        LEFT JOIN ADMISSIONS_DECISION f_35 ON
            a.PERSON_UID = f_35.PERSON_UID AND
            a.ACADEMIC_PERIOD = f_35.ACADEMIC_PERIOD AND
            f_35.DECISION = '35' )
        LEFT JOIN ADMISSIONS_DECISION f_45 ON
            a.PERSON_UID = f_45.PERSON_UID AND
            a.ACADEMIC_PERIOD = f_45.ACADEMIC_PERIOD AND
            f_45.DECISION = '45' )
        LEFT JOIN RECEIVABLE_ACCOUNT_DETAIL g ON
            a.PERSON_UID = g.ACCOUNT_UID AND
            a.ACADEMIC_PERIOD = g.ACADEMIC_PERIOD AND
            SUBSTR(g.DETAIL_CODE,1,2) IN ('FM','XM','YM','ZM','T1','X1','Y1','Z1','TA','XA','YA','ZA','TF','XF','YF','ZF','E1','E2') AND
            (SUBSTR(g.CROSSREF_DETAIL_CODE,1,2) IN ('FM','XM','YM','ZM','T1','X1','Y1','Z1','TA','XA','YA','ZA','TF','XF','YF','ZF') OR g.CROSSREF_DETAIL_CODE is null) )
        LEFT JOIN ODSMGR.LOE_BASE_TABLE_EQUIV h_program ON 
            COALESCE( CASE
                        WHEN SUBSTR(g.DETAIL_CODE,1,2) IN ('FM','XM','YM','ZM','T1','X1','Y1','Z1','TA','XA','YA','ZA','TF','XF','YF','ZF')
                        THEN SUBSTR(g.DETAIL_CODE,3,2)
                        ELSE NULL
                    END,
                    CASE
                        WHEN SUBSTR(g.DETAIL_CODE,1,1) = 'E'
                        THEN SUBSTR(g.CROSSREF_DETAIL_CODE,3,2)
                        ELSE NULL
                    END) = h_program.VALUE1 AND 
            h_program.ESTADO = 'Y' AND
            h_program.TABLE_PARENT_ID = 17 AND
            (a.PROGRAM = h_program.VALUE2 OR h_program.VALUE2 IS NULL ) )
        LEFT JOIN ODSMGR.LOE_BASE_TABLE_EQUIV h_campus ON 
            CASE
                WHEN SUBSTR(g.DETAIL_CODE,1,1) = 'E'
                THEN SUBSTR(g.DETAIL_CODE,3,2)
                ELSE NULL
            END = h_campus.VALUE1 AND 
            h_campus.ESTADO = 'Y' AND
            h_campus.TABLE_PARENT_ID = 158
            --AND (a.CAMPUS = h_campus.VALUE2 OR h_campus.VALUE2 IS NULL )
            )
        LEFT JOIN HOLD i ON
            a.PERSON_UID = i.PERSON_UID AND
            i.HOLD IN ('C1','F1','M1') AND
            i.ACTIVE_HOLD_IND = 'Y' )
        LEFT JOIN LOE_SPRIDEN j ON
            a.PERSON_UID = j.SPRIDEN_PIDM AND
            j.SPRIDEN_CHANGE_IND IS NULL )
        LEFT JOIN (SELECT 
                k1.BUSINESS_UNIT
                , k1.INVOICE
                , k1.BILL_TO_CUST_ID
                , k1.INVOICE_AMOUNT
                , k1.FROM_DT
                , k1.TO_DT
                , k1.PO_REF
                , k1.BILL_STATUS
                , k1.BILL_TYPE_ID
                , k1.ADD_DTTM
                , MAX(k1.ADD_DTTM) OVER(PARTITION BY k1.BILL_TO_CUST_ID, k1.PO_REF ) AS MAX_ADD_DTTM
                , k1.INVOICE_DT
                , k2.DESCR
                , k2.NET_EXTENDED_AMT
            FROM 
                PS_BI_HDR k1
                    INNER JOIN PS_BI_LINE k2 ON
                        k1.BUSINESS_UNIT = k2.BUSINESS_UNIT AND
                        k1.INVOICE = k2.INVOICE
            WHERE 
                k1.BILL_STATUS = 'INV'
                AND k1.BILL_TYPE_ID IN ('B1','F1')
                AND CASE
                    WHEN UPPER(k2.DESCR) LIKE '%CUOTA%INI%' OR UPPER(k2.DESCR) LIKE '%CUOTA 0%' OR UPPER(k2.DESCR) LIKE '%CUOTA 1%' 
                    --upper (k2.DESCR) like '%CUOTA  INICIAL%' or upper (k2.DESCR) like '%CUOTAINICIAL%' or upper (k2.DESCR) like '%CUOTA  INIC.%' or upper (k2.DESCR) like '%CUOTA INICIAL%' or upper (k2.DESCR) like '%CUOTA 0%' or upper (k2.DESCR) like '%CUOTA 1%'
                    THEN ( CASE WHEN UPPER (k2.DESCR) LIKE '%ARANCEL%' 
                            THEN 'TA' 
                            ELSE 'T1' END ) 
                    WHEN UPPER(k2.DESCR) LIKE '%ARANCEL CONTADO%' 
                    THEN 'TF' 
                    ELSE NULL END  IN ('T1','TF') ) k ON
            a.ID = k.BILL_TO_CUST_ID AND 
            a.ACADEMIC_PERIOD = k.PO_REF AND
            k.BUSINESS_UNIT = 'PER03' AND
            k.ADD_DTTM = k.MAX_ADD_DTTM )
        LEFT JOIN PS_ITEM l ON
            k.BUSINESS_UNIT = l.BUSINESS_UNIT AND
            k.INVOICE = l.ITEM
WHERE
    a.ACADEMIC_PERIOD = a.ACADEMIC_PERIOD_ADMITTED
    --AND a.STUDENT_LEVEL = 'UG'
    --AND a.ACADEMIC_PERIOD IN ('218533')
    AND a.ACADEMIC_PERIOD IN ('220434','220534')
    --AND j.SPRIDEN_ID IN ('N00002655','N00018579')
ORDER BY 1 DESC;

USE SCHEMA ODSMGR;

SELECT PERSON_UID, ID, NAME, ACADEMIC_PERIOD,ACADEMIC_PERIOD_ADMITTED, PROGRAM, PROGRAM_DESC, STUDENT_LEVEL, CAMPUS
FROM ODSMGR.ACADEMIC_STUDY
WHERE ACADEMIC_PERIOD = ACADEMIC_PERIOD_ADMITTED AND ACADEMIC_PERIOD IN ('220413','220513');

SELECT PERSON_UID, ID, NAME, ACADEMIC_PERIOD, PROGRAM, PROGRAM_DESC, STUDENT_LEVEL, CAMPUS FROM ADMISSIONS_APPLICATION
WHERE PERSON_UID IN (18579,2655) AND ACADEMIC_PERIOD IN ('218942');

SELECT * FROM SPRIDEN
WHERE SPRIDEN_CHANGE_IND IS NULL AND SPRIDEN_ID IN ('N00059595'
,'N00186976'
,'N00084242'
,'N00116576'
);

SELECT * FROM RECEIVABLE_ACCOUNT_DETAIL
WHERE ACADEMIC_PERIOD = '218714' AND ACCOUNT_UID = 26612
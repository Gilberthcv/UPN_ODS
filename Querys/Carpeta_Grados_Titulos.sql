--Carpeta_Grados_Titulos_
SELECT
    A.DEPOSIT_BU, A.ACCOUNTING_DT, B.REF_VALUE, C.ACCOUNT_UID, C.ID, C.NAME, C.TRANSACTION_NUMBER, D.SVRSVPR_SRVC_CODE, E.SVVSRVC_DESC, C.AMOUNT
    , MAX(F.SPRTELE_PHONE_NUMBER) AS CELULAR, MAX(G.GOREMAL_EMAIL_ADDRESS) AS CORREO
FROM ODSMGR.PS_PAYMENT A
        INNER JOIN ODSMGR.PS_PAYMENT_ID_ITEM B ON A.DEPOSIT_BU = B.DEPOSIT_BU AND A.PAYMENT_SEQ_NUM = B.PAYMENT_SEQ_NUM AND A.DEPOSIT_ID = B.DEPOSIT_ID
        INNER JOIN ODSMGR.RECEIVABLE_ACCOUNT_DETAIL C ON B.REF_VALUE = C.CREDIT_CARD_NUMBER --AND C.ACADEMIC_PERIOD = '000000'
        INNER JOIN ODSMGR.LOE_SVRSVPR D ON C.ACCOUNT_UID = D.SVRSVPR_PIDM AND C.TRANSACTION_NUMBER = D.SVRSVPR_ACCD_TRAN_NUMBER
        INNER JOIN ODSMGR.LOE_SVVSRVC E ON D.SVRSVPR_SRVC_CODE = E.SVVSRVC_CODE
        LEFT JOIN ODSMGR.SPRTELE F ON C.ACCOUNT_UID = F.SPRTELE_PIDM AND F.SPRTELE_TELE_CODE = 'CP'
        LEFT JOIN ODSMGR.GOREMAL G ON C.ACCOUNT_UID = G.GOREMAL_PIDM AND G.GOREMAL_STATUS_IND = 'A' AND G.GOREMAL_EMAL_CODE = 'PERS'
                                        AND G.GOREMAL_ACTIVITY_DATE = (SELECT MAX(G1.GOREMAL_ACTIVITY_DATE) FROM ODSMGR.GOREMAL G1
                                                                        WHERE G1.GOREMAL_PIDM = G.GOREMAL_PIDM AND G1.GOREMAL_STATUS_IND = 'A' AND G1.GOREMAL_EMAL_CODE = 'PERS')
        /*LEFT JOIN ( SELECT DISTINCT PERSON_UID, ID, NAME, CURRICULUM_CHANGE_REASON FROM ODSMGR.FIELD_OF_STUDY
                    WHERE SOURCE = 'OUTCOME' AND CURRICULUM_CHANGE_REASON = 'TITULADO' AND STUDENT_LEVEL = 'UG'
                    ) T ON C.ACCOUNT_UID = T.PERSON_UID*/
WHERE D.SVRSVPR_SRVC_CODE IN ('UG.007','WA.005','CAR3','CAR4','UG.006','WA.004' --CAJ
        ,'UG.066','WA.059','CAR7','CAR8','UG.065','WA.058' --LC0
        ,'UG.219','WA.197','UG.218','WA.196' --LE0
        ,'UG.168','WA.151','CAR5','CAR6','UG.167','WA.150' --LN0
        ,'UG.117','WA.105','UG.116','WA.104' --LN1
        ,'UG.270','WA.243','CAR1','CAR2','UG.269','WA.242' --TML
        ,'UG.321','WA.289','UG.320','WA.288') --TSI
    AND A.ACCOUNTING_DT BETWEEN TO_DATE('01/01/2021','DD/MM/YYYY') AND TO_DATE('31/03/2021','DD/MM/YYYY')
    --AND A.ACCOUNTING_DT BETWEEN DATE_TRUNC('MONTH',CURRENT_DATE) AND CURRENT_TIMESTAMP    --AVANCE DEL MES
    --AND T.CURRICULUM_CHANGE_REASON IS NULL
GROUP BY A.DEPOSIT_BU, A.ACCOUNTING_DT, B.REF_VALUE, C.ACCOUNT_UID, C.ID, C.NAME, C.TRANSACTION_NUMBER, D.SVRSVPR_SRVC_CODE, E.SVVSRVC_DESC, C.AMOUNT
ORDER BY 4,7,2
;
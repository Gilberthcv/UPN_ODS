--Carpeta_Titulación_Grados
SELECT DISTINCT
    a.DEPOSIT_BU, a.ACCOUNTING_DT, b.REF_VALUE, c.ACCOUNT_UID, c.ID, c.NAME, c.TRANSACTION_NUMBER, d.SVRSVPR_SRVC_CODE, e.SVVSRVC_DESC, c.AMOUNT
FROM ODSMGR.PS_PAYMENT a, ODSMGR.PS_PAYMENT_ID_ITEM b, ODSMGR.RECEIVABLE_ACCOUNT_DETAIL c, ODSMGR.LOE_SVRSVPR d, ODSMGR.LOE_SVVSRVC e
WHERE a.DEPOSIT_BU = b.DEPOSIT_BU
    AND a.PAYMENT_SEQ_NUM = b.PAYMENT_SEQ_NUM
    AND a.DEPOSIT_ID = b.DEPOSIT_ID
    AND b.REF_VALUE = c.CREDIT_CARD_NUMBER
    --AND c.ACADEMIC_PERIOD = '000000'
    AND c.ACCOUNT_UID = d.SVRSVPR_PIDM
    AND c.TRANSACTION_NUMBER = d.SVRSVPR_ACCD_TRAN_NUMBER
    AND d.SVRSVPR_SRVC_CODE = e.SVVSRVC_CODE
    AND d.SVRSVPR_SRVC_CODE IN ('UG.007','WA.005','CAR3','CAR4','UG.006','WA.004' --CAJ
        ,'UG.066','WA.059','CAR7','CAR8','UG.065','WA.058' --LC0
        ,'UG.219','WA.197','UG.218','WA.196' --LE0
        ,'UG.168','WA.151','CAR5','CAR6','UG.167','WA.150' --LN0
        ,'UG.117','WA.105','UG.116','WA.104' --LN1
        ,'UG.270','WA.243','CAR1','CAR2','UG.269','WA.242' --TML
        ,'UG.321','WA.289','UG.320','WA.288') --TSI
    AND a.ACCOUNTING_DT BETWEEN TO_DATE('01/08/2020','DD/MM/YYYY') AND TO_DATE('31/08/2020','DD/MM/YYYY')
ORDER BY 4,7,2;

SELECT --* 
    SVRSVPR_CAMP_CODE, SVRSVPR_PIDM, SPRIDEN_ID, CONCAT(CONCAT(SPRIDEN_LAST_NAME,', '),SPRIDEN_FIRST_NAME) AS APELLIDOS_NOMBRES
    , SVRSVPR_SRVC_CODE, SVVSRVC_DESC, SVRSVPR_RECEPTION_DATE
    , SVRSVPR_PROTOCOL_AMOUNT, SVRSVPR_ACCD_TRAN_NUMBER, CREDIT_CARD_NUMBER, SVRSVPR_ORIG_CODE, SVRSVPR_SRVS_CODE
    , SVRSVPR_ACTIVITY_DATE, SVRSVPR_USER_ID, a.BILL_STATUS AS STATUS_BI, b.ITEM_STATUS AS STATUS_AR
FROM LOE_SVRSVPR, LOE_SVVSRVC, RECEIVABLE_ACCOUNT_DETAIL, SPRIDEN, PS_BI_HDR a, PS_ITEM b
WHERE SVRSVPR_SRVC_CODE = SVVSRVC_CODE
    AND SVRSVPR_PIDM = ACCOUNT_UID AND SVRSVPR_ACCD_TRAN_NUMBER = TRANSACTION_NUMBER
    AND SVRSVPR_PIDM = SPRIDEN_PIDM AND SPRIDEN_CHANGE_IND IS NULL
    AND CREDIT_CARD_NUMBER = a.INVOICE(+) AND a.BUSINESS_UNIT(+) = 'PER03'
    AND a.BUSINESS_UNIT = b.BUSINESS_UNIT(+) AND a.INVOICE = b.ITEM(+)
    --AND SVRSVPR_SRVS_CODE = 'CA'
    AND SVRSVPR_RECEPTION_DATE BETWEEN '01/07/2019' AND '18/07/2019';


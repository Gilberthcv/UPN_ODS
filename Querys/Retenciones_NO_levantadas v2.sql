
SELECT DISTINCT
    x.PERSON_UID, x.ID, x.NAME, x.HOLD, x.HOLD_DESC, x.HOLD_USER_CREATOR, x.HOLD_FROM_DATE, x.HOLD_TO_DATE, x.ACTIVE_HOLD_IND, x.HOLD_EXPLANATION
    , x.INVOICE, x.BILL_STATUS, x.BILL_TYPE_ID, x.DESCR, x.ITEM_STATUS, NVL(z.ADD_DTTM,x.ACCOUNTING_DT) AS FECHA_PAGO, z.PAYMENT_METHOD_CDR
FROM (  SELECT 
            a.PERSON_UID, a.ID, a.NAME, a.HOLD, a.HOLD_DESC, a.HOLD_USER_CREATOR, a.HOLD_FROM_DATE, a.HOLD_TO_DATE, a.ACTIVE_HOLD_IND, a.HOLD_EXPLANATION
            , b.INVOICE, b.BILL_STATUS, b.BILL_TYPE_ID, c.DESCR, d.ITEM_STATUS, d.ACCOUNTING_DT, b.ADD_DTTM, MAX(b.ADD_DTTM) OVER(PARTITION BY b.BILL_TO_CUST_ID,b.PO_REF) AS MAX_ADD_DTTM
        FROM ODSMGR.HOLD a, ODSMGR.PS_BI_HDR b, ODSMGR.PS_BI_LINE c, ODSMGR.PS_ITEM d
        WHERE a.ID = b.BILL_TO_CUST_ID AND SUBSTR(a.HOLD_EXPLANATION,1,6) = b.PO_REF
            AND b.INVOICE = c.INVOICE AND (SUBSTR(c.DESCR,1,2) = 'T1' OR UPPER(c.DESCR) LIKE '%CUOTA%INI%' OR UPPER(c.DESCR) LIKE '%CUOTA 0%' OR UPPER(c.DESCR) LIKE '%CUOTA 1%' OR UPPER(c.DESCR) LIKE '%ARANCEL CONTADO%')
            AND b.INVOICE = d.ITEM(+)
            AND a.HOLD IN ('C1','F1') AND CURRENT_TIMESTAMP BETWEEN a.HOLD_FROM_DATE AND a.HOLD_TO_DATE/* AND a.ACTIVE_HOLD_IND = 'Y'*/ AND SUBSTR(a.HOLD_EXPLANATION,1,3) = '220' ) x
     , (SELECT DISTINCT
            a.DEPOSIT_ID, a.PAYMENT_SEQ_NUM, a.REF_VALUE, b.RECEIPT_NBR, b.PAYMENT_METHOD_CDR, c.ADD_DTTM
        FROM ODSMGR.PS_PAYMENT_ID_ITEM a, ODSMGR.PS_CDR_RECEIPT_PMT b, ODSMGR.PS_CDR_RECEIPT c
        WHERE a.DEPOSIT_ID = b.DEPOSIT_ID AND a.PAYMENT_SEQ_NUM = b.PAYMENT_SEQ_NUM AND b.RECEIPT_NBR = c.RECEIPT_NBR ) z
WHERE x.ADD_DTTM = x.MAX_ADD_DTTM AND x.ITEM_STATUS = 'C' AND x.INVOICE = z.REF_VALUE(+)
UNION
SELECT DISTINCT
    y.PERSON_UID, y.ID, y.NAME, y.HOLD, y.HOLD_DESC, y.HOLD_USER_CREATOR, y.HOLD_FROM_DATE, y.HOLD_TO_DATE, y.ACTIVE_HOLD_IND, y.HOLD_EXPLANATION
    , y.INVOICE, y.BILL_STATUS, y.BILL_TYPE_ID, y.DESCR, y.ITEM_STATUS, NVL(z.ADD_DTTM,y.ACCOUNTING_DT) AS FECHA_PAGO, z.PAYMENT_METHOD_CDR
FROM (  SELECT DISTINCT
            x.PERSON_UID, x.ID, x.NAME, x.HOLD, x.HOLD_DESC, x.HOLD_USER_CREATOR, x.HOLD_FROM_DATE, x.HOLD_TO_DATE, x.ACTIVE_HOLD_IND, x.HOLD_EXPLANATION
            , x.INVOICE, x.BILL_STATUS, x.BILL_TYPE_ID, x.DESCR, x.ITEM_STATUS, x.ACCOUNTING_DT
            , CASE WHEN x.ENTRY_REASON = 'CASTI' OR (x.ENTRY_TYPE = 'IN' AND x.GROUP_TYPE = 'T') THEN 'CASTIGADO' ELSE NULL END AS CASTIGADO
        FROM (  SELECT 
                    a.PERSON_UID, a.ID, a.NAME, a.HOLD, a.HOLD_DESC, a.HOLD_USER_CREATOR, a.HOLD_FROM_DATE, a.HOLD_TO_DATE, a.ACTIVE_HOLD_IND, a.HOLD_EXPLANATION
                    , b.INVOICE, b.BILL_STATUS, b.BILL_TYPE_ID, MAX(CASE WHEN c.LINE_SEQ_NUM = 1 THEN c.DESCR END) OVER(PARTITION BY c.INVOICE) AS DESCR
                    , d.ITEM_STATUS, d.ACCOUNTING_DT, b.ADD_DTTM, MAX(b.ADD_DTTM) OVER(PARTITION BY b.BILL_TO_CUST_ID,b.PO_REF) AS MAX_ADD_DTTM
                    , e.ITEM_SEQ_NUM, e.ENTRY_TYPE, e.ENTRY_REASON, e.GROUP_TYPE, MAX(e.ITEM_SEQ_NUM) OVER(PARTITION BY e.ITEM) AS MAX_ITEM_SEQ_NUM
                FROM ODSMGR.HOLD a, ODSMGR.PS_BI_HDR b, ODSMGR.PS_BI_LINE c, ODSMGR.PS_ITEM d, ODSMGR.PS_ITEM_ACTIVITY e
                WHERE a.ID = b.BILL_TO_CUST_ID AND CASE WHEN SUBSTR(HOLD_EXPLANATION,1,15) = 'Overdue Invoice' THEN SUBSTR(HOLD_EXPLANATION,16)
                                                    WHEN SUBSTR(HOLD_EXPLANATION,1,10) = 'PS Inv ID:' THEN SUBSTR(HOLD_EXPLANATION,12)
                                                    WHEN SUBSTR(HOLD_EXPLANATION,1,18) = 'PeopleSoft Inv ID:' THEN SUBSTR(HOLD_EXPLANATION,20) ELSE NULL END = b.INVOICE
                    AND b.INVOICE = c.INVOICE
                    AND b.INVOICE = d.ITEM
                    AND d.ITEM = e.ITEM
                    AND a.HOLD = 'AR' AND CURRENT_TIMESTAMP BETWEEN a.HOLD_FROM_DATE AND a.HOLD_TO_DATE/* AND a.ACTIVE_HOLD_IND = 'Y'*/ ) x
        WHERE x.ADD_DTTM = x.MAX_ADD_DTTM AND x.ITEM_SEQ_NUM = x.MAX_ITEM_SEQ_NUM AND x.ITEM_STATUS = 'C' ) y
     , (SELECT DISTINCT
            a.DEPOSIT_ID, a.PAYMENT_SEQ_NUM, a.REF_VALUE, b.RECEIPT_NBR, b.PAYMENT_METHOD_CDR, c.ADD_DTTM
        FROM ODSMGR.PS_PAYMENT_ID_ITEM a, ODSMGR.PS_CDR_RECEIPT_PMT b, ODSMGR.PS_CDR_RECEIPT c
        WHERE a.DEPOSIT_ID = b.DEPOSIT_ID AND a.PAYMENT_SEQ_NUM = b.PAYMENT_SEQ_NUM AND b.RECEIPT_NBR = c.RECEIPT_NBR ) z
WHERE y.CASTIGADO IS NULL AND y.INVOICE = z.REF_VALUE(+);

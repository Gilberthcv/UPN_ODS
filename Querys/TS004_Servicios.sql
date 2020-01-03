--TS004

SELECT * FROM PS_BI_HDR

SELECT * FROM PS_BI_INSTALL_SCHE

SELECT * FROM PS_LI_GBL_ARPY_REF

SELECT * FROM PS_LI_GBL_ARPY_TBL

SELECT * FROM PS_CDR_RECEIPT

SELECT * FROM PS_CASH_DRAWER_TBL

SELECT * FROM PS_LI_GBL_ARPY_DTL

SELECT * FROM PS_CUSTOMER

SELECT * FROM PS_LI_GBL_BI_INV

SELECT * FROM PS_ITEM

SELECT * FROM PS_ITEM_DST

SELECT * FROM PS_PAYMENT

SELECT * FROM PS_PAYMENT_ID_ITEM

SELECT * FROM PS_BI_LINE

SELECT * FROM PS_BI_LINE_DST

SELECT * FROM PS_ITEM_ACTIVITY

SELECT * FROM RECEIVABLE_ACCOUNT_DETAIL

SELECT * FROM LOE_SVRSVPR

SELECT * FROM LOE_SVVSRVC

SELECT * FROM LOE_TBRACCD

----------------------------------------

SELECT BUSINESS_UNIT, CUST_ID, ITEM, ITEM_LINE, ITEM_SEQ_NUM, LEDGER, ACCOUNT, ALTACCT, MONETARY_AMOUNT, JOURNAL_ID, JOURNAL_DATE
FROM PS_ITEM_DST, 
WHERE BUSINESS_UNIT = 'PER03' AND LEDGER = 'ACTUALS' AND JOURNAL_DATE BETWEEN '01/10/2019' AND '01/10/2019'

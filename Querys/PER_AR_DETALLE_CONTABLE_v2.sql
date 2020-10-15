--PER_AR_DETALLE_CONTABLE_
WITH PER_AR_DETALLE_CONTABLE AS (
	SELECT DISTINCT A.JOURNAL_ID AS ASIENTO, B.CUST_ID AS CLIENTE, REPLACE(CONCAT(CONCAT( M.NAME1,' '), M.NAME2),';','�') AS APELLIDOS_NOMBRES, TO_CHAR(CAST((K.CREATEDTTM) AS TIMESTAMP),'YYYY-MM-DD-HH24.MI.SS.FF') AS FECHA_COBRANZA
		, B.ITEM AS INVOICE, B.ITEM_SEQ_NUM AS SECUENCIA, B.ACCOUNT AS CUENTA, B.ALTACCT AS CUENTA_ALT, B.MONETARY_AMOUNT AS IMPORTE, B.APPL_JRNL_ID AS PLANTILLA, TO_CHAR(B.ACCOUNTING_DT,'YYYY-MM-DD') AS FECHA_CONTABLE
		, B.FISCAL_YEAR AS ANIO, B.ACCOUNTING_PERIOD AS PERIODO, TO_CHAR(E.INVOICE_DT,'YYYY-MM-DD') AS FECHA_EMISION, E.PO_REF AS PERIODO_ACADEMICO, E.CREATEOPRID AS USUARIO, F.INVOICE2 AS NRO_GOBIERNO, G.INSTALL_NBR AS CUOTA
		, H.DEPTID AS DPTO, H.OPERATING_UNIT AS U_EXPLT, H.PRODUCT AS PRODUCTO, H.CHARTFIELD2 AS CC2, I.PYMNT_REF_ID AS ID_PAGO, J.RECEIPT_NBR AS N_RECEP, J.DRAWER_ID AS ID_CAJA, K.CR_CARD_TYPE AS TIPO_TARJETA, K.CR_CARD_AUTH_CD AS CD_AUTORIZ
		, N.DEPOSIT_ID AS ID_DEP, N.PAYMENT_SEQ_NUM AS SEC, N.PAYMENT_ID AS ID_PG, N.PAYMENT_METHOD AS MET_PAGO, N.BANK_ACCOUNT_NUM AS NRO_CUENTA, N.BNK_ID_NBR AS ID_BANCO, C.ENTRY_TYPE AS TP_ENTRADA, C.ENTRY_REASON AS MOTIVO
		--, TO_CHAR(CURRENT_TIMESTAMP,'YYYY-MM-DD') 
	FROM ODSMGR.PS_JRNL_LN A
		, ((((((((ODSMGR.PS_ITEM_DST B
				LEFT OUTER JOIN  (ODSMGR.PS_BI_HDR E INNER JOIN ODSMGR.PS_SP_BU_BI_CLSVW E1 ON (E.BUSINESS_UNIT = E1.BUSINESS_UNIT AND  E1.OPRCLASS = 'LI_PPL_PER03_PER' )) ON  B.BUSINESS_UNIT = E.BUSINESS_UNIT AND E.INVOICE = B.ITEM )
				LEFT OUTER JOIN  ODSMGR.PS_LI_GBL_BI_INV F ON  E.BUSINESS_UNIT = F.BUSINESS_UNIT AND E.INVOICE = F.INVOICE )
				LEFT OUTER JOIN  ODSMGR.PS_BI_INSTALL_SCHE G ON  E.BUSINESS_UNIT = G.BUSINESS_UNIT AND E.INVOICE = G.GENERATED_INVOICE )
				LEFT OUTER JOIN  ODSMGR.PS_BI_LINE_DST H ON  E.BUSINESS_UNIT = H.BUSINESS_UNIT AND E.INVOICE = H.INVOICE )
				LEFT OUTER JOIN  ODSMGR.PS_LI_GBL_ARPY_REF I ON  E.INVOICE = I.INVOICE )
				LEFT OUTER JOIN  ODSMGR.PS_LI_GBL_ARPY_TBL J ON  I.DEPOSIT_BU = J.DEPOSIT_BU AND I.PYMNT_REF_ID = J.PYMNT_REF_ID )
				LEFT OUTER JOIN  ODSMGR.PS_LI_GBL_ARPY_DTL K ON  J.DEPOSIT_BU = K.DEPOSIT_BU AND J.PYMNT_REF_ID = K.PYMNT_REF_ID )
				LEFT OUTER JOIN  ODSMGR.PS_CDR_RECEIPT_REF L ON  L.REF_VALUE = B.ITEM )
		, (ODSMGR.PS_ITEM_ACTIVITY C LEFT OUTER JOIN  ODSMGR.PS_PAYMENT N ON  N.DEPOSIT_BU = C.DEPOSIT_BU AND N.DEPOSIT_ID = C.DEPOSIT_ID AND N.PAYMENT_SEQ_NUM = C.PAYMENT_SEQ_NUM )
		, ODSMGR.PS_CUSTOMER M 
	  WHERE ( ( A.BUSINESS_UNIT = B.BUSINESS_UNIT 
	     AND A.JOURNAL_ID = B.JOURNAL_ID 
	     AND A.JOURNAL_DATE = B.JOURNAL_DATE 
	     AND A.JOURNAL_LINE = B.JOURNAL_LINE 
	     AND A.LEDGER = B.LEDGER 
	     AND B.LEDGER = 'ACTUALS' 
	     AND B.BUSINESS_UNIT = C.BUSINESS_UNIT 
	     AND B.CUST_ID = C.CUST_ID 
	     AND B.ITEM = C.ITEM 
	     AND B.ITEM_LINE = C.ITEM_LINE 
	     AND B.ITEM_SEQ_NUM = C.ITEM_SEQ_NUM 
	     AND B.FISCAL_YEAR = '2020' 
	     AND B.ACCOUNTING_PERIOD = '9' 
	     AND B.CUST_ID = M.CUST_ID ))
)
SELECT ASIENTO, CLIENTE, APELLIDOS_NOMBRES, FECHA_COBRANZA, INVOICE, SECUENCIA, CUENTA, CUENTA_ALT--, IMPORTE
	, CASE WHEN ROW_NUMBER() OVER(PARTITION BY INVOICE, SECUENCIA, CUENTA, CUENTA_ALT, IMPORTE ORDER BY SECUENCIA ASC) = 1 THEN IMPORTE ELSE 0 END AS IMPORTE
	, PLANTILLA, FECHA_CONTABLE, ANIO, PERIODO, FECHA_EMISION, PERIODO_ACADEMICO, USUARIO, NRO_GOBIERNO, CUOTA, DPTO, U_EXPLT, PRODUCTO, CC2
	, ID_PAGO, N_RECEP, ID_CAJA, TIPO_TARJETA, CD_AUTORIZ, ID_DEP, SEC, ID_PG, MET_PAGO, NRO_CUENTA, ID_BANCO, TP_ENTRADA, MOTIVO
FROM PER_AR_DETALLE_CONTABLE
;
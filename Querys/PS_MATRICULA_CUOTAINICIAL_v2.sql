--PS_MATRICULA_CUOTAINICIAL_
--USE ROLE ADMIN_PROD;

USE DATABASE UPN_RPT_DM_PROD;
USE SCHEMA ODSMGR;

--CREATE OR REPLACE VIEW PS_MATRICULA_CUOTAINICIAL AS
WITH DEVOLUCION AS (
	SELECT DISTINCT A.INVOICE, A.BILL_TO_CUST_ID, A.PO_REF, A.BILL_STATUS, A.BILL_TYPE_ID, A.BILLING_FREQUENCY, A.INVOICE_DT, B.LAST_ACTIVITY_DT, C.ENTRY_TYPE, C.ENTRY_REASON
		, NVL(SUBSTR(N.TEXT254,LENGTH(N.TEXT254)-9),N0.TEXT254) AS ORIGINAL_INVOICE
	FROM ODSMGR.PS_BI_HDR A
			INNER JOIN ODSMGR.PS_ITEM B ON A.BUSINESS_UNIT = B.BUSINESS_UNIT AND A.INVOICE = B.ITEM AND (B.CUST_ID <> '9999999999' OR B.CUST_ID IS NULL)
			INNER JOIN ODSMGR.PS_ITEM_ACTIVITY C ON B.BUSINESS_UNIT = C.BUSINESS_UNIT AND B.CUST_ID = C.CUST_ID AND B.ITEM = C.ITEM AND B.ITEM_LINE = C.ITEM_LINE
													AND B.ITEM_SEQ_NUM = C.ITEM_SEQ_NUM AND C.ENTRY_TYPE = 'WOC' AND C.ENTRY_REASON = 'REF'
			LEFT JOIN ODSMGR.PS_BI_LINE_NOTE N ON A.INVOICE = N.INVOICE AND N.TEXT254 LIKE '%ORIGINAL_INVOICE:%'
											    	AND N.LINE_SEQ_NUM = (SELECT MIN(N1.LINE_SEQ_NUM) FROM ODSMGR.PS_BI_LINE_NOTE N1
																		WHERE N1.BUSINESS_UNIT = N.BUSINESS_UNIT AND N1.INVOICE = N.INVOICE AND N1.TEXT254 LIKE '%ORIGINAL_INVOICE:%')
			LEFT JOIN ODSMGR.PS_BI_LINE_NOTE N0 ON A.INVOICE = N0.INVOICE AND N0.NOTE_TYPE = 'INVOICE'
													AND N0.LINE_SEQ_NUM = (SELECT MIN(N2.LINE_SEQ_NUM) FROM ODSMGR.PS_BI_LINE_NOTE N2
																			WHERE N2.BUSINESS_UNIT = N0.BUSINESS_UNIT AND N2.INVOICE = N0.INVOICE AND N2.NOTE_TYPE = 'INVOICE')
	WHERE A.BUSINESS_UNIT = 'PER03' AND A.BILL_STATUS = 'INV' AND A.BILL_TYPE_ID IN ('C1','C2') AND A.BILLING_FREQUENCY = 'ONC'
)
SELECT E.INVOICE, SPRIDEN_PIDM AS PIDM, E.BILL_TO_CUST_ID AS ID, E.BILL_STATUS AS ESTADO_BI, E.BILL_TYPE_ID AS TIPO_DOCUMENTO, E.INVOICE_AMOUNT
	, E.INVOICE_DT AS FECHA_EMISION, E.PO_REF AS PERIODO, E.ADD_DTTM, E.CARGO, E.CARGO_MONTO, E.ITEM_STATUS AS ESTADO_AR, E.BAL_AMT AS SALDO
	, MAX(NVL(F.CREATEDTTM,CASE WHEN E.ITEM_STATUS = 'C' THEN E.LAST_ACTIVITY_DT ELSE NULL END)) AS FECHA_PAGO
	, E.ACCOUNTING_DT AS FECHA_CONTABLE, H.RECON_ID AS ID_CONCILIACION, J.INVOICE AS DEVOLUCION_INVOICE, J.LAST_ACTIVITY_DT AS DEVOLUCION_FECHA
FROM ( SELECT C.BUSINESS_UNIT, C.INVOICE, C.BILL_TO_CUST_ID, C.BILL_STATUS, C.BILL_TYPE_ID, C.INVOICE_AMOUNT, C.INVOICE_DT
			, C.PO_REF, C.ADD_DTTM, C.CARGO, C.CARGO_MONTO, D.ITEM_STATUS, D.BAL_AMT, D.LAST_ACTIVITY_DT, D.ACCOUNTING_DT
			, MAX(C.ADD_DTTM) OVER(PARTITION BY C.BILL_TO_CUST_ID,C.PO_REF,C.CARGO) AS MAX_ADD_DTTM				
		FROM ( (SELECT A.BUSINESS_UNIT, A.INVOICE, A.BILL_TO_CUST_ID, A.BILL_STATUS, A.BILL_TYPE_ID, A.INVOICE_AMOUNT
					, A.INVOICE_DT, A.PO_REF, A.ADD_DTTM--, B.LINE_SEQ_NUM, B.DESCR, B.NET_EXTENDED_AMT
					, NVL(CASE 						
	                        WHEN SUBSTR(B.DESCR,1,2) = 'FM' THEN 'MATRICULA' 
	                        WHEN SUBSTR(B.DESCR,1,2) = 'T1' THEN 'CUOTA INICIAL' 
	                        WHEN UPPER(B.DESCR) LIKE '%ARANCEL CONTADO%' THEN 'CONTADO' 
	                        WHEN UPPER(B.DESCR) LIKE '%ARANCEL%' OR UPPER(B.DESCR) LIKE '%REG%CUO%INI%' THEN 'ARANCEL' 
	                        WHEN UPPER(B.DESCR) LIKE '%CUOTA%INI%' OR UPPER(B.DESCR) LIKE '%CUOTA 0%' 
	                            OR UPPER(B.DESCR) LIKE '%CUOTA 1%' THEN 'CUOTA INICIAL' 
	                        WHEN UPPER(B.DESCR) LIKE '%MATR%' OR UPPER(B.DESCR) LIKE '%PRONABEC%MAT%' THEN 'MATRICULA' 
	                        --WHEN UPPER(B.DESCR) LIKE '%2DA%' OR UPPER(B.DESCR) LIKE '%3RA%' THEN 'T2/T3' 
	                        ELSE NULL END
	                    , CASE 
	                        WHEN SUBSTR(C.TEXT254,LENGTH(C.TEXT254) -3,2) IN ('T1','X1','Y1','Z1') THEN 'CUOTA INICIAL'
	                        WHEN SUBSTR(C.TEXT254,LENGTH(C.TEXT254) -3,2) IN ('TF','XF','YF','ZF') THEN 'CONTADO'
	                        WHEN SUBSTR(C.TEXT254,LENGTH(C.TEXT254) -3,2) IN ('FM','XM','YM','ZM') THEN 'MATRICULA'
	                        ELSE NULL END) AS CARGO
					, SUM(B.NET_EXTENDED_AMT) AS CARGO_MONTO
				FROM (ODSMGR.PS_BI_HDR A
							INNER JOIN ODSMGR.PS_BI_LINE B ON A.BUSINESS_UNIT = B.BUSINESS_UNIT AND A.INVOICE = B.INVOICE)
							LEFT JOIN ODSMGR.PS_BI_LINE_NOTE C ON B.BUSINESS_UNIT = C.BUSINESS_UNIT AND B.INVOICE = C.INVOICE AND B.LINE_SEQ_NUM = C.LINE_SEQ_NUM
																	AND SUBSTR(C.TEXT254,LENGTH(C.TEXT254) -3,2) IN ('T1','X1','Y1','Z1','TF','XF','YF','ZF','FM','XM','YM','ZM')
				WHERE A.BUSINESS_UNIT = 'PER03' AND A.BILL_STATUS = 'INV' AND A.BILL_TYPE_ID IN ('B1','F1')
                	--AND A.PO_REF IN ('220413','220513') --INGRESAR_PERIODO
            	GROUP BY A.BUSINESS_UNIT, A.INVOICE, A.BILL_TO_CUST_ID, A.BILL_STATUS, A.BILL_TYPE_ID, A.INVOICE_AMOUNT
	                , A.INVOICE_DT, A.PO_REF, A.ADD_DTTM--, B.LINE_SEQ_NUM, B.DESCR, B.NET_EXTENDED_AMT
	                , NVL(CASE 
	                        WHEN SUBSTR(B.DESCR,1,2) = 'FM' THEN 'MATRICULA' 
	                        WHEN SUBSTR(B.DESCR,1,2) = 'T1' THEN 'CUOTA INICIAL' 
	                        WHEN UPPER(B.DESCR) LIKE '%ARANCEL CONTADO%' THEN 'CONTADO' 
	                        WHEN UPPER(B.DESCR) LIKE '%ARANCEL%' OR UPPER(B.DESCR) LIKE '%REG%CUO%INI%' THEN 'ARANCEL' 
	                        WHEN UPPER(B.DESCR) LIKE '%CUOTA%INI%' OR UPPER(B.DESCR) LIKE '%CUOTA 0%' 
	                            OR UPPER(B.DESCR) LIKE '%CUOTA 1%' THEN 'CUOTA INICIAL' 
	                        WHEN UPPER(B.DESCR) LIKE '%MATR%' OR UPPER(B.DESCR) LIKE '%PRONABEC%MAT%' THEN 'MATRICULA' 
	                        --WHEN UPPER(B.DESCR) LIKE '%2DA%' OR UPPER(B.DESCR) LIKE '%3RA%' THEN 'T2/T3' 
	                        ELSE NULL END
	                    , CASE 
	                        WHEN SUBSTR(C.TEXT254,LENGTH(C.TEXT254) -3,2) IN ('T1','X1','Y1','Z1') THEN 'CUOTA INICIAL'
	                        WHEN SUBSTR(C.TEXT254,LENGTH(C.TEXT254) -3,2) IN ('TF','XF','YF','ZF') THEN 'CONTADO'
	                        WHEN SUBSTR(C.TEXT254,LENGTH(C.TEXT254) -3,2) IN ('FM','XM','YM','ZM') THEN 'MATRICULA'
	                        ELSE NULL END)
				) C
					LEFT JOIN ODSMGR.PS_ITEM D ON C.BUSINESS_UNIT = D.BUSINESS_UNIT AND C.INVOICE = D.ITEM AND (D.CUST_ID <> '9999999999' OR D.CUST_ID IS NULL))
					LEFT JOIN ODSMGR.PS_ITEM_ACTIVITY I ON D.BUSINESS_UNIT = I.BUSINESS_UNIT AND D.CUST_ID = I.CUST_ID AND D.ITEM = I.ITEM AND D.ITEM_LINE = I.ITEM_LINE
															AND D.ITEM_SEQ_NUM = I.ITEM_SEQ_NUM AND ((I.ENTRY_TYPE = 'WOC' AND I.ENTRY_REASON = 'A-DIR') OR I.ENTRY_TYPE = 'CM')
		WHERE C.CARGO IN ('CONTADO','CUOTA INICIAL','MATRICULA') /*AND (D.DEDUCTION_STATUS <> 'REGU' OR D.DEDUCTION_STATUS IS NULL) */AND I.ITEM IS NULL
	) E
		LEFT JOIN ODSMGR.PS_LI_GBL_ARPY_REF F ON E.BUSINESS_UNIT = F.DEPOSIT_BU AND E.INVOICE = F.INVOICE
		LEFT JOIN ODSMGR.PS_LI_GBL_ARPY_TBL G ON F.DEPOSIT_BU = G.DEPOSIT_BU AND F.PYMNT_REF_ID = G.PYMNT_REF_ID AND G.DRAWER_ID IS NOT NULL
		LEFT JOIN ODSMGR.PS_CDR_RECEIPT H ON G.DEPOSIT_BU = H.DEPOSIT_BU AND G.RECEIPT_NBR = H.RECEIPT_NBR
		LEFT JOIN DEVOLUCION J ON E.INVOICE = J.ORIGINAL_INVOICE
									AND J.INVOICE = (SELECT MAX(J1.INVOICE) FROM DEVOLUCION J1 WHERE J1.ORIGINAL_INVOICE = J.ORIGINAL_INVOICE)
		LEFT JOIN ODSMGR.LOE_SPRIDEN ON E.BILL_TO_CUST_ID = SPRIDEN_ID AND SPRIDEN_CHANGE_IND IS NULL
WHERE E.ADD_DTTM = E.MAX_ADD_DTTM
GROUP BY E.INVOICE, SPRIDEN_PIDM, E.BILL_TO_CUST_ID, E.BILL_STATUS, E.BILL_TYPE_ID, E.INVOICE_AMOUNT, E.INVOICE_DT, E.PO_REF
    , E.ADD_DTTM, E.CARGO, E.CARGO_MONTO, E.ITEM_STATUS, E.BAL_AMT, E.ACCOUNTING_DT, H.RECON_ID, J.INVOICE, J.LAST_ACTIVITY_DT
;
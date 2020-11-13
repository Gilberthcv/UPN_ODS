--FC020_
SELECT I.PO_REF AS PERIODO, I.BILL_TO_CUST_ID AS ID_ESTUDIANTE, I.BILL_TYPE_ID AS TIPO_DOCUMENTO, I.ITEM AS INVOICE, I.INVOICE2 AS NRO_GOBIERNO, ROUND(I.INVOICE_AMOUNT,2) AS MONTO_TRANSACCION
	, J.LINE_SEQ_NUM AS SEQ, J.DESCR AS DESCRIPCION, ROUND(J.NET_EXTENDED_AMT,2) AS MONTO_DESCRIPCION, I.INSTALL_NBR AS NRO_CUOTA, I.INVOICE_DT AS FECHA_EMISION, N.DUE_DT AS FECHA_VENCIMIENTO
	, ROUND(I.ENTRY_AMT,2) AS SALDO, ROUND(I.INVOICE_AMOUNT-I.ENTRY_AMT,2) AS MONTO_PAGADO, CASE WHEN I.ENTRY_AMT = 0 THEN 'TOTAL' ELSE 'PARCIAL' END AS TIPO_PAGO, MAX(O.PAYMENT_METHOD_CDR) AS FORMA_PAGO
	, I.ENTRY_TYPE AS TIPO_ENTRADA, MAX(O.CREATEDTTM) AS FECHA_PAGO, I.ACCOUNTING_DT AS FECHA_CONTABLE, L.VALUE2 AS NIVEL, M.VALUE2 AS CAMPUS
FROM ( SELECT B.BUSINESS_UNIT, C.PO_REF, C.BILL_TO_CUST_ID, C.BILL_TYPE_ID, B.ITEM, H.INVOICE2, C.INVOICE_AMOUNT, NVL(D.INSTALL_NBR,G.INSTALL_NBR) AS INSTALL_NBR, C.INVOICE_DT
			, SUM(B.ENTRY_AMT) AS ENTRY_AMT
			, MAX(CASE WHEN B.ITEM_SEQ_NUM = B.MAX_ITEM_SEQ_NUM THEN B.ENTRY_TYPE END) AS ENTRY_TYPE
			, MAX(CASE WHEN B.ITEM_SEQ_NUM = B.MAX_ITEM_SEQ_NUM THEN B.ACCOUNTING_DT END) AS ACCOUNTING_DT
			, MAX(CASE WHEN B.ITEM_SEQ_NUM = B.MAX_ITEM_SEQ_NUM THEN B.DEPOSIT_ID END) AS DEPOSIT_ID
			, MAX(CASE WHEN B.ITEM_SEQ_NUM = B.MAX_ITEM_SEQ_NUM THEN B.PAYMENT_ID END) AS PAYMENT_ID
			, MAX(CASE WHEN B.ITEM_SEQ_NUM = B.MAX_ITEM_SEQ_NUM THEN B.PAYMENT_SEQ_NUM END) AS PAYMENT_SEQ_NUM
		FROM ( SELECT A.BUSINESS_UNIT, A.ITEM, A.ITEM_SEQ_NUM, A.ENTRY_AMT, A.ENTRY_TYPE, A.ACCOUNTING_DT, A.DEPOSIT_ID, A.PAYMENT_ID, A.PAYMENT_SEQ_NUM
					, MAX(A.ITEM_SEQ_NUM) OVER(PARTITION BY A.BUSINESS_UNIT,A.ITEM) AS MAX_ITEM_SEQ_NUM
				FROM ODSMGR.PS_ITEM_ACTIVITY A
				WHERE A.BUSINESS_UNIT = 'PER03' AND (A.CUST_ID <> '9999999999' OR A.CUST_ID IS NULL) AND A.ACCOUNTING_DT <= TO_DATE(:FECHA_FIN2,'YYYY-MM-DD')
					AND A.ITEM IN (SELECT DISTINCT A1.ITEM FROM ODSMGR.PS_ITEM_ACTIVITY A1
									WHERE A1.BUSINESS_UNIT = 'PER03' AND A1.ENTRY_TYPE IN ('PY','MT') AND (A1.CUST_ID <> '9999999999' OR A1.CUST_ID IS NULL)
										AND A1.ACCOUNTING_DT BETWEEN TO_DATE(:FECHA_INICIO,'YYYY-MM-DD') AND TO_DATE(:FECHA_FIN,'YYYY-MM-DD'))
			) B
				INNER JOIN ODSMGR.PS_BI_HDR C ON B.BUSINESS_UNIT = C.BUSINESS_UNIT AND B.ITEM = C.INVOICE AND C.BILL_TYPE_ID IN ('B1','F1','D1','D2')				
				LEFT JOIN ODSMGR.PS_BI_INSTALL_SCHE D ON C.INVOICE = D.GENERATED_INVOICE
				LEFT JOIN ODSMGR.PS_BI_LINE_NOTE E ON C.INVOICE = E.INVOICE AND E.TEXT254 LIKE '%ORIGINAL_INVOICE:%'
													    	AND E.LINE_SEQ_NUM = (SELECT MIN(E1.LINE_SEQ_NUM) FROM ODSMGR.PS_BI_LINE_NOTE E1
																				WHERE E1.BUSINESS_UNIT = E.BUSINESS_UNIT AND E1.INVOICE = E.INVOICE
																					AND E1.TEXT254 LIKE '%ORIGINAL_INVOICE:%')		
				LEFT JOIN ODSMGR.PS_BI_LINE_NOTE F ON C.INVOICE = F.INVOICE AND F.NOTE_TYPE = 'INVOICE'
														AND F.LINE_SEQ_NUM = (SELECT MIN(F1.LINE_SEQ_NUM) FROM ODSMGR.PS_BI_LINE_NOTE F1
																				WHERE F1.BUSINESS_UNIT = F.BUSINESS_UNIT AND F1.INVOICE = F.INVOICE
																					AND F1.NOTE_TYPE = 'INVOICE')		
				LEFT JOIN ODSMGR.PS_BI_INSTALL_SCHE G ON NVL(SUBSTR(E.TEXT254,LENGTH(E.TEXT254)-9),F.TEXT254) = G.GENERATED_INVOICE
				LEFT JOIN ODSMGR.PS_LI_GBL_BI_INV H ON C.BUSINESS_UNIT = H.BUSINESS_UNIT AND C.INVOICE = H.INVOICE				
		GROUP BY B.BUSINESS_UNIT, C.PO_REF, C.BILL_TO_CUST_ID, C.BILL_TYPE_ID, B.ITEM, H.INVOICE2, C.INVOICE_AMOUNT, NVL(D.INSTALL_NBR,G.INSTALL_NBR), C.INVOICE_DT
	) I
		INNER JOIN ODSMGR.PS_BI_LINE J ON I.BUSINESS_UNIT = J.BUSINESS_UNIT AND I.ITEM = J.INVOICE
		LEFT JOIN ODSMGR.PS_BI_LINE_DST K ON J.BUSINESS_UNIT = K.BUSINESS_UNIT AND J.INVOICE = K.INVOICE AND J.LINE_SEQ_NUM = K.LINE_SEQ_NUM
		LEFT JOIN ODSMGR.LOE_BASE_TABLE_EQUIV L ON K.PRODUCT = L.VALUE1 AND L.TABLE_PARENT_ID = 9
		LEFT JOIN ODSMGR.LOE_BASE_TABLE_EQUIV M ON K.OPERATING_UNIT = M.VALUE1 AND M.TABLE_PARENT_ID = 1
		LEFT JOIN ODSMGR.PS_ITEM N ON I.BUSINESS_UNIT = N.BUSINESS_UNIT AND I.ITEM = N.ITEM
		LEFT JOIN ODSMGR.PS_LI_PER_ARPMT_VW O ON I.BUSINESS_UNIT = O.DEPOSIT_BU AND I.DEPOSIT_ID = O.DEPOSIT_ID AND I.PAYMENT_ID = O.PAYMENT_ID
												AND I.PAYMENT_SEQ_NUM = O.PAYMENT_SEQ_NUM AND I.ITEM = O.INVOICE AND I.BILL_TO_CUST_ID = O.CUST_ID
GROUP BY I.PO_REF, I.BILL_TO_CUST_ID, I.BILL_TYPE_ID, I.ITEM, I.INVOICE2, ROUND(I.INVOICE_AMOUNT,2), J.LINE_SEQ_NUM, J.DESCR, ROUND(J.NET_EXTENDED_AMT,2), I.INSTALL_NBR, I.INVOICE_DT, N.DUE_DT
	, ROUND(I.ENTRY_AMT,2), ROUND(I.INVOICE_AMOUNT-I.ENTRY_AMT,2), CASE WHEN I.ENTRY_AMT = 0 THEN 'TOTAL' ELSE 'PARCIAL' END, I.ENTRY_TYPE, I.ACCOUNTING_DT, L.VALUE2, M.VALUE2
;

--
SELECT I.PO_REF AS PERIODO, I.BILL_TO_CUST_ID AS ID_ESTUDIANTE, I.BILL_TYPE_ID AS TIPO_DOCUMENTO, I.ITEM AS INVOICE, I.INVOICE2 AS NRO_GOBIERNO, ROUND(I.INVOICE_AMOUNT,2) AS MONTO_TRANSACCION
	, J.LINE_SEQ_NUM AS SEQ, J.DESCR AS DESCRIPCION, ROUND(J.NET_EXTENDED_AMT,2) AS MONTO_DESCRIPCION, I.INSTALL_NBR AS NRO_CUOTA, I.INVOICE_DT AS FECHA_EMISION, N.DUE_DT AS FECHA_VENCIMIENTO
	, ROUND(N.BAL_AMT,2) AS SALDO, N.ITEM_STATUS AS ESTADO_AR, ROUND(I.INVOICE_AMOUNT-N.BAL_AMT,2) AS MONTO_PAGADO, CASE WHEN N.BAL_AMT = 0 THEN 'TOTAL' ELSE 'PARCIAL' END AS TIPO_PAGO, MAX(O.PAYMENT_METHOD_CDR) AS FORMA_PAGO
	, I.ENTRY_TYPE AS TIPO_ENTRADA, I.ENTRY_REASON AS MOTIVO, MAX(O.CREATEDTTM) AS FECHA_PAGO, I.ACCOUNTING_DT AS FECHA_CONTABLE, L.VALUE2 AS NIVEL, M.VALUE2 AS CAMPUS
FROM ( SELECT B.BUSINESS_UNIT, C.PO_REF, C.BILL_TO_CUST_ID, C.BILL_TYPE_ID, B.ITEM, H.INVOICE2, C.INVOICE_AMOUNT, NVL(D.INSTALL_NBR,G.INSTALL_NBR) AS INSTALL_NBR, C.INVOICE_DT
			, MAX(CASE WHEN B.ITEM_SEQ_NUM = B.MAX_ITEM_SEQ_NUM THEN B.ENTRY_TYPE END) AS ENTRY_TYPE
			, MAX(CASE WHEN B.ITEM_SEQ_NUM = B.MAX_ITEM_SEQ_NUM THEN B.ENTRY_REASON END) AS ENTRY_REASON
			, MAX(CASE WHEN B.ITEM_SEQ_NUM = B.MAX_ITEM_SEQ_NUM THEN B.ACCOUNTING_DT END) AS ACCOUNTING_DT
			, MAX(CASE WHEN B.ITEM_SEQ_NUM = B.MAX_ITEM_SEQ_NUM THEN B.DEPOSIT_ID END) AS DEPOSIT_ID
			, MAX(CASE WHEN B.ITEM_SEQ_NUM = B.MAX_ITEM_SEQ_NUM THEN B.PAYMENT_ID END) AS PAYMENT_ID
			, MAX(CASE WHEN B.ITEM_SEQ_NUM = B.MAX_ITEM_SEQ_NUM THEN B.PAYMENT_SEQ_NUM END) AS PAYMENT_SEQ_NUM
		FROM ( SELECT A.BUSINESS_UNIT, A.ITEM, A.ITEM_SEQ_NUM, A.ENTRY_AMT, A.ENTRY_TYPE, A.ENTRY_REASON, A.ACCOUNTING_DT, A.DEPOSIT_ID, A.PAYMENT_ID, A.PAYMENT_SEQ_NUM
					, MAX(A.ITEM_SEQ_NUM) OVER(PARTITION BY A.BUSINESS_UNIT,A.ITEM) AS MAX_ITEM_SEQ_NUM
				FROM ODSMGR.PS_ITEM_ACTIVITY A
				WHERE A.BUSINESS_UNIT = 'PER03' AND (A.CUST_ID <> '9999999999' OR A.CUST_ID IS NULL)
					AND A.ITEM IN (SELECT DISTINCT A1.ITEM FROM ODSMGR.PS_ITEM_ACTIVITY A1
									WHERE A1.BUSINESS_UNIT = 'PER03' AND A1.ENTRY_TYPE IN ('PY','MT') AND (A1.CUST_ID <> '9999999999' OR A1.CUST_ID IS NULL)
										AND A1.ACCOUNTING_DT BETWEEN TO_DATE(:FECHA_INICIO,'YYYY-MM-DD') AND TO_DATE(:FECHA_FIN,'YYYY-MM-DD'))
			) B
				INNER JOIN ODSMGR.PS_BI_HDR C ON B.BUSINESS_UNIT = C.BUSINESS_UNIT AND B.ITEM = C.INVOICE AND C.BILL_TYPE_ID IN ('B1','F1','D1','D2')
				LEFT JOIN ODSMGR.PS_BI_INSTALL_SCHE D ON C.INVOICE = D.GENERATED_INVOICE
				LEFT JOIN ODSMGR.PS_BI_LINE_NOTE E ON C.INVOICE = E.INVOICE AND E.TEXT254 LIKE '%ORIGINAL_INVOICE:%'
													    	AND E.LINE_SEQ_NUM = (SELECT MIN(E1.LINE_SEQ_NUM) FROM ODSMGR.PS_BI_LINE_NOTE E1
																				WHERE E1.BUSINESS_UNIT = E.BUSINESS_UNIT AND E1.INVOICE = E.INVOICE
																					AND E1.TEXT254 LIKE '%ORIGINAL_INVOICE:%')		
				LEFT JOIN ODSMGR.PS_BI_LINE_NOTE F ON C.INVOICE = F.INVOICE AND F.NOTE_TYPE = 'INVOICE'
														AND F.LINE_SEQ_NUM = (SELECT MIN(F1.LINE_SEQ_NUM) FROM ODSMGR.PS_BI_LINE_NOTE F1
																				WHERE F1.BUSINESS_UNIT = F.BUSINESS_UNIT AND F1.INVOICE = F.INVOICE
																					AND F1.NOTE_TYPE = 'INVOICE')		
				LEFT JOIN ODSMGR.PS_BI_INSTALL_SCHE G ON NVL(SUBSTR(E.TEXT254,LENGTH(E.TEXT254)-9),F.TEXT254) = G.GENERATED_INVOICE
				LEFT JOIN ODSMGR.PS_LI_GBL_BI_INV H ON C.BUSINESS_UNIT = H.BUSINESS_UNIT AND C.INVOICE = H.INVOICE				
		GROUP BY B.BUSINESS_UNIT, C.PO_REF, C.BILL_TO_CUST_ID, C.BILL_TYPE_ID, B.ITEM, H.INVOICE2, C.INVOICE_AMOUNT, NVL(D.INSTALL_NBR,G.INSTALL_NBR), C.INVOICE_DT
	) I
		INNER JOIN ODSMGR.PS_BI_LINE J ON I.BUSINESS_UNIT = J.BUSINESS_UNIT AND I.ITEM = J.INVOICE
		LEFT JOIN ODSMGR.PS_BI_LINE_DST K ON J.BUSINESS_UNIT = K.BUSINESS_UNIT AND J.INVOICE = K.INVOICE AND J.LINE_SEQ_NUM = K.LINE_SEQ_NUM
		LEFT JOIN ODSMGR.LOE_BASE_TABLE_EQUIV L ON K.PRODUCT = L.VALUE1 AND L.TABLE_PARENT_ID = 9
		LEFT JOIN ODSMGR.LOE_BASE_TABLE_EQUIV M ON K.OPERATING_UNIT = M.VALUE1 AND M.TABLE_PARENT_ID = 1
		LEFT JOIN ODSMGR.PS_ITEM N ON I.BUSINESS_UNIT = N.BUSINESS_UNIT AND I.ITEM = N.ITEM
		LEFT JOIN ODSMGR.PS_LI_PER_ARPMT_VW O ON I.BUSINESS_UNIT = O.DEPOSIT_BU AND I.DEPOSIT_ID = O.DEPOSIT_ID AND I.PAYMENT_ID = O.PAYMENT_ID
												AND I.PAYMENT_SEQ_NUM = O.PAYMENT_SEQ_NUM AND I.ITEM = O.INVOICE AND I.BILL_TO_CUST_ID = O.CUST_ID
GROUP BY I.PO_REF, I.BILL_TO_CUST_ID, I.BILL_TYPE_ID, I.ITEM, I.INVOICE2, ROUND(I.INVOICE_AMOUNT,2), J.LINE_SEQ_NUM, J.DESCR, ROUND(J.NET_EXTENDED_AMT,2), I.INSTALL_NBR, I.INVOICE_DT, N.DUE_DT
	, ROUND(N.BAL_AMT,2), N.ITEM_STATUS, ROUND(I.INVOICE_AMOUNT-N.BAL_AMT,2), CASE WHEN N.BAL_AMT = 0 THEN 'TOTAL' ELSE 'PARCIAL' END, I.ENTRY_TYPE, I.ENTRY_REASON, I.ACCOUNTING_DT, L.VALUE2, M.VALUE2
;

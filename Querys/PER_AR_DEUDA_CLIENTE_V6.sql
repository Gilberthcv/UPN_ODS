--PER_AR_DEUDA_CLIENTE_V6_
SELECT A.BILL_TO_CUST_ID AS ID_CLIENTE, CONCAT(CONCAT( F.NAME1,', '), F.NAME2) AS APELLIDOS_NOMBRES, A.PO_REF AS PERIODO, I.INSTALL_NBR AS CUOTA
	, (CASE WHEN A.BILL_TYPE_ID = 'B1' THEN 'Boleta' ELSE (CASE WHEN A.BILL_TYPE_ID = 'F1' THEN 'Factura' ELSE (CASE WHEN A.BILL_TYPE_ID = 'D1' OR A.BILL_TYPE_ID = 'D2' THEN 'Nota Debito' ELSE '-' END) END) END) AS TIPO
	, G.INVOICE2 AS GOV_ID, (CASE WHEN B.ITEM_STATUS IS NOT NULL THEN (CASE WHEN B.ITEM_STATUS = 'O' THEN 'Abierto' ELSE 'Cerrado' END) ELSE 'Nuevo' END) AS ESTADO, A.INVOICE_AMOUNT AS IMPORTE
	, CASE WHEN B.BAL_AMT IS NULL THEN A.INVOICE_AMOUNT ELSE  B.BAL_AMT END AS SALDO, CASE WHEN C.USER_AMT3 IS NULL THEN 0.00 ELSE C.USER_AMT3 END AS MORA
	, CASE WHEN C.USER_AMT4 IS NULL THEN 0.00 ELSE C.USER_AMT4 END AS GASTO_ADM
	, (CASE WHEN B.BAL_AMT IS NULL THEN A.INVOICE_AMOUNT ELSE B.BAL_AMT END) + (CASE WHEN C.USER_AMT3 IS NULL THEN 0.00 ELSE C.USER_AMT3 END) + (CASE WHEN C.USER_AMT4 IS NULL THEN 0.00 ELSE C.USER_AMT4 END) AS TOTAL
	, TO_CHAR(A.INVOICE_DT,'YYYY-MM-DD') AS FECHA_EMISION
	, CASE WHEN TO_CHAR(B.DUE_DT,'YYYY-MM-DD') IS NULL THEN (CASE WHEN A.PYMNT_TERMS_CD = 00000 THEN TO_CHAR(A.DUE_DT,'YYYY-MM-DD') ELSE TO_CHAR(E.DUE_DT,'YYYY-MM-DD') END) ELSE TO_CHAR(B.DUE_DT,'YYYY-MM-DD') END AS FECHA_VENCIMIENTO
	, A.INVOICE AS NRO_TRANSACCION
FROM (((((ODSMGR.PS_BI_HDR A
			INNER JOIN ODSMGR.PS_SP_BU_BI_CLSVW A1 ON (A.BUSINESS_UNIT = A1.BUSINESS_UNIT AND  A1.OPRCLASS = 'LI_PPL_PER03_PER' ))
			LEFT JOIN ODSMGR.PS_ITEM B ON  A.BUSINESS_UNIT = B.BUSINESS_UNIT AND A.INVOICE = B.INVOICE AND A.BILL_TO_CUST_ID = B.CUST_ID )
			LEFT JOIN ODSMGR.PS_ITEM_ACTIVITY C ON  B.BUSINESS_UNIT = C.BUSINESS_UNIT AND B.CUST_ID = C.CUST_ID AND B.ITEM = C.ITEM AND C.ITEM_SEQ_NUM = 1 )
			LEFT JOIN ODSMGR.PS_LI_GBL_BI_INV G ON  A.BUSINESS_UNIT = G.BUSINESS_UNIT AND A.INVOICE = G.INVOICE )
			LEFT JOIN ODSMGR.PS_BI_INSTALL_SCHE I ON  A.BUSINESS_UNIT = I.BUSINESS_UNIT AND A.INVOICE = I.GENERATED_INVOICE )
				, PS_PAY_TRMS_NET D, PS_PAY_TRMS_TIME E, PS_CUSTOMER F
WHERE ( ( A.BUSINESS_UNIT = :1
     AND D.PYMNT_TERMS_CD = A.PYMNT_TERMS_CD
     AND D.EFFDT =
        (SELECT MAX(D_ED.EFFDT) FROM ODSMGR.PS_PAY_TRMS_NET D_ED
        WHERE D.SETID = D_ED.SETID
          AND D.PYMNT_TERMS_CD = D_ED.PYMNT_TERMS_CD
          AND D_ED.EFFDT <= CURRENT_DATE)
     AND D.SETID = A.BUSINESS_UNIT
     AND D.SETID = E.SETID
     AND E.PAY_TRMS_TIME_ID = D.PAY_TRMS_TIME_ID
     AND F.SETID = A.BUSINESS_UNIT
     AND F.CUST_ID = A.BILL_TO_CUST_ID
     AND ( A.BILL_STATUS = 'NEW'
     OR B.ITEM_STATUS = 'O')
     AND ( A.BILLING_FREQUENCY = 'ONC'
     OR ( A.BILLING_FREQUENCY = 'INS'
     AND I.GENERATED_INVOICE IS NOT NULL))
     AND F.SETID = :1
     --AND F.CUST_ID = :2
     AND A.PO_REF = :3
     --AND A.INVOICE = :4
     AND A.BILL_TYPE_ID IN ('B1','F1','D1','D2') ))
UNION
SELECT NULL, CONCAT('FECHA: ',TO_CHAR(CAST((CURRENT_TIMESTAMP) AS TIMESTAMP),'DD/MM/YYYY HH12:MI:SSPM')), NULL, NULL, NULL, 'SUMA TOTAL: ', NULL, NULL, NULL, NULL, NULL
	, SUM( ((CASE WHEN  K.BAL_AMT IS NULL THEN  J.INVOICE_AMOUNT ELSE  K.BAL_AMT END) + (CASE WHEN  L.USER_AMT3 IS NULL THEN 0.00 ELSE  L.USER_AMT3 END) + (CASE WHEN  L.USER_AMT4 IS NULL THEN 0.00 ELSE  L.USER_AMT4 END)))
	, NULL, NULL, NULL
FROM ((((ODSMGR.PS_BI_HDR J
			INNER JOIN ODSMGR.PS_SP_BU_BI_CLSVW J1 ON (J.BUSINESS_UNIT = J1.BUSINESS_UNIT AND  J1.OPRCLASS = 'LI_PPL_PER03_PER' ))
			LEFT JOIN ODSMGR.PS_ITEM K ON  J.BUSINESS_UNIT = K.BUSINESS_UNIT AND J.INVOICE = K.INVOICE AND J.BILL_TO_CUST_ID = K.CUST_ID )
			LEFT JOIN ODSMGR.PS_ITEM_ACTIVITY L ON  K.BUSINESS_UNIT = L.BUSINESS_UNIT AND K.CUST_ID = L.CUST_ID AND K.ITEM = L.ITEM AND L.ITEM_SEQ_NUM = 1 )
			LEFT JOIN ODSMGR.PS_BI_INSTALL_SCHE H ON  J.BUSINESS_UNIT = H.BUSINESS_UNIT AND J.INVOICE = H.GENERATED_INVOICE )
WHERE ( ( ( J.BILL_STATUS = 'NEW'
     OR K.ITEM_STATUS = 'O')
     AND ( J.BILLING_FREQUENCY = 'ONC'
     OR ( J.BILLING_FREQUENCY = 'INS'
     AND H.GENERATED_INVOICE IS NOT NULL))
     AND J.BUSINESS_UNIT = :1
     --AND J.BILL_TO_CUST_ID = :2
     AND J.PO_REF = :3
     --AND J.INVOICE = :4
     AND J.BILL_TYPE_ID IN ('B1','F1','D1','D2') ))
GROUP BY  NULL,  CONCAT('FECHA: ',TO_CHAR(CAST((CURRENT_TIMESTAMP) AS TIMESTAMP),'DD/MM/YYYY HH12:MI:SSPM')),  NULL,  NULL,  NULL,  'SUMA TOTAL: ',  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL,  NULL
ORDER BY 14
;

SELECT DISTINCT A.BUSINESS_UNIT, A.PO_REF
    , MAX(C.PRODUCT) OVER(PARTITION BY C.INVOICE) AS PRODUCT
    , MAX(C.OPERATING_UNIT) OVER(PARTITION BY C.INVOICE) AS OPERATING_UNIT
    , A.BILL_TO_CUST_ID, REPLACE(CONCAT(CONCAT(E.NAME2,' '),E.NAME1),'/',' ') AS NOMBRE_COMPLETO, E.SUBCUST_QUAL1
	, E.CORPORATE_CUST_ID, REPLACE(CONCAT(CONCAT(F.NAME2,' '),F.NAME1),'/',' ') AS NOMBRE_COMPLETO_CORPORATE    
    , A.BILL_TYPE_ID, A.BILL_STATUS, I.INSTALL_NBR, A.INVOICE, G.INVOICE2, D.DESCR, A.INVOICE_DT
    , CASE WHEN L.DUE_DT IS NULL 
        THEN (CASE WHEN A.PYMNT_TERMS_CD IN ('000','0000','00000') 
            THEN A.DUE_DT 
            ELSE K.DUE_DT END) 
        ELSE L.DUE_DT END AS FECHA_VENCIMIENTO
	, H.VAT_RGSTRN_ID, A.TOT_VAT, A.INVOICE_AMT_PRETAX, A.INVOICE_AMOUNT, B.SALDO_CALCULADO
	, M.ENTRY_TYPE, M.ENTRY_REASON, CASE WHEN N.ITEM IS NOT NULL THEN 'Y' ELSE 'N' END AS COBRANZA_DUDOSA
FROM PS_BI_HDR A
	, ( SELECT BUSINESS_UNIT, ITEM, SUM(ENTRY_AMT) AS SALDO_CALCULADO FROM PS_ITEM_ACTIVITY
		WHERE BUSINESS_UNIT = 'PER03' AND ACCOUNTING_DT BETWEEN :PERIODO_INICIO AND :PERIODO_FIN
		GROUP BY BUSINESS_UNIT, ITEM) B
	, PS_BI_LINE_DST C, PS_BI_LINE D, PS_CUSTOMER E, PS_CUSTOMER F, PS_LI_GBL_BI_INV G, PS_CUST_VAT_REG H, PS_BI_INSTALL_SCHE I
	, PS_PAY_TRMS_NET J, PS_PAY_TRMS_TIME K, PS_ITEM L, PS_ITEM_ACTIVITY M, PS_LI_PER_BDBTCALC N
WHERE A.INVOICE = B.ITEM
	AND A.BUSINESS_UNIT = C.BUSINESS_UNIT AND A.INVOICE = C.INVOICE
	AND A.BUSINESS_UNIT = D.BUSINESS_UNIT AND A.INVOICE = D.INVOICE
    AND D.LINE_SEQ_NUM = (SELECT MIN(D1.LINE_SEQ_NUM) FROM PS_BI_LINE D1
                            WHERE D.BUSINESS_UNIT = D1.BUSINESS_UNIT AND D.INVOICE = D1.INVOICE
                            GROUP BY D1.INVOICE)
    AND A.BILL_TO_CUST_ID = E.CUST_ID(+)
    AND E.CORPORATE_CUST_ID = F.CUST_ID(+)
    AND A.BUSINESS_UNIT = G.BUSINESS_UNIT(+) AND A.INVOICE = G.INVOICE(+)
    AND A.BILL_TO_CUST_ID = H.CUST_ID(+)
    AND A.INVOICE = I.GENERATED_INVOICE(+)
    AND A.BUSINESS_UNIT = J.SETID(+) AND A.PYMNT_TERMS_CD = J.PYMNT_TERMS_CD(+) AND J.EFFDT(+) <= CURRENT_DATE
    AND J.SETID = K.SETID(+) AND J.PAY_TRMS_TIME_ID = K.PAY_TRMS_TIME_ID(+)
    AND A.BUSINESS_UNIT = L.BUSINESS_UNIT(+) AND A.INVOICE = L.ITEM(+)
    AND B.BUSINESS_UNIT = M.BUSINESS_UNIT(+) AND B.ITEM = M.ITEM(+)
    AND M.ITEM_SEQ_NUM = (SELECT MAX(M1.ITEM_SEQ_NUM) FROM PS_ITEM_ACTIVITY M1
								WHERE M.BUSINESS_UNIT = M1.BUSINESS_UNIT AND M.ITEM = M1.ITEM
									AND M1.ACCOUNTING_DT BETWEEN :PERIODO_INICIO AND :PERIODO_FIN
								GROUP BY M1.ITEM)
    AND A.BUSINESS_UNIT = N.BUSINESS_UNIT(+) AND A.INVOICE = N.ITEM(+)
	AND A.BUSINESS_UNIT = 'PER03' AND A.BILL_TYPE_ID IN ('B1','F1','C1','C2','D1','D2') AND A.BILL_STATUS = 'INV'
	AND A.INVOICE_DT BETWEEN :PERIODO_INICIO AND :PERIODO_FIN
	AND B.SALDO_CALCULADO <> 0;
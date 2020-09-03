WITH PS_INVOICE_SUBCATEGORIA AS (
SELECT DISTINCT A.BUSINESS_UNIT, A.INVOICE, A.BILL_STATUS, A.BILL_TYPE_ID, A.PO_REF, A.BILL_TO_CUST_ID, NVL(E.INSTALL_NBR,H.INSTALL_NBR) AS INSTALL_NBR
	/*, B.LINE_SEQ_NUM, B.DESCR, B.REV_RECOG_BASIS, C.ACCOUNT, C.ACCT_ENTRY_TYPE, C.JOURNAL_DATE, D.SVRSVPR_SRVC_CODE, D.SVVSRVC_DESC, D.SVVSRVC_SRCA_CODE*/
	, NVL(MAX(CASE
	    	WHEN LENGTH(A.INVOICE) < 10 OR D.SVRSVPR_SRVC_CODE IS NOT NULL OR (C.ACCOUNT = '4800000' AND B.REV_RECOG_BASIS = 'INV') THEN 'SERVICIO'
	    	WHEN C.ACCOUNT = '4119200' THEN 'INGRESOS POR PAGO ATRASADO'
	    	WHEN C.ACCOUNT = '8200000' THEN 'INTERES MORATORIO'
	    	WHEN SUBSTR(A.PO_REF,4,1) IN ('8','9') THEN 'EPEC'
	    	WHEN SUBSTR(A.PO_REF,4,1) = '7' THEN 'INGLES'
	    	WHEN NVL(E.INSTALL_NBR,H.INSTALL_NBR) IS NOT NULL THEN 'CUOTA ' || NVL(E.INSTALL_NBR,H.INSTALL_NBR)
	    	WHEN C.ACCOUNT = '4620000' THEN 'INGRESOS POR CAFETERIA'	    	
	    	WHEN C.ACCOUNT = '6332000' THEN 'INTERCOMPANYS'
	    	WHEN C.ACCOUNT = '6551000' THEN 'RECUPEROS'
	    	WHEN C.ACCOUNT = '8350000' THEN 'INGRESOS NO OPERACIONES'
	    	WHEN C.ACCOUNT = '8400000' THEN 'AJUSTE TC GANANCIA/PERDIDA'
	    	WHEN C.ACCOUNT = '8400010' THEN 'AJUSTE POR REDONDEO'
	    	WHEN C.ACCOUNT = '2120000' THEN 'REEMBOLSO A ESTUDIANTE'
	    	WHEN C.ACCOUNT = '2161000' THEN 'PAGOS ADELANTADOS'
	    	WHEN C.ACCOUNT = '1140000' THEN 'CUENTAS POR COBRAR'
	    	ELSE NULL END) OVER(PARTITION BY A.INVOICE)
	    , MAX(CASE	    	
		    	WHEN C.ACCOUNT IN ('4000000','2160000','4901000','4904000','2160100','2160400') THEN 'MATRICULA / CUOTA INICIAL'
		    	WHEN C.ACCOUNT IN ('4800000','2160080') THEN 'OTROS INGRESOS'
		    	ELSE NULL END) OVER(PARTITION BY A.INVOICE)) AS SUBCATEGORIA
FROM ODSMGR.PS_BI_HDR A
		INNER JOIN ODSMGR.PS_BI_LINE B ON A.BUSINESS_UNIT = B.BUSINESS_UNIT AND A.INVOICE = B.INVOICE
		INNER JOIN ODSMGR.PS_BI_ACCT_ENTRY C ON B.BUSINESS_UNIT = C.BUSINESS_UNIT AND B.INVOICE = C.INVOICE AND B.LINE_SEQ_NUM = C.LINE_SEQ_NUM
												AND C.ACCT_ENTRY_TYPE IN ('DR','RR') AND C.APPL_JRNL_ID = 'BI_BILLING' AND (C.JOURNAL_ID <> ' ' OR C.JOURNAL_ID IS NOT NULL)
		LEFT JOIN ( SELECT DISTINCT ACCOUNT_UID, ID, NAME, CREDIT_CARD_NUMBER, SVRSVPR_SRVC_CODE, SVVSRVC_DESC, SVVSRVC_SRCA_CODE
					FROM ODSMGR.RECEIVABLE_ACCOUNT_DETAIL, ODSMGR.LOE_SVRSVPR, ODSMGR.LOE_SVVSRVC
					WHERE ACCOUNT_UID = SVRSVPR_PIDM AND TRANSACTION_NUMBER = SVRSVPR_ACCD_TRAN_NUMBER AND SVRSVPR_SRVC_CODE = SVVSRVC_CODE ) D ON 
												B.INVOICE = D.CREDIT_CARD_NUMBER AND B.DESCR = D.SVVSRVC_DESC
		LEFT JOIN ODSMGR.PS_BI_INSTALL_SCHE E ON A.INVOICE = E.GENERATED_INVOICE			
		LEFT JOIN ODSMGR.PS_BI_LINE_NOTE F ON A.INVOICE = F.INVOICE AND F.TEXT254 LIKE '%ORIGINAL_INVOICE:%'
											    	AND F.LINE_SEQ_NUM = (SELECT MIN(F1.LINE_SEQ_NUM) FROM ODSMGR.PS_BI_LINE_NOTE F1
																		WHERE F1.BUSINESS_UNIT = F.BUSINESS_UNIT AND F1.INVOICE = F.INVOICE
																			AND F1.TEXT254 LIKE '%ORIGINAL_INVOICE:%')		
		LEFT JOIN ODSMGR.PS_BI_LINE_NOTE G ON A.INVOICE = G.INVOICE AND G.NOTE_TYPE = 'INVOICE'
												AND G.LINE_SEQ_NUM = (SELECT MIN(G1.LINE_SEQ_NUM) FROM ODSMGR.PS_BI_LINE_NOTE G1
																		WHERE G1.BUSINESS_UNIT = G.BUSINESS_UNIT AND G1.INVOICE = G.INVOICE
																			AND G1.NOTE_TYPE = 'INVOICE')		
		LEFT JOIN ODSMGR.PS_BI_INSTALL_SCHE H ON NVL(SUBSTR(F.TEXT254,LENGTH(F.TEXT254)-9),G.TEXT254) = H.GENERATED_INVOICE
WHERE A.BUSINESS_UNIT = 'PER03'
)
SELECT 
	CAST(I.OPERATING_UNIT AS VARCHAR(50)) OPERATING_UNIT
	, CAST(N.VALUE2 AS VARCHAR(50)) AS CAMPUS
	, CAST(I.PRODUCT AS VARCHAR(50)) PRODUCT
	, CAST(O.VALUE2 AS VARCHAR(50)) AS NIVEL
	, CAST(D.PO_REF AS VARCHAR(50)) AS PO_REF
	, CAST(CASE 
		WHEN SUBSTR(E.DRAWER_ID,1,1) = 'C' OR E.PAYMENT_METHOD_CDR = 'CSH' THEN 'CAJA' ELSE 'BANCO' END AS VARCHAR(50)) AS ORIGEN
	, CAST(D.BILL_TO_CUST_ID AS VARCHAR(50)) AS BILL_TO_CUST_ID
	, CAST(REPLACE(REPLACE(CONCAT(CONCAT(J.NAME2,' '),J.NAME1),'/',' '),';','�') AS VARCHAR(255)) AS NOMBRE_COMPLETO
	, CAST(D.BILL_TYPE_ID AS VARCHAR(50)) AS BILL_TYPE_ID
	, CAST(D.INVOICE AS VARCHAR(50)) AS INVOICE
	, CAST(K.INVOICE2 AS VARCHAR(50)) AS NRO_GOBIERNO
	, CAST(NVL(E.PAYMENT_METHOD_CDR,G.PAYMENT_METHOD) AS VARCHAR(50)) AS FORMA_PAGO
	, CAST(NVL(CASE E.PAYMENT_METHOD_CDR
			WHEN 'CSH' THEN 'Efectivo'
			WHEN 'CC' THEN 'Tarjeta de Credito'
			WHEN 'CV' THEN 'Boleta de Deposito'
			WHEN 'DC' THEN 'Tarjeta de Debito'
			WHEN 'PC' THEN 'Procurenment Card'
			WHEN 'EFT' THEN 'Asbanc'
			ELSE E.PAYMENT_METHOD_CDR END
		, CASE G.PAYMENT_METHOD
			WHEN 'CSH' THEN 'Efectivo'
			WHEN 'EFT' THEN 'Asbanc'
			ELSE G.PAYMENT_METHOD END) AS VARCHAR(50)) AS FORMA_PAGO_DESC
	, CAST(CASE WHEN F.CR_CARD_TYPE = ' ' OR F.CR_CARD_TYPE IS NULL THEN NULL ELSE F.CR_CARD_TYPE  END AS VARCHAR(50)) AS TIPO_TARJETA
	, CAST(CASE
		WHEN F.CR_CARD_TYPE = '01' THEN 'Visa'
		WHEN F.CR_CARD_TYPE = '02' THEN 'MasterCard'
		WHEN F.CR_CARD_TYPE = '03' THEN 'Diners Club'
		WHEN F.CR_CARD_TYPE = '04' THEN 'Amex'
		WHEN NVL(E.PAYMENT_METHOD_CDR,G.PAYMENT_METHOD) = 'EFT' THEN 'Banco'
		WHEN NVL(E.PAYMENT_METHOD_CDR,G.PAYMENT_METHOD) = 'CSH' THEN 'Caja'
		WHEN NVL(E.PAYMENT_METHOD_CDR,G.PAYMENT_METHOD) = 'CV' THEN 'Deposito'
		WHEN F.CR_CARD_TYPE = ' ' THEN NULL
		ELSE F.CR_CARD_TYPE END AS VARCHAR(50)) AS TIPO_TARJETA_DESC
	, CAST(C.DEPOSIT_ID AS VARCHAR(50)) AS DEPOSIT_ID
	, CAST(C.PAYMENT_ID AS VARCHAR(50)) AS PAYMENT_ID
	, CAST(E.DRAWER_ID AS VARCHAR(50)) AS DRAWER_ID
	, CAST(TO_CHAR(NVL(E.CREATEDTTM,C.ACCOUNTING_DT),'YYYY-MM-DD HH24:MI:SS') AS DATETIME) AS FECHA_COBRANZA
	, C.ACCOUNTING_DT
	, C.POST_DT
	, D.INVOICE_DT
	, CASE WHEN A.DUE_DT IS NULL 
        THEN ( CASE WHEN D.PYMNT_TERMS_CD IN ('000','0000','00000') THEN D.DUE_DT ELSE M.DUE_DT END ) 
        ELSE A.DUE_DT END AS FECHA_VENCIMIENTO
	, D.INVOICE_AMOUNT
	, B.MONETARY_AMOUNT
	, G.PAYMENT_AMT
	, CASE WHEN ABS(B.MONETARY_AMOUNT) = ABS(D.INVOICE_AMOUNT) THEN 'TOTAL' ELSE 'PARCIAL' END AS PAGO
	, CASE WHEN G.PAYMENT_STATUS = 'C' AND G.WO_ADJ_USED_SW = 'Y' THEN 'Y' ELSE 'N' END AS ANULADO
	, CASE WHEN G.UNPOST_REASON = 'ERROR' THEN 'Y' ELSE 'N' END AS DESCONTABILIZADO
	, CAST(H.RECON_ID AS VARCHAR(50)) AS RECON_ID
	, CAST(G.BNK_ID_NBR AS VARCHAR(50)) AS BNK_ID_NBR
	, CAST(G.BANK_ACCOUNT_NUM AS VARCHAR(50)) AS BANK_ACCOUNT_NUM
	, CAST(B.ACCOUNT AS VARCHAR(50)) AS ACCOUNT
	, CAST(B.JOURNAL_ID AS VARCHAR(50)) AS JOURNAL_ID
	, B.JOURNAL_DATE
	, CASE WHEN B.JOURNAL_ID = ' ' OR B.JOURNAL_ID IS NULL THEN 'Y' ELSE 'N' END AS MIGRADO
	, CAST(P.SUBCATEGORIA AS VARCHAR(50)) AS SUBCATEGORIA
    , CAST(CASE
    	WHEN (Q.SEMESTRE ||' ('|| Q.NIVEL ||')') IS NOT NULL AND (P.SUBCATEGORIA = 'MATRICULA / CUOTA INICIAL' OR SUBSTR(P.SUBCATEGORIA,1,5) = 'CUOTA') THEN P.SUBCATEGORIA
    	WHEN P.SUBCATEGORIA IN ('EPEC','INGLES') THEN P.SUBCATEGORIA
    	WHEN P.SUBCATEGORIA IN ('INGRESOS POR PAGO ATRASADO','INTERES MORATORIO') THEN 'LATE FEES'
    	ELSE 'OTROS' END AS VARCHAR(50)) AS CATEGORIA
    , CAST(CASE WHEN (Q.SEMESTRE ||' ('|| Q.NIVEL ||')') IS NOT NULL AND (P.SUBCATEGORIA = 'MATRICULA / CUOTA INICIAL' OR SUBSTR(P.SUBCATEGORIA,1,5) = 'CUOTA')
    		THEN (Q.SEMESTRE ||' ('|| Q.NIVEL ||')') ELSE 'OTROS INGRESOS' END AS VARCHAR(50)) AS PERIODO
    , R.START_DATE
    , R.END_DATE
    , CASE
    	WHEN P.SUBCATEGORIA IN ('INGRESOS POR PAGO ATRASADO','INTERES MORATORIO','SERVICIO','PAGOS ADELANTADOS')
    			OR (SUBSTR(D.PO_REF,4,1) IN ('3','4','5') AND TO_CHAR(C.ACCOUNTING_DT,'YYYY') = TO_CHAR(R.END_DATE,'YYYY')) THEN 'Y'
    	WHEN C.ACCOUNTING_DT > R.END_DATE THEN 'N'
    	ELSE 'Y' END AS ACTIVA
	--SUM(B.MONETARY_AMOUNT) AS MONTO_PAGO
FROM ODSMGR.PS_ITEM A
		INNER JOIN ODSMGR.PS_ITEM_DST B ON A.BUSINESS_UNIT = B.BUSINESS_UNIT AND A.ITEM = B.ITEM AND A.ITEM_LINE = B.ITEM_LINE AND B.LEDGER = 'ACTUALS'
											AND B.ACCOUNT NOT IN ('1140000','4000000')
											--AND B.JOURNAL_DATE BETWEEN TO_DATE('2019-01-01','YYYY-MM-DD') AND TO_DATE('2020-06-30','YYYY-MM-DD')											
											AND B.JOURNAL_DATE BETWEEN DATE_TRUNC('MONTH',CURRENT_DATE-1) AND (CURRENT_DATE-1)
		INNER JOIN ODSMGR.PS_ITEM_ACTIVITY C ON A.BUSINESS_UNIT = C.BUSINESS_UNIT AND A.ITEM = C.ITEM AND A.ITEM_LINE = C.ITEM_LINE AND B.ITEM_SEQ_NUM = C.ITEM_SEQ_NUM AND C.ENTRY_TYPE = 'PY'											
											--AND C.ACCOUNTING_DT BETWEEN TO_DATE('2019-01-01','YYYY-MM-DD') AND TO_DATE('2020-06-30','YYYY-MM-DD')
											AND C.ACCOUNTING_DT BETWEEN DATE_TRUNC('MONTH',CURRENT_DATE-1) AND (CURRENT_DATE-1)
		INNER JOIN ODSMGR.PS_BI_HDR D ON A.BUSINESS_UNIT = D.BUSINESS_UNIT AND A.ITEM = D.INVOICE		
		LEFT JOIN ODSMGR.PS_LI_PER_ARPMT_VW E ON C.BUSINESS_UNIT = E.DEPOSIT_BU AND C.DEPOSIT_ID = E.DEPOSIT_ID AND C.PAYMENT_ID = E.PAYMENT_ID AND C.PAYMENT_SEQ_NUM = E.PAYMENT_SEQ_NUM AND C.ITEM = E.INVOICE		
		LEFT JOIN ODSMGR.PS_LI_GBL_ARPY_DTL F ON E.DEPOSIT_BU = F.DEPOSIT_BU AND E.PYMNT_REF_ID = F.PYMNT_REF_ID		
		LEFT JOIN ODSMGR.PS_PAYMENT G ON C.BUSINESS_UNIT = G.DEPOSIT_BU AND C.PAYMENT_ID = G.PAYMENT_ID AND C.PAYMENT_SEQ_NUM = G.PAYMENT_SEQ_NUM AND C.DEPOSIT_ID = G.DEPOSIT_ID		
		LEFT JOIN ODSMGR.PS_CDR_RECEIPT H ON E.DEPOSIT_BU = H.DEPOSIT_BU AND E.RECEIPT_NBR = H.RECEIPT_NBR		
		LEFT JOIN ODSMGR.PS_BI_LINE_DST I ON D.BUSINESS_UNIT = I.BUSINESS_UNIT AND D.INVOICE = I.INVOICE
												AND I.LINE_SEQ_NUM = (SELECT MAX(I1.LINE_SEQ_NUM) FROM ODSMGR.PS_BI_LINE_DST I1 WHERE I1.BUSINESS_UNIT = I.BUSINESS_UNIT AND I1.INVOICE = I.INVOICE)		
		LEFT JOIN ODSMGR.PS_CUSTOMER J ON D.BILL_TO_CUST_ID = J.CUST_ID												
		LEFT JOIN ODSMGR.PS_LI_GBL_BI_INV K ON D.BUSINESS_UNIT = K.BUSINESS_UNIT AND D.INVOICE = K.INVOICE		
		LEFT JOIN ODSMGR.PS_PAY_TRMS_NET L ON D.BUSINESS_UNIT = L.SETID AND D.PYMNT_TERMS_CD = L.PYMNT_TERMS_CD
												AND L.EFFDT = (SELECT MAX(L1.EFFDT) FROM ODSMGR.PS_PAY_TRMS_NET L1
																WHERE L1.SETID = L.SETID AND L1.PYMNT_TERMS_CD = L.PYMNT_TERMS_CD AND L1.EFFDT <= CURRENT_DATE)			
		LEFT JOIN ODSMGR.PS_PAY_TRMS_TIME M ON L.SETID = M.SETID AND L.PAY_TRMS_TIME_ID = M.PAY_TRMS_TIME_ID		
		LEFT JOIN ODSMGR.LOE_BASE_TABLE_EQUIV N ON I.OPERATING_UNIT = N.VALUE1 AND N.TABLE_PARENT_ID = 1		
		LEFT JOIN ODSMGR.LOE_BASE_TABLE_EQUIV O ON I.PRODUCT = O.VALUE1 AND O.TABLE_PARENT_ID = 9		
		LEFT JOIN PS_INVOICE_SUBCATEGORIA P ON D.BUSINESS_UNIT = P.BUSINESS_UNIT AND D.INVOICE = P.INVOICE		
		LEFT JOIN ( SELECT TERM_CODE, SUBSTR(STVTERM_DESC,1,6) AS SEMESTRE, STVTERM_DESC
						, CASE SUBSTR(TERM_CODE,4,1) WHEN '4' THEN 'UG' WHEN '5' THEN 'WA' END AS NIVEL
					FROM ODSMGR.LOE_SECTION_PART_OF_TERM, ODSMGR.STVTERM
					WHERE TERM_CODE = STVTERM_CODE AND WEEKS > 15 AND WEEKS < 18
						AND SUBSTR(TERM_CODE,4,1) IN ('4','5') AND TERM_CODE > 217430 ) Q ON
										D.PO_REF = Q.TERM_CODE		
		LEFT JOIN ODSMGR.LOE_SECTION_PART_OF_TERM R ON D.PO_REF = R.TERM_CODE
WHERE A.BUSINESS_UNIT = 'PER03' AND (A.CUST_ID <> '9999999999' OR A.CUST_ID IS NULL)
;
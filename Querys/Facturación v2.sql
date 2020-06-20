
SELECT
    Z.BUSINESS_UNIT, Z.PO_REF, Z.PRODUCT, Z.NIVEL, Z.OPERATING_UNIT, Z.CAMPUS, Z.BILL_TO_CUST_ID, REPLACE(Z.NOMBRE_COMPLETO,';','�') AS NOMBRE_COMPLETO
    , REPLACE(Z.NOMBRE_COMPLETO_CORPORATE,';','�') AS NOMBRE_COMPLETO_CORPORATE
    , Z.BILL_TYPE_ID, Z.INSTALL_NBR, Z.INVOICE, Z.INVOICE2, Z.LINE_SEQ_NUM, Z.DESCR, Z.SVRSVPR_SRVC_CODE, Z.SVVSRVC_DESC, Z.SVVSRVC_SRCA_CODE
    , Z.INVOICE_DT, Z.FECHA_VENCIMIENTO, Z.VAT_RGSTRN_ID, ROUND(Z.NET_EXTENDED_AMT,2) AS NET_EXTENDED_AMT, ROUND(Z.INVOICE_AMOUNT,2) AS INVOICE_AMOUNT
    , Z.ORIGINAL_INVOICE, Z.ORIGINAL_INVOICE2, Z.ENTRY_TYPE_BI, Z.ACCOUNT_BI, Z.JOURNAL_ID_BI, Z.JOURNAL_DATE_BI, Z.REV_RECOG_BASIS_DESC
    , Z.ITEM_SEQ_NUM, Z.ENTRY_TYPE_AR, Z.ENTRY_REASON_AR, Z.JOURNAL_ID_AR, Z.JOURNAL_DATE_AR
    , ROUND(CASE WHEN Z.MONTO_IMPUESTO <> 0 THEN Z.MONTO_BI_AR_CALCULADO ELSE 0 END,2) AS MONTO_AFECTO
    , ROUND(CASE WHEN Z.MONTO_IMPUESTO = 0 THEN Z.MONTO_BI_AR_CALCULADO ELSE 0 END,2) AS MONTO_INAFECTO
    , ROUND(Z.MONTO_IMPUESTO,2) AS MONTO_IMPUESTO, ROUND((Z.MONTO_BI_AR_CALCULADO + Z.MONTO_IMPUESTO),2) AS MONTO_TOTAL
    , NVL(Z.SUBCATEGORIA1,Z.SUBCATEGORIA2) AS SUBCATEGORIA
    , CASE
    	WHEN Z.PERIODO IS NOT NULL AND (NVL(Z.SUBCATEGORIA1,Z.SUBCATEGORIA2) = 'MATRICULA / CUOTA INICIAL' OR SUBSTR(NVL(Z.SUBCATEGORIA1,Z.SUBCATEGORIA2),1,5) = 'CUOTA')
    			THEN NVL(Z.SUBCATEGORIA1,Z.SUBCATEGORIA2)
    	WHEN NVL(Z.SUBCATEGORIA1,Z.SUBCATEGORIA2) IN ('EPEC','INGLES') THEN NVL(Z.SUBCATEGORIA1,Z.SUBCATEGORIA2)
    	WHEN NVL(Z.SUBCATEGORIA1,Z.SUBCATEGORIA2) IN ('INGRESOS POR PAGO ATRASADO','INTERES MORATORIO') THEN 'LATE FEES'    	
    	ELSE 'OTROS' END AS CATEGORIA
    , CASE WHEN Z.PERIODO IS NOT NULL AND (NVL(Z.SUBCATEGORIA1,Z.SUBCATEGORIA2) = 'MATRICULA / CUOTA INICIAL' OR SUBSTR(NVL(Z.SUBCATEGORIA1,Z.SUBCATEGORIA2),1,5) = 'CUOTA')
    		THEN Z.PERIODO ELSE 'OTROS INGRESOS' END AS PERIODO
    , Z.START_DATE, Z.END_DATE
    , CASE WHEN NVL(Z.SUBCATEGORIA1,Z.SUBCATEGORIA2) IN ('INGRESOS POR PAGO ATRASADO','INTERES MORATORIO','SERVICIO','PAGOS ADELANTADOS')
    			OR (SUBSTR(Z.PO_REF,4,1) IN ('3','4','5') AND TO_CHAR(Z.INVOICE_DT,'YYYY') = TO_CHAR(Z.END_DATE,'YYYY'))
    		THEN 'Y' ELSE Z.ACTIVA END AS ACTIVA
    /*SUM(ROUND(CASE WHEN Z.MONTO_IMPUESTO <> 0 THEN Z.MONTO_BI_AR_CALCULADO ELSE 0 END,2)) AS MONTO_AFECTO
    , SUM(ROUND(CASE WHEN Z.MONTO_IMPUESTO = 0 THEN Z.MONTO_BI_AR_CALCULADO ELSE 0 END,2)) AS MONTO_INAFECTO
    , SUM(ROUND(Z.MONTO_IMPUESTO,2)) AS MONTO_IMPUESTO, SUM(ROUND((Z.MONTO_BI_AR_CALCULADO + Z.MONTO_IMPUESTO),2)) AS MONTO_TOTAL*/
FROM (

SELECT DISTINCT
    D.BUSINESS_UNIT, D.INVOICE, D.BILL_STATUS, D.BILL_TYPE_ID, D.INVOICE_AMOUNT, D.INVOICE_DT, D.PO_REF, D.TOT_VAT, D.DUE_DT, D.PRODUCT, U.VALUE2 AS NIVEL
    , D.OPERATING_UNIT, T.VALUE2 AS CAMPUS, D.NET_EXTENDED_AMT, D.ENTRY_TYPE ENTRY_TYPE_BI
    , D.BILL_TO_CUST_ID, REPLACE(CONCAT(CONCAT(I.NAME2,' '),I.NAME1),'/',' ') AS NOMBRE_COMPLETO
    , I.CORPORATE_CUST_ID, REPLACE(CONCAT(CONCAT(J.NAME2,' '),J.NAME1),'/',' ') AS NOMBRE_COMPLETO_CORPORATE, K.INVOICE2, L.VAT_RGSTRN_ID
    , NVL(M.INSTALL_NBR,M0.INSTALL_NBR) AS INSTALL_NBR, NVL(M.INVOICE,D.INVOICE) AS INVOICE_PLANTILLA
    , NVL(SUBSTR(N.TEXT254,LENGTH(N.TEXT254)-9),N0.TEXT254) AS ORIGINAL_INVOICE, O.INVOICE2 AS ORIGINAL_INVOICE2
    , CASE WHEN R.DUE_DT IS NULL 
        THEN ( CASE WHEN D.PYMNT_TERMS_CD IN ('000','0000','00000') 
            THEN D.DUE_DT 
            ELSE Q.DUE_DT END ) 
        ELSE R.DUE_DT END AS FECHA_VENCIMIENTO
    , CASE WHEN D.TOT_VAT <> 0 AND H.ENTRY_TYPE = 'WOC' AND H.ENTRY_REASON = 'A-DIR' 
        THEN D.TOT_VAT *-1 
        ELSE D.TOT_VAT END AS MONTO_IMPUESTO
    , CASE WHEN D.BILL_TYPE_ID IN ('F1','B1','D1','D2','C1','C2') 
        THEN (CASE WHEN H.ITEM IS NOT NULL 
                THEN (D.NET_EXTENDED_AMT * H.ENTRY_AMT) / D.INVOICE_AMOUNT
                ELSE E.MONETARY_AMOUNT *-1 END)
        ELSE E.MONETARY_AMOUNT END AS MONTO_BI_AR_CALCULADO
    , E.MONETARY_AMOUNT/*, E.LINE_SEQ_NUM*/, E.ACCOUNT ACCOUNT_BI, E.JOURNAL_ID JOURNAL_ID_BI, E.JOURNAL_DATE JOURNAL_DATE_BI
    , D.LINE_SEQ_NUM, D.DESCR, D.REV_RECOG_BASIS, S.SVRSVPR_SRVC_CODE, S.SVVSRVC_DESC, S.SVVSRVC_SRCA_CODE
    , CASE D.REV_RECOG_BASIS 
            WHEN 'CHG' THEN 'Rango F Inicial/Final' 
            WHEN 'INV' THEN 'Fecha Factura' ELSE D.REV_RECOG_BASIS END AS REV_RECOG_BASIS_DESC
    , H.ITEM_SEQ_NUM, H.ENTRY_TYPE ENTRY_TYPE_AR, H.ENTRY_REASON ENTRY_REASON_AR, H.ACCOUNTING_DT, H.JOURNAL_ID JOURNAL_ID_AR, H.JOURNAL_DATE JOURNAL_DATE_AR
    , MAX(CASE
	    	WHEN LENGTH(D.INVOICE) < 10 OR S.SVRSVPR_SRVC_CODE IS NOT NULL OR (E.ACCOUNT = '4800000' AND D.REV_RECOG_BASIS = 'INV') THEN 'SERVICIO'
	    	WHEN E.ACCOUNT = '4119200' THEN 'INGRESOS POR PAGO ATRASADO'
	    	WHEN E.ACCOUNT = '8200000' THEN 'INTERES MORATORIO'
	    	WHEN SUBSTR(D.PO_REF,4,1) IN ('8','9') THEN 'EPEC'
	    	WHEN SUBSTR(D.PO_REF,4,1) = '7' THEN 'INGLES'
	    	WHEN NVL(M.INSTALL_NBR,M0.INSTALL_NBR) IS NOT NULL THEN 'CUOTA ' || NVL(M.INSTALL_NBR,M0.INSTALL_NBR)
	    	WHEN E.ACCOUNT = '4620000' THEN 'INGRESOS POR CAFETERIA'	    	
	    	WHEN E.ACCOUNT = '6332000' THEN 'INTERCOMPANYS'
	    	WHEN E.ACCOUNT = '6551000' THEN 'RECUPEROS'
	    	WHEN E.ACCOUNT = '8350000' THEN 'INGRESOS NO OPERACIONES'
	    	WHEN E.ACCOUNT = '8400000' THEN 'AJUSTE TC GANANCIA/PERDIDA'
	    	WHEN E.ACCOUNT = '8400010' THEN 'AJUSTE POR REDONDEO'
	    	WHEN E.ACCOUNT = '2120000' THEN 'REEMBOLSO A ESTUDIANTE'
	    	WHEN E.ACCOUNT = '2161000' THEN 'PAGOS ADELANTADOS'
	    	WHEN E.ACCOUNT = '1140000' THEN 'CUENTAS POR COBRAR'	    	
	    	ELSE NULL END) OVER(PARTITION BY D.INVOICE) AS SUBCATEGORIA1
    , MAX(CASE	    	
	    	WHEN E.ACCOUNT IN ('4000000','2160000','4901000','4904000','2160100','2160400') THEN 'MATRICULA / CUOTA INICIAL'
	    	WHEN E.ACCOUNT IN ('4800000','2160080') THEN 'OTROS INGRESOS'
	    	ELSE NULL END) OVER(PARTITION BY D.INVOICE) AS SUBCATEGORIA2
    , V.SEMESTRE ||' ('|| V.NIVEL ||')' AS PERIODO
    , W.START_DATE, W.END_DATE, CASE WHEN D.INVOICE_DT > W.END_DATE THEN 'N' ELSE 'Y' END AS ACTIVA
    
FROM ( SELECT DISTINCT 
            A.BUSINESS_UNIT, A.INVOICE, A.BILL_STATUS, A.BILL_TYPE_ID, A.INVOICE_AMOUNT, A.INVOICE_DT, A.PO_REF, A.TOT_VAT, A.DUE_DT
            , A.BILL_TO_CUST_ID, A.PYMNT_TERMS_CD, A.ENTRY_TYPE, B.LINE_SEQ_NUM, B.DESCR, B.NET_EXTENDED_AMT, B.REV_RECOG_BASIS
            , MAX(C.PRODUCT) AS PRODUCT
            , MAX(C.OPERATING_UNIT) AS OPERATING_UNIT
        FROM ODSMGR.PS_BI_HDR A, ODSMGR.PS_BI_LINE B, ODSMGR.PS_BI_LINE_DST C
        WHERE A.BUSINESS_UNIT = B.BUSINESS_UNIT AND A.INVOICE = B.INVOICE
        	AND B.BUSINESS_UNIT = C.BUSINESS_UNIT(+) AND B.INVOICE = C.INVOICE(+) AND B.LINE_SEQ_NUM = C.LINE_SEQ_NUM(+)
            AND A.BUSINESS_UNIT = 'PER03' AND A.INVOICE_DT BETWEEN TO_DATE(:FECHA_INICIO,'YYYY-MM-DD') AND TO_DATE(:FECHA_FIN,'YYYY-MM-DD')
        GROUP BY A.BUSINESS_UNIT, A.INVOICE, A.BILL_STATUS, A.BILL_TYPE_ID, A.INVOICE_AMOUNT, A.INVOICE_DT, A.PO_REF, A.TOT_VAT, A.DUE_DT
            , A.BILL_TO_CUST_ID, A.PYMNT_TERMS_CD, A.ENTRY_TYPE, B.LINE_SEQ_NUM, B.DESCR, B.NET_EXTENDED_AMT, B.REV_RECOG_BASIS ) D
            
			LEFT JOIN ODSMGR.PS_BI_ACCT_ENTRY E ON D.BUSINESS_UNIT = E.BUSINESS_UNIT AND D.INVOICE = E.INVOICE AND D.LINE_SEQ_NUM = E.LINE_SEQ_NUM
													AND E.ACCT_ENTRY_TYPE IN ('DR','RR') AND E.APPL_JRNL_ID = 'BI_BILLING' AND E.JOURNAL_ID <> ' ' AND E.JOURNAL_ID IS NOT NULL
													AND E.JOURNAL_DATE BETWEEN TO_DATE(:FECHA_INICIO,'YYYY-MM-DD') AND TO_DATE(:FECHA_FIN,'YYYY-MM-DD')
			
			LEFT JOIN ( SELECT DISTINCT F.BUSINESS_UNIT, F.ITEM, F.ITEM_LINE, F.ITEM_SEQ_NUM, F.ENTRY_TYPE, F.ENTRY_REASON, F.ENTRY_AMT, F.ACCOUNTING_DT, G.JOURNAL_ID, G.JOURNAL_DATE
				        FROM (SELECT BUSINESS_UNIT, ITEM, ITEM_LINE, ITEM_SEQ_NUM, ENTRY_TYPE, ENTRY_REASON, ENTRY_AMT, ACCOUNTING_DT
				                    , MAX(CASE WHEN ENTRY_TYPE IN ('WO','WOC') AND ENTRY_REASON = 'A-DIR' THEN 'WO_WOC_A-DIR' END) OVER(PARTITION BY ITEM) AS WO_WOC_A_DIR              
				                FROM ODSMGR.PS_ITEM_ACTIVITY
				                WHERE BUSINESS_UNIT = 'PER03' AND ENTRY_TYPE NOT IN ('PY','MT') AND ACCOUNTING_DT BETWEEN TO_DATE(:FECHA_INICIO,'YYYY-MM-DD') AND TO_DATE(:FECHA_FIN,'YYYY-MM-DD')) F
				            , ODSMGR.PS_ITEM_DST G
				        WHERE F.BUSINESS_UNIT = G.BUSINESS_UNIT(+) AND F.ITEM = G.ITEM(+) AND F.ITEM_LINE = G.ITEM_LINE(+) AND F.ITEM_SEQ_NUM = G.ITEM_SEQ_NUM(+)
				            AND F.WO_WOC_A_DIR = 'WO_WOC_A-DIR'
				            AND G.LEDGER(+) = 'ACTUALS' AND G.JOURNAL_DATE(+) BETWEEN TO_DATE(:FECHA_INICIO,'YYYY-MM-DD') AND TO_DATE(:FECHA_FIN,'YYYY-MM-DD') ) H ON 
				            				D.BUSINESS_UNIT = H.BUSINESS_UNIT AND D.INVOICE = H.ITEM AND NOT(H.ENTRY_TYPE = 'WOC' AND H.ENTRY_REASON = 'REF')
			
			LEFT JOIN ODSMGR.PS_CUSTOMER I ON D.BILL_TO_CUST_ID = I.CUST_ID
			
			LEFT JOIN ODSMGR.PS_CUSTOMER J ON I.CORPORATE_CUST_ID = J.CUST_ID
			
			LEFT JOIN ODSMGR.PS_LI_GBL_BI_INV K ON D.BUSINESS_UNIT = K.BUSINESS_UNIT AND D.INVOICE = K.INVOICE
			
			LEFT JOIN ODSMGR.PS_CUST_VAT_REG L ON D.BILL_TO_CUST_ID = L.CUST_ID
			
			LEFT JOIN ODSMGR.PS_BI_INSTALL_SCHE M ON D.INVOICE = M.GENERATED_INVOICE			
			
			LEFT JOIN ODSMGR.PS_BI_LINE_NOTE N ON D.INVOICE = N.INVOICE AND N.TEXT254 LIKE '%ORIGINAL_INVOICE:%'
												    	AND N.LINE_SEQ_NUM = (SELECT MIN(N1.LINE_SEQ_NUM) FROM ODSMGR.PS_BI_LINE_NOTE N1
																			WHERE N1.BUSINESS_UNIT = N.BUSINESS_UNIT AND N1.INVOICE = N.INVOICE
																				AND N1.TEXT254 LIKE '%ORIGINAL_INVOICE:%')
			
			LEFT JOIN ODSMGR.PS_BI_LINE_NOTE N0 ON D.INVOICE = N0.INVOICE AND N0.NOTE_TYPE = 'INVOICE'
													AND N0.LINE_SEQ_NUM = (SELECT MIN(N2.LINE_SEQ_NUM) FROM ODSMGR.PS_BI_LINE_NOTE N2
																			WHERE N2.BUSINESS_UNIT = N0.BUSINESS_UNIT AND N2.INVOICE = N0.INVOICE
																				AND N2.NOTE_TYPE = 'INVOICE')
			
			LEFT JOIN ODSMGR.PS_BI_INSTALL_SCHE M0 ON NVL(SUBSTR(N.TEXT254,LENGTH(N.TEXT254)-9),N0.TEXT254) = M0.GENERATED_INVOICE
			
			LEFT JOIN ODSMGR.PS_LI_GBL_BI_INV O ON NVL(SUBSTR(N.TEXT254,LENGTH(N.TEXT254)-9),N0.TEXT254) = O.INVOICE
			
			LEFT JOIN ODSMGR.PS_PAY_TRMS_NET P ON D.BUSINESS_UNIT = P.SETID AND D.PYMNT_TERMS_CD = P.PYMNT_TERMS_CD AND P.EFFDT <= CURRENT_DATE
			
			LEFT JOIN ODSMGR.PS_PAY_TRMS_TIME Q ON P.SETID = Q.SETID AND P.PAY_TRMS_TIME_ID = Q.PAY_TRMS_TIME_ID
			
			LEFT JOIN ODSMGR.PS_ITEM R ON D.BUSINESS_UNIT = R.BUSINESS_UNIT AND D.INVOICE = R.ITEM AND (R.CUST_ID <> '9999999999' OR R.CUST_ID IS NULL)
			
			LEFT JOIN ( SELECT DISTINCT ACCOUNT_UID, ID, NAME, CREDIT_CARD_NUMBER
							, SVRSVPR_SRVC_CODE, SVVSRVC_DESC, SVVSRVC_SRCA_CODE
						FROM ODSMGR.RECEIVABLE_ACCOUNT_DETAIL, ODSMGR.LOE_SVRSVPR, ODSMGR.LOE_SVVSRVC
						WHERE ACCOUNT_UID = SVRSVPR_PIDM AND TRANSACTION_NUMBER = SVRSVPR_ACCD_TRAN_NUMBER
							AND SVRSVPR_SRVC_CODE = SVVSRVC_CODE ) S ON 
											D.INVOICE = S.CREDIT_CARD_NUMBER AND D.DESCR = S.SVVSRVC_DESC

			LEFT JOIN ODSMGR.LOE_BASE_TABLE_EQUIV T ON D.OPERATING_UNIT = T.VALUE1 AND T.TABLE_PARENT_ID = 1
		
			LEFT JOIN ODSMGR.LOE_BASE_TABLE_EQUIV U ON D.PRODUCT = U.VALUE1 AND U.TABLE_PARENT_ID = 9
			
			LEFT JOIN ( SELECT TERM_CODE, SUBSTR(STVTERM_DESC,1,6) AS SEMESTRE, STVTERM_DESC
							, CASE SUBSTR(TERM_CODE,4,1) WHEN '4' THEN 'UG' WHEN '5' THEN 'WA' END AS NIVEL
						FROM ODSMGR.LOE_SECTION_PART_OF_TERM, ODSMGR.STVTERM
						WHERE TERM_CODE = STVTERM_CODE AND WEEKS > 15 AND WEEKS < 18
							AND SUBSTR(TERM_CODE,4,1) IN ('4','5') AND TERM_CODE > 217430 ) V ON
											D.PO_REF = V.TERM_CODE
			
			LEFT JOIN ODSMGR.LOE_SECTION_PART_OF_TERM W ON D.PO_REF = W.TERM_CODE

WHERE (E.JOURNAL_ID IS NOT NULL OR H.JOURNAL_ID IS NOT NULL)
) Z
;


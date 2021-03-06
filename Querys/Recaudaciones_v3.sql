
WITH PER_AR_COBRANZAS AS (
    SELECT DISTINCT A.BUSINESS_UNIT AS UN, I.PYMNT_REF_ID AS ID_PAGO, A.BILL_TO_CUST_ID AS CLIENTE, A.INVOICE AS TRANSACCION, B.INSTALL_NBR AS NRO_CUOTA, D.INVOICE2 AS GOV_ID
        , A.INVOICE_AMOUNT AS IMPORTE_DOCUMEN, A.BASE_CURRENCY AS MON_BASE, TO_CHAR(A.DUE_DT,'YYYY-MM-DD') AS F_VTO, I.FC_AMT AS MORA, A.BILL_TYPE_ID AS TIPO_FAC_SIS, J.RECEIPT_STATUS AS ESTADO
        , CASE WHEN SUBSTR( J.DRAWER_ID,1,1) = 'C' THEN  A.INVOICE_AMOUNT ELSE CASE WHEN  G.PAY_AMT = 0 THEN  A.INVOICE_AMOUNT ELSE  G.PAY_AMT END END AS IMPORTE_PAGADO
        , CASE WHEN ROW_NUMBER () OVER (PARTITION BY  G.DEPOSIT_ID,  H.PAYMENT_ID,  A.BILL_TO_CUST_ID ORDER BY  A.INVOICE ASC)  = 1 THEN  H.PAYMENT_AMT ELSE 0 END AS TOTAL_PAGADO
        , J.PAYMENT_TOTAL AS TOTAL_PAGO, J.CASH_AMT AS COBROS, J.DRAWER_ID AS ID_CAJA_EFVO, L.RECEIPT_NBR AS NRO_RECEP, L.RECON_ID AS ID_CONCILI, L.CURRENCY_CD AS MONEDA, L.NON_CASH_AMT AS NO_EFECTIVO
        , L.CASH_AMT AS COBROS_CJA, L.ORIG_OPRID AS USUARIO_CJA, CONCAT(CONCAT((REPLACE( C.NAME1,'/',' ')),' '), C.NAME2) AS NOMBRES_APELLIDOS, M.DESCR AS DESCRIPCION
        , TO_CHAR(CAST((L.ADD_DTTM) AS TIMESTAMP),'YYYY-MM-DD-HH24.MI.SS.FF') AS FECHA_ARQUEO, TO_CHAR(CAST((I.CREATEDTTM) AS TIMESTAMP),'YYYY-MM-DD-HH24.MI.SS.FF') AS FECHA_CREACION
        , E.ITEM_STATUS AS ESTADO_AR, K.PAYMENT_METHOD_CDR AS PAGO, K.CR_CARD_TYPE AS TIPO_TARJETA, K.CR_CARD_AUTH_CD AS CD_AUTORIZ, J.SOURCE AS ORIG
        , TO_CHAR(CAST((K.CREATEDTTM) AS TIMESTAMP),'YYYY-MM-DD-HH24.MI.SS.FF') AS FECHA_COBRANZA, CASE WHEN ( H.PAYMENT_STATUS = 'C' AND  H.WO_ADJ_USED_SW = 'Y') THEN 'Si' ELSE 'No' END AS ANULADO
        , CASE WHEN  H.UNPOST_REASON = 'ERROR' THEN 'Si' ELSE 'No'  END AS DESCONTABILIZADO, J.LOCKBOX_RUN_STATUS AS RUN_STATUS, J.FILENAME AS NOMBRE_ARCHIVO, H.BNK_ID_NBR AS ID_BANCO
        , H.BANK_ACCOUNT_NUM AS NRO_CUENTA, F.JOURNAL_ID AS ASIENTO, TO_CHAR(F.JOURNAL_DATE,'YYYY-MM-DD') AS F_ASIENTO, G.DEPOSIT_ID AS ID_DEP, H.PAYMENT_ID AS ID_PG
        , TO_CHAR(H.ACCOUNTING_DT,'YYYY-MM-DD') AS F_CONTABLE, H.PAYMENT_STATUS AS ESTADO_COBRO, F.ACCOUNT AS CUENTA, A.CREATEOPRID AS USUARIO
        , ROW_NUMBER () OVER (PARTITION BY  G.DEPOSIT_ID,  H.PAYMENT_ID,  A.BILL_TO_CUST_ID ORDER BY  A.INVOICE ASC) AS LINEA, A.PO_REF
        --, TO_CHAR(SYSDATE,'YYYY-MM-DD'),M.BUS_UNIT_TYPE,M.BUSINESS_UNIT,M.DRAWER_ID 
    FROM (((((((PS_BI_HDR A INNER JOIN PS_SP_BU_BI_CLSVW A1 ON (A.BUSINESS_UNIT = A1.BUSINESS_UNIT AND  A1.OPRCLASS = 'LI_PPL_PER03_PER' )) 
                    LEFT OUTER JOIN  PS_BI_INSTALL_SCHE B ON  A.INVOICE = B.GENERATED_INVOICE ) 
                    LEFT OUTER JOIN  PS_LI_GBL_ARPY_REF I ON  A.INVOICE = I.INVOICE ) 
                    LEFT OUTER JOIN  PS_LI_GBL_ARPY_TBL J ON  I.PYMNT_REF_ID = J.PYMNT_REF_ID ) 
                    LEFT OUTER JOIN  PS_CDR_RECEIPT L ON  L.RECEIPT_NBR = J.RECEIPT_NBR ) 
                    LEFT OUTER JOIN  PS_CASH_DRAWER_TBL M ON  M.DRAWER_ID = J.DRAWER_ID ) 
                    LEFT OUTER JOIN  PS_LI_GBL_ARPY_DTL K ON  I.PYMNT_REF_ID = K.PYMNT_REF_ID )
                , PS_CUSTOMER C, PS_LI_GBL_BI_INV D, PS_ITEM E, PS_ITEM_DST F, PS_PAYMENT_ID_ITEM G, PS_PAYMENT H 
    WHERE ( ( A.BILL_TO_CUST_ID = C.CUST_ID 
        AND A.INVOICE = D.INVOICE 
        AND A.INVOICE = E.INVOICE 
        AND E.CUST_ID = F.CUST_ID 
        AND E.ITEM = F.ITEM 
        AND E.ITEM_LINE = F.ITEM_LINE 
        AND F.LEDGER = 'ACTUALS' 
        AND F.SYSTEM_DEFINED = 'C' 
        AND A.INVOICE = G.REF_VALUE 
        AND G.DEPOSIT_ID = H.DEPOSIT_ID 
        AND G.PAYMENT_SEQ_NUM = H.PAYMENT_SEQ_NUM 
        AND NOT ( A.CREATEOPRID LIKE 'CONVCAJ%' 
        AND I.PYMNT_REF_ID IS NULL) 
        AND F.JOURNAL_ID <> ' ' 
        AND F.ITEM_SEQ_NUM = E.ITEM_SEQ_NUM 
        --AND H.ACCOUNTING_DT BETWEEN TO_DATE(:1,'YYYY-MM-DD') AND TO_DATE(:2,'YYYY-MM-DD') ))
        AND H.ACCOUNTING_DT BETWEEN TO_DATE('2020-03-01','YYYY-MM-DD') AND TO_DATE('2020-03-31','YYYY-MM-DD') ))    --INGRESAR FECHAS
    )
    , PS AS (
    SELECT DISTINCT A.*
        , MAX(CASE 
            WHEN UPPER(B.DESCR) LIKE '%ARANCEL CONTADO%' OR UPPER(B.DESCR) LIKE '%ARANCEL%' THEN 'PENSIONES' 
            WHEN UPPER(B.DESCR) LIKE '%CUOTA%INI%' OR UPPER(B.DESCR) LIKE '%CUOTA 0%' OR UPPER(B.DESCR) LIKE '%CUOTA 1%' 
                    OR UPPER(B.DESCR) LIKE '%MATR%' OR UPPER(B.DESCR) LIKE '%PRONABEC%MAT%' THEN 'MATRICULA / CUOTA INICIAL'
            WHEN UPPER(B.DESCR) LIKE '%2DA%' OR UPPER(B.DESCR) LIKE '%3RA%' THEN 'PENSIONES' 
            ELSE 'SERVICIOS' END) OVER(PARTITION BY B.INVOICE) AS CONCEPTO
    FROM PER_AR_COBRANZAS A 
            LEFT JOIN PS_BI_LINE B ON
                A.UN = B.BUSINESS_UNIT AND A.TRANSACCION = B.INVOICE
                AND (UPPER(B.DESCR) LIKE '%ARANCEL CONTADO%' OR UPPER(B.DESCR) LIKE '%ARANCEL%' 
                    OR UPPER(B.DESCR) LIKE '%CUOTA%INI%' OR UPPER(B.DESCR) LIKE '%CUOTA 0%' OR UPPER(B.DESCR) LIKE '%CUOTA 1%' 
                    OR UPPER(B.DESCR) LIKE '%MATR%' OR UPPER(B.DESCR) LIKE '%PRONABEC%MAT%' 
                    OR UPPER(B.DESCR) LIKE '%2DA%' OR UPPER(B.DESCR) LIKE '%3RA%')
    WHERE A.TOTAL_PAGADO <> 0
    )
    , CURRICULA AS (
    SELECT DISTINCT SOVLCUR_PIDM, SOVLCUR_SEQNO, SOVLCUR_TERM_CODE, SOVLCUR_TERM_CODE_END
    	, SOVLCUR_LEVL_CODE, SOVLCUR_CAMP_CODE, SOVLCUR_STYP_CODE
    FROM LOE_SOVLCUR
    WHERE SOVLCUR_LMOD_CODE = 'LEARNER' AND SOVLCUR_CACT_CODE = 'ACTIVE' AND SOVLCUR_LEVL_CODE IN ('UG','EC')
    )

SELECT UN, ID_PAGO, CLIENTE, TRANSACCION, IMPORTE_DOCUMEN, TOTAL_PAGADO
    , CASE 
        WHEN PAGO = 'DC' THEN PAGO || ' - Tarjeta D�bito' 
        WHEN PAGO = 'CV' THEN PAGO || ' - Comprobante Corporativo' 
        WHEN PAGO = 'CC' THEN PAGO || ' - Tarjeta Cr�dito' 
        WHEN PAGO = 'EFT' THEN PAGO || ' - Transferencia Electr�nica' 
        WHEN PAGO = 'CSH' THEN PAGO || ' - Efectivo' 
        ELSE PAGO END AS MEDIO_PAGO
    , CASE 
        WHEN ORIG = 'POS' THEN ORIG || ' - Caja UPN' 
        WHEN ORIG = 'POR' THEN ORIG || ' - Portal' 
        WHEN ORIG = 'BNK' THEN ORIG || ' - Asbanc' 
        ELSE ORIG END AS ORIGEN
    , FECHA_COBRANZA, ID_BANCO, NRO_CUENTA
    , CASE 
        WHEN SOVLCUR_STYP_CODE = 'N' THEN 'NUEVO'             
        WHEN SOVLCUR_STYP_CODE = 'C' OR SOVLCUR_STYP_CODE IS NULL THEN 
            CASE 
                WHEN SOVLCUR_LEVL_CODE = 'UG' AND COHORT = 'NEW_REING'
                    THEN 'NUEVO REINGRESO'
                WHEN SOVLCUR_LEVL_CODE = 'UG' AND COHORT = 'REINGRESO'
                    THEN 'REINGRESO'
                ELSE 'CONTINUO' END
        ELSE SOVLCUR_STYP_CODE END AS TIPO_ESTUDIANTE
    , SOVLCUR_CAMP_CODE || ' - ' || STVCAMP_DESC AS CAMPUS, CONCEPTO
    --, PO_REF, SPRIDEN_PIDM, SOVLCUR_STYP_CODE, COHORT
FROM (((PS INNER JOIN LOE_SPRIDEN ON CLIENTE = SPRIDEN_ID AND SPRIDEN_CHANGE_IND IS NULL)
			LEFT JOIN CURRICULA C ON SPRIDEN_PIDM = SOVLCUR_PIDM
			    AND PO_REF >= SOVLCUR_TERM_CODE AND PO_REF < NVL(SOVLCUR_TERM_CODE_END,'999996'))
			LEFT JOIN STUDENT_COHORT ON SOVLCUR_PIDM = PERSON_UID AND PO_REF = ACADEMIC_PERIOD
    			AND COHORT IN ('REINGRESO','NEW_REING'))
            LEFT JOIN STVCAMP ON SOVLCUR_CAMP_CODE = STVCAMP_CODE
WHERE C.SOVLCUR_SEQNO = (SELECT MAX(C1.SOVLCUR_SEQNO) FROM CURRICULA C1
                        WHERE C1.SOVLCUR_PIDM = C.SOVLCUR_PIDM
                            AND PO_REF >= C1.SOVLCUR_TERM_CODE AND PO_REF < NVL(C1.SOVLCUR_TERM_CODE_END,'999996')) OR C.SOVLCUR_SEQNO IS NULL;

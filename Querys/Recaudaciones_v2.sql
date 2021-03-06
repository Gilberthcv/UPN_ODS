
WITH PER_AR_CTA_CORRIENTE_CAJA AS (
    SELECT TO_CHAR(CAST((A.ADD_DTTM) AS TIMESTAMP),'YYYY-MM-DD-HH24.MI.SS.FF') AS FECHA_COBRANZA, A.DRAWER_ID AS CAJA, J.PYMNT_REF_ID AS ID_PAGO_CAJA, A.BILL_TO_CUST_ID AS CLIENTE, CONCAT(CONCAT((REPLACE( E.NAME1,'/',' ')),', '), E.NAME2) AS APELLIDOS_NOMBRE, B.REF_VALUE AS TRANSACCION, C.PO_REF, C.BILL_STATUS AS ESTADO_BI, AE.ITEM_STATUS AS ESTADO_AR, C.BILL_TYPE_ID AS T_DOC, D.INVOICE2 AS GOV_ID, F.INSTALL_NBR AS CUO, C.INVOICE_AMOUNT AS IMPORTE, CASE WHEN ROW_NUMBER () 
    OVER 
    (PARTITION BY  A.DRAWER_ID,  J.PYMNT_REF_ID,  A.BILL_TO_CUST_ID,  A.RECEIPT_NBR ORDER BY  TO_CHAR(CAST((A.ADD_DTTM) AS TIMESTAMP),'YYYY-MM-DD-HH24.MI.SS.FF') DESC,  B.REF_VALUE DESC) = 1 
    THEN ( CASE WHEN  J.TOTAL_TEND_AMT IS NULL THEN  A.TOTAL_TEND_AMT ELSE  J.TOTAL_TEND_AMT END) ELSE 0 END AS IMP_PAGO, A.RECEIPT_NBR AS NRO_RECP, G.PAYMENT_METHOD_CDR AS TIPO_PAGO, CASE WHEN  G.CR_CARD_TYPE = '01' OR  G.CR_CARD_TYPE = 'V' THEN 'Visa' ELSE 
    CASE WHEN  G.CR_CARD_TYPE = '02' OR  G.CR_CARD_TYPE = 'M' THEN 'MasterCard' ELSE 
    CASE WHEN  G.CR_CARD_TYPE = '03' THEN 'Diners Club/Carte Blanche' ELSE 
    CASE WHEN  G.CR_CARD_TYPE = '04' OR  G.CR_CARD_TYPE = 'A' THEN 'AMEX' ELSE '' END END END END AS TIPO_TARJ, G.CR_CARD_AUTH_CD AS COD_AUT, CASE WHEN  J.PYMNT_REF_ID IS NULL AND  G.PAYMENT_METHOD_CDR != 'CV' THEN 'NAT' ELSE 'POS' END AS ORIG, CASE WHEN  U.PAYMENT_METHOD_CDR = 'CV' THEN  U.BNK_ID_NBR ELSE  V.BNK_ID_NBR END AS ID_BANCO, LTRIM( A.RECON_ID, '0') AS ID_CONCIL, CASE WHEN ( V.PAYMENT_STATUS = 'C' AND  V.WO_ADJ_USED_SW = 'Y') THEN 'Si' ELSE 'No' END AS ANUL, CASE WHEN  V.UNPOST_REASON = 'ERROR' THEN 'Si' ELSE 'No'  END AS DSCLZDO--, TO_CHAR(SYSDATE,'YYYY-MM-DD') 
      FROM ((PS_CDR_RECEIPT A LEFT OUTER JOIN  PS_LI_GBL_ARPY_TBL J ON  A.DEPOSIT_BU = J.DEPOSIT_BU AND A.RECEIPT_NBR = J.RECEIPT_NBR ) LEFT OUTER JOIN  PS_LI_GBL_ARPY_DTL U ON  J.DEPOSIT_BU = U.DEPOSIT_BU AND J.PYMNT_REF_ID = U.PYMNT_REF_ID ), (PS_CDR_RECEIPT_REF B LEFT OUTER JOIN  PS_ITEM AE ON  B.DEPOSIT_BU = AE.BUSINESS_UNIT AND B.REF_VALUE = AE.ITEM ), (((PS_BI_HDR C INNER JOIN PS_SP_BU_BI_CLSVW C1 ON (C.BUSINESS_UNIT = C1.BUSINESS_UNIT AND  C1.OPRCLASS = 'LI_PPL_PER03_PER' )) LEFT OUTER JOIN  PS_LI_GBL_BI_INV D ON  C.BUSINESS_UNIT = D.BUSINESS_UNIT AND C.INVOICE = D.INVOICE ) LEFT OUTER JOIN  PS_BI_INSTALL_SCHE F ON  C.BUSINESS_UNIT = F.BUSINESS_UNIT AND C.INVOICE = F.GENERATED_INVOICE ), PS_CUSTOMER E, (PS_CDR_RECEIPT_PMT G LEFT OUTER JOIN  PS_PAYMENT V ON  G.DEPOSIT_BU = V.DEPOSIT_BU AND V.DEPOSIT_ID = G.DEPOSIT_ID AND V.PAYMENT_SEQ_NUM = G.PAYMENT_SEQ_NUM ) 
      WHERE ( ( A.DEPOSIT_BU = B.DEPOSIT_BU 
         AND A.RECEIPT_NBR = B.RECEIPT_NBR 
         AND C.BUSINESS_UNIT = B.DEPOSIT_BU 
         AND C.INVOICE = B.REF_VALUE 
         AND E.SETID = A.DEPOSIT_BU 
         AND E.CUST_ID = A.BILL_TO_CUST_ID 
         AND A.DEPOSIT_BU = G.DEPOSIT_BU 
         AND A.RECEIPT_NBR = G.RECEIPT_NBR 
         AND A.DEPOSIT_BU = 'PER03' 
         --AND A.DEPOSIT_BU = :1 
         --AND A.BILL_TO_CUST_ID LIKE :2 
         /*AND A.ADD_DTTM > TO_CHAR(CAST((TO_DATE(:3,'YYYY-MM-DD')) AS TIMESTAMP)) 
         AND A.ADD_DTTM < TO_CHAR(CAST((TO_DATE(:4,'YYYY-MM-DD')) AS TIMESTAMP) + 1) */
         AND TO_CHAR(A.ADD_DTTM,'YYYY-MM-DD') > '2019-01-01' 
         AND TO_CHAR(A.ADD_DTTM,'YYYY-MM-DD') < '2020-01-01' 
         AND A.DRAWER_ID <> ' ' 
         --AND A.DRAWER_ID = :5 
         AND CASE WHEN (( G.PAYMENT_METHOD_CDR = 'CC' OR  G.PAYMENT_METHOD_CDR = 'DD') AND  G.CR_CARD_AUTH_STAT = 'U') THEN 0 ELSE 1 END = 1 
         AND G.PAYMENT_METHOD_CDR <> 'CV' )) 
    UNION 
    SELECT TO_CHAR(CAST((P.CREATEDTTM) AS TIMESTAMP),'YYYY-MM-DD-HH24.MI.SS.FF'), L.DRAWER_ID, K.PYMNT_REF_ID, K.CUSTOMER_ID, CONCAT(CONCAT((REPLACE( N.NAME1,'/',' ')),', '), N.NAME2), K.INVOICE, AD.PO_REF, AD.BILL_STATUS, AF.ITEM_STATUS, K.BILL_TYPE_ID, O.INVOICE2, CASE WHEN  K.INSTALL_NBR > 0 THEN  K.INSTALL_NBR ELSE null END, AD.INVOICE_AMOUNT, CASE WHEN ROW_NUMBER () 
    OVER 
    (PARTITION BY  L.DRAWER_ID,  K.PYMNT_REF_ID,  K.CUSTOMER_ID,  M.RECEIPT_NBR ORDER BY  TO_CHAR(CAST((P.CREATEDTTM) AS TIMESTAMP),'YYYY-MM-DD-HH24.MI.SS.FF') DESC,  K.INVOICE DESC) = 1 
    THEN  L.PAYMENT_TOTAL ELSE 0 END, M.RECEIPT_NBR, P.PAYMENT_METHOD_CDR, P.CR_CARD_TYPE, P.CR_CARD_AUTH_CD, L.SOURCE, CASE WHEN  P.PAYMENT_METHOD_CDR = 'CV' THEN  P.BNK_ID_NBR ELSE  Q.BNK_ID_NBR END, LTRIM(AG.RECON_ID, '0'), CASE WHEN ( Q.PAYMENT_STATUS = 'C' AND  Q.WO_ADJ_USED_SW = 'Y') THEN 'Si' ELSE 'No' END, CASE WHEN  Q.UNPOST_REASON = 'ERROR' THEN 'Si' ELSE 'No'  END--, TO_CHAR(SYSDATE,'YYYY-MM-DD'), TO_CHAR(SYSDATE,'YYYY-MM-DD') 
      FROM ((PS_LI_GBL_ARPY_REF K LEFT OUTER JOIN  (PS_BI_HDR AD INNER JOIN PS_SP_BU_BI_CLSVW AD1 ON (AD.BUSINESS_UNIT = AD1.BUSINESS_UNIT AND  AD1.OPRCLASS = 'LI_PPL_PER03_PER' )) ON  K.INVOICE = AD.INVOICE ) LEFT OUTER JOIN  PS_ITEM AF ON  K.DEPOSIT_BU = AF.BUSINESS_UNIT AND K.INVOICE = AF.INVOICE ), (((PS_LI_GBL_ARPY_TBL L LEFT OUTER JOIN  PS_CDR_RECEIPT_PMT M ON  L.DEPOSIT_BU = M.DEPOSIT_BU AND M.RECEIPT_NBR = L.RECEIPT_NBR ) LEFT OUTER JOIN  PS_PAYMENT Q ON  M.DEPOSIT_BU = Q.DEPOSIT_BU AND Q.DEPOSIT_ID = M.DEPOSIT_ID AND Q.PAYMENT_SEQ_NUM = M.PAYMENT_SEQ_NUM ) LEFT OUTER JOIN  PS_CDR_RECEIPT AG ON  L.DEPOSIT_BU = AG.DEPOSIT_BU AND AG.RECEIPT_NBR = L.RECEIPT_NBR ), PS_CUSTOMER N, PS_LI_GBL_BI_INV O, PS_LI_GBL_ARPY_DTL P 
      WHERE ( ( K.DEPOSIT_BU = L.DEPOSIT_BU 
         AND K.PYMNT_REF_ID = L.PYMNT_REF_ID 
         AND N.SETID = K.DEPOSIT_BU 
         AND N.CUST_ID = K.CUSTOMER_ID 
         AND K.DEPOSIT_BU = O.BUSINESS_UNIT 
         AND K.INVOICE = O.INVOICE 
         AND L.DEPOSIT_BU = P.DEPOSIT_BU 
         AND L.PYMNT_REF_ID = P.PYMNT_REF_ID 
         AND K.DEPOSIT_BU = 'PER03' 
         --AND K.DEPOSIT_BU = :1 
         --AND K.CUSTOMER_ID = :2 
         AND P.PAYMENT_DT BETWEEN TO_DATE('2019-01-01','YYYY-MM-DD') AND TO_DATE('2019-12-31','YYYY-MM-DD') 
         --AND L.DRAWER_ID = :5 
         AND L.DRAWER_ID <> ' ' 
         AND ( P.PAYMENT_METHOD_CDR = 'CV' 
         OR L.RECEIPT_NBR NOT IN (SELECT H.RECEIPT_NBR 
      FROM PS_CDR_RECEIPT H 
      WHERE ( H.DEPOSIT_BU = 'PER03' 
         --AND H.DEPOSIT_BU = :1 
         AND H.DRAWER_ID <> ' ' 
         --AND H.DRAWER_ID = :5 
         --AND H.BILL_TO_CUST_ID = :2 
         /*AND H.ADD_DTTM > TO_CHAR(CAST((TO_DATE(:3,'YYYY-MM-DD')) AS TIMESTAMP)) 
         AND H.ADD_DTTM < TO_CHAR(CAST((TO_DATE(:4,'YYYY-MM-DD')) AS TIMESTAMP) + 1) ))) */
         AND TO_CHAR(H.ADD_DTTM,'YYYY-MM-DD') > '2019-01-01' 
         AND TO_CHAR(H.ADD_DTTM,'YYYY-MM-DD') < '2020-01-01' ))) 
         AND K.DEPOSIT_BU = AD.BUSINESS_UNIT ))
    )
    , PS AS (
    SELECT DISTINCT A.*
        , MAX(CASE 
            WHEN UPPER(B.DESCR) LIKE '%ARANCEL CONTADO%' OR UPPER(B.DESCR) LIKE '%ARANCEL%' THEN 'PENSIONES' 
            WHEN UPPER(B.DESCR) LIKE '%CUOTA%INI%' OR UPPER(B.DESCR) LIKE '%CUOTA 0%' OR UPPER(B.DESCR) LIKE '%CUOTA 1%' 
                    OR UPPER(B.DESCR) LIKE '%MATR%' OR UPPER(B.DESCR) LIKE '%PRONABEC%MAT%' THEN 'MATRICULA / CUOTA INICIAL'
            WHEN UPPER(B.DESCR) LIKE '%2DA%' OR UPPER(B.DESCR) LIKE '%3RA%' THEN 'PENSIONES' 
            ELSE 'SERVICIOS' END) OVER(PARTITION BY B.INVOICE) AS CONCEPTO
    FROM PER_AR_CTA_CORRIENTE_CAJA A 
            LEFT JOIN PS_BI_LINE B ON
                A.TRANSACCION = B.INVOICE AND B.BUSINESS_UNIT = 'PER03'
                AND (UPPER(B.DESCR) LIKE '%ARANCEL CONTADO%' OR UPPER(B.DESCR) LIKE '%ARANCEL%' 
                    OR UPPER(B.DESCR) LIKE '%CUOTA%INI%' OR UPPER(B.DESCR) LIKE '%CUOTA 0%' OR UPPER(B.DESCR) LIKE '%CUOTA 1%' 
                    OR UPPER(B.DESCR) LIKE '%MATR%' OR UPPER(B.DESCR) LIKE '%PRONABEC%MAT%' 
                    OR UPPER(B.DESCR) LIKE '%2DA%' OR UPPER(B.DESCR) LIKE '%3RA%')
    WHERE A.IMP_PAGO <> 0
    )
    , CURRICULA AS (
    SELECT DISTINCT SOVLCUR_PIDM, SOVLCUR_SEQNO, SOVLCUR_TERM_CODE, SOVLCUR_TERM_CODE_END
    	, SOVLCUR_LEVL_CODE, SOVLCUR_CAMP_CODE, SOVLCUR_STYP_CODE
    FROM LOE_SOVLCUR
    WHERE SOVLCUR_LMOD_CODE = 'LEARNER' AND SOVLCUR_CACT_CODE = 'ACTIVE' AND SOVLCUR_LEVL_CODE IN ('UG','EC')
    )

SELECT CLIENTE
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
    , SOVLCUR_CAMP_CODE
    , PO_REF
    , CONCEPTO
    , IMP_PAGO
    , TRANSACCION
    , FECHA_COBRANZA
    , ORIG
    , ID_BANCO
    , TIPO_PAGO
    /*, SPRIDEN_PIDM
    , SOVLCUR_STYP_CODE
    , COHORT*/
FROM ((PS INNER JOIN SPRIDEN ON CLIENTE = SPRIDEN_ID AND SPRIDEN_CHANGE_IND IS NULL)
			LEFT JOIN CURRICULA C ON SPRIDEN_PIDM = SOVLCUR_PIDM
			    AND PO_REF >= SOVLCUR_TERM_CODE AND PO_REF < NVL(SOVLCUR_TERM_CODE_END,'999996'))
			LEFT JOIN STUDENT_COHORT ON SOVLCUR_PIDM = PERSON_UID AND PO_REF = ACADEMIC_PERIOD
    			AND COHORT IN ('REINGRESO','NEW_REING')
WHERE C.SOVLCUR_SEQNO = (SELECT MAX(C1.SOVLCUR_SEQNO) FROM CURRICULA C1
                        WHERE C1.SOVLCUR_PIDM = C.SOVLCUR_PIDM
                            AND PO_REF >= C1.SOVLCUR_TERM_CODE AND PO_REF < NVL(C1.SOVLCUR_TERM_CODE_END,'999996')) OR C.SOVLCUR_SEQNO IS NULL;

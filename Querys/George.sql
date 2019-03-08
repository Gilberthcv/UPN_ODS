SELECT *
FROM (

SELECT CASE WHEN A.CHARGE_TYPE IN ('FM','T1','TF') THEN A.START_DATE
            ELSE A.FECHA_VENCIMIENTO END AS DUE_DATE_DIMKEY,
            A.*
FROM (
SELECT DISTINCT
    A.PO_REF, A.INVOICE, B.NET_EXTENDED_AMT, TO_CHAR(D.START_DATE,'YYYYMMDD') START_DATE, E.FECHA_VENCIMIENTO,
    NVL(CASE WHEN upper(B.DESCR) LIKE '%ARANCEL CONTADO%' THEN 'TF'
             WHEN upper(B.DESCR) LIKE '%ARANCEL%' THEN 'TA'
             WHEN upper(B.DESCR) LIKE '%CUOTA%INI%' OR upper(B.DESCR) LIKE '%CUOTAINICIAL%' OR 
                    upper(B.DESCR) LIKE '%CUOTA 0%' OR upper(B.DESCR) LIKE '%CUOTA 1%' THEN 'T1'
             WHEN upper(B.DESCR) LIKE '%MATR%' OR upper(B.DESCR) LIKE '%PRONABEC%MAT%' THEN 'FM'
             WHEN upper(B.DESCR) LIKE '%2DA%' OR upper(B.DESCR) LIKE '%3RA%' THEN 'T2/T3'
        END,
        CASE (CASE WHEN F.TEXT254 like '%EXEMPTION/CROSS_REF:%' THEN SUBSTR(F.TEXT254,LENGTH(F.TEXT254)-3,2) ELSE NULL END) 
            WHEN 'XM' THEN 'FM' 
            WHEN 'X1' THEN 'T1' 
            WHEN 'XA' THEN 'TA' 
            WHEN 'YM' THEN 'FM' 
            WHEN 'Y1' THEN 'T1' 
            WHEN 'YA' THEN 'TA' 
            WHEN 'ZM' THEN 'FM' 
            WHEN 'Z1' THEN 'T1' 
            WHEN 'ZA' THEN 'TA' 
            ELSE (CASE WHEN F.TEXT254 like '%EXEMPTION/CROSS_REF:%' THEN SUBSTR(F.TEXT254,LENGTH(F.TEXT254)-3,2) ELSE NULL END) 
        END) AS CHARGE_TYPE, B.DESCR,
    CASE WHEN A.BILL_TYPE_ID = 'F1' THEN 6
         WHEN A.BILL_TYPE_ID = 'B1' THEN 1
    END AS BILL_TYPE,
    CASE WHEN A.BILL_STATUS = 'INV' THEN 3
         WHEN A.BILL_STATUS = 'CAN' THEN 1
         WHEN A.BILL_STATUS = 'HLD' THEN 2
         WHEN A.BILL_STATUS = 'RDY' THEN 5
         WHEN A.BILL_STATUS = 'NEW' THEN 4
    END AS BILL_STATUS,
    TO_CHAR(A.INVOICE_DT,'YYYYMMDD') TRAN_DT, A.INVOICE_AMOUNT,
    CASE WHEN C.GENERATED_INVOICE IS NOT NULL THEN 'CUOTA '||TO_CHAR(C.INSTALL_NBR)
        ELSE NULL
    END CUOTA_NUMBER
FROM PS_BI_HDR A JOIN PS_BI_LINE B ON B.INVOICE = A.INVOICE
    JOIN LOE_SECTION_PART_OF_TERM  D ON D.TERM_CODE = A.PO_REF
    LEFT JOIN PS_BI_LINE_NOTE F ON
                a.BUSINESS_UNIT = F.BUSINESS_UNIT AND
                a.INVOICE = F.INVOICE AND
                b.LINE_SEQ_NUM = F.LINE_SEQ_NUM AND
                CASE WHEN F.TEXT254 like '%EXEMPTION/CROSS_REF:%' THEN SUBSTR(F.TEXT254,LENGTH(F.TEXT254)-3,2) ELSE NULL END 
                    IN ('FM','T1','TA','XM','X1','XA','YM','Y1','YA','ZM','Z1','ZA') 
    LEFT JOIN PS_BI_INSTALL_SCHE C ON C.GENERATED_INVOICE=B.INVOICE
    LEFT JOIN (SELECT DISTINCT 
                a.SETID
                , a.INSTALL_PLAN_ID
                , a.PO_REF
                , a.EFFDT_NEW
                , b.INSTALL_NBR
                , b.PYMNT_TERMS_CD
                , TO_CHAR(c.DUE_DT,'YYYYMMDD') FECHA_VENCIMIENTO
            FROM (PS_LI_PER_BI_ACDTR a
                    LEFT OUTER JOIN PS_LI_PER_BI_PAYTM b ON 
                            a.SETID = b.SETID
                            AND a.INSTALL_PLAN_ID = b.INSTALL_PLAN_ID
                            AND a.PO_REF = b.PO_REF)
                    LEFT OUTER JOIN ODSMGR.PS_LI_GBL_PYTRM_VW c ON 
                        b.PYMNT_TERMS_CD = c.PYMNT_TERMS_CD AND
                        a.SETID = c.BUSINESS_UNIT) E ON E.PO_REF = A.PO_REF AND E.INSTALL_NBR = C.INSTALL_NBR
                AND E.INSTALL_PLAN_ID NOT LIKE '%PRONABEC%'
WHERE A.BILL_STATUS = 'INV'
    AND A.BILL_TYPE_ID IN ('F1','B1')
)A
)
WHERE 
DUE_DATE_DIMKEY IS NULL
AND TO_NUMBER(SUBSTR(TRAN_DT,0,4))>2017
;

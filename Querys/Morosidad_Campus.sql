
SELECT DISTINCT
    CASE WHEN TO_CHAR(d.DUE_DT,'YYYY-MM-DD') IS NULL
        THEN (CASE WHEN a.PYMNT_TERMS_CD IN ('000','0000','00000') THEN TO_CHAR(a.DUE_DT,'YYYY-MM-DD') ELSE TO_CHAR(f.DUE_DT,'YYYY-MM-DD') END)
      ELSE TO_CHAR(d.DUE_DT,'YYYY-MM-DD') END AS FECHA_VENCIMIENTO
    , a.PO_REF
    , a.CARGO
    , NVL(b.INSTALL_NBR,c.INSTALL_NBR) AS CUOTA
    , NVL(b.INVOICE,c.INVOICE) AS PLANTILLA
    , a.INVOICE
    , a.BILL_STATUS
    , a.BILL_TYPE_ID
    , a.INVOICE_AMOUNT
FROM (SELECT
          a.BUSINESS_UNIT
          , a.INVOICE
          , a.BILL_TO_CUST_ID
          , a.BILL_STATUS
          , a.BILL_TYPE_ID
          , a.NAME1
          , a.PYMNT_TERMS_CD
          , a.INVOICE_AMOUNT
          , a.INVOICE_DT
          , a.DUE_DT
          , a.PO_REF
          , b.LINE_SEQ_NUM
          , b.DESCR
          , b.NET_EXTENDED_AMT
          , NVL(CASE 
                    WHEN UPPER(b.DESCR) LIKE '%ARANCEL%' THEN 'TA'
                    WHEN UPPER(b.DESCR) LIKE '%CUOTA%INI%' OR UPPER(b.DESCR) LIKE '%CUOTA 0%' OR UPPER(b.DESCR) LIKE '%CUOTA 1%' THEN 'T1'
                    WHEN UPPER(b.DESCR) LIKE '%MATR%' THEN 'FM'
                    ELSE NULL
                END,
                CASE (CASE WHEN c.TEXT254 like '%EXEMPTION/CROSS_REF:%' THEN SUBSTR(c.TEXT254,LENGTH(c.TEXT254)-3,2) ELSE NULL END) 
                    WHEN 'XM' THEN 'FM' 
                    WHEN 'X1' THEN 'T1' 
                    WHEN 'XA' THEN 'TA' 
                    WHEN 'YM' THEN 'FM' 
                    WHEN 'Y1' THEN 'T1' 
                    WHEN 'YA' THEN 'TA' 
                    WHEN 'ZM' THEN 'FM' 
                    WHEN 'Z1' THEN 'T1' 
                    WHEN 'ZA' THEN 'TA' 
                    ELSE (CASE WHEN c.TEXT254 like '%EXEMPTION/CROSS_REF:%' THEN SUBSTR(c.TEXT254,LENGTH(c.TEXT254)-3,2) ELSE NULL END) 
                END) AS CARGO
          , MAX(SUBSTR(d.TEXT254,INSTR(d.TEXT254,' ', 1, 1)+1)) OVER(PARTITION BY d.INVOICE) AS ORIGINAL_INVOICE
      FROM (PS_BI_HDR a
              INNER JOIN PS_BI_LINE b ON
                  a.BUSINESS_UNIT = b.BUSINESS_UNIT
                  AND a.INVOICE = b.INVOICE )
              LEFT JOIN PS_BI_LINE_NOTE c ON
                  a.BUSINESS_UNIT = c.BUSINESS_UNIT
                  AND a.INVOICE = c.INVOICE
                  AND b.LINE_SEQ_NUM = c.LINE_SEQ_NUM
                  AND CASE WHEN c.TEXT254 like '%EXEMPTION/CROSS_REF:%' THEN SUBSTR(c.TEXT254,LENGTH(c.TEXT254)-3,2) 
                      ELSE NULL END IN ('FM','T1','TA','XM','X1','XA','YM','Y1','YA','ZM','Z1','ZA')
              LEFT JOIN PS_BI_LINE_NOTE d ON
                  a.BUSINESS_UNIT = d.BUSINESS_UNIT
                  AND a.INVOICE = d.INVOICE
                  AND b.LINE_SEQ_NUM = d.LINE_SEQ_NUM
                  AND d.TEXT254 like '%ORIGINAL_INVOICE:%'        
      WHERE a.BUSINESS_UNIT = 'PER03') a ,
      PS_BI_INSTALL_SCHE b, 
      PS_BI_INSTALL_SCHE c, 
      PS_ITEM d, 
      PS_PAY_TRMS_NET e, 
      PS_PAY_TRMS_TIME f
WHERE a.BUSINESS_UNIT = b.BUSINESS_UNIT(+) AND a.INVOICE = b.GENERATED_INVOICE(+)
    AND a.BUSINESS_UNIT = c.BUSINESS_UNIT(+) AND a.ORIGINAL_INVOICE = c.GENERATED_INVOICE(+)
    AND a.BUSINESS_UNIT = d.BUSINESS_UNIT(+) AND a.INVOICE = d.ITEM(+)
    AND e.PYMNT_TERMS_CD = a.PYMNT_TERMS_CD 
    AND e.EFFDT = (SELECT MAX(e_ed.EFFDT) FROM PS_PAY_TRMS_NET e_ed 
                  WHERE e.SETID = e_ed.SETID AND e.PYMNT_TERMS_CD = e_ed.PYMNT_TERMS_CD AND e_ed.EFFDT <= SYSDATE) 
     AND e.SETID = f.SETID 
     AND f.PAY_TRMS_TIME_ID = e.PAY_TRMS_TIME_ID 
    AND a.CARGO = 'TA' AND NVL(b.INSTALL_NBR,c.INSTALL_NBR) IS NULL
    AND a.PO_REF LIKE '219%'
ORDER BY 2,4,1
    ;
    

--0001744165
--0001731628
SELECT * FROM PS_BI_INSTALL_SCHE
WHERE INVOICE = '0001731628'

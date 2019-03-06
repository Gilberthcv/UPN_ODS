SELECT
    c.BUSINESS_UNIT,
    c.BILL_TO_CUST_ID,
    c.PO_REF,
    c.INVOICE,
    /*CASE
        WHEN c.TIPO_CARGO IS NULL THEN NULL
        ELSE 'PAGÓ'
    END AS CARGO,
    c.ADD_DTTM,*/
    d.ITEM_STATUS,
    e.HOLD,
    e.HOLD_DESC
FROM
    (( SELECT
        b.BUSINESS_UNIT AS BUSINESS_UNIT,
        b.BILL_TO_CUST_ID AS BILL_TO_CUST_ID,
        b.PO_REF AS PO_REF,
        b.INVOICE AS INVOICE,
        a.TIPO_CARGO AS TIPO_CARGO,
        b.ADD_DTTM AS ADD_DTTM,
        MAX(b.ADD_DTTM)
            OVER( PARTITION BY
                b.BILL_TO_CUST_ID,
                b.PO_REF ) AS MAX_ADD_DTTM
    FROM        
        ( SELECT
            BUSINESS_UNIT AS BUSINESS_UNIT, 
            INVOICE AS INVOICE, 
            replace(DESCR, 'ADJ-UG', 'ADI-UG') AS DESCR, 
            NET_EXTENDED_AMT AS NET_EXTENDED_AMT, 
            PO_REF AS PO_REF, 
            SHIP_TO_CUST_ID AS SHIP_TO_CUST_ID, 
            CASE 
                WHEN 
                    UPPER(replace(DESCR, 'ADJ-UG', 'ADI-UG')) LIKE '%CUOTA%INIC%' OR
                    UPPER(replace(DESCR, 'ADJ-UG', 'ADI-UG')) LIKE '%CUOTA 0%' OR
                    UPPER(replace(DESCR, 'ADJ-UG', 'ADI-UG')) LIKE '%CUOTA 1%'
                    THEN CASE 
                            WHEN UPPER(replace(DESCR, 'ADJ-UG', 'ADI-UG')) LIKE '%ARANCEL%' THEN 'TA'
                            ELSE 'T1'
                        END
                WHEN UPPER(replace(DESCR, 'ADJ-UG', 'ADI-UG')) LIKE '%ARANCEL%CONTADO%' THEN 'TF'
                ELSE NULL
            END AS TIPO_CARGO
        FROM
            PS_BI_LINE 
        WHERE 
            BUSINESS_UNIT = 'PER03' AND
            CASE 
                WHEN 
                    UPPER(replace(DESCR, 'ADJ-UG', 'ADI-UG')) LIKE '%CUOTA%INIC%' OR
                    UPPER(replace(DESCR, 'ADJ-UG', 'ADI-UG')) LIKE '%CUOTA 0%' OR
                    UPPER(replace(DESCR, 'ADJ-UG', 'ADI-UG')) LIKE '%CUOTA 1%'
                    THEN CASE 
                            WHEN UPPER(replace(DESCR, 'ADJ-UG', 'ADI-UG')) LIKE '%ARANCEL%' THEN 'TA'
                            ELSE 'T1'
                        END
                WHEN UPPER(replace(DESCR, 'ADJ-UG', 'ADI-UG')) LIKE '%ARANCEL%CONTADO%' THEN 'TF'
                ELSE NULL
            END IN ( 'T1', 'TF' ) ) a
            INNER JOIN PS_BI_HDR b ON
                a.BUSINESS_UNIT = b.BUSINESS_UNIT AND
                a.INVOICE = b.INVOICE AND
                b.BILL_STATUS = 'INV' AND
                b.BILL_TYPE_ID IN ( 'B1', 'F1' ) ) c
        INNER JOIN PS_ITEM d ON
            c.BUSINESS_UNIT = d.BUSINESS_UNIT AND
            c.INVOICE = d.ITEM AND
            d.ITEM_STATUS = 'C' )
        LEFT JOIN HOLD e ON
            c.BILL_TO_CUST_ID = e.ID AND
            e.HOLD IN ( 'DC', 'DI', 'DM' )
WHERE
    c.ADD_DTTM = c.MAX_ADD_DTTM AND
    c.PO_REF IN ( '218413', '218512' ) --INGRESAR PERIODO
ORDER BY
    c.BILL_TO_CUST_ID;
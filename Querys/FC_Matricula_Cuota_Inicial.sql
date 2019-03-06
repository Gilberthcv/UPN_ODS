( SELECT DISTINCT
    a.BUSINESS_UNIT, 
    a.INVOICE, 
    a.BILL_TO_CUST_ID, 
    a.BILL_STATUS, 
    a.BILL_TYPE_ID, 
    a.NAME1, 
    a.INVOICE_AMOUNT, 
    a.INVOICE_DT, 
    a.PO_REF, 
    b.LINE_SEQ_NUM, 
    b.DESCR, 
    b.NET_EXTENDED_AMT, 
    CASE 
        WHEN UPPER(b.DESCR) LIKE '%CUOTA%INI%' OR UPPER(b.DESCR) LIKE '%CUOTA 0%' OR UPPER(b.DESCR) LIKE '%CUOTA 1%' THEN 'T1'
        WHEN UPPER(b.DESCR) LIKE '%MATR%' THEN 'FM'
        ELSE NULL
    END AS TIPO_CARGO,
    CASE (CASE WHEN c.TEXT254 like '%EXEMPTION/CROSS_REF:%' THEN SUBSTR(c.TEXT254,LENGTH(c.TEXT254)-3,2) ELSE NULL END) 
        WHEN 'XM' THEN 'FM' 
        WHEN 'X1' THEN 'T1' 
        WHEN 'YM' THEN 'FM' 
        WHEN 'Y1' THEN 'T1' 
        WHEN 'ZM' THEN 'FM' 
        WHEN 'Z1' THEN 'T1' 
        ELSE (CASE WHEN c.TEXT254 like '%EXEMPTION/CROSS_REF:%' THEN SUBSTR(c.TEXT254,LENGTH(c.TEXT254)-3,2) ELSE NULL END) 
    END AS CARGO_ORIGEN
FROM 
    (PS_BI_HDR a
        INNER JOIN PS_BI_LINE b ON
            a.BUSINESS_UNIT = b.BUSINESS_UNIT AND
            a.INVOICE = b.INVOICE )
        LEFT JOIN PS_BI_LINE_NOTE c ON
            a.BUSINESS_UNIT = c.BUSINESS_UNIT AND
            a.INVOICE = c.INVOICE AND
            b.LINE_SEQ_NUM = c.LINE_SEQ_NUM AND
            CASE WHEN c.TEXT254 like '%EXEMPTION/CROSS_REF:%' THEN SUBSTR(c.TEXT254,LENGTH(c.TEXT254)-3,2) ELSE NULL END IN ('FM','T1','XM','X1','YM','Y1','ZM','Z1')
WHERE 
    a.BUSINESS_UNIT = 'PER03' AND
    a.BILL_STATUS = 'INV' AND
    a.BILLING_FREQUENCY = 'ONC'--) d
    
    AND
    a.PO_REF IN ('218413')
ORDER BY a.BILL_TO_CUST_ID, a.PO_REF, a.INVOICE;

-----------------------------------------------------------------------------
select distinct
    a.SPRIDEN_PIDM, a.SPRIDEN_ID, a.SPRIDEN_LAST_NAME, a.SPRIDEN_FIRST_NAME
from 
    SPRIDEN a
        inner join ACADEMIC_STUDY b ON
            a.SPRIDEN_PIDM = b.PERSON_UID
where a.SPRIDEN_CHANGE_IND is null --and SUBSTR(SPRIDEN_ID,1,1) = 'N'
order by a.SPRIDEN_PIDM desc;
-----------------------------------------------------------------------------
select distinct
    b.PERSON_UID, b.INSTRUCTOR_ID, b.INSTRUCTOR_LAST_NAME, b.INSTRUCTOR_FIRST_NAME
from
    MEETING_TIME a
        inner join INSTRUCTIONAL_ASSIGNMENT b on
            a.ACADEMIC_PERIOD = b.ACADEMIC_PERIOD and
            a.COURSE_REFERENCE_NUMBER = b.COURSE_REFERENCE_NUMBER and
            a.CATEGORY = b.CATEGORY 
where a.SCHEDULE = 'VIR'
order by b.PERSON_UID desc;
-----------------------------------------------------------------------------


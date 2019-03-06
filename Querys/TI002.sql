SELECT
    Consulta6.PERSON_UID AS PERSON_UID, 
    Consulta6.ID AS ID, 
    Consulta6.LAST_NAME AS LAST_NAME, 
    Consulta6.FIRST_NAME AS FIRST_NAME, 
    Consulta6.HOLD AS HOLD, 
    Consulta6.HOLD_DESC AS HOLD_DESC, 
    Consulta6.HOLD_FROM_DATE AS HOLD_FROM_DATE, 
    Consulta6.HOLD_TO_DATE AS HOLD_TO_DATE, 
    Consulta6.ACTIVE_HOLD_IND AS ACTIVE_HOLD_IND, 
    Consulta6.BUSINESS_UNIT AS BUSINESS_UNIT, 
    Consulta6.INVOICE AS INVOICE, 
    Consulta6.BILL_STATUS AS BILL_STATUS, 
    Consulta6.BILL_TYPE_ID AS BILL_TYPE_ID, 
    Consulta6.FROM_DT AS FROM_DT, 
    Consulta6.TO_DT AS TO_DT, 
    Consulta6.INVOICE_AMOUNT AS INVOICE_AMOUNT, 
    Consulta6.INVOICE_DT AS INVOICE_DT, 
    Consulta6.PO_REF AS PO_REF, 
    --Consulta6.DESCR AS DESCR, 
    --Consulta6.NET_EXTENDED_AMT AS NET_EXTENDED_AMT, 
    Consulta6.ITEM AS ITEM, 
    Consulta6.ITEM_STATUS AS ITEM_STATUS, 
    Consulta6.BAL_AMT AS BAL_AMT, 
    Consulta6.ENTRY_TYPE AS ENTRY_TYPE, 
    Consulta6.ENTRY_REASON AS ENTRY_REASON, 
    Consulta6.GROUP_TYPE AS GROUP_TYPE, 
    PS_PAYMENT13.PAYMENT_METHOD AS PAYMENT_METHOD, 
    PS_PAYMENT13.ACCOUNTING_DT AS ACCOUNTING_DT, 
    CASE 
        WHEN PS_PAYMENT13.ACCOUNTING_DT IS NULL THEN Consulta6.INVOICE_DT
        ELSE PS_PAYMENT13.ACCOUNTING_DT
    END AS FECHA_PAGO
FROM
    (
    SELECT
        Consulta5.PERSON_UID AS PERSON_UID, 
        Consulta5.ID AS ID, 
        Consulta5.LAST_NAME AS LAST_NAME, 
        Consulta5.FIRST_NAME AS FIRST_NAME, 
        Consulta5.HOLD AS HOLD, 
        Consulta5.HOLD_DESC AS HOLD_DESC, 
        Consulta5.HOLD_FROM_DATE AS HOLD_FROM_DATE, 
        Consulta5.HOLD_TO_DATE AS HOLD_TO_DATE, 
        Consulta5.ACTIVE_HOLD_IND AS ACTIVE_HOLD_IND, 
        Consulta5.BUSINESS_UNIT AS BUSINESS_UNIT, 
        Consulta5.INVOICE AS INVOICE, 
        Consulta5.BILL_STATUS AS BILL_STATUS, 
        Consulta5.BILL_TYPE_ID AS BILL_TYPE_ID, 
        Consulta5.FROM_DT AS FROM_DT, 
        Consulta5.TO_DT AS TO_DT, 
        Consulta5.INVOICE_AMOUNT AS INVOICE_AMOUNT, 
        Consulta5.INVOICE_DT AS INVOICE_DT, 
        Consulta5.PO_REF AS PO_REF, 
        Consulta5.DESCR AS DESCR, 
        Consulta5.NET_EXTENDED_AMT AS NET_EXTENDED_AMT, 
        Consulta5.ITEM AS ITEM, 
        Consulta5.ITEM_STATUS AS ITEM_STATUS, 
        Consulta5.BAL_AMT AS BAL_AMT, 
        Consulta5.ENTRY_TYPE AS ENTRY_TYPE, 
        Consulta5.ENTRY_REASON AS ENTRY_REASON, 
        Consulta5.GROUP_TYPE AS GROUP_TYPE, 
        PS_PAYMENT_ID_ITEM15.DEPOSIT_BU AS DEPOSIT_BU, 
        PS_PAYMENT_ID_ITEM15.DEPOSIT_ID AS DEPOSIT_ID, 
        PS_PAYMENT_ID_ITEM15.PAYMENT_SEQ_NUM AS PAYMENT_SEQ_NUM
    FROM
        (
        SELECT
            Consulta4.PERSON_UID AS PERSON_UID, 
            Consulta4.ID AS ID, 
            Consulta4.LAST_NAME AS LAST_NAME, 
            Consulta4.FIRST_NAME AS FIRST_NAME, 
            Consulta4.HOLD AS HOLD, 
            Consulta4.HOLD_DESC AS HOLD_DESC, 
            Consulta4.HOLD_FROM_DATE AS HOLD_FROM_DATE, 
            Consulta4.HOLD_TO_DATE AS HOLD_TO_DATE, 
            Consulta4.ACTIVE_HOLD_IND AS ACTIVE_HOLD_IND, 
            Consulta4.BUSINESS_UNIT AS BUSINESS_UNIT, 
            Consulta4.INVOICE AS INVOICE, 
            Consulta4.BILL_STATUS AS BILL_STATUS, 
            Consulta4.BILL_TYPE_ID AS BILL_TYPE_ID, 
            Consulta4.FROM_DT AS FROM_DT, 
            Consulta4.TO_DT AS TO_DT, 
            Consulta4.INVOICE_AMOUNT AS INVOICE_AMOUNT, 
            Consulta4.INVOICE_DT AS INVOICE_DT, 
            Consulta4.PO_REF AS PO_REF, 
            Consulta4.DESCR AS DESCR, 
            Consulta4.NET_EXTENDED_AMT AS NET_EXTENDED_AMT, 
            Consulta4.ITEM AS ITEM, 
            Consulta4.ITEM_STATUS AS ITEM_STATUS, 
            Consulta4.BAL_AMT AS BAL_AMT, 
            PS_ITEM_ACTIVITY12.ENTRY_TYPE AS ENTRY_TYPE, 
            PS_ITEM_ACTIVITY12.ENTRY_REASON AS ENTRY_REASON, 
            PS_ITEM_ACTIVITY12.GROUP_TYPE AS GROUP_TYPE, 
            CASE 
                WHEN 
                    PS_ITEM_ACTIVITY12.ENTRY_REASON = 'CASTI' OR
                    PS_ITEM_ACTIVITY12.ENTRY_TYPE = 'IN' AND
                    PS_ITEM_ACTIVITY12.GROUP_TYPE = 'T'
                    THEN
                        'CASTIGADO'
                ELSE NULL
            END AS CASTIGADO
        FROM
            (
            SELECT
                Consulta1.PERSON_UID AS PERSON_UID, 
                Consulta1.ID AS ID, 
                Consulta1.LAST_NAME AS LAST_NAME, 
                Consulta1.FIRST_NAME AS FIRST_NAME, 
                Consulta1.HOLD AS HOLD, 
                Consulta1.HOLD_DESC AS HOLD_DESC, 
                Consulta1.HOLD_FROM_DATE AS HOLD_FROM_DATE, 
                Consulta1.HOLD_TO_DATE AS HOLD_TO_DATE, 
                Consulta1.ACTIVE_HOLD_IND AS ACTIVE_HOLD_IND, 
                Consulta3.BUSINESS_UNIT AS BUSINESS_UNIT, 
                Consulta3.INVOICE AS INVOICE, 
                Consulta3.BILL_STATUS AS BILL_STATUS, 
                Consulta3.BILL_TYPE_ID AS BILL_TYPE_ID, 
                Consulta3.FROM_DT AS FROM_DT, 
                Consulta3.TO_DT AS TO_DT, 
                Consulta3.INVOICE_AMOUNT AS INVOICE_AMOUNT, 
                Consulta3.INVOICE_DT AS INVOICE_DT, 
                Consulta3.PO_REF AS PO_REF, 
                Consulta3.DESCR AS DESCR, 
                Consulta3.NET_EXTENDED_AMT AS NET_EXTENDED_AMT, 
                Consulta3.ITEM AS ITEM, 
                Consulta3.ITEM_STATUS AS ITEM_STATUS, 
                Consulta3.BAL_AMT AS BAL_AMT
            FROM
                (
                SELECT
                    PERSON2.PERSON_UID AS PERSON_UID, 
                    PERSON2.ID AS ID, 
                    PERSON2.LAST_NAME AS LAST_NAME, 
                    PERSON2.FIRST_NAME AS FIRST_NAME, 
                    Hold0.HOLD AS HOLD, 
                    Hold0.HOLD_DESC AS HOLD_DESC, 
                    Hold0.HOLD_FROM_DATE AS HOLD_FROM_DATE, 
                    Hold0.HOLD_TO_DATE AS HOLD_TO_DATE, 
                    Hold0.ACTIVE_HOLD_IND AS ACTIVE_HOLD_IND, 
                    Hold0.HOLD_EXPLANATION AS HOLD_EXPLANATION, 
                    Hold0.HOLD_INVOICE AS HOLD_INVOICE
                FROM
                    (
                    SELECT
                        PERSON.PERSON_UID AS PERSON_UID, 
                        PERSON.ID AS ID, 
                        PERSON.LAST_NAME AS LAST_NAME, 
                        PERSON.FIRST_NAME AS FIRST_NAME, 
                        PERSON.LEGAL_NAME AS LEGAL_NAME, 
                        PERSON.BIRTH_DATE AS BIRTH_DATE, 
                        PERSON.GENDER AS GENDER, 
                        PERSON.GENDER_DESC AS GENDER_DESC, 
                        PERSON.MARITAL_STATUS AS MARITAL_STATUS, 
                        PERSON.MARITAL_STATUS_DESC AS MARITAL_STATUS_DESC
                    FROM
                        ODSMGR.PERSON PERSON 
                    GROUP BY 
                        PERSON.PERSON_UID, 
                        PERSON.ID, 
                        PERSON.LAST_NAME, 
                        PERSON.FIRST_NAME, 
                        PERSON.LEGAL_NAME, 
                        PERSON.BIRTH_DATE, 
                        PERSON.GENDER, 
                        PERSON.GENDER_DESC, 
                        PERSON.MARITAL_STATUS, 
                        PERSON.MARITAL_STATUS_DESC
                    ) PERSON2
                        INNER JOIN 
                        (
                        SELECT
                            HOLD.PERSON_UID AS PERSON_UID, 
                            HOLD.ID AS ID, 
                            HOLD.NAME AS NAME, 
                            HOLD.HOLD AS HOLD, 
                            HOLD.HOLD_DESC AS HOLD_DESC, 
                            HOLD.HOLD_USER_CREATOR AS HOLD_USER_CREATOR, 
                            HOLD.HOLD_FROM_DATE AS HOLD_FROM_DATE, 
                            HOLD.HOLD_TO_DATE AS HOLD_TO_DATE, 
                            HOLD.ACTIVE_HOLD_IND AS ACTIVE_HOLD_IND, 
                            HOLD.HOLD_EXPLANATION AS HOLD_EXPLANATION, 
                            HOLD.HOLD_AMOUNT AS HOLD_AMOUNT, 
                            HOLD.HOLD_ORIGINATING_OFFICE AS HOLD_ORIGINATING_OFFICE, 
                            HOLD.HOLD_ORIGINATING_OFFICE_DESC AS HOLD_ORIGINATING_OFFICE_DESC, 
                            HOLD.REGISTRATION_HOLD_IND AS REGISTRATION_HOLD_IND, 
                            CASE 
                                WHEN substr(HOLD.HOLD_EXPLANATION, 1, 15) = 'Overdue Invoice' THEN substr(HOLD.HOLD_EXPLANATION, 16)
                                WHEN substr(HOLD.HOLD_EXPLANATION, 1, 10) = 'PS Inv ID:' THEN substr(HOLD.HOLD_EXPLANATION, 12)
                                WHEN substr(HOLD.HOLD_EXPLANATION, 1, 18) = 'PeopleSoft Inv ID:' THEN substr(HOLD.HOLD_EXPLANATION, 20)
                                ELSE NULL
                            END AS HOLD_INVOICE
                        FROM
                            ODSMGR.HOLD HOLD 
                        WHERE 
                            HOLD.ACTIVE_HOLD_IND = 'Y' 
                        GROUP BY 
                            HOLD.PERSON_UID, 
                            HOLD.ID, 
                            HOLD.NAME, 
                            HOLD.HOLD, 
                            HOLD.HOLD_DESC, 
                            HOLD.HOLD_USER_CREATOR, 
                            HOLD.HOLD_FROM_DATE, 
                            HOLD.HOLD_TO_DATE, 
                            HOLD.ACTIVE_HOLD_IND, 
                            HOLD.HOLD_EXPLANATION, 
                            HOLD.HOLD_AMOUNT, 
                            HOLD.HOLD_ORIGINATING_OFFICE, 
                            HOLD.HOLD_ORIGINATING_OFFICE_DESC, 
                            HOLD.REGISTRATION_HOLD_IND, 
                            CASE 
                                WHEN substr(HOLD.HOLD_EXPLANATION, 1, 15) = 'Overdue Invoice' THEN substr(HOLD.HOLD_EXPLANATION, 16)
                                WHEN substr(HOLD.HOLD_EXPLANATION, 1, 10) = 'PS Inv ID:' THEN substr(HOLD.HOLD_EXPLANATION, 12)
                                WHEN substr(HOLD.HOLD_EXPLANATION, 1, 18) = 'PeopleSoft Inv ID:' THEN substr(HOLD.HOLD_EXPLANATION, 20)
                                ELSE NULL
                            END
                        ) Hold0
                        ON PERSON2.PERSON_UID = Hold0.PERSON_UID 
                GROUP BY 
                    PERSON2.PERSON_UID, 
                    PERSON2.ID, 
                    PERSON2.LAST_NAME, 
                    PERSON2.FIRST_NAME, 
                    Hold0.HOLD, 
                    Hold0.HOLD_DESC, 
                    Hold0.HOLD_FROM_DATE, 
                    Hold0.HOLD_TO_DATE, 
                    Hold0.ACTIVE_HOLD_IND, 
                    Hold0.HOLD_EXPLANATION, 
                    Hold0.HOLD_INVOICE
                ) Consulta1
                    INNER JOIN 
                    (
                    SELECT
                        Consulta2.BUSINESS_UNIT AS BUSINESS_UNIT, 
                        Consulta2.INVOICE AS INVOICE, 
                        Consulta2.BILL_TO_CUST_ID AS BILL_TO_CUST_ID, 
                        Consulta2.BILL_STATUS AS BILL_STATUS, 
                        Consulta2.BILL_TYPE_ID AS BILL_TYPE_ID, 
                        Consulta2.FROM_DT AS FROM_DT, 
                        Consulta2.TO_DT AS TO_DT, 
                        Consulta2.INVOICE_AMOUNT AS INVOICE_AMOUNT, 
                        Consulta2.INVOICE_DT AS INVOICE_DT, 
                        Consulta2.PO_REF AS PO_REF, 
                        Consulta2.DESCR AS DESCR, 
                        Consulta2.NET_EXTENDED_AMT AS NET_EXTENDED_AMT, 
                        PS_ITEM8.ITEM AS ITEM, 
                        PS_ITEM8.ITEM_STATUS AS ITEM_STATUS, 
                        PS_ITEM8.BAL_AMT AS BAL_AMT
                    FROM
                        (
                        SELECT
                            PS_BI_HDR4.BUSINESS_UNIT AS BUSINESS_UNIT, 
                            PS_BI_HDR4.INVOICE AS INVOICE, 
                            PS_BI_HDR4.BILL_TO_CUST_ID AS BILL_TO_CUST_ID, 
                            PS_BI_HDR4.BILL_STATUS AS BILL_STATUS, 
                            PS_BI_HDR4.BILL_TYPE_ID AS BILL_TYPE_ID, 
                            PS_BI_HDR4.FROM_DT AS FROM_DT, 
                            PS_BI_HDR4.TO_DT AS TO_DT, 
                            PS_BI_HDR4.INVOICE_AMOUNT AS INVOICE_AMOUNT, 
                            PS_BI_HDR4.INVOICE_DT AS INVOICE_DT, 
                            PS_BI_HDR4.PO_REF AS PO_REF, 
                            PS_BI_HDR4.ADD_DTTM AS ADD_DTTM, 
                            PS_BI_LINE6.DESCR AS DESCR, 
                            PS_BI_LINE6.NET_EXTENDED_AMT AS NET_EXTENDED_AMT
                        FROM
                            (
                            SELECT
                                PS_BI_HDR.BUSINESS_UNIT AS BUSINESS_UNIT, 
                                PS_BI_HDR.INVOICE AS INVOICE, 
                                PS_BI_HDR.BILL_TO_CUST_ID AS BILL_TO_CUST_ID, 
                                PS_BI_HDR.BILL_STATUS AS BILL_STATUS, 
                                PS_BI_HDR.BILL_TYPE_ID AS BILL_TYPE_ID, 
                                PS_BI_HDR.FROM_DT AS FROM_DT, 
                                PS_BI_HDR.TO_DT AS TO_DT, 
                                PS_BI_HDR.INVOICE_AMOUNT AS INVOICE_AMOUNT, 
                                PS_BI_HDR.INVOICE_DT AS INVOICE_DT, 
                                PS_BI_HDR.PO_REF AS PO_REF, 
                                PS_BI_HDR.ADD_DTTM AS ADD_DTTM
                            FROM
                                ODSMGR.PS_BI_HDR PS_BI_HDR 
                            WHERE 
                                PS_BI_HDR.BUSINESS_UNIT = 'PER03' AND
                                PS_BI_HDR.BILL_STATUS = 'INV' AND
                                PS_BI_HDR.BILL_TYPE_ID IN ( 
                                    'B1', 
                                    'F1' ) 
                            GROUP BY 
                                PS_BI_HDR.BUSINESS_UNIT, 
                                PS_BI_HDR.INVOICE, 
                                PS_BI_HDR.BILL_TO_CUST_ID, 
                                PS_BI_HDR.BILL_STATUS, 
                                PS_BI_HDR.BILL_TYPE_ID, 
                                PS_BI_HDR.FROM_DT, 
                                PS_BI_HDR.TO_DT, 
                                PS_BI_HDR.INVOICE_AMOUNT, 
                                PS_BI_HDR.INVOICE_DT, 
                                PS_BI_HDR.PO_REF, 
                                PS_BI_HDR.ADD_DTTM
                            ) PS_BI_HDR4
                                INNER JOIN 
                                (
                                SELECT
                                    PS_BI_LINE.BUSINESS_UNIT AS BUSINESS_UNIT, 
                                    PS_BI_LINE.INVOICE AS INVOICE, 
                                    PS_BI_LINE.DESCR AS DESCR, 
                                    PS_BI_LINE.NET_EXTENDED_AMT AS NET_EXTENDED_AMT, 
                                    PS_BI_LINE.PO_REF AS PO_REF, 
                                    PS_BI_LINE.SHIP_TO_CUST_ID AS SHIP_TO_CUST_ID
                                FROM
                                    ODSMGR.PS_BI_LINE PS_BI_LINE 
                                WHERE 
                                    PS_BI_LINE.BUSINESS_UNIT = 'PER03' 
                                GROUP BY 
                                    PS_BI_LINE.BUSINESS_UNIT, 
                                    PS_BI_LINE.INVOICE, 
                                    PS_BI_LINE.DESCR, 
                                    PS_BI_LINE.NET_EXTENDED_AMT, 
                                    PS_BI_LINE.PO_REF, 
                                    PS_BI_LINE.SHIP_TO_CUST_ID
                                ) PS_BI_LINE6
                                ON 
                                    PS_BI_HDR4.BUSINESS_UNIT = PS_BI_LINE6.BUSINESS_UNIT AND
                                    PS_BI_HDR4.INVOICE = PS_BI_LINE6.INVOICE 
                        GROUP BY 
                            PS_BI_HDR4.BUSINESS_UNIT, 
                            PS_BI_HDR4.INVOICE, 
                            PS_BI_HDR4.BILL_TO_CUST_ID, 
                            PS_BI_HDR4.BILL_STATUS, 
                            PS_BI_HDR4.BILL_TYPE_ID, 
                            PS_BI_HDR4.FROM_DT, 
                            PS_BI_HDR4.TO_DT, 
                            PS_BI_HDR4.INVOICE_AMOUNT, 
                            PS_BI_HDR4.INVOICE_DT, 
                            PS_BI_HDR4.PO_REF, 
                            PS_BI_HDR4.ADD_DTTM, 
                            PS_BI_LINE6.DESCR, 
                            PS_BI_LINE6.NET_EXTENDED_AMT
                        ) Consulta2
                            INNER JOIN 
                            (
                            SELECT
                                PS_ITEM.BUSINESS_UNIT AS BUSINESS_UNIT, 
                                PS_ITEM.CUST_ID AS CUST_ID, 
                                PS_ITEM.ITEM AS ITEM, 
                                PS_ITEM.ITEM_STATUS AS ITEM_STATUS, 
                                PS_ITEM.BAL_AMT AS BAL_AMT, 
                                PS_ITEM.PO_REF AS PO_REF, 
                                PS_ITEM.INVOICE AS INVOICE
                            FROM
                                ODSMGR.PS_ITEM PS_ITEM 
                            WHERE 
                                PS_ITEM.BUSINESS_UNIT = 'PER03' AND
                                PS_ITEM.ITEM_STATUS = 'C' 
                            GROUP BY 
                                PS_ITEM.BUSINESS_UNIT, 
                                PS_ITEM.CUST_ID, 
                                PS_ITEM.ITEM, 
                                PS_ITEM.ITEM_STATUS, 
                                PS_ITEM.BAL_AMT, 
                                PS_ITEM.PO_REF, 
                                PS_ITEM.INVOICE
                            ) PS_ITEM8
                            ON 
                                Consulta2.BUSINESS_UNIT = PS_ITEM8.BUSINESS_UNIT AND
                                Consulta2.INVOICE = PS_ITEM8.ITEM 
                    GROUP BY 
                        Consulta2.BUSINESS_UNIT, 
                        Consulta2.INVOICE, 
                        Consulta2.BILL_TO_CUST_ID, 
                        Consulta2.BILL_STATUS, 
                        Consulta2.BILL_TYPE_ID, 
                        Consulta2.FROM_DT, 
                        Consulta2.TO_DT, 
                        Consulta2.INVOICE_AMOUNT, 
                        Consulta2.INVOICE_DT, 
                        Consulta2.PO_REF, 
                        Consulta2.DESCR, 
                        Consulta2.NET_EXTENDED_AMT, 
                        PS_ITEM8.ITEM, 
                        PS_ITEM8.ITEM_STATUS, 
                        PS_ITEM8.BAL_AMT
                    ) Consulta3
                    ON 
                        Consulta1.ID = Consulta3.BILL_TO_CUST_ID AND
                        Consulta1.HOLD_INVOICE = Consulta3.INVOICE 
            GROUP BY 
                Consulta1.PERSON_UID, 
                Consulta1.ID, 
                Consulta1.LAST_NAME, 
                Consulta1.FIRST_NAME, 
                Consulta1.HOLD, 
                Consulta1.HOLD_DESC, 
                Consulta1.HOLD_FROM_DATE, 
                Consulta1.HOLD_TO_DATE, 
                Consulta1.ACTIVE_HOLD_IND, 
                Consulta3.BUSINESS_UNIT, 
                Consulta3.INVOICE, 
                Consulta3.BILL_STATUS, 
                Consulta3.BILL_TYPE_ID, 
                Consulta3.FROM_DT, 
                Consulta3.TO_DT, 
                Consulta3.INVOICE_AMOUNT, 
                Consulta3.INVOICE_DT, 
                Consulta3.PO_REF, 
                Consulta3.DESCR, 
                Consulta3.NET_EXTENDED_AMT, 
                Consulta3.ITEM, 
                Consulta3.ITEM_STATUS, 
                Consulta3.BAL_AMT
            ) Consulta4
                LEFT OUTER JOIN 
                (
                SELECT
                    TQ0_PS_ITEM_ACTIVITY.BUSINESS_UNIT AS BUSINESS_UNIT, 
                    TQ0_PS_ITEM_ACTIVITY.CUST_ID AS CUST_ID, 
                    TQ0_PS_ITEM_ACTIVITY.ITEM AS ITEM, 
                    TQ0_PS_ITEM_ACTIVITY.ITEM_SEQ_NUM AS ITEM_SEQ_NUM, 
                    TQ0_PS_ITEM_ACTIVITY.ENTRY_TYPE AS ENTRY_TYPE, 
                    TQ0_PS_ITEM_ACTIVITY.ENTRY_REASON AS ENTRY_REASON, 
                    TQ0_PS_ITEM_ACTIVITY.ENTRY_AMT AS ENTRY_AMT, 
                    TQ0_PS_ITEM_ACTIVITY.ENTRY_EVENT AS ENTRY_EVENT, 
                    TQ0_PS_ITEM_ACTIVITY.ACCOUNTING_DT AS ACCOUNTING_DT, 
                    TQ0_PS_ITEM_ACTIVITY.POST_DT AS POST_DT, 
                    TQ0_PS_ITEM_ACTIVITY.GROUP_TYPE AS GROUP_TYPE
                FROM
                    (
                    SELECT
                        PS_ITEM_ACTIVITY.BUSINESS_UNIT AS BUSINESS_UNIT, 
                        PS_ITEM_ACTIVITY.CUST_ID AS CUST_ID, 
                        PS_ITEM_ACTIVITY.ITEM AS ITEM, 
                        PS_ITEM_ACTIVITY.ITEM_SEQ_NUM AS ITEM_SEQ_NUM, 
                        PS_ITEM_ACTIVITY.ENTRY_TYPE AS ENTRY_TYPE, 
                        PS_ITEM_ACTIVITY.ENTRY_REASON AS ENTRY_REASON, 
                        PS_ITEM_ACTIVITY.ENTRY_AMT AS ENTRY_AMT, 
                        PS_ITEM_ACTIVITY.ENTRY_EVENT AS ENTRY_EVENT, 
                        PS_ITEM_ACTIVITY.ACCOUNTING_DT AS ACCOUNTING_DT, 
                        PS_ITEM_ACTIVITY.POST_DT AS POST_DT, 
                        PS_ITEM_ACTIVITY.GROUP_TYPE AS GROUP_TYPE, 
                        MAX(PS_ITEM_ACTIVITY.ITEM_SEQ_NUM)
                            OVER(
                                PARTITION BY
                                    PS_ITEM_ACTIVITY.ITEM
                            ) AS Max1
                    FROM
                        ODSMGR.PS_ITEM_ACTIVITY PS_ITEM_ACTIVITY 
                    WHERE 
                        PS_ITEM_ACTIVITY.BUSINESS_UNIT = 'PER03'
                    ) TQ0_PS_ITEM_ACTIVITY 
                WHERE 
                    TQ0_PS_ITEM_ACTIVITY.ITEM_SEQ_NUM = TQ0_PS_ITEM_ACTIVITY.Max1 
                GROUP BY 
                    TQ0_PS_ITEM_ACTIVITY.BUSINESS_UNIT, 
                    TQ0_PS_ITEM_ACTIVITY.CUST_ID, 
                    TQ0_PS_ITEM_ACTIVITY.ITEM, 
                    TQ0_PS_ITEM_ACTIVITY.ITEM_SEQ_NUM, 
                    TQ0_PS_ITEM_ACTIVITY.ENTRY_TYPE, 
                    TQ0_PS_ITEM_ACTIVITY.ENTRY_REASON, 
                    TQ0_PS_ITEM_ACTIVITY.ENTRY_AMT, 
                    TQ0_PS_ITEM_ACTIVITY.ENTRY_EVENT, 
                    TQ0_PS_ITEM_ACTIVITY.ACCOUNTING_DT, 
                    TQ0_PS_ITEM_ACTIVITY.POST_DT, 
                    TQ0_PS_ITEM_ACTIVITY.GROUP_TYPE
                ) PS_ITEM_ACTIVITY12
                ON 
                    Consulta4.INVOICE = PS_ITEM_ACTIVITY12.ITEM AND
                    Consulta4.BUSINESS_UNIT = PS_ITEM_ACTIVITY12.BUSINESS_UNIT 
        WHERE 
            CASE 
                WHEN 
                    PS_ITEM_ACTIVITY12.ENTRY_REASON = 'CASTI' OR
                    PS_ITEM_ACTIVITY12.ENTRY_TYPE = 'IN' AND
                    PS_ITEM_ACTIVITY12.GROUP_TYPE = 'T'
                    THEN
                        'CASTIGADO'
                ELSE NULL
            END IS NULL 
        GROUP BY 
            Consulta4.PERSON_UID, 
            Consulta4.ID, 
            Consulta4.LAST_NAME, 
            Consulta4.FIRST_NAME, 
            Consulta4.HOLD, 
            Consulta4.HOLD_DESC, 
            Consulta4.HOLD_FROM_DATE, 
            Consulta4.HOLD_TO_DATE, 
            Consulta4.ACTIVE_HOLD_IND, 
            Consulta4.BUSINESS_UNIT, 
            Consulta4.INVOICE, 
            Consulta4.BILL_STATUS, 
            Consulta4.BILL_TYPE_ID, 
            Consulta4.FROM_DT, 
            Consulta4.TO_DT, 
            Consulta4.INVOICE_AMOUNT, 
            Consulta4.INVOICE_DT, 
            Consulta4.PO_REF, 
            Consulta4.DESCR, 
            Consulta4.NET_EXTENDED_AMT, 
            Consulta4.ITEM, 
            Consulta4.ITEM_STATUS, 
            Consulta4.BAL_AMT, 
            PS_ITEM_ACTIVITY12.ENTRY_TYPE, 
            PS_ITEM_ACTIVITY12.ENTRY_REASON, 
            PS_ITEM_ACTIVITY12.GROUP_TYPE, 
            CASE 
                WHEN 
                    PS_ITEM_ACTIVITY12.ENTRY_REASON = 'CASTI' OR
                    PS_ITEM_ACTIVITY12.ENTRY_TYPE = 'IN' AND
                    PS_ITEM_ACTIVITY12.GROUP_TYPE = 'T'
                    THEN
                        'CASTIGADO'
                ELSE NULL
            END
        ) Consulta5
            LEFT OUTER JOIN 
            (
            SELECT
                PS_PAYMENT_ID_ITEM.DEPOSIT_BU AS DEPOSIT_BU, 
                PS_PAYMENT_ID_ITEM.DEPOSIT_ID AS DEPOSIT_ID, 
                PS_PAYMENT_ID_ITEM.PAYMENT_SEQ_NUM AS PAYMENT_SEQ_NUM, 
                PS_PAYMENT_ID_ITEM.ID_SEQ_NUM AS ID_SEQ_NUM, 
                PS_PAYMENT_ID_ITEM.PO_REF AS PO_REF, 
                PS_PAYMENT_ID_ITEM.ITEM AS ITEM, 
                PS_PAYMENT_ID_ITEM.PAY_AMT AS PAY_AMT, 
                PS_PAYMENT_ID_ITEM.ITEM_AMT AS ITEM_AMT, 
                PS_PAYMENT_ID_ITEM.BUSINESS_UNIT AS BUSINESS_UNIT, 
                PS_PAYMENT_ID_ITEM.CUST_ID AS CUST_ID, 
                PS_PAYMENT_ID_ITEM.BAL_AMT AS BAL_AMT, 
                PS_PAYMENT_ID_ITEM.ENTRY_TYPE AS ENTRY_TYPE, 
                PS_PAYMENT_ID_ITEM.ENTRY_REASON AS ENTRY_REASON, 
                PS_PAYMENT_ID_ITEM.REF_VALUE AS REF_VALUE, 
                PS_PAYMENT_ID_ITEM.PAY_AMT_BASE AS PAY_AMT_BASE, 
                PS_PAYMENT_ID_ITEM.CURRENCY_CD AS CURRENCY_CD
            FROM
                ODSMGR.PS_PAYMENT_ID_ITEM PS_PAYMENT_ID_ITEM 
            GROUP BY 
                PS_PAYMENT_ID_ITEM.DEPOSIT_BU, 
                PS_PAYMENT_ID_ITEM.DEPOSIT_ID, 
                PS_PAYMENT_ID_ITEM.PAYMENT_SEQ_NUM, 
                PS_PAYMENT_ID_ITEM.ID_SEQ_NUM, 
                PS_PAYMENT_ID_ITEM.PO_REF, 
                PS_PAYMENT_ID_ITEM.ITEM, 
                PS_PAYMENT_ID_ITEM.PAY_AMT, 
                PS_PAYMENT_ID_ITEM.ITEM_AMT, 
                PS_PAYMENT_ID_ITEM.BUSINESS_UNIT, 
                PS_PAYMENT_ID_ITEM.CUST_ID, 
                PS_PAYMENT_ID_ITEM.BAL_AMT, 
                PS_PAYMENT_ID_ITEM.ENTRY_TYPE, 
                PS_PAYMENT_ID_ITEM.ENTRY_REASON, 
                PS_PAYMENT_ID_ITEM.REF_VALUE, 
                PS_PAYMENT_ID_ITEM.PAY_AMT_BASE, 
                PS_PAYMENT_ID_ITEM.CURRENCY_CD
            ) PS_PAYMENT_ID_ITEM15
            ON 
                Consulta5.BUSINESS_UNIT = PS_PAYMENT_ID_ITEM15.BUSINESS_UNIT AND
                Consulta5.INVOICE = PS_PAYMENT_ID_ITEM15.REF_VALUE 
    GROUP BY 
        Consulta5.PERSON_UID, 
        Consulta5.ID, 
        Consulta5.LAST_NAME, 
        Consulta5.FIRST_NAME, 
        Consulta5.HOLD, 
        Consulta5.HOLD_DESC, 
        Consulta5.HOLD_FROM_DATE, 
        Consulta5.HOLD_TO_DATE, 
        Consulta5.ACTIVE_HOLD_IND, 
        Consulta5.BUSINESS_UNIT, 
        Consulta5.INVOICE, 
        Consulta5.BILL_STATUS, 
        Consulta5.BILL_TYPE_ID, 
        Consulta5.FROM_DT, 
        Consulta5.TO_DT, 
        Consulta5.INVOICE_AMOUNT, 
        Consulta5.INVOICE_DT, 
        Consulta5.PO_REF, 
        Consulta5.DESCR, 
        Consulta5.NET_EXTENDED_AMT, 
        Consulta5.ITEM, 
        Consulta5.ITEM_STATUS, 
        Consulta5.BAL_AMT, 
        Consulta5.ENTRY_TYPE, 
        Consulta5.ENTRY_REASON, 
        Consulta5.GROUP_TYPE, 
        PS_PAYMENT_ID_ITEM15.DEPOSIT_BU, 
        PS_PAYMENT_ID_ITEM15.DEPOSIT_ID, 
        PS_PAYMENT_ID_ITEM15.PAYMENT_SEQ_NUM
    ) Consulta6
        LEFT OUTER JOIN 
        (
        SELECT
            PS_PAYMENT.DEPOSIT_BU AS DEPOSIT_BU, 
            PS_PAYMENT.DEPOSIT_ID AS DEPOSIT_ID, 
            PS_PAYMENT.PAYMENT_SEQ_NUM AS PAYMENT_SEQ_NUM, 
            PS_PAYMENT.PAYMENT_ID AS PAYMENT_ID, 
            PS_PAYMENT.PAYMENT_AMT AS PAYMENT_AMT, 
            PS_PAYMENT.PAYMENT_STATUS AS PAYMENT_STATUS, 
            PS_PAYMENT.PAYMENT_METHOD AS PAYMENT_METHOD, 
            PS_PAYMENT.ENTRY_DT AS ENTRY_DT, 
            PS_PAYMENT.ACCOUNTING_DT AS ACCOUNTING_DT, 
            PS_PAYMENT.POST_DT AS POST_DT, 
            PS_PAYMENT.AMT_SEL AS AMT_SEL, 
            PS_PAYMENT.GROUP_ID AS GROUP_ID, 
            PS_PAYMENT.PAYMENT_CURRENCY AS PAYMENT_CURRENCY, 
            PS_PAYMENT.BANK_ACCOUNT_NUM AS BANK_ACCOUNT_NUM, 
            PS_PAYMENT.BNK_ID_NBR AS BNK_ID_NBR, 
            PS_PAYMENT.STTLMNT_DT_EST AS STTLMNT_DT_EST, 
            PS_PAYMENT.DOC_TYPE AS DOC_TYPE, 
            PS_PAYMENT.DOC_SEQ_NBR AS DOC_SEQ_NBR, 
            PS_PAYMENT.DOC_SEQ_DATE AS DOC_SEQ_DATE, 
            PS_PAYMENT.ENTERED_DTTM AS ENTERED_DTTM, 
            PS_PAYMENT.OPRID AS OPRID, 
            PS_PAYMENT.LAST_UPDATE_DTTM AS LAST_UPDATE_DTTM, 
            PS_PAYMENT.OPRID_LAST_UPDT AS OPRID_LAST_UPDT
        FROM
            ODSMGR.PS_PAYMENT PS_PAYMENT 
        GROUP BY 
            PS_PAYMENT.DEPOSIT_BU, 
            PS_PAYMENT.DEPOSIT_ID, 
            PS_PAYMENT.PAYMENT_SEQ_NUM, 
            PS_PAYMENT.PAYMENT_ID, 
            PS_PAYMENT.PAYMENT_AMT, 
            PS_PAYMENT.PAYMENT_STATUS, 
            PS_PAYMENT.PAYMENT_METHOD, 
            PS_PAYMENT.ENTRY_DT, 
            PS_PAYMENT.ACCOUNTING_DT, 
            PS_PAYMENT.POST_DT, 
            PS_PAYMENT.AMT_SEL, 
            PS_PAYMENT.GROUP_ID, 
            PS_PAYMENT.PAYMENT_CURRENCY, 
            PS_PAYMENT.BANK_ACCOUNT_NUM, 
            PS_PAYMENT.BNK_ID_NBR, 
            PS_PAYMENT.STTLMNT_DT_EST, 
            PS_PAYMENT.DOC_TYPE, 
            PS_PAYMENT.DOC_SEQ_NBR, 
            PS_PAYMENT.DOC_SEQ_DATE, 
            PS_PAYMENT.ENTERED_DTTM, 
            PS_PAYMENT.OPRID, 
            PS_PAYMENT.LAST_UPDATE_DTTM, 
            PS_PAYMENT.OPRID_LAST_UPDT
        ) PS_PAYMENT13
        ON 
            Consulta6.DEPOSIT_BU = PS_PAYMENT13.DEPOSIT_BU AND
            Consulta6.DEPOSIT_ID = PS_PAYMENT13.DEPOSIT_ID AND
            Consulta6.PAYMENT_SEQ_NUM = PS_PAYMENT13.PAYMENT_SEQ_NUM 
GROUP BY 
    Consulta6.PERSON_UID, 
    Consulta6.ID, 
    Consulta6.LAST_NAME, 
    Consulta6.FIRST_NAME, 
    Consulta6.HOLD, 
    Consulta6.HOLD_DESC, 
    Consulta6.HOLD_FROM_DATE, 
    Consulta6.HOLD_TO_DATE, 
    Consulta6.ACTIVE_HOLD_IND, 
    Consulta6.BUSINESS_UNIT, 
    Consulta6.INVOICE, 
    Consulta6.BILL_STATUS, 
    Consulta6.BILL_TYPE_ID, 
    Consulta6.FROM_DT, 
    Consulta6.TO_DT, 
    Consulta6.INVOICE_AMOUNT, 
    Consulta6.INVOICE_DT, 
    Consulta6.PO_REF, 
    --Consulta6.DESCR, 
    --Consulta6.NET_EXTENDED_AMT, 
    Consulta6.ITEM, 
    Consulta6.ITEM_STATUS, 
    Consulta6.BAL_AMT, 
    Consulta6.ENTRY_TYPE, 
    Consulta6.ENTRY_REASON, 
    Consulta6.GROUP_TYPE, 
    PS_PAYMENT13.PAYMENT_METHOD, 
    PS_PAYMENT13.ACCOUNTING_DT, 
    CASE 
        WHEN PS_PAYMENT13.ACCOUNTING_DT IS NULL THEN Consulta6.INVOICE_DT
        ELSE PS_PAYMENT13.ACCOUNTING_DT
    END;
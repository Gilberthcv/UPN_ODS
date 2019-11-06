select   gorsdav_Table_name,
           gorsdav_attr_name,
           gorsdav_disc,
           gorsdav_pk_parenttab,
           F_UPN_DAS(GORSDAV_PK_PARENTTAB,1)  DECODE_PIDM  , --for NEW FIELD 1 and
           F_UPN_DAS(GORSDAV_PK_PARENTTAB,2) DECODE_SEQ  ,
           /*gorsdav_value,*/ gorsdav_Activity_date,
           gorsdav_user_id,
           gorsdav_Version,
           SYSDATE as load_date,
           gorsdav_vpdi_code,
           DECODE(G.gorsdav_value.gettypename(),
             'SYS.DATE'    , TO_CHAR(G.gorsdav_value.accessDate()),
             'SYS.VARCHAR2', G.gorsdav_value.accessVarchar2(),
             'SYS.CLOB'    , TO_CHAR(G.gorsdav_value.accessCLOB()),
             'SYS.NUMBER'  , TO_CHAR(G.gorsdav_value.accessNumber()) ) Decode_value
            FROM GENERAL.GORSDAV@AROUPNBN G  ; 
  select 'EXTERNAL_TERM_KEY|NAME|DURATION|START_DATE|END_DATE|DATA_SOURCE_KEY' from dual;
       SELECT
           a.sobptrm_term_code
             ||'|'|| b.stvterm_desc
             ||'|R'
             ||'|'|| to_char(a.sobptrm_start_date,'YYYYMMDD')
             ||'|'|| to_char(a.sobptrm_end_date,'YYYYMMDD')
             ||'|Banner' AS data_source_key
       FROM sobptrm a, stvterm b
       WHERE a.sobptrm_term_code = b.stvterm_code;
   spool off
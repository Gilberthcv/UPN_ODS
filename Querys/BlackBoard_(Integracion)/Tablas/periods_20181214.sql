select 'EXTERNAL_TERM_KEY|NAME|DURATION|START_DATE|END_DATE|DATA_SOURCE_KEY' from dual;
    SELECT
        a.sobptrm_term_code --sobptrm_term_code
        ||'|'|| b.stvterm_desc
        ||'|R'
        ||'|'|| to_char(a.sobptrm_start_date,'YYYYMMDD') --sobptrm_start_date
        ||'|'|| to_char(a.sobptrm_end_date,'YYYYMMDD') --sobptrm_end_date
        ||'|'|| 'UPN.Periodos.Banner' --'UPN.<Instancia>.Banner.<Nivel>'
    FROM sobptrm a, stvterm b
    WHERE a.sobptrm_term_code = b.stvterm_code
        AND a.sobptrm_term_code <> '999996'
        AND a.sobptrm_start_date <= SYSDATE +7 AND a.sobptrm_end_date >= SYSDATE -16;
  spool off
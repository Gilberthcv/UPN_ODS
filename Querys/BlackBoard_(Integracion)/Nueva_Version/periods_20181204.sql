select 'EXTERNAL_TERM_KEY|NAME|DURATION|START_DATE|END_DATE|DATA_SOURCE_KEY' from dual;
    SELECT
        a.term_code --sobptrm_term_code
        ||'|'|| b.stvterm_desc
        ||'|R'
        ||'|'|| to_char(a.start_date,'YYYYMMDD') --sobptrm_start_date
        ||'|'|| to_char(a.end_date,'YYYYMMDD') --sobptrm_end_date
        ||'|'|| 'UPN.Periodos.Banner' --'UPN.<Instancia>.Banner.<Nivel>'
    FROM LOE_SECTION_PART_OF_TERM a, stvterm b
    WHERE a.term_code = b.stvterm_code
        AND a.term_code <> '999996'
        AND a.start_date <= SYSDATE +7 AND a.end_date >= SYSDATE -16;
  spool off
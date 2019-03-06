
SELECT DISTINCT
    a.TERM_CODE AS SIS_TERM_KEY
    , b.STVTERM_DESC AS TERM_DESCRIPTION
    , CASE WHEN TO_CHAR(a.START_DATE,'MM') = '01' AND TO_CHAR(a.END_DATE,'MM') IN ('02','03')
        THEN 'Vacacional' ELSE 'Normal' END AS TERM_CATEGORY
    , CASE SUBSTR(a.TERM_CODE,4,1) 
          WHEN '2' THEN 'Trimestral' --PAE
          WHEN '3' THEN 'Trimestral' --PDN
          WHEN '4' THEN 'Semestral' --UG
          WHEN '5' THEN 'Semestral' --WA
          WHEN '7' THEN 'Cuatrimestral' --Inglés
          WHEN '8' THEN 'cada 18 meses' --Maestrías
          WHEN '9' THEN 'cada 9 meses' --Diplomados
        ELSE NULL END AS TERM_TYPE
    , b.STVTERM_ACYR_CODE AS ACADEMIC_YEAR
    , TO_CHAR(a.START_DATE,'YYYY-MM-DD') AS TERM_BEGIN_DATE
    , TO_CHAR(a.END_DATE,'YYYY-MM-DD') AS TERM_END_DATE
    , 'UPN' AS INSTITUTION
FROM LOE_SECTION_PART_OF_TERM a, 
     STVTERM b
WHERE a.TERM_CODE = b.STVTERM_CODE
    AND a.TERM_CODE <> '999996'
    AND a.start_date <= SYSDATE +7 AND a.end_date >= SYSDATE -16
ORDER BY 1 DESC;

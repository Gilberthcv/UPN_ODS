SELECT DISTINCT 
    a.external_course_key,
    a.course_id,
    a.course_name,
    a.available_ind,
    a.row_status,
    a.duration,
    a.start_date,
    a.end_date,
    a.term_key,
    a.data_source_key,
    a.ssbsect_camp_code||'.'||b.primary_external_node_key as primary_external_node_key,
    b.primary_external_node_key ||'.'|| a.ssbsect_crn AS external_association_key
FROM 
    (SELECT DISTINCT 
        a.ssbsect_term_code,
        a.ssbsect_crn,
        a.ssbsect_camp_code,
        case 
            when a.ssbsect_insm_code='V' then  a.ssbsect_subj_code || '.' || a.ssbsect_crse_numb || '.' ||
                a.ssbsect_term_code || '.' || a.ssbsect_crn|| '.' ||'V' 
            else 
                a.ssbsect_subj_code || '.' || a.ssbsect_crse_numb || '.' ||
                a.ssbsect_term_code || '.' || a.ssbsect_crn|| '.' ||'P' 
        end  AS external_course_key,
        case 
            when a.ssbsect_insm_code='V' then a.ssbsect_subj_code || '.' || a.ssbsect_crse_numb || '.' ||
                a.ssbsect_term_code || '.' || a.ssbsect_crn|| '.' ||'V' 
            else
                a.ssbsect_subj_code || '.' || a.ssbsect_crse_numb || '.' ||
                a.ssbsect_term_code || '.' || a.ssbsect_crn|| '.' ||'P' 
        end AS course_id,
        case 
            when a.ssbsect_insm_code='V' then b.scbcrse_title||'(Virtual)' 
            else b.scbcrse_title||'(Presencial)' 
        end  AS course_name,
        CASE
            WHEN a.ssbsect_ssts_code = 'A' THEN 'Y' ELSE 'N'
        END AS available_ind,
        CASE
            WHEN a.ssbsect_ssts_code = 'A' THEN 'ENABLED' ELSE 'DISABLED'
        END AS row_status,
        'R' AS duration,      
        to_char(to_date(a.ssbsect_ptrm_start_date, 'DD/MM/YY')-7,'YYYYMMDD') AS start_date,           
        to_char(to_date(a.ssbsect_ptrm_end_date, 'DD/MM/YY')+16,'YYYYMMDD') AS end_date,
        a.ssbsect_term_code AS term_key,
        'Banner' AS data_source_key
    FROM ssbsect a, 
            scbcrse b
    WHERE a.ssbsect_crse_numb = b.scbcrse_crse_numb
        AND a.ssbsect_subj_code = b.scbcrse_subj_code
        AND a.ssbsect_subj_code not in ('ACAD','REPS','TEST','XPEN','XSER')
        --AND a.ssbsect_insm_code = 'V'
        AND a.ssbsect_term_code like '218%') a--,
        LEFT JOIN
        --AND a.ssbsect_crn in ('12743','12744','12747','12750','5102','5116','5117','5119','5120','5125','5127','5129')
    (SELECT DISTINCT 
        a.ssrattr_term_code,
        a.ssrattr_crn,
        /*d.sobcurr_camp_code||'.'||*/
        CASE
            WHEN a.ssrattr_attr_code = 'DHUM' THEN 'DHUM'
            WHEN a.ssrattr_attr_code = 'DCIE' THEN 'DCIE'
            ELSE d.sobcurr_program
        END AS primary_external_node_key
    FROM ssrattr a,
            stvmajr b,
            loe_sorcmjr c,
            loe_sobcurr d
    WHERE a.ssrattr_attr_code = b.stvmajr_code(+)
        AND c.sorcmjr_majr_code(+) = b.stvmajr_code
        AND d.sobcurr_curr_rule(+) = c.sorcmjr_curr_rule
        AND a.ssrattr_term_code like '218%') b ON
    a.ssbsect_term_code = b.ssrattr_term_code
    AND a.ssbsect_crn = b.ssrattr_crn;
/*WHERE a.ssbsect_term_code = b.ssrattr_term_code
    AND a.ssbsect_crn = b.ssrattr_crn*/

--AC045
SELECT --A.*, C.REGISTRATION_STATUS 
	D.CAMPUS, B.SPRIDEN_ID, B.SPRIDEN_LAST_NAME ||' '|| B.SPRIDEN_FIRST_NAME AS APELLIDOS_NOMBRES, A.SFRREGP_TERM_CODE AS PERIODO_PROYECCION
	, A.SFRREGP_SUBJ_CODE||A.SFRREGP_CRSE_NUMB_LOW AS CURSO_PROYECCION, CASE WHEN C.PERSON_UID IS NOT NULL THEN 'Y' ELSE 'N' END AS MATRICULADO
	, A.SHRTCKN_SUBJ_CODE||A.SHRTCKN_CRSE_NUMB AS CURSO_APROBADO, A.SHRTCKG_GRDE_CODE_FINAL AS NOTA, A.SHRTCKN_TERM_CODE AS PERIODO_APROBO
	, A.SFRREGP_USER_ID AS USUARIO_AUTORIZO, A.SPRIDEN_LAST_NAME ||' '|| A.SPRIDEN_FIRST_NAME AS APELLIDOS_NOMBRES_USUARIO
FROM (
	SELECT SFRREGP_PIDM,
		SFRREGP_SUBJ_CODE,
		SFRREGP_CRSE_NUMB_LOW,
		shrtckn_subj_code,
		shrtckn_crse_numb,
		SHRTCKG_GRDE_CODE_FINAL,
		sfrregp_term_code,
		shrtckn_term_code,
		sfrregp_user_id,
		spriden_last_name,
		spriden_first_name
		--COUNT(distinct SHRTCKN_TERM_CODE)
	FROM SFRREGP, SHRTCKN, SCREQIV, SHRTCKG, SPRIDEN, SFRSTCR, SSBSECT
	WHERE  shrtckn_pidm = sfrregp_pidm
		AND sfrregp_pidm = sfrstcr_pidm
		and sfrregp_term_code = sfrstcr_term_code
		and sfrstcr_term_code = ssbsect_term_code
		and sfrstcr_crn = SSBSECT_crn
		and sfrregp_subj_code = ssbsect_subj_code
		and sfrregp_crse_numb_low = ssbsect_crse_numb
		AND substr(sfrregp_user_id,2,9) = spriden_id
		--and sfrregp_pidm = 35137
		AND SFRREGP_TERM_CODE IN ('220435','220534')
		And shrtckn_pidm = shrtckg_pidm 
		and shrtckn_term_code = shrtckg_term_code
		and shrtckn_seq_no = shrtckg_tckn_seq_no
		and shrtckg_grde_code_final  IN (SELECT SHRGRDE_CODE FROM SHRGRDE WHERE SHRGRDE_PASSED_IND = 'Y' OR shrtckg_grde_code_final not like 'R%')
		--   and (shrtckn_subj_code ||shrtckn_crse_numb = sfrregp_subj_code||sfrregp_crse_numb_low
		and ((shrtckn_subj_code = sfrregp_subj_code and shrtckn_crse_numb = sfrregp_crse_numb_low)  
				--or screqiv_subj_code||screqiv_crse_numb = sfrregp_subj_code||sfrregp_crse_numb_low)
				or(screqiv_subj_code = sfrregp_subj_code and screqiv_crse_numb = sfrregp_crse_numb_low))
		and 
		--shrtckn_subj_code||shrtckn_crse_numb||shrtckn_term_code between screqiv_subj_code_eqiv(+)||screqiv_crse_numb_eqiv (+)||screqiv_start_term (+) and screqiv_subj_code_eqiv(+)||screqiv_crse_numb_eqiv (+)||screqiv_end_term (+)
		(shrtckn_subj_code = screqiv_subj_code_eqiv(+) AND shrtckn_crse_numb = screqiv_crse_numb_eqiv(+) AND shrtckn_term_code BETWEEN screqiv_start_term (+) and screqiv_end_term(+))
		and sfrregp_maint_ind = 'U'
		and (shrtckg_grde_code_final in ('12','13','14','15','16','17','18','19','20', 'C') OR shrtckg_grde_code_final like 'C%' )
		--and sfrregp_most_prob is not null
	GROUP BY SFRREGP_PIDM,
		SFRREGP_SUBJ_CODE,
	    SFRREGP_CRSE_NUMB_LOW,
	    shrtckn_subj_code,
	    shrtckn_crse_numb,
	    SHRTCKG_GRDE_CODE_FINAL,
	    sfrregp_term_code,
	    shrtckn_term_code,
	    sfrregp_user_id,
	    spriden_last_name,
	    spriden_first_name
	) A
		INNER JOIN SPRIDEN B ON A.SFRREGP_PIDM = B.SPRIDEN_PIDM AND B.SPRIDEN_CHANGE_IND IS NULL
		INNER JOIN STUDENT_COURSE C ON A.SFRREGP_PIDM = C.PERSON_UID AND A.SFRREGP_TERM_CODE = C.ACADEMIC_PERIOD
										AND A.SFRREGP_SUBJ_CODE = C.SUBJECT AND A.SFRREGP_CRSE_NUMB_LOW = C.COURSE_NUMBER AND C.REGISTRATION_STATUS IN ('RE','RW','RA','WC','RF','RO','IA')		
		LEFT JOIN ACADEMIC_STUDY D ON A.SFRREGP_PIDM = D.PERSON_UID AND A.SFRREGP_TERM_CODE = D.ACADEMIC_PERIOD AND D.STUDENT_LEVEL = 'UG' --AND D.CAMPUS IN ('')
;

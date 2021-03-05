--BdUsuarios_
USE DATABASE UPN_RPT_DM_PROD;
USE SCHEMA ODSMGR;

--CREATE OR REPLACE VIEW BdUsuarios AS
SELECT DISTINCT
	A.EXTERNAL_PERSON_KEY AS EXTERNAL_PERSON_KEY
    , B.SPRIDEN_ID AS USER_ID
    , B.SPRIDEN_FIRST_NAME AS FIRSTNAME
    , REPLACE(B.SPRIDEN_LAST_NAME,'/',' ') AS LASTNAME
    , CASE WHEN MAX(A.PREFERENCIA) OVER(PARTITION BY A.EXTERNAL_PERSON_KEY) = 'DOCENTE'
		THEN C.GOREMAL_EMAIL_ADDRESS ELSE B.SPRIDEN_ID ||'@upn.pe' END AS EMAIL
    , A.ROW_STATUS AS ROW_STATUS
    , A.AVAILABLE_IND AS AVAILABLE_IND
    , 'UPN.Usuarios.Banner' AS DATA_SOURCE_KEY
    , MAX(CASE WHEN D.SPRTELE_TELE_CODE = 'CP' THEN D.SPRTELE_PHONE_NUMBER END) OVER(PARTITION BY D.SPRTELE_PIDM) AS M_PHONE
FROM ( SELECT DISTINCT
			A.SFRSTCR_PIDM AS EXTERNAL_PERSON_KEY
			, CASE WHEN C.SFBETRM_ESTS_CODE = 'EL' THEN 'ENABLED' ELSE 'DISABLED' END AS ROW_STATUS
			, CASE WHEN C.SFBETRM_ESTS_CODE = 'EL' THEN 'Y' ELSE 'N' END AS AVAILABLE_IND
			, NULL AS PREFERENCIA
		FROM ODSMGR.SFRSTCR A
				INNER JOIN ODSMGR.LOE_SSBSECT B ON A.SFRSTCR_TERM_CODE = B.SSBSECT_TERM_CODE AND A.SFRSTCR_CRN = B.SSBSECT_CRN
				INNER JOIN ODSMGR.SFBETRM C ON A.SFRSTCR_PIDM = C.SFBETRM_PIDM AND A.SFRSTCR_TERM_CODE = C.SFBETRM_TERM_CODE AND C.SFBETRM_ESTS_CODE IS NOT NULL
				INNER JOIN (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
								, MIN(SSRMEET_START_DATE) AS START_DATE, MAX(SSRMEET_END_DATE) AS END_DATE
							FROM ODSMGR.SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN
							) D ON B.SSBSECT_TERM_CODE = D.SSRMEET_TERM_CODE AND B.SSBSECT_CRN = D.SSRMEET_CRN
		WHERE A.SFRSTCR_RSTS_CODE IN ('RW','RE','RA')
			AND B.SSBSECT_SUBJ_CODE NOT IN ('ACAD','REPS','TEST','XPEN','XSER')
			AND CURRENT_DATE BETWEEN TO_DATE(D.START_DATE)-20 AND TO_DATE(D.END_DATE)+10
			AND B.SSBSECT_TERM_CODE IN (SELECT DISTINCT TERM_CODE FROM ODSMGR.LOE_SECTION_PART_OF_TERM
										WHERE CURRENT_DATE BETWEEN TO_DATE(START_DATE)-20 AND TO_DATE(END_DATE)+10)
		UNION
		SELECT DISTINCT
			A.SIRASGN_PIDM AS EXTERNAL_PERSON_KEY
			, CASE WHEN C.SIBINST_FCST_CODE = 'AC' THEN 'ENABLED' ELSE 'DISABLED' END AS ROW_STATUS
			, CASE WHEN C.SIBINST_FCST_CODE = 'AC' THEN 'Y' ELSE 'N' END AS AVAILABLE_IND
			, 'DOCENTE' AS PREFERENCIA
		FROM ODSMGR.SIRASGN A
				INNER JOIN ODSMGR.LOE_SSBSECT B ON A.SIRASGN_TERM_CODE = B.SSBSECT_TERM_CODE AND A.SIRASGN_CRN = B.SSBSECT_CRN
				INNER JOIN ODSMGR.LOE_SIBINST C ON A.SIRASGN_PIDM = C.SIBINST_PIDM
													AND C.SIBINST_TERM_CODE_EFF = (SELECT MAX(C1.SIBINST_TERM_CODE_EFF) FROM ODSMGR.LOE_SIBINST C1
																					WHERE C1.SIBINST_PIDM = A.SIRASGN_PIDM AND C1.SIBINST_TERM_CODE_EFF <> '999996')
				INNER JOIN (SELECT DISTINCT SSRMEET_TERM_CODE, SSRMEET_CRN
								, MIN(SSRMEET_START_DATE) AS START_DATE, MAX(SSRMEET_END_DATE) AS END_DATE
							FROM ODSMGR.SSRMEET GROUP BY SSRMEET_TERM_CODE, SSRMEET_CRN
							) D ON B.SSBSECT_TERM_CODE = D.SSRMEET_TERM_CODE AND B.SSBSECT_CRN = D.SSRMEET_CRN
		WHERE C.SIBINST_FCST_CODE = 'AC'
			AND CURRENT_DATE BETWEEN TO_DATE(D.START_DATE)-20 AND TO_DATE(D.END_DATE)+10
			AND B.SSBSECT_TERM_CODE IN (SELECT DISTINCT TERM_CODE FROM ODSMGR.LOE_SECTION_PART_OF_TERM
										WHERE CURRENT_DATE BETWEEN TO_DATE(START_DATE)-20 AND TO_DATE(END_DATE)+10)
		) A
			INNER JOIN ODSMGR.LOE_SPRIDEN B ON A.EXTERNAL_PERSON_KEY = B.SPRIDEN_PIDM AND B.SPRIDEN_CHANGE_IND IS NULL
			LEFT JOIN ODSMGR.GOREMAL C ON A.EXTERNAL_PERSON_KEY = C.GOREMAL_PIDM AND C.GOREMAL_STATUS_IND = 'A' AND C.GOREMAL_EMAL_CODE = 'UNIV'
											AND C.GOREMAL_ACTIVITY_DATE = (SELECT MAX(C1.GOREMAL_ACTIVITY_DATE) FROM ODSMGR.GOREMAL C1
																			WHERE C1.GOREMAL_PIDM = A.EXTERNAL_PERSON_KEY AND C1.GOREMAL_STATUS_IND = 'A' AND C1.GOREMAL_EMAL_CODE = 'UNIV')
			LEFT JOIN ODSMGR.SPRTELE D ON A.EXTERNAL_PERSON_KEY = D.SPRTELE_PIDM AND D.SPRTELE_TELE_CODE = 'CP'
;
-- SISStudentAttributeByDate.txt

SELECT 'SIS_Student_Key|Effective_Date|Term_Source_Key|Major_Description|Major_code|MajorAcademicLevelDescription|Major_Degree_Description|Major_Degree_code|Class_Level|Class_Level_Code|Academic_Level_Description|AcademicStangingCode|Academic_Standing|PrimaryCollegeDescription|PrimaryCollegeCode' FROM DUAL
UNION ALL
SELECT 
    SIS_Student_Key || '|' ||
    Effective_Date || '|' ||
    Term_Source_Key || '|' ||
    Major_Description || '.' || Major_code || '|' ||
    Major_code || '|' ||
    MajorAcademicLevelDescription || '|' ||
    Major_Degree_Description || '|' ||
    Major_Degree_code || '|' ||
    Class_Level || '|' ||
    Class_Level_Code || '|' ||
    Academic_Level_Description || '|' ||
    AcademicStangingCode || '|' ||
    Academic_Standing || '|' || 
    PrimaryCollegeDescription || '|' || 
    PrimaryCollegeCode
FROM
    (
        SELECT DISTINCT
            SPRIDEN_ID AS SIS_Student_Key,
            SGBSTDN_TERM_CODE_EFF AS Term_Source_Key,
            TO_CHAR(SGBSTDN_ACTIVITY_DATE,'YYYY-MM-DD') AS Effective_Date,
            SMRPRLE_PROGRAM_DESC AS Major_Description,
            SMRPRLE_PROGRAM AS Major_code,
            (SELECT  STVLEVL_DESC FROM STVLEVL WHERE STVLEVL_CODE = SMRPRLE_LEVL_CODE) AS MajorAcademicLevelDescription,
           STVDEGC_CODE AS Major_Degree_code,
            STVDEGC_DESC AS Major_Degree_Description,
            STVLEVL_DESC AS Class_Level ,
            STVLEVL_CODE AS Class_Level_Code,
            STVLEVL_DESC AS Academic_Level_Description,
            STVLEVL_CODE AS Academic_Level_Code,
            SGBSTDN_CAMP_CODE AS AcademicStangingCode,
            STVASTD_DESC AS Academic_Standing,
            STVCOLL_CODE AS PrimaryCollegeCode,
            STVCOLL_DESC AS PrimaryCollegeDescription
        FROM SPRIDEN A
            INNER JOIN SGBSTDN ON SGBSTDN_PIDM = SPRIDEN_PIDM AND SGBSTDN_STST_CODE = 'AS' AND SGBSTDN_TERM_CODE_EFF = (SELECT MAX(SGBSTDN_TERM_CODE_EFF) FROM SGBSTDN WHERE SGBSTDN_PIDM = SPRIDEN_PIDM)
            INNER JOIN (SELECT * FROM LOE_SECTION_PART_OF_TERM 
                        INNER JOIN STVTERM ON STVTERM_CODE = TERM_CODE
                        WHERE TERM_CODE <> '999996'
                        AND START_DATE >= '01/01/2018') ON TERM_CODE = SGBSTDN_TERM_CODE_EFF
            LEFT JOIN STVMAJR ON STVMAJR_CODE = SGBSTDN_MAJR_CODE_1
            LEFT JOIN STVLEVL ON STVLEVL_CODE = SGBSTDN_LEVL_CODE
            LEFT JOIN STVDEGC ON STVDEGC_CODE = SGBSTDN_DEGC_CODE_1
            LEFT JOIN STVASTD ON STVASTD_CODE = SGBSTDN_ASTD_CODE
            LEFT JOIN STVCAMP ON STVCAMP_CODE = SGBSTDN_CAMP_CODE 
            LEFT JOIN STVCOLL ON STVCOLL_CODE = SGBSTDN_COLL_CODE_1
            LEFT JOIN SMRPRLE ON SMRPRLE_PROGRAM  = SGBSTDN_PROGRAM_1
        WHERE SPRIDEN_CHANGE_IND IS NULL
    )



SELECT
    SORLCUR_PIDM, SORLCUR_SEQNO, SORLCUR_TERM_CODE, SORLCUR_ACTIVITY_DATE, SORLCUR_LEVL_CODE, SORLCUR_COLL_CODE
    , SORLCUR_DEGC_CODE, SORLCUR_TERM_CODE_END, SORLCUR_TERM_CODE_ADMIT, SORLCUR_CAMP_CODE, SORLCUR_PROGRAM, SMRPRLE_PROGRAM_DESC
FROM SORLCUR
    INNER JOIN (SELECT * FROM LOE_SECTION_PART_OF_TERM 
                INNER JOIN STVTERM ON STVTERM_CODE = TERM_CODE
                WHERE END_DATE >= '01/01/2018') ON
        NVL(SORLCUR_TERM_CODE_END,'999996') = TERM_CODE
    LEFT JOIN SMRPRLE ON SMRPRLE_PROGRAM  = SORLCUR_PROGRAM
WHERE SORLCUR_LMOD_CODE = 'LEARNER' AND SORLCUR_CACT_CODE = 'ACTIVE'
    --AND SORLCUR_PIDM = 15238
--195163

SELECT
    SORLCUR_PIDM, SORLCUR_SEQNO, SORLCUR_TERM_CODE, SORLCUR_ACTIVITY_DATE, SORLCUR_LEVL_CODE, SORLCUR_COLL_CODE
    , SORLCUR_DEGC_CODE, SORLCUR_TERM_CODE_END, SORLCUR_TERM_CODE_ADMIT, SORLCUR_CAMP_CODE, SORLCUR_PROGRAM, SMRPRLE_PROGRAM_DESC
FROM SORLCUR
    INNER JOIN (SELECT * FROM SOBPTRM
                INNER JOIN STVTERM ON STVTERM_CODE = SOBPTRM_TERM_CODE
                WHERE SOBPTRM_END_DATE >= '01/01/2018') ON
        NVL(SORLCUR_TERM_CODE_END,'999996') = TERM_CODE
    LEFT JOIN SMRPRLE ON SMRPRLE_PROGRAM  = SORLCUR_PROGRAM
WHERE SORLCUR_LMOD_CODE = 'LEARNER' AND SORLCUR_CACT_CODE = 'ACTIVE'
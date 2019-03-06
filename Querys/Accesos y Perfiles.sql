--PS
SELECT A.OPRID, A.OPRDEFNDESC, A.EMAILID, B.ROLENAME, C.DESCR,C.ROLENAME 
  FROM PSOPRDEFN A, PSROLEUSER B, PSROLEDEFN C 
  WHERE ( A.OPRID = B.ROLEUSER 
     AND B.ROLENAME = C.ROLENAME 
     AND A.OPRID = :1);

--BANNER
SET PAGESIZE 40000
SET FEEDBACK OFF
SET MARKUP HTML ON
SET NUM 24
col spoolname1 new_value spoolname1
col spoolname2 new_value spoolname2
col spoolname3 new_value spoolname3
select 'quarterly_banner_user_report_'||to_char(sysdate,'yyyymmdd')||'.html' spoolname1 from dual;
select 'quarterly_admin_user_report_'||to_char(sysdate,'yyyymmdd')||'.html' spoolname2 from dual;
select 'quarterly_vendor_user_report_'||to_char(sysdate,'yyyymmdd')||'.html' spoolname3 from dual;
alter session set nls_language='_.UTF8';
spool &spoolname1;
 /* User type 'U1%' or 'U2%' or 'U3%' */
SELECT b.ultipro_emp_id, b.ultipro_first_name, b.ultipro_last_name, b.ultipro_supervisor_name, b.ultipro_org_level1, x.guvuobj_user_class, x.guvuobj_object,x.guvuobj_role,x.gzraobj_desc,x.gzraobj_criticality
  FROM (SELECT DISTINCT z.ultipro_emp_id,z.ultipro_first_name,z.ultipro_last_name,z.ultipro_supervisor_name,z.ultipro_org_level1
             FROM laureatedev.ultipro z) b,
       (SELECT DISTINCT guvuobj_class, guvuobj_user_class,guvuobj_role,guvuobj_object,b.gzraobj_desc,b.gzraobj_criticality
          FROM bansecr.guvuobj a ,
               laureatedev.gzraobj b
         WHERE a.guvuobj_object=b.gzraobj_object and 
         a.guvuobj_user_class IN
         (SELECT username  FROM dba_users where (username LIKE 'U1%' OR username LIKE 'U2%' OR username LIKE 'U3%'))-- WHERE (username LIKE 'S1%' OR username LIKE 'S2%' OR  username LIKE 'S3%'))
         ORDER BY a.guvuobj_class,a.guvuobj_user_class,a.guvuobj_object) x
 WHERE b.ultipro_emp_id = substr(x.guvuobj_user_class,2,9)
UNION
SELECT b.ultipro_emp_id,b.ultipro_first_name,b.ultipro_last_name,b.ultipro_supervisor_name,b.ultipro_org_level1,x.guvuobj_user_class,x.guvuobj_object,x.guvuobj_role,x.gzraobj_desc,x.gzraobj_criticality
  FROM (SELECT DISTINCT z.ultipro_emp_id,z.ultipro_first_name,z.ultipro_last_name,z.ultipro_supervisor_name,z.ultipro_org_level1
          FROM laureatedev.ultipro z) b,
       (SELECT DISTINCT guvuobj_class,guvuobj_user_class, guvuobj_role,guvuobj_object,b.gzraobj_desc,b.gzraobj_criticality
          FROM bansecr.guvuobj a, bansecr.gtvclas c,laureatedev.gzraobj b
         WHERE a.guvuobj_user_class = c.gtvclas_class_code
           AND a.guvuobj_object=b.gzraobj_object
           AND a.guvuobj_class NOT IN 'BASELINE'
           AND a.guvuobj_class IN
               (SELECT username FROM dba_users WHERE (username LIKE 'U1%' OR username LIKE 'U2%' OR username LIKE 'U3%'))    
         ORDER BY a.guvuobj_class, a.guvuobj_user_class, a.guvuobj_object) x
 WHERE b.ultipro_emp_id = substr(x.guvuobj_class,2,9)
  ORDER BY 1,6,7,8;
 /* User type 'U1%' or 'U2%' or 'U3%' */
spool &spoolname2;
  /* User type 'S1%' or 'S2%' or 'S3%' */
 SELECT b.ultipro_emp_id, b.ultipro_first_name, b.ultipro_last_name, b.ultipro_supervisor_name, b.ultipro_org_level1, x.guvuobj_user_class, x.guvuobj_object,x.guvuobj_role,x.gzraobj_desc,x.gzraobj_criticality
  FROM (SELECT DISTINCT z.ultipro_emp_id,z.ultipro_first_name,z.ultipro_last_name,z.ultipro_supervisor_name,z.ultipro_org_level1
             FROM laureatedev.ultipro z) b,
       (SELECT DISTINCT guvuobj_class, guvuobj_user_class,guvuobj_role,guvuobj_object,b.gzraobj_desc,b.gzraobj_criticality
          FROM bansecr.guvuobj a,
          laureatedev.gzraobj b
         WHERE a.guvuobj_object=b.gzraobj_object and
         a.guvuobj_user_class IN
         (SELECT username  FROM dba_users where (username LIKE 'S1%' OR username LIKE 'S2%' OR username LIKE 'S3%'))-- WHERE (username LIKE 'S1%' OR username LIKE 'S2%' OR  username LIKE 'S3%'))
         ORDER BY a.guvuobj_class,a.guvuobj_user_class,a.guvuobj_object) x
 WHERE b.ultipro_emp_id = substr(x.guvuobj_user_class,2,9)
UNION
SELECT b.ultipro_emp_id,b.ultipro_first_name,b.ultipro_last_name,b.ultipro_supervisor_name,b.ultipro_org_level1,x.guvuobj_user_class,x.guvuobj_object,x.guvuobj_role,x.gzraobj_desc,x.gzraobj_criticality
  FROM (SELECT DISTINCT z.ultipro_emp_id,z.ultipro_first_name,z.ultipro_last_name,z.ultipro_supervisor_name,z.ultipro_org_level1
          FROM laureatedev.ultipro z) b,
       (SELECT DISTINCT guvuobj_class,guvuobj_user_class, guvuobj_role,guvuobj_object,b.gzraobj_desc,b.gzraobj_criticality
          FROM bansecr.guvuobj a, bansecr.gtvclas c,laureatedev.gzraobj b 
         WHERE a.guvuobj_user_class = c.gtvclas_class_code
           AND a.guvuobj_object=b.gzraobj_object
           AND a.guvuobj_class NOT IN 'BASELINE'
           AND a.guvuobj_class IN
               (SELECT username FROM dba_users WHERE (username LIKE 'S1%' OR username LIKE 'S2%' OR username LIKE 'S3%'))    
         ORDER BY a.guvuobj_class, a.guvuobj_user_class, a.guvuobj_object) x
 WHERE b.ultipro_emp_id = substr(x.guvuobj_class,2,9)
 ORDER BY 1,6,7,8;
   /* User type 'S1%' or 'S2%' or 'S3%' */
spool &spoolname3;
   /* User Account Status=OPEN and Name <>'ULTIPRO' */
SELECT DISTINCT a.guvuobj_user_class as USERID, 'Banner: R.Clark' as OWNER, a.guvuobj_type as Grant_Class,a.guvuobj_object as Grant_object,a.guvuobj_role as Grant_Role,b.gzraobj_desc,b.gzraobj_criticality
          FROM bansecr.guvuobj a ,
               laureatedev.gzraobj b
         WHERE a.guvuobj_object=b.gzraobj_object and
          a.guvuobj_user_class IN
         (SELECT username FROM dba_users WHERE  Account_status='OPEN' )
         and a.guvuobj_user_class NOT IN ( SELECT username from dba_users where username  LIKE 'S1%' OR username LIKE 'S2%' OR username LIKE 'S3%' OR
               username LIKE 'U1%' OR username LIKE 'U2%' OR username LIKE 'U3%') 
UNION
   SELECT DISTINCT a.guvuobj_class as USERID ,'Banner: R.Clark' as OWNER, a.guvuobj_user_class as Grant_class,a.guvuobj_object as Grant_object , a.guvuobj_role as Grant_Role,b.gzraobj_desc,b.gzraobj_criticality
          FROM bansecr.guvuobj a, bansecr.gtvclas c,laureatedev.gzraobj b
         WHERE a.guvuobj_user_class = c.gtvclas_class_code
           AND a.guvuobj_object=b.gzraobj_object
           AND a.guvuobj_class NOT IN 'BASELINE'
          AND a.guvuobj_class IN
              (SELECT username FROM dba_users WHERE  Account_status='OPEN' )
               and a.guvuobj_class NOT IN ( SELECT username from dba_users where username  LIKE 'S1%' OR username LIKE 'S2%' OR username LIKE 'S3%' OR
               username LIKE 'U1%' OR username LIKE 'U2%' OR username LIKE 'U3%');
              -- order by a.guvuobj_class desc;    
spool off; 
exit;
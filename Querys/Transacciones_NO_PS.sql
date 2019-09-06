SELECT DISTINCT b.spriden_id id,
                b.spriden_pidm,
                a.tbraccd_user "User",
                a.tbraccd_tran_number,
                b.spriden_last_name  "Last Name",
                b.spriden_first_name "First Name",
                -- b.spriden_mi,
                a.tbraccd_term_code "Term",
                a.tbraccd_detail_code "Detail Code",
                cd.tbbdetc_desc "Description",
                a.tbraccd_entry_date "Date",
                a.tbraccd_amount "Amount",
                a.tbraccd_payment_id "Invoice Number",
                c.sgbstdn_styp_code "Student Type",
                c.sgbstdn_camp_code "Campus",
                a.tbraccd_surrogate_id "Surrogate ID"/*
                gz_common.fz_get_xref_val(p_xlbl_code  => 'PSOPUNIT',
                                          p_ban_val_in => c.sgbstdn_camp_code) "Op Unit",
                                          a.tbraccd_surrogate_id "Surrogate ID"*/
  FROM tbraccd a,
       spriden b,
       tbbdetc cd,
       sgbstdn c
 WHERE --a.tbraccd_user = 'U100012001'
  -- AND trunc(a.tbraccd_activity_date) = trunc(SYSDATE)
       a.tbraccd_pidm = b.spriden_pidm
   AND b.spriden_change_ind IS NULL
   AND a.tbraccd_detail_code = cd.tbbdetc_detail_code
   AND a.tbraccd_pidm = c.sgbstdn_pidm
   AND a.tbraccd_payment_id IS NULL
   AND c.sgbstdn_term_code_eff =
       (SELECT MAX(dd.sgbstdn_term_code_eff)
          FROM sgbstdn dd
         WHERE dd.sgbstdn_pidm = c.sgbstdn_pidm)
    AND a.tbraccd_term_code in ('219435','219534','219735','219736')
    --AND b.spriden_id =''
    --AND a.tbraccd_tran_number=
 ORDER BY b.spriden_pidm
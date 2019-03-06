CREATE OR REPLACE TRIGGER tzt_tbbestu_trig
  BEFORE INSERT OR UPDATE OR DELETE ON tbbestu
  FOR EACH ROW
DECLARE
  l_user VARCHAR2(20) := USER;
BEGIN
  IF updating
     OR inserting
  THEN
    :new.tbbestu_user_id := l_user;
  END IF;
  IF updating
  THEN
    INSERT INTO tzbestu
    VALUES
      (:new.tbbestu_exemption_code,
       :new.tbbestu_pidm,
       :new.tbbestu_term_code,
       :new.tbbestu_activity_date,
       :new.tbbestu_del_ind,
       :new.tbbestu_student_expt_roll_ind,
       :new.tbbestu_term_code_expiration,
       :new.tbbestu_user_id,
       :new.tbbestu_exemption_priority,
       :new.tbbestu_max_student_amount,
       tzbestu_seq.nextval,
       current_timestamp,
       USER,
       'UPDATE');
  ELSIF deleting
  THEN
    INSERT INTO tzbestu
    VALUES
      (:old.tbbestu_exemption_code,
       :old.tbbestu_pidm,
       :old.tbbestu_term_code,
       :old.tbbestu_activity_date,
       :old.tbbestu_del_ind,
       :old.tbbestu_student_expt_roll_ind,
       :old.tbbestu_term_code_expiration,
       :old.tbbestu_user_id,
       :old.tbbestu_exemption_priority,
       :old.tbbestu_max_student_amount,
       tzbestu_seq.nextval,
       current_timestamp,
       USER,
       'DELETE');
  ELSIF inserting
  THEN
    INSERT INTO tzbestu
    VALUES
      (:new.tbbestu_exemption_code,
       :new.tbbestu_pidm,
       :new.tbbestu_term_code,
       :new.tbbestu_activity_date,
       :new.tbbestu_del_ind,
       :new.tbbestu_student_expt_roll_ind,
       :new.tbbestu_term_code_expiration,
       :new.tbbestu_user_id,
       :new.tbbestu_exemption_priority,
       :new.tbbestu_max_student_amount,
       tzbestu_seq.nextval,
       current_timestamp,
       USER,
       'INSERT');
  END IF;
END tzt_tbbestu_trig;
/

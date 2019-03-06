-- Create table
create table TZBESTU
(
  tzbestu_exemption_code        VARCHAR2(8) not null,
  tzbestu_pidm                  NUMBER(8) not null,
  tzbestu_term_code             VARCHAR2(6) not null,
  tzbestu_activity_date         DATE not null,
  tzbestu_del_ind               VARCHAR2(1),
  tzbestu_student_expt_roll_ind VARCHAR2(1) not null,
  tzbestu_term_code_expiration  VARCHAR2(6),
  tzbestu_user_id               VARCHAR2(30) not null,
  tzbestu_exemption_priority    NUMBER(2) not null,
  tzbestu_max_student_amount    NUMBER(12,2),
  tzbestu_seq                   NUMBER(8) not null,
  tzbestu_timestamp             TIMESTAMP(6),
  tzbestu_update_user_id        VARCHAR2(30) not null,
  tzbestu_operation_type        VARCHAR2(10)
)
tablespace DEVELOPMENT
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

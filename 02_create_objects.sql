-- =================================================================================================
-- 02. CREATE HR OBJECTS
-- Description  : Creates HR tables, sequences, constraints, indexes, view, procedures, triggers and comments
-- Requirements : Run as HR user.
-- =================================================================================================

----------------------------------------------------------------------------------------------------
-- Drop all HR objects
----------------------------------------------------------------------------------------------------
drop table job_history cascade constraints;
drop table departments cascade constraints;
drop table employees cascade constraints;
drop table jobs cascade constraints;
drop table locations cascade constraints;
drop table countries cascade constraints;
drop table regions cascade constraints;
drop sequence locations_seq;
drop sequence departments_seq;
drop sequence employees_seq;

----------------------------------------------------------------------------------------------------
-- Set session to American English (required for correct day names and date formats)
----------------------------------------------------------------------------------------------------
alter session set nls_language = 'AMERICAN';
alter session set nls_territory = 'AMERICA';

----------------------------------------------------------------------------------------------------
-- Regions
----------------------------------------------------------------------------------------------------
create table regions (
    region_id   number constraint regions_id_nn not null,
    region_name varchar2(25),
    constraint reg_id_pk primary key (region_id)
);

comment on table  regions             is 'Lookup table: major world regions (Europe, Americas, Asia, etc.)';
comment on column regions.region_id   is 'Primary key of regions';
comment on column regions.region_name is 'Region name';

----------------------------------------------------------------------------------------------------
-- Countries
----------------------------------------------------------------------------------------------------
create table countries (
    country_id   char(2) constraint country_id_nn not null,
    country_name varchar2(60),
    region_id    number,
    constraint country_c_id_pk primary key (country_id),
    constraint countr_reg_fk   foreign key (region_id) references regions(region_id)
) organization index;

comment on table  countries              is 'Lookup table: countries';
comment on column countries.country_id   is 'Primary key of countries';
comment on column countries.country_name is 'Country name';
comment on column countries.region_id    is 'Foreign key to regions.region_id';

----------------------------------------------------------------------------------------------------
-- Locations
----------------------------------------------------------------------------------------------------
create table locations (
    location_id    number(4)    constraint loc_id_nn not null,
    street_address varchar2(40),
    postal_code    varchar2(12),
    city           varchar2(30) constraint loc_city_nn not null,
    state_province varchar2(25),
    country_id     char(2),
    constraint loc_id_pk   primary key (location_id),
    constraint loc_c_id_fk foreign key (country_id) references countries(country_id)    
);

create sequence locations_seq start with 3300 increment by 100 maxvalue 9900 nocache nocycle;

create index loc_city_ix on locations (city);
create index loc_state_province_ix on locations (state_province);
create index loc_country_ix on locations (country_id);

comment on table  locations                is 'Company locations (offices, warehouses, etc)';
comment on column locations.location_id    is 'Primary key of locations';
comment on column locations.street_address is 'Street address';
comment on column locations.postal_code    is 'Postal/ZIP code';
comment on column locations.city           is 'City name';
comment on column locations.state_province is 'State, province or region';
comment on column locations.country_id     is 'FK to countries.country_id.';

----------------------------------------------------------------------------------------------------
-- Departments
----------------------------------------------------------------------------------------------------
create table departments (
    department_id   number(4)    constraint dept_id_nn not null,
    department_name varchar2(30) constraint dept_name_nn not null,
    manager_id      number(6),
    location_id     number(4),
    constraint dept_id_pk  primary key (department_id),
    constraint dept_loc_fk foreign key (location_id) references locations(location_id)
);

create sequence departments_seq start with 280 increment by 10 maxvalue 9990 nocache nocycle;

create index dept_location_ix on departments (location_id);

comment on table  departments                  is 'Company departments (IT, Sales, Accounting, etc.)';
comment on column departments.department_id   is 'Primary key of departments';
comment on column departments.department_name is 'Department name';
comment on column departments.manager_id      is 'Department manager - FK to employees.employee_id';
comment on column departments.location_id     is 'Where the department is physically located - FK to locations.location_id';

----------------------------------------------------------------------------------------------------
-- Jobs
----------------------------------------------------------------------------------------------------
create table jobs (
    job_id     varchar2(10) constraint job_id_nn not null,
    job_title  varchar2(35) constraint job_title_nn not null,
    min_salary number(6),
    max_salary number(6),
    constraint job_id_pk primary key (job_id)
);

comment on table  jobs            is 'Job positions with salary ranges';
comment on column jobs.job_id     is 'Primary key of jobs';
comment on column jobs.job_title  is 'Job title';
comment on column jobs.min_salary is 'Minimum salary for a job';
comment on column jobs.max_salary is 'Maximum salary for a job';

----------------------------------------------------------------------------------------------------
-- Employees
----------------------------------------------------------------------------------------------------
create table employees (
    employee_id    number(6)    constraint emp_id_nn not null,
    first_name     varchar2(20),
    last_name      varchar2(25) constraint emp_last_name_nn not null,
    email          varchar2(25) constraint emp_email_nn not null,
    phone_number   varchar2(20),
    hire_date      date         constraint emp_hire_date_nn not null,
    job_id         varchar2(10) constraint emp_job_nn not null,
    salary         number(8,2),
    commission_pct number(2,2),
    manager_id     number(6),
    department_id  number(4),
    constraint emp_emp_id_pk  primary key (employee_id),
    constraint emp_email_uk   unique (email),
    constraint emp_job_fk     foreign key (job_id) references jobs(job_id),
    constraint emp_manager_fk foreign key (manager_id) references employees(employee_id),
    constraint emp_dept_fk    foreign key (department_id) references departments(department_id),
    constraint emp_salary_min check (salary > 0)
);

create sequence employees_seq start with 207 increment by 1 nocache nocycle;

create index emp_department_ix on employees (department_id);
create index emp_job_ix on employees (job_id);
create index emp_manager_ix on employees (manager_id);
create index emp_name_ix on employees (last_name, first_name);

comment on table  employees                is 'Employees table with self-referencing manager';
comment on column employees.employee_id    is 'Primary key of employees';
comment on column employees.first_name     is 'First name';
comment on column employees.last_name      is 'Last name';
comment on column employees.email          is 'Email';
comment on column employees.phone_number   is 'Phone number';
comment on column employees.hire_date      is 'Hire date';
comment on column employees.job_id         is 'Current job - FK to jobs.job_id';
comment on column employees.salary         is 'Monthly salary – must be positive';
comment on column employees.commission_pct is 'Commission percentage (for sales roles)';
comment on column employees.manager_id     is 'Manager of an employee (self-reference)';
comment on column employees.department_id  is 'Current department - FK to departments.department_id';

-- FK from departments.manager_id must be added after employees is created
alter table departments add constraint dept_mgr_fk foreign key (manager_id) references employees(employee_id);

----------------------------------------------------------------------------------------------------
-- Job_history
----------------------------------------------------------------------------------------------------
create table job_history (
    employee_id   number(6)    constraint jhist_employee_nn not null,
    start_date    date         constraint jhist_start_date_nn not null,
    end_date      date         constraint jhist_end_date_nn not null,
    job_id        varchar2(10) constraint jhist_job_nn not null,
    department_id number(4),
    constraint jhist_emp_id_st_date_pk primary key (employee_id, start_date),
    constraint jhist_job_fk            foreign key (job_id) references jobs(job_id),
    constraint jhist_emp_fk            foreign key (employee_id) references employees(employee_id),
    constraint jhist_dept_fk           foreign key (department_id) references departments(department_id),
    constraint jhist_date_interval     check (end_date > start_date)
);

create index jhist_job_ix on job_history (job_id);
create index jhist_employee_ix on job_history (employee_id);
create index jhist_department_ix on job_history (department_id);

comment on table  job_history               is 'History of job and department changes for employees';
comment on column job_history.employee_id   is 'Employee who changed job/department';
comment on column job_history.start_date    is 'Start date of the period';
comment on column job_history.end_date      is 'End date of the period';
comment on column job_history.job_id        is 'Job held during the period - FK to jobs.job_id';
comment on column job_history.department_id is 'Department during the period - FK to departments.department_id';

----------------------------------------------------------------------------------------------------
-- View
----------------------------------------------------------------------------------------------------
create or replace view emp_details_view as
select
    e.employee_id,
    e.job_id,
    e.manager_id,
    e.department_id,
    d.location_id,
    l.country_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.commission_pct,
    d.department_name,
    j.job_title,
    l.city,
    l.state_province,
    c.country_name,
    r.region_name
from employees e
join departments d on e.department_id = d.department_id
join jobs j        on e.job_id = j.job_id
join locations l   on d.location_id = l.location_id
join countries c   on l.country_id = c.country_id
join regions r     on c.region_id = r.region_id
with read only;

----------------------------------------------------------------------------------------------------
-- Procedures & Triggers
----------------------------------------------------------------------------------------------------
create or replace Procedure Secure_Dml as
begin
  if to_char(sysdate, 'HH24:MI') not between '08:00' and '18:00' or
     to_char(sysdate, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN') in ('SAT', 'SUN') then
    Raise_Application_Error(-20205, 'DML allowed only during office hours');
  end if;
end Secure_Dml;
/

create or replace trigger Secure_Employees
  before insert or update or delete on Employees
begin
  Secure_Dml;
end Secure_Employees;
/

alter trigger secure_employees disable;


create or replace Procedure Add_Job_History
(
  p_Emp_Id        in Job_History.Employee_Id%type,
  p_Start_Date    in Job_History.Start_Date%type,
  p_End_Date      in Job_History.End_Date%type,
  p_Job_Id        in Job_History.Job_Id%type,
  p_Department_Id in Job_History.Department_Id%type
) as
begin
  insert into Job_History
    (Employee_Id, Start_Date, End_Date, Job_Id, Department_Id)
  values
    (p_Emp_Id, p_Start_Date, p_End_Date, p_Job_Id, p_Department_Id);
end Add_Job_History;
/

create or replace trigger Update_Job_History
  after update of Job_Id, Department_Id on Employees
  for each row
begin
  Add_Job_History(:Old.Employee_Id, :Old.Hire_Date, sysdate, :Old.Job_Id, :Old.Department_Id);
end Update_Job_History;
/

commit;

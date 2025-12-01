-- =================================================================================================
-- 01. CREATE HR SCHEMA
-- Description  : Creates the HR user and grants required privileges.
-- Requirements : Run as SYS or SYSTEM.
-- =================================================================================================

----------------------------------------------------------------------------------------------------
-- If you are using Oracle 12c or later, switch to the correct pluggable database.
-- Update the PDB name below if needed (examples: ORCLPDB1, PDB1).
----------------------------------------------------------------------------------------------------
alter session set container = orclpdb1;

----------------------------------------------------------------------------------------------------
-- Reset the HR schema by dropping the user and all associated objects.
-- Then create a fresh HR user and assign necessary tablespaces.
----------------------------------------------------------------------------------------------------
drop user hr cascade;

create user hr identified by hrpassword;

----------------------------------------------------------------------------------------------------
-- Assign default and temporary tablespaces
----------------------------------------------------------------------------------------------------
alter user hr default tablespace users quota unlimited on users;
alter user hr temporary tablespace temp;

----------------------------------------------------------------------------------------------------
-- Grant required privileges for HR schema operations.
----------------------------------------------------------------------------------------------------
grant connect to hr;

grant create session,
      create table,
      create view,
      create sequence,
      alter session,
      create synonym,
      create database link,
      resource,
      unlimited tablespace
to hr;
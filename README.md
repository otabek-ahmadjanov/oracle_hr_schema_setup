# Oracle HR Schema Setup

This repository contains SQL scripts to fully create the HR schema in Oracle Database.

---

## Files

| File | Purpose | Run As |
|------|---------|--------|
| `01_create_schema.sql` | Creates HR user and grants required privileges | SYS / SYSTEM |
| `02_create_objects.sql` | Creates tables, constraints, sequences, indexes, views, procedures, triggers | HR |
| `03_insert_data.sql` | Inserts sample data into all HR tables | HR |

---

## How to Run

### 1. Connect as SYS or SYSTEM and run scripts in this file:
```sql
01_create_schema.sql
```

### 2. Connect as newly created HR and run scripts in this file:
```sql
02_create_objects.sql
```

### 3. Still under HR run scripts in this file:
```sql
03_insert_data.sql
```

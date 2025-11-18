--lab8
-- 1. Setup: tables and data
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    dept_id   INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location  VARCHAR(50)
);

CREATE TABLE employees (
    emp_id   INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id  INT,
    salary   DECIMAL(10,2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE projects (
    proj_id   INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget    DECIMAL(12,2),
    dept_id   INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO departments VALUES
(101, 'IT',         'Building A'),
(102, 'HR',         'Building B'),
(103, 'Operations', 'Building C');

INSERT INTO employees VALUES
(1, 'John Smith',      101, 50000),
(2, 'Jane Doe',        101, 55000),
(3, 'Mike Johnson',    102, 48000),
(4, 'Sarah Williams',  102, 52000),
(5, 'Tom Brown',       103, 60000);

INSERT INTO projects VALUES
(201, 'Website Redesign',    75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade',   50000, 102);

-- 2.1 Simple B-tree index
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';

-- 2.2 Index on foreign key
CREATE INDEX emp_dept_idx ON employees(dept_id);

SELECT * FROM employees WHERE dept_id = 101;

-- 2.3 View all indexes in public schema
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

--PART 3
--3.1

CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;

-- Would this index be useful for a query that only filters by
-- salary (without dept_id)? Why or why not?

--No, the index (dept_id, salary)
-- would NOT be useful for a query that filters only by salary.
-- A multicolumn index works from left to right, meaning PostgreSQL
-- can use the index only if the first column (dept_id) is included
-- in the WHERE clause. If the query does not filter by the first
-- column, the index cannot be used efficiently.

--3.2
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

SELECT * FROM employees
WHERE dept_id = 102 AND salary > 50000;

SELECT * FROM employees
WHERE salary > 50000 AND dept_id = 102;

--Does the order of columns in a multicolumn index matter? Explain.
--Yes, the order of columns in a multicolumn index definitely matters.
-- PostgreSQL uses the index based on the order of the columns: it first
-- sorts by the first column, and then by the second. Therefore, the first column
-- must appear in the query’s WHERE clause for the index to be used. An index on
-- (dept_id, salary) is useful for queries filtering by dept_id, while an index on
-- (salary, dept_id) is useful for queries filtering by salary.


--PART 4
ALTER TABLE employees ADD COLUMN email VARCHAR(100);

UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');
-- INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
-- VALUES (6, 'New Employee', 101, 55000, 'new.employee@company.com');


--What error message did you receive?
--WE will receive a unique constraint violation error.
--This happens because a unique index does not allow two rows to have the same value in the email column.

--4.2
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';

--Did PostgreSQL automatically create an index? What type of index?
--Yes, PostgreSQL automatically created an index for the phone column.
-- The index type is a B-tree unique index, which is the default index type used
-- for enforcing UNIQUE constraints.

--PART 5

CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;
--How does this index help with ORDER BY queries?
--The index helps because it is already sorted in descending order by salary.
-- When PostgreSQL executes ORDER BY salary DESC, it can read the values directly from
-- the index instead of sorting the data manually. This makes the query faster, especially
-- on large tables.

--5.2
CREATE INDEX proj_budget_nulls_first_idx
ON projects(budget NULLS FIRST);

SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;

--PART 6
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));

SELECT * FROM employees
WHERE LOWER(emp_name) = 'john smith';

--Without this index, how would PostgreSQL search?
-- PostgreSQL would apply LOWER() to every row and do a full table scan,
-- because normal indexes cannot be used when a function is applied.

--6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;

UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx
ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;


--PART 7
-- 7.1 Rename index
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;

SELECT indexname FROM pg_indexes
WHERE tablename='employees';

-- 7.2 Drop index
DROP INDEX emp_salary_dept_idx;

-- Q: Why drop an index?
-- A: To reduce overhead if the index is unused or duplicated.

-- 7.3 Reindex
REINDEX INDEX employees_salary_index;

-- Q: When is REINDEX useful?
-- A: After bulk inserts, major updates, or index bloat.

-- PART 8

-- 8.1 Optimize frequent query
CREATE INDEX emp_salary_filter_idx
ON employees(salary)
WHERE salary > 50000;

-- emp_dept_idx already exists
-- emp_salary_desc_idx already created


-- 8.2 Partial index
CREATE INDEX proj_high_budget_idx
ON projects(budget)
WHERE budget > 80000;

SELECT proj_name, budget
FROM projects
WHERE budget > 80000;

-- Q: Advantage of partial index?
-- A: Smaller, faster, applied only to frequently queried subset.


-- 8.3 Analyze index usage
EXPLAIN SELECT * FROM employees WHERE salary > 52000;

-- Q: Index Scan or Seq Scan?
-- A: If it shows Index Scan → the index is used.
--    If Seq Scan → PostgreSQL decided index was not efficient.

-- PART 9

-- 9.1 Hash index
CREATE INDEX dept_name_hash_idx
ON departments USING HASH (dept_name);

SELECT * FROM departments WHERE dept_name = 'IT';

-- Q: When use HASH index?
-- A: For equality (=) comparisons only. Not for range queries.


-- 9.2
CREATE INDEX proj_name_btree_idx ON projects(proj_name);
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);

SELECT * FROM projects WHERE proj_name = 'Website Redesign';

SELECT * FROM projects WHERE proj_name > 'Database';

-- PART 10

-- 10.1 Index sizes
SELECT schemaname, tablename, indexname,
       pg_size_pretty(pg_relation_size(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname='public'
ORDER BY tablename, indexname;

-- Q: Which index is largest? Why?
-- A: Usually the index on the largest table or widest column.


-- 10.2 Drop unnecessary index
DROP INDEX IF EXISTS proj_name_hash_idx;


-- 10.3 Document indexes
CREATE VIEW index_documentation AS
SELECT tablename, indexname, indexdef,
       'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname='public'
  AND indexname LIKE '%salary%';

SELECT * FROM index_documentation;


-- 1. Default index type?
--    Answer: B-tree.

-- 2. When should you create an index?
--    Answer:
--      - Columns used in WHERE
--      - JOIN columns
--      - Columns used in ORDER BY
--      - Columns frequently filtered

-- 3. When NOT to create an index?
--    Answer:
--      - Very small tables
--      - Columns rarely filtered

-- 4. What happens on INSERT/UPDATE/DELETE?
--    Answer: Indexes must also update → extra overhead.

-- 5. How to check index usage?
--    Answer: Use EXPLAIN or EXPLAIN ANALYZE.



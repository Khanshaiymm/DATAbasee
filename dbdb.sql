DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
);
DROP TABLE IF EXISTS departments;
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);
DROP TABLE IF EXISTS projects;
CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
);

--1.2
-- employees
INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);

-- departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');

-- projects
INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

--PART 2

SELECT e.emp_name, d.dept_name
FROM employees e
CROSS JOIN departments d;

--2.2
SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON TRUE;
--Both queries give the same 20 rows
-- 2.3
SELECT e.emp_name, p.project_name
FROM employees e CROSS JOIN projects p;
-- 5 × 5 = 25 rows total

-- 3.1 Basic INNER JOIN with ON
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
-- 4 rows, Tom Brown excluded (dept_id NULL)


--3.2
SELECT emp_name, dept_name, location
FROM employees INNER JOIN departments USING (dept_id);
-- Same result, but dept_id not duplicated in output

--3.3
SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;
-- Automatically joins tables by all columns with the same name.
-- Here it finds dept_id as the common column.
-- Works like USING (dept_id).

--3.4
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;
-- Joins all three tables.
-- Employees ↔ Departments (by dept_id)
-- Departments ↔ Projects (by dept_id)
-- Only rows where all three match are returned.

--PART 4
--4.1
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
--Returns all employees, even those without departments.
--When there’s no match, columns from departments are NULL.
--So Tom Brown is shown, but dept_name = NULL.

--4.2
SELECT emp_name, dept_id, dept_name
FROM employees
LEFT JOIN departments USING (dept_id);
--Same result as above.
--Simpler syntax with USING.
--dept_id appears only once in the output.

--4.3
SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;
--Shows employees who don’t belong to any department.
--Filtered by WHERE d.dept_id IS NULL.
--4.4
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;
--Explanation:
--Counts employees per department.
--Uses LEFT JOIN so even departments without employees are included .


--PART5

SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;
--5.2
SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id;

--5.3
SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

--PART 6
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS dept_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;

--6.2
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;


--6.3
SELECT
  CASE
    WHEN e.emp_id IS NULL THEN 'Department without employees'
    WHEN d.dept_id IS NULL THEN 'Employee without department'
    ELSE 'Matched'
  END AS record_status,
  e.emp_name,
  d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;


--PART 7
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

--7.2
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- Answer
-- ON Keeps all employees (LEFT JOIN preserved). Filters apply only to right table match.
-- WHERE   Converts to INNER JOIN behavior, because it filters out NULLs after joining.
-- So, 7.1 keeps unmatched rows; 7.2 removes them.


--7.3
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

--For INNER JOIN, ON and WHERE produce the same result — because unmatched rows are excluded anyway.
-- Both give employees from Building A (IT department only).

--Part 8
SELECT d.dept_name, e.emp_name, e.salary, p.project_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

-- Combines 3 tables:
-- Departments always included (LEFT JOIN)
-- Employees & projects may be NULL if no match.
-- Creates a full department overview.

--8.2

ALTER TABLE employees ADD COLUMN manager_id INT;

-- Example data
UPDATE employees SET manager_id = 3 WHERE emp_id IN (1, 2, 5);
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;

-- Self-join query
SELECT e.emp_name AS Employee, m.emp_name AS Manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

--8.3
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;
--Departments with average salaries above 50,000 only.


--1
-- 1️What is the difference between INNER JOIN and LEFT JOIN?
-- INNER JOIN returns only rows that have matching values in both tables.
-- → Unmatched rows are excluded.
-- LEFT JOIN returns all rows from the left table and only the matching rows from the right table.
-- → If there is no match, columns from the right table will contain NULL.

--2
-- When would you use CROSS JOIN in a practical scenario?
-- You use CROSS JOIN when you need all possible combinations of rows between two tables — also known as a Cartesian product.
-- Practical example:
-- Creating an employee shift schedule:
-- Each employee × each working day of the week.
-- Building an availability matrix:
-- employees CROSS JOIN projects to plan assignments.

--3
-- Why does the position of a filter condition (ON vs WHERE) matter for outer joins but not for inner joins?
--
-- In INNER JOIN, both ON and WHERE filters give the same result because only matching rows are kept anyway.
-- In OUTER JOIN, the filter position changes the meaning:
-- ON clause: the filter is applied during the join — unmatched left rows are kept .
-- WHERE clause: the filter is applied after the join — unmatched rows are removed .

--4
-- What is the result of:
-- SELECT COUNT(*) FROM table1 CROSS JOIN table2
-- if table1 has 5 rows and table2 has 10 rows?
--
-- Answer:
-- CROSS JOIN produces a Cartesian product:
-- Total rows = 5 × 10 = 50 rows.

--5
-- How does NATURAL JOIN determine which columns to join on?
-- A NATURAL JOIN automatically joins tables on all columns with the same names in both tables.
--
-- Example:
-- SELECT * FROM employees NATURAL JOIN departments;
-- Joins automatically on dept_id (since both have that column name).

--6
-- What are the potential risks of using NATURAL JOIN?
-- It can cause unexpected joins if two tables have columns with the same name but different meanings.
-- It can break if new columns are added later with matching names.
-- Harder to read and maintain, since the join condition isn’t visible.
-- Safer alternative: use ON or USING explicitly.

--7
-- SELECT * FROM A LEFT JOIN B ON A.id = B.id;
--
-- SELECT * FROM B RIGHT JOIN A ON A.id = B.id;
--
-- SELECT * FROM B RIGHT JOIN A ON B.id = A.id;
-- You simply swap table positions and keep the same join condition.

--8
-- When should you use FULL OUTER JOIN instead of other join types?
-- Use FULL OUTER JOIN when you want to:
-- Combine all rows from both tables,
-- Show matches where they exist,
-- And still keep unmatched rows from both sides with NULLs.
-- Example use case:
-- Comparing employee and project lists to find:
-- Employees without projects,
-- Projects without assigned employees.



-------------
--Additional Challenges
-------------
-- 1
--Works like FULL JOIN — includes all rows from both sides.
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
UNION
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- 2
-- find employees who work in departments with more than one project
-- We can use GROUP BY and HAVING to find departments that manage multiple projects,
-- then join with employees.
SELECT e.emp_name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IN (
  SELECT dept_id
  FROM projects
  GROUP BY dept_id
  HAVING COUNT(project_id) > 1
);

--Shows employees working in departments that have >1 project (like IT).

--3
-- create hierarchical query (employee → manager → manager’s manager)
-- This uses a self-join on the employees table.

SELECT e.emp_name AS Employee,
       m.emp_name AS Manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

--4
-- Find all pairs of employees who work in the same department
-- This uses a self-join as well, matching two employees from the same department.

SELECT e1.emp_name AS Employee1,
       e2.emp_name AS Employee2,
       e1.dept_id
FROM employees e1
JOIN employees e2
  ON e1.dept_id = e2.dept_id
 AND e1.emp_id < e2.emp_id;
-- This ensures each pair is listed only once (not reversed duplicates).




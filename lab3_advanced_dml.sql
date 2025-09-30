--PART A

CREATE DATABASE advanced_lab;


-- \c advanced_lab;

DROP TABLE IF EXISTS employees ;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS departments;

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    salary     INTEGER,
    hire_date  DATE,
    status     VARCHAR(20) DEFAULT 'Active'
);

DROP TABLE IF EXISTS departments ;
CREATE TABLE departments (
    dept_id   SERIAL PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    budget    INTEGER,
    manager_id INTEGER
);

DROP TABLE IF EXISTS  projects ;
CREATE TABLE projects (
    project_id   SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    dept_id      INTEGER,
    start_date   DATE,
    end_date     DATE,
    budget       INTEGER,

    CONSTRAINT fk_dept FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- PART B

ALTER TABLE employees
ALTER COLUMN salary SET DEFAULT 0;

INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (DEFAULT, 'Aruzhan', 'Rysbaeva', 'IT');

INSERT INTO employees (first_name, last_name, department, salary, status)
VALUES ('Diana', 'Abdrahman', 'Finance', DEFAULT, DEFAULT);


INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('IT', 200000, 1),
    ('Finance', 150000, 2),
    ('HR', 100000, 3);



INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Khanshaiym', 'Nugman', 'Sales', 50000 * 1.1, CURRENT_DATE);


DROP TABLE IF EXISTS temp_employees;
CREATE TEMP TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';



--PART C

UPDATE employees
SET salary = salary * 1.10
WHERE department = 'IT';

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';


UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END
WHERE salary IS NOT NULL;


UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';


UPDATE departments d
SET budget = (
    SELECT AVG(salary) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
)
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department = d.dept_name
);


UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

--PART D

DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;


DELETE FROM departments d
WHERE d.dept_name NOT IN (
    SELECT DISTINCT e.department
    FROM employees e
    WHERE e.department IS NOT NULL
);

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

--PART E

INSERT INTO employees (first_name, last_name, salary, department)
VALUES ('Aigerim', 'Samatova', NULL, NULL);

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;

--PART F

INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Nurlan', 'Abdulla', 'Marketing', 45000, CURRENT_DATE)
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;


--PART G


INSERT INTO employees (first_name, last_name, department, salary, hire_date)
SELECT 'Alina', 'Turarova', 'HR', 38000, CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE first_name = 'Alina' AND last_name = 'Turarova'
);

UPDATE employees e
SET salary = salary * CASE
    WHEN d.budget > 100000 THEN 1.10
    ELSE 1.05
END
FROM departments d
WHERE e.department = d.dept_name;


INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES
  ('Azamat', 'Kuralbayev', 'IT', 60000, CURRENT_DATE),
  ('Dana', 'Zhansaya', 'Finance', 55000, CURRENT_DATE),
  ('Miras', 'Serikuly', 'Sales', 45000, CURRENT_DATE),
  ('Aruzhan', 'Tleubek', 'HR', 40000, CURRENT_DATE),
  ('Yerbol', 'Nurtas', 'Marketing', 50000, CURRENT_DATE);

UPDATE employees
SET salary = salary * 1.10
WHERE (first_name, last_name) IN (
    ('Azamat','Kuralbayev'),
    ('Dana','Zhansaya'),
    ('Miras','Serikuly'),
    ('Aruzhan','Tleubek'),
    ('Yerbol','Nurtas')
);


CREATE TABLE IF NOT EXISTS employee_archive AS
TABLE employees WITH NO DATA;


INSERT INTO employee_archive
SELECT * FROM employees
WHERE status = 'Inactive';


DELETE FROM employees
WHERE status = 'Inactive';


UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND (
      SELECT COUNT(*)
      FROM employees e
      WHERE e.department = (
          SELECT d.dept_name
          FROM departments d
          WHERE d.dept_id = p.dept_id
      )
  ) > 3;



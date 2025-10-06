
CREATE TABLE  IF NOT EXISTS employees (
  employee_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  department VARCHAR(50),
  salary NUMERIC(10,2),
  hire_date DATE,
  manager_id INTEGER,
  email VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS projects (
  project_id SERIAL PRIMARY KEY,
  project_name VARCHAR(100),
  budget NUMERIC(12,2),
  start_date DATE,
  end_date DATE,
  status VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS assignments (
  assignment_id SERIAL PRIMARY KEY,
  employee_id INTEGER REFERENCES employees(employee_id),
  project_id INTEGER REFERENCES projects(project_id),
  hours_worked NUMERIC(5,1),
  assignment_date DATE
);

INSERT INTO employees (first_name, last_name, department, salary, hire_date, manager_id, email) VALUES
('John', 'Smith', 'IT', 75000, '2020-01-15', NULL, 'john.smith@company.com'),
('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1, 'sarah.j@company.com'),
('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL, 'mbrown@company.com'),
('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL, 'emily.davis@company.com'),
('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3, 'lisa.a@company.com');

INSERT INTO projects (project_name, budget, start_date, end_date, status) VALUES
('Website Redesign', 150000, '2024-01-01', '2024-06-30', 'Active'),
('CRM Implementation', 200000, '2024-02-15', '2024-12-31', 'Active'),
('Marketing Campaign', 80000, '2024-03-01', '2024-05-31', 'Completed'),
('Database Migration', 120000, '2024-01-10', NULL, 'Active');

INSERT INTO assignments (employee_id, project_id, hours_worked, assignment_date) VALUES
(1, 1, 120.5, '2024-01-15'),
(2, 1, 95.0, '2024-01-20'),
(1, 4, 80.0, '2024-02-01'),
(3, 3, 60.0, '2024-03-05'),
(5, 2, 110.0, '2024-02-20'),
(6, 3, 75.5, '2024-03-10');


-- Task 1.1
SELECT first_name || ' ' || last_name AS full_name, department, salary
FROM employees;

-- Task 1.2
SELECT DISTINCT department FROM employees ORDER BY department;

-- Task 1.3
SELECT project_name, budget,
       CASE WHEN budget > 150000 THEN 'Large'
            WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
            ELSE 'Small' END AS budget_category
FROM projects
ORDER BY project_name;

-- Task 1.4
SELECT first_name || ' ' || last_name AS full_name,
       COALESCE(email, 'No email provided') AS email_shown
FROM employees
ORDER BY full_name;

--TASK 2.1
SELECT *
FROM employees
WHERE hire_date > '2020-01-01';

--TASK 2.2
SELECT first_name, last_name, department, salary
FROM employees
WHERE salary BETWEEN 60000 AND 70000;

-- TASK 2.3

SELECT first_name, last_name, department
FROM employees
WHERE last_name LIKE 'S%' OR last_name LIKE 'J%';

--TASK 2.4

SELECT first_name, last_name, department, manager_id
FROM employees
WHERE manager_id IS NOT NULL
  AND department = 'IT';

--TASK 3.1

SELECT
  UPPER(first_name || ' ' || last_name) AS upper_name,
  LENGTH(last_name) AS last_name_length,
  SUBSTRING(email FROM 1 FOR 3) AS email_first3
FROM employees;

-- TASK 3.2
SELECT
  first_name || ' ' || last_name AS full_name,
  salary AS annual_salary,
  ROUND(salary / 12.0, 2) AS monthly_salary,
  ROUND(salary * 0.10, 2) AS raise_10_percent
FROM employees;

--TASK 3.3
SELECT
  FORMAT(
    'Project: %s - Budget: %s - Status: %s',
    project_name,
    TO_CHAR(budget, 'FM$999,999,999.00'),
    status
  ) AS project_info
FROM projects;

--TASK 3.4
SELECT
  first_name || ' ' || last_name AS full_name,
  hire_date,
  EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date)) AS years_with_company
FROM employees;

--TASK 4.1
SELECT
  department,
  ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY department
ORDER BY department;

--TASK 4.2
SELECT
  p.project_name,
  SUM(a.hours_worked) AS total_hours
FROM projects p
JOIN assignments a ON a.project_id = p.project_id
GROUP BY p.project_id, p.project_name
ORDER BY total_hours DESC;

--TASK 4.3
SELECT
  department,
  COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 1
ORDER BY employee_count DESC, department;

--TASK 4.4
SELECT
  MAX(salary) AS max_salary,
  MIN(salary) AS min_salary,
  SUM(salary) AS total_payroll
FROM employees;

-- Task 5.1
SELECT employee_id,
       first_name || ' ' || last_name AS full_name,
       salary
FROM employees
WHERE salary > 65000

UNION

SELECT employee_id,
       first_name || ' ' || last_name AS full_name,
       salary
FROM employees
WHERE hire_date > '2020-01-01'
ORDER BY salary DESC;

-- Task 5.2
SELECT employee_id
FROM employees
WHERE department = 'IT'

INTERSECT

SELECT employee_id
FROM employees
WHERE salary > 65000;

--5.2
SELECT employee_id,
       first_name || ' ' || last_name AS full_name,
       department,
       salary
FROM employees
WHERE employee_id IN (
  SELECT employee_id
  FROM employees
  WHERE department = 'IT'
  INTERSECT
  SELECT employee_id
  FROM employees
  WHERE salary > 65000
)
ORDER BY salary DESC;

-- Task 5.3
SELECT employee_id, first_name || ' ' || last_name AS full_name
FROM employees

EXCEPT

SELECT DISTINCT employee_id, first_name || ' ' || last_name AS full_name
FROM employees
JOIN assignments USING (employee_id)
ORDER BY full_name;

--TASK 6.1
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS full_name
FROM employees e
WHERE EXISTS (
  SELECT 1
  FROM assignments a
  WHERE a.employee_id = e.employee_id
)
ORDER BY full_name;

--TASK 6.2

SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS full_name,
       e.department
FROM employees e
WHERE e.employee_id IN (
  SELECT DISTINCT a.employee_id
  FROM assignments a
  JOIN projects p ON p.project_id = a.project_id
  WHERE p.status = 'Active'
)
ORDER BY full_name;

--TASK 6.3
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS full_name,
       e.department,
       e.salary
FROM employees e
WHERE e.salary > ANY (
  SELECT salary
  FROM employees
  WHERE department = 'Sales'
)
ORDER BY salary DESC;

--TASK 7.1
SELECT
  e.first_name || ' ' || e.last_name AS full_name,
  e.department,
  ROUND(AVG(a.hours_worked), 1) AS avg_hours,
  RANK() OVER (PARTITION BY e.department ORDER BY e.salary DESC) AS salary_rank
FROM employees e
LEFT JOIN assignments a ON a.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.department, e.salary
ORDER BY e.department, salary_rank;

--TASK 7.2
SELECT
  p.project_name,
  SUM(a.hours_worked) AS total_hours,
  COUNT(DISTINCT a.employee_id) AS num_employees
FROM projects p
JOIN assignments a ON p.project_id = a.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(a.hours_worked) > 150
ORDER BY total_hours DESC;

--TASK 7.3

WITH dept_stats AS (
  SELECT
    department,
    COUNT(*) AS emp_count,
    AVG(salary) AS avg_salary,
    MAX(salary) AS max_salary
  FROM employees
  GROUP BY department
),
top_earner AS (
  SELECT
    department,
    first_name || ' ' || last_name AS top_employee,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
  FROM employees
)
SELECT
  d.department,
  d.emp_count,
  ROUND(d.avg_salary, 2) AS avg_salary,
  t.top_employee,
  -- Using GREATEST / LEAST:
  GREATEST(d.avg_salary - 5000, 0) AS avg_minus_5000_floor,
  LEAST(d.max_salary, d.avg_salary * 1.5) AS capped_top_salary
FROM dept_stats d
JOIN top_earner t ON t.department = d.department AND t.rn = 1
ORDER BY d.department;





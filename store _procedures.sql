-- Create the database
CREATE DATABASE enterprise;

-- Use the created database
USE enterprise;

-- Create 'departments' table
CREATE TABLE departments (
    dept_no CHAR(4) NOT NULL,
    dept_name VARCHAR(40) NOT NULL,
    PRIMARY KEY (dept_no)
);

-- Insert data into 'departments'
INSERT INTO departments (dept_no, dept_name) VALUES
('d001', 'Marketing'),
('d002', 'Finance'),
('d003', 'Human Resources'),
('d004', 'Production'),
('d005', 'Development');


-- Create 'employees' 
DROP TABLE IF EXISTS employees;
-- Create 'employees' table  
CREATE TABLE employees (
    emp_no INT NOT NULL,
    birth_date DATE NOT NULL,
    first_name VARCHAR(14) NOT NULL,
    last_name VARCHAR(16) NOT NULL,
    gender ENUM('M', 'F') NOT NULL,
    hire_date DATE NOT NULL,
    PRIMARY KEY (emp_no)
);
-- Insert data into 'employees'
INSERT INTO employees (emp_no, birth_date, first_name, last_name, gender, hire_date) VALUES
(10001, '1980-06-12', 'John', 'Doe', 'M', '2001-03-15'),
(10002, '1975-11-07', 'Jane', 'Smith', 'F', '2003-08-23'),
(10003, '1990-01-23', 'Sam', 'Williams', 'M', '2007-12-01'),
(10004, '1983-05-18', 'Lisa', 'Brown', 'F', '2010-06-20');


-- Create 'dept_emp' table (many-to-many relationship between employees and departments)
CREATE TABLE dept_emp (
    emp_no INT NOT NULL,
    dept_no CHAR(4) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    PRIMARY KEY (emp_no, dept_no),
    FOREIGN KEY (emp_no) REFERENCES employees(emp_no) ON DELETE CASCADE,
    FOREIGN KEY (dept_no) REFERENCES departments(dept_no) ON DELETE CASCADE
);
-- Insert data into 'dept_emp'
INSERT INTO dept_emp (emp_no, dept_no, from_date, to_date) VALUES
(10001, 'd001', '2001-03-15', '9999-01-01'),
(10002, 'd002', '2003-08-23', '9999-01-01'),
(10003, 'd003', '2007-12-01', '9999-01-01'),
(10004, 'd004', '2010-06-20', '9999-01-01');


-- Create 'dept_manager' table (managers for each department)
CREATE TABLE dept_manager (
    dept_no CHAR(4) NOT NULL,
    emp_no INT  NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    PRIMARY KEY (dept_no, emp_no),
    FOREIGN KEY (dept_no) REFERENCES departments(dept_no) ON DELETE CASCADE,
    FOREIGN KEY (emp_no) REFERENCES employees(emp_no) ON DELETE CASCADE
);
-- Insert data into 'dept_manager'
INSERT INTO dept_manager (dept_no, emp_no, from_date, to_date) VALUES
('d001', 10001, '2001-03-15', '9999-01-01'),
('d002', 10002, '2003-08-23', '9999-01-01');

-- Create 'salaries' table (salaries for employees)
CREATE TABLE salaries (
    emp_no INT NOT NULL,
    salary INT  NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    PRIMARY KEY (emp_no, from_date),
    FOREIGN KEY (emp_no) REFERENCES employees(emp_no) ON DELETE CASCADE
);
-- Insert data into 'salaries'
INSERT INTO salaries (emp_no, salary, from_date, to_date) VALUES
(10001, 50000, '2001-03-15', '9999-01-01'),
(10002, 60000, '2003-08-23', '9999-01-01'),
(10003, 55000, '2007-12-01', '9999-01-01'),
(10004, 70000, '2010-06-20', '9999-01-01');


-- Create 'titles' table (job titles for employees)
CREATE TABLE titles (
    emp_no INT  NOT NULL,
    title VARCHAR(50) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE,
    PRIMARY KEY (emp_no, title, from_date),
    FOREIGN KEY (emp_no) REFERENCES employees(emp_no) ON DELETE CASCADE
);

-- Insert data into 'titles'
INSERT INTO titles (emp_no, title, from_date, to_date) VALUES
(10001, 'Marketing Specialist', '2001-03-15', '9999-01-01'),
(10002, 'Finance Analyst', '2003-08-23', '9999-01-01'),
(10003, 'HR Consultant', '2007-12-01', '9999-01-01'),
(10004, 'Production Engineer', '2010-06-20', '9999-01-01');


SHOW TABLES;

-- Find the average salary of the male and female employees in each department
SELECT
    d.dept_name, e.gender, AVG(salary)
FROM
    salaries s
        JOIN
    employees e ON s.emp_no = e.emp_no
        JOIN
    dept_emp de ON e.emp_no = de.emp_no
        JOIN
    departments d ON d.dept_no = de.dept_no
GROUP BY de.dept_no , e.gender
ORDER BY de.dept_no;

-- Find the lowest department number encountered the ‘dept_emp’ table. Then, find the highest department number.
SELECT MIN(dept_no) AS lowest_department_number
FROM dept_emp;

SELECT MAX(dept_no) AS HIGHEST_department_number
FROM dept_emp;

-- Create a procedure that asks you to insert an employee number and that will obtain an output containing the same number, as well as the number and name of the last department the employee has worked in.
-- Finally, call the procedure for employee number 10010.
DROP PROCEDURE IF EXISTS last_dept;
DELIMITER $$

CREATE PROCEDURE last_dept (IN p_emp_no INTEGER)
BEGIN
    SELECT
        e.emp_no, d.dept_no, d.dept_name
    FROM
        employees e
        JOIN dept_emp de ON e.emp_no = de.emp_no
        JOIN departments d ON de.dept_no = d.dept_no
    WHERE
        e.emp_no = p_emp_no
        AND de.from_date = (SELECT MAX(from_date)
                            FROM dept_emp
                            WHERE emp_no = p_emp_no);
END$$

DELIMITER ;
 
CALL last_dept(10004);
   

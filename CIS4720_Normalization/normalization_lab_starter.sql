/* ================================================================
   CIS 4720  Normalization Lab
   Starter file: normalization_lab_starter.sql

   Name: ______________________________
   Date: November 20, 2026

   Work in this file and keep its name. It lives in your OneDrive
   folder CIS4720_Normalization, and it is the one file you publish
   to GitHub at the end.

   Write a comment in your own words above every statement.
   Total: 10 points.

   For EVERY problem below, complete all five steps:

     Step 1  DIAGNOSE  Which normal form (1NF, 2NF, or 3NF) does the
                       table break? Why? Name the columns involved.
     Step 2  DESIGN    List your new tables. Mark the primary key (PK)
                       and every foreign key (FK).
     Step 3  CREATE    Write a CREATE TABLE statement for each table,
                       with PRIMARY KEY and FOREIGN KEY constraints.
                       Create parent tables before child tables.
     Step 4  INSERT    Insert at least TWO rows into EVERY table.
                       Insert parent rows before child rows.
     Step 5  JOIN      Write one SELECT with JOINs that shows the data
                       from all of the problem's tables together.

   Use ONLY the table names given in each problem.
   The whole file must run from top to bottom without errors.
   ================================================================ */

-- Create the database for this lab if it is not already there.
CREATE DATABASE IF NOT EXISTS misc_db;
-- Make sure all the tables go into the correct database.
USE misc_db;

-- Remove old lab tables in child-first order so the script can be run again.
DROP TABLE IF EXISTS enrollment;
-- Remove the old course table after its enrollment links.
DROP TABLE IF EXISTS course;
-- Remove the old student table after its enrollment links.
DROP TABLE IF EXISTS student;
-- Remove employees before departments because of the foreign key.
DROP TABLE IF EXISTS employee;
-- Remove the old department table.
DROP TABLE IF EXISTS department;
-- Remove apartment units before their buildings.
DROP TABLE IF EXISTS apartment_unit;
-- Remove the old building table.
DROP TABLE IF EXISTS building;
-- Remove pets before their owners.
DROP TABLE IF EXISTS pet;
-- Remove the old owner table.
DROP TABLE IF EXISTS owner;


/* ================================================================
   PROBLEM 1  Pet owners and their pets                 (2 points)
   ================================================================

   A pet grooming shop keeps one table named owner_pets:

     owner_id, owner_name, owner_city, pet1_name, pet2_name, pet3_name

   Sample rows:

   owner_id | owner_name   | owner_city | pet1_name | pet2_name | pet3_name
   =========+==============+============+===========+===========+==========
   1        | Maria Lopez  | Turlock    | Bella     | Max       | NULL
   2        | James Chen   | Modesto    | Luna      | NULL      | NULL
   3        | Priya Singh  | Ceres      | Rocky     | Daisy     | Coco

   The shop just signed up a customer with four pets.

   Use these table names:  owner, pet

   Step 1  DIAGNOSE:
   This breaks 1NF because pet1_name, pet2_name, and pet3_name are
   repeating columns. A fourth pet would require another column.

   Step 2  DESIGN:
   owner(owner_id PK, owner_name, owner_city)
   pet(pet_id PK, owner_id FK -> owner.owner_id, pet_name)

*/

/* Step 3  CREATE */
-- Store each owner's information once.
CREATE TABLE owner (
    owner_id INT PRIMARY KEY,
    owner_name VARCHAR(60) NOT NULL,
    owner_city VARCHAR(50) NOT NULL
);
-- Store each pet separately and link it to its owner.
CREATE TABLE pet (
    pet_id INT PRIMARY KEY,
    owner_id INT NOT NULL,
    pet_name VARCHAR(50) NOT NULL,
    FOREIGN KEY (owner_id) REFERENCES owner(owner_id)
);

/* Step 4  INSERT */
-- Add the owners before adding their pets.
INSERT INTO owner (owner_id, owner_name, owner_city) VALUES
(1, 'Maria Lopez', 'Turlock'),
(2, 'James Chen', 'Modesto'),
(3, 'Priya Singh', 'Ceres');
-- Add the pets, including multiple pets belonging to the same owner.
INSERT INTO pet (pet_id, owner_id, pet_name) VALUES
(1, 1, 'Bella'), (2, 1, 'Max'), (3, 2, 'Luna'),
(4, 3, 'Rocky'), (5, 3, 'Daisy'), (6, 3, 'Coco');

/* Step 5  JOIN */
-- Show each pet next to its owner's information.
SELECT o.owner_id, o.owner_name, o.owner_city, p.pet_name
FROM owner AS o
JOIN pet AS p ON o.owner_id = p.owner_id
ORDER BY o.owner_id, p.pet_id;



/* ================================================================
   PROBLEM 2  Apartment buildings and units             (2 points)
   ================================================================

   A property manager keeps one table named building_unit.
   Unit numbers repeat across buildings (every building has a 101),
   so the primary key is (building_id, unit_number).

     building_id, unit_number, building_name, building_address,
     bedrooms, monthly_rent

   Sample rows:

   building_id | unit_number | building_name | building_address  | bedrooms | monthly_rent
   ============+=============+===============+===================+==========+=============
   B1          | 101         | Oak Terrace   | 100 Oak St        | 1        | 1250.00
   B1          | 102         | Oak Terrace   | 100 Oak St        | 2        | 1600.00
   B2          | 101         | Canal Court   | 45 Canal Dr       | 2        | 1550.00
   B2          | 201         | Canal Court   | 45 Canal Dr       | 3        | 1900.00

   Hint: look at which columns need BOTH key columns and which
   need only one of them.

   Use these table names:  building, apartment_unit

   Step 1  DIAGNOSE:
   This breaks 2NF because building_name and building_address depend
   only on building_id, not the whole (building_id, unit_number) key.
   bedrooms and monthly_rent describe the specific unit.

   Step 2  DESIGN:
   building(building_id PK, building_name, building_address)
   apartment_unit(building_id PK/FK -> building.building_id,
                  unit_number PK, bedrooms, monthly_rent)

*/

/* Step 3  CREATE */
-- Store each building's shared details once.
CREATE TABLE building (
    building_id VARCHAR(5) PRIMARY KEY,
    building_name VARCHAR(60) NOT NULL,
    building_address VARCHAR(100) NOT NULL
);
-- Identify each unit by both its building and unit number.
CREATE TABLE apartment_unit (
    building_id VARCHAR(5) NOT NULL,
    unit_number INT NOT NULL,
    bedrooms INT NOT NULL,
    monthly_rent DECIMAL(9,2) NOT NULL,
    PRIMARY KEY (building_id, unit_number),
    FOREIGN KEY (building_id) REFERENCES building(building_id)
);

/* Step 4  INSERT */
-- Add the buildings first so units can reference them.
INSERT INTO building (building_id, building_name, building_address) VALUES
('B1', 'Oak Terrace', '100 Oak St'),
('B2', 'Canal Court', '45 Canal Dr');
-- Add units; number 101 can appear in different buildings.
INSERT INTO apartment_unit (building_id, unit_number, bedrooms, monthly_rent) VALUES
('B1', 101, 1, 1250.00), ('B1', 102, 2, 1600.00),
('B2', 101, 2, 1550.00), ('B2', 201, 3, 1900.00);

/* Step 5  JOIN */
-- Show building details together with each unit's rent and bedrooms.
SELECT b.building_id, u.unit_number, b.building_name,
       b.building_address, u.bedrooms, u.monthly_rent
FROM building AS b
JOIN apartment_unit AS u ON b.building_id = u.building_id
ORDER BY b.building_id, u.unit_number;



/* ================================================================
   PROBLEM 3  Employees and departments                 (2 points)
   ================================================================

   A company keeps one table named employee_info.
   The primary key is emp_id.

     emp_id, emp_name, hire_year, dept_id, dept_name, dept_phone

   Sample rows:

   emp_id | emp_name      | hire_year | dept_id | dept_name  | dept_phone
   =======+===============+===========+=========+============+=============
   E01    | Linda Park    | 2019      | D10     | Accounting | 209.555.0300
   E02    | Raj Mehta     | 2021      | D20     | Marketing  | 209.555.0400
   E03    | Carlos Vega   | 2022      | D10     | Accounting | 209.555.0300
   E04    | Emma Wilson   | 2024      | D20     | Marketing  | 209.555.0400

   Accounting gets a new phone number. How many rows must change?
   What happens to the Marketing department if Raj and Emma both quit?

   Use these table names:  department, employee

   Step 1  DIAGNOSE:
   This breaks 3NF because emp_id determines dept_id, which then
   determines dept_name and dept_phone. Those department details
   depend on another non-key column instead of directly on emp_id.
   Updating Accounting's phone would change two rows in the old table.
   If both Marketing employees quit, its department details disappear.

   Step 2  DESIGN:
   department(dept_id PK, dept_name, dept_phone)
   employee(emp_id PK, emp_name, hire_year,
            dept_id FK -> department.dept_id)

*/

/* Step 3  CREATE */
-- Keep department names and phone numbers in one place.
CREATE TABLE department (
    dept_id VARCHAR(5) PRIMARY KEY,
    dept_name VARCHAR(60) NOT NULL,
    dept_phone VARCHAR(20) NOT NULL
);
-- Keep employee details and a reference to their department.
CREATE TABLE employee (
    emp_id VARCHAR(5) PRIMARY KEY,
    emp_name VARCHAR(60) NOT NULL,
    hire_year INT NOT NULL,
    dept_id VARCHAR(5) NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

/* Step 4  INSERT */
-- Add each department once before assigning employees.
INSERT INTO department (dept_id, dept_name, dept_phone) VALUES
('D10', 'Accounting', '209.555.0300'),
('D20', 'Marketing', '209.555.0400');
-- Add employees with department IDs instead of repeating department details.
INSERT INTO employee (emp_id, emp_name, hire_year, dept_id) VALUES
('E01', 'Linda Park', 2019, 'D10'),
('E02', 'Raj Mehta', 2021, 'D20'),
('E03', 'Carlos Vega', 2022, 'D10'),
('E04', 'Emma Wilson', 2024, 'D20');

/* Step 5  JOIN */
-- Display employees alongside their department information.
SELECT e.emp_id, e.emp_name, e.hire_year, e.dept_id,
       d.dept_name, d.dept_phone
FROM employee AS e
JOIN department AS d ON e.dept_id = d.dept_id
ORDER BY e.emp_id;



/* ================================================================
   PROBLEM 4  Students and courses                     (2.5 points)
              This problem REQUIRES a bridge table with a
              composite primary key.
   ================================================================

   A college keeps one table named student_course.
   One student takes many courses, and one course has many students.

     student_id, student_name, student_major, course_id,
     course_name, course_description, units, grade

   Sample rows:

   student_id | student_name | student_major | course_id | course_name        | course_description                 | units | grade
   ===========+==============+===============+===========+====================+====================================+=======+======
   S100       | Ana Torres   | CIS           | CIS4720   | Database Mgmt      | Relational design and SQL          | 3     | A
   S100       | Ana Torres   | CIS           | CIS2000   | Intro to Python    | Programming fundamentals in Python | 3     | B
   S200       | Ben Shah     | Business      | CIS4720   | Database Mgmt      | Relational design and SQL          | 3     | B
   S300       | Chloe Nguyen | CIS           | CIS2000   | Intro to Python    | Programming fundamentals in Python | 3     | A

   Questions to think about:
     Which columns describe only the STUDENT?
     Which columns describe only the COURSE?
     Which column describes "this student in this course"?

   Use these table names:  student, course, enrollment
   enrollment is the bridge table. Its primary key must be the
   composite key (student_id, course_id), and each of those columns
   must also be a foreign key.

   Step 1  DIAGNOSE:
   This breaks 2NF because student_name and student_major depend only
   on student_id, while course_name, course_description, and units
   depend only on course_id. The grade depends on the whole pair
   (student_id, course_id). Student and course details also repeat.

   Step 2  DESIGN:
   student(student_id PK, student_name, student_major)
   course(course_id PK, course_name, course_description, units)
   enrollment(student_id PK/FK -> student.student_id,
              course_id PK/FK -> course.course_id, grade)

*/

/* Step 3  CREATE */
-- Store each student's name and major once.
CREATE TABLE student (
    student_id VARCHAR(5) PRIMARY KEY,
    student_name VARCHAR(60) NOT NULL,
    student_major VARCHAR(60) NOT NULL
);
-- Store each course's details once.
CREATE TABLE course (
    course_id VARCHAR(10) PRIMARY KEY,
    course_name VARCHAR(80) NOT NULL,
    course_description VARCHAR(150) NOT NULL,
    units INT NOT NULL
);
-- Connect students to courses with a two-column primary key.
CREATE TABLE enrollment (
    student_id VARCHAR(5) NOT NULL,
    course_id VARCHAR(10) NOT NULL,
    grade CHAR(2),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES student(student_id),
    FOREIGN KEY (course_id) REFERENCES course(course_id)
);

/* Step 4  INSERT */
-- Add students before creating enrollment records.
INSERT INTO student (student_id, student_name, student_major) VALUES
('S100', 'Ana Torres', 'CIS'),
('S200', 'Ben Shah', 'Business'),
('S300', 'Chloe Nguyen', 'CIS');
-- Add the two courses and their descriptions.
INSERT INTO course (course_id, course_name, course_description, units) VALUES
('CIS4720', 'Database Mgmt', 'Relational design and SQL', 3),
('CIS2000', 'Intro to Python', 'Programming fundamentals in Python', 3);
-- Enroll Ana in two courses and show multiple students in each course.
INSERT INTO enrollment (student_id, course_id, grade) VALUES
('S100', 'CIS4720', 'A'),
('S100', 'CIS2000', 'B'),
('S200', 'CIS4720', 'B'),
('S300', 'CIS2000', 'A');

/* Step 5  JOIN  (three tables: student, enrollment, course) */
-- Rebuild the student-course view with grades from the bridge table.
SELECT s.student_id, s.student_name, s.student_major,
       c.course_id, c.course_name, c.course_description,
       c.units, e.grade
FROM student AS s
JOIN enrollment AS e ON s.student_id = e.student_id
JOIN course AS c ON e.course_id = c.course_id
ORDER BY s.student_id, c.course_id;

-- =========================================
-- SCHOOL MANAGEMENT SYSTEM
-- Converted from T-SQL (SQL Server) to MySQL
-- =========================================

CREATE DATABASE IF NOT EXISTS schools;
USE schools;


-- =========================================
-- DROP TABLES IF THEY EXIST
-- (Must drop in reverse order of dependencies)
-- =========================================

DROP TABLE IF EXISTS fees;
DROP TABLE IF EXISTS attendances;
DROP TABLE IF EXISTS results;
DROP TABLE IF EXISTS guardians;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS lecturers;
DROP TABLE IF EXISTS departments;


-- =========================================
-- DEPARTMENTS TABLE
-- =========================================

CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    office_location VARCHAR(50) NOT NULL
);

CREATE INDEX idx_departments_department_name
    ON departments (department_name);


-- =========================================
-- LECTURERS TABLE
-- =========================================

CREATE TABLE lecturers (
    lecturer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE CHECK (email LIKE '%@%.%'),
    phone_number VARCHAR(11) UNIQUE,
    department_id INT NOT NULL,
    hire_date DATE NOT NULL,

    CONSTRAINT fk_lecturer_department
        FOREIGN KEY (department_id)
            REFERENCES departments (department_id)
            ON UPDATE CASCADE
);

CREATE INDEX idx_lecturers_name
    ON lecturers (first_name, last_name);


-- =========================================
-- STUDENTS TABLE
-- =========================================

CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender VARCHAR(6) NOT NULL CHECK (gender IN ('Male', 'Female')),
    date_of_birth DATE NOT NULL,
    email VARCHAR(100) UNIQUE CHECK (email LIKE '%@%.%'),
    phone_number VARCHAR(11) NOT NULL,
    home_address VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    admission_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    matric_number VARCHAR(50) NOT NULL UNIQUE,

    CONSTRAINT fk_student_department
        FOREIGN KEY (department_id)
            REFERENCES departments (department_id)
            ON UPDATE CASCADE
);

CREATE INDEX idx_students_name
    ON students (first_name, last_name);


-- =========================================
-- COURSES TABLE
-- =========================================

CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_title VARCHAR(100) NOT NULL UNIQUE,
    course_code VARCHAR(10) NOT NULL UNIQUE,
    credit_unit INT NOT NULL CHECK (credit_unit > 0),
    department_id INT NOT NULL,
    lecturer_id  INT NOT NULL,

    CONSTRAINT fk_course_department
        FOREIGN KEY (department_id)
            REFERENCES departments (department_id)
            ON UPDATE CASCADE,

    CONSTRAINT fk_course_lecturer
        FOREIGN KEY (lecturer_id)
            REFERENCES lecturers (lecturer_id)
            ON UPDATE CASCADE
);

CREATE INDEX idx_courses_course_code
    ON courses (course_code);


-- =========================================
-- ENROLLMENTS TABLE
-- =========================================

CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    semester VARCHAR(6)  NOT NULL CHECK (semester IN ('First', 'Second')),
    session VARCHAR(10) NOT NULL,
    enrollment_date DATE NOT NULL DEFAULT (CURRENT_DATE),

    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (student_id)
            REFERENCES students (student_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,

    CONSTRAINT fk_enrollment_course
        FOREIGN KEY (course_id)
            REFERENCES courses (course_id)
            ON UPDATE CASCADE,

    CONSTRAINT uq_student_course_session
        UNIQUE (student_id, course_id, semester, session)
);

CREATE INDEX idx_enrollments_semester
    ON enrollments (semester);


-- =========================================
-- RESULTS TABLE
-- =========================================

CREATE TABLE results (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL UNIQUE,
    score INT NOT NULL CHECK (score BETWEEN 0 AND 100),

    grade CHAR(1) GENERATED ALWAYS AS (
        CASE
            WHEN score >= 70 THEN 'A'
            WHEN score >= 60 THEN 'B'
            WHEN score >= 50 THEN 'C'
            WHEN score >= 45 THEN 'D'
            WHEN score >= 40 THEN 'E'
            ELSE 'F'
        END
    ) STORED,

    remark VARCHAR(10) GENERATED ALWAYS AS (
        CASE
            WHEN score >= 70 THEN 'Excellent'
            WHEN score >= 60 THEN 'Very Good'
            WHEN score >= 50 THEN 'Good'
            WHEN score >= 45 THEN 'Fair'
            WHEN score >= 40 THEN 'Pass'
            ELSE 'Fail'
        END
    ) STORED,

    CONSTRAINT fk_result_enrollment
        FOREIGN KEY (enrollment_id)
            REFERENCES enrollments (enrollment_id)
            ON DELETE CASCADE
);

CREATE INDEX idx_results_score
    ON results (score);

CREATE INDEX idx_results_grade
    ON results (grade);


-- =========================================
-- ATTENDANCES TABLE
-- =========================================

CREATE TABLE attendances (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    attendance_status VARCHAR(10) NOT NULL CHECK (attendance_status IN ('Present', 'Absent')),

    CONSTRAINT fk_attendance_enrollment
        FOREIGN KEY (enrollment_id)
            REFERENCES enrollments (enrollment_id)
            ON DELETE CASCADE
);

CREATE INDEX idx_attendances_enrollment_id
    ON attendances (enrollment_id);

CREATE INDEX idx_attendances_status
    ON attendances (attendance_status);


-- =========================================
--  FEES TABLE
-- =========================================

CREATE TABLE fees (
    fee_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    enrollment_id INT NOT NULL,
    amount_paid DECIMAL(10, 2) NOT NULL CHECK (amount_paid > 0),
    payment_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    payment_method VARCHAR(20) NOT NULL,

    CONSTRAINT fk_fee_student
        FOREIGN KEY (student_id)
            REFERENCES students (student_id)
            ON UPDATE CASCADE,

    CONSTRAINT fk_fee_enrollment
        FOREIGN KEY (enrollment_id)
            REFERENCES enrollments (enrollment_id)
            ON DELETE CASCADE
);

CREATE INDEX idx_fees_student_id
    ON fees (student_id);

CREATE INDEX idx_fees_amount_paid
    ON fees (amount_paid);


-- =========================================
-- GUARDIANS TABLE
-- =========================================

CREATE TABLE guardians (
    guardian_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    guardian_name VARCHAR(50) NOT NULL,
    relationship VARCHAR(20) NOT NULL,
    phone_number VARCHAR(11) NOT NULL,
    home_address VARCHAR(100) NOT NULL,

    CONSTRAINT fk_guardian_student
        FOREIGN KEY (student_id)
            REFERENCES students (student_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE
);

CREATE INDEX idx_guardians_name
    ON guardians (guardian_name);


-- =========================================
-- INSERT INTO DEPARTMENTS
-- =========================================

INSERT INTO departments (department_name, office_location)
VALUES
    ('Computer Science',  'Block A'),
    ('Mathematics',       'Block B'),
    ('Accounting',        'Block C'),
    ('Physics',           'Block D'),
    ('Chemistry',         'Block E'),
    ('Biology',           'Block F'),
    ('Economics',         'Block G'),
    ('English',           'Block H'),
    ('Political Science', 'Block I'),
    ('Statistics',        'Block J');


-- =========================================
-- INSERT INTO LECTURERS
-- =========================================

INSERT INTO lecturers (first_name, last_name, email, phone_number, department_id, hire_date)
VALUES
    ('James',    'Walker', 'james.w@email.com',    '07011111111', 1,  '2018-06-12'),
    ('Patricia', 'Hall',   'patricia.h@email.com', '07022222222', 2,  '2019-02-20'),
    ('Robert',   'Allen',  'robert.a@email.com',   '07033333333', 3,  '2017-09-14'),
    ('Linda',    'Young',  'linda.y@email.com',    '07044444444', 4,  '2016-01-18'),
    ('Joseph',   'King',   'joseph.k@email.com',   '07055555555', 5,  '2020-03-11'),
    ('Susan',    'Wright', 'susan.w@email.com',    '07066666666', 6,  '2021-07-09'),
    ('Charles',  'Scott',  'charles.s@email.com',  '07077777777', 7,  '2015-11-25'),
    ('Karen',    'Green',  'karen.g@email.com',    '07088888888', 8,  '2018-04-17'),
    ('Matthew',  'Baker',  'matthew.b@email.com',  '07099999999', 9,  '2019-12-30'),
    ('Nancy',    'Adams',  'nancy.a@email.com',    '07100000000', 10, '2022-05-05');


-- =========================================
-- INSERT INTO STUDENTS
-- =========================================

INSERT INTO students
    (first_name, last_name, gender, date_of_birth, email, phone_number, home_address, admission_date, department_id, matric_number)
VALUES
    ('John',    'Doe',      'Male',   '2002-03-15', 'john.doe@email.com',  '08011111111', 'Lagos',         '2024-01-10', 1,  '2024001'),
    ('Mary',    'Johnson',  'Female', '2001-07-20', 'mary.j@email.com',    '08022222222', 'Abuja',         '2024-01-10', 2,  '2024002'),
    ('David',   'Smith',    'Male',   '2003-01-11', 'david.s@email.com',   '08033333333', 'Enugu',         '2024-01-10', 3,  '2024003'),
    ('Grace',   'Brown',    'Female', '2002-05-09', 'grace.b@email.com',   '08044444444', 'Kano',          '2024-01-10', 4,  '2024004'),
    ('Michael', 'Wilson',   'Male',   '2001-12-30', 'michael.w@email.com', '08055555555', 'Ibadan',        '2024-01-10', 5,  '2024005'),
    ('Sarah',   'Davis',    'Female', '2003-08-14', 'sarah.d@email.com',   '08066666666', 'Port Harcourt', '2024-01-10', 6,  '2024006'),
    ('Daniel',  'Miller',   'Male',   '2002-09-17', 'daniel.m@email.com',  '08077777777', 'Benin',         '2024-01-10', 7,  '2024007'),
    ('Esther',  'Taylor',   'Female', '2001-06-25', 'esther.t@email.com',  '08088888888', 'Jos',           '2024-01-10', 8,  '2024008'),
    ('Samuel',  'Anderson', 'Male',   '2002-10-12', 'samuel.a@email.com',  '08099999999', 'Owerri',        '2024-01-10', 9,  '2024009'),
    ('Ruth',    'Thomas',   'Female', '2003-02-05', 'ruth.t@email.com',    '08100000000', 'Uyo',           '2024-01-10', 10, '2024010');


-- =========================================
-- INSERT INTO COURSES
-- =========================================

INSERT INTO courses (course_title, course_code, credit_unit, department_id, lecturer_id)
VALUES
    ('Introduction to Computer Science', 'CSC101', 3, 1,  1),
    ('Calculus I',                       'MTH101', 4, 2,  2),
    ('Financial Accounting',             'ACC101', 3, 3,  3),
    ('General Physics',                  'PHY101', 4, 4,  4),
    ('Organic Chemistry',                'CHM101', 3, 5,  5),
    ('Cell Biology',                     'BIO101', 4, 6,  6),
    ('Microeconomics',                   'ECO101', 3, 7,  7),
    ('English Literature',               'ENG101', 3, 8,  8),
    ('International Relations',          'POL101', 3, 9,  9),
    ('Probability and Statistics',       'STA101', 4, 10, 10);


-- =========================================
-- INSERT INTO ENROLLMENTS
-- =========================================

INSERT INTO enrollments (student_id, course_id, semester, session, enrollment_date)
VALUES
    (1,  1,  'First', '2024/2025', '2024-01-15'),
    (2,  2,  'First', '2024/2025', '2024-01-15'),
    (3,  3,  'First', '2024/2025', '2024-01-15'),
    (4,  4,  'First', '2024/2025', '2024-01-15'),
    (5,  5,  'First', '2024/2025', '2024-01-15'),
    (6,  6,  'First', '2024/2025', '2024-01-15'),
    (7,  7,  'First', '2024/2025', '2024-01-15'),
    (8,  8,  'First', '2024/2025', '2024-01-15'),
    (9,  9,  'First', '2024/2025', '2024-01-15'),
    (10, 10, 'First', '2024/2025', '2024-01-15');


-- =========================================
-- INSERT INTO RESULTS
-- =========================================

INSERT INTO results (enrollment_id, score)
VALUES
    (1,  85),
    (2,  78),
    (3,  92),
    (4,  65),
    (5,  88),
    (6,  72),
    (7,  80),
    (8,  60),
    (9,  90),
    (10, 75);


-- =========================================
-- INSERT INTO ATTENDANCES
-- =========================================

INSERT INTO attendances (enrollment_id, attendance_date, attendance_status)
VALUES
    (1,  '2024-02-01', 'Present'),
    (2,  '2024-02-01', 'Absent'),
    (3,  '2024-02-01', 'Present'),
    (4,  '2024-02-01', 'Present'),
    (5,  '2024-02-01', 'Absent'),
    (6,  '2024-02-01', 'Present'),
    (7,  '2024-02-01', 'Present'),
    (8,  '2024-02-01', 'Absent'),
    (9,  '2024-02-01', 'Present'),
    (10, '2024-02-01', 'Present');


-- =========================================
-- INSERT INTO FEES
-- =========================================

INSERT INTO fees (student_id, enrollment_id, amount_paid, payment_date, payment_method)
VALUES
    (1,  1,  50000, '2024-02-10', 'Credit Card'),
    (2,  2,  45000, '2024-02-12', 'Bank Transfer'),
    (3,  3,  55000, '2024-02-15', 'Cash'),
    (4,  4,  40000, '2024-02-18', 'Credit Card'),
    (5,  5,  60000, '2024-02-20', 'Bank Transfer'),
    (6,  6,  48000, '2024-02-22', 'Cash'),
    (7,  7,  52000, '2024-02-25', 'Credit Card'),
    (8,  8,  47000, '2024-02-28', 'Bank Transfer'),
    (9,  9,  53000, '2024-03-01', 'Cash'),
    (10, 10, 49000, '2024-03-05', 'Credit Card');


-- =========================================
-- INSERT INTO GUARDIANS
-- =========================================

INSERT INTO guardians (student_id, guardian_name, relationship, phone_number, home_address)
VALUES
    (1,  'Jane Doe',       'Mother', '09011111111', 'Lagos'),
    (2,  'Robert Johnson', 'Father', '09022222222', 'Abuja'),
    (3,  'Emily Smith',    'Mother', '09033333333', 'Enugu'),
    (4,  'Michael Brown',  'Father', '09044444444', 'Kano'),
    (5,  'Sarah Wilson',   'Mother', '09055555555', 'Ibadan'),
    (6,  'David Davis',    'Father', '09066666666', 'Port Harcourt'),
    (7,  'Laura Miller',   'Mother', '09077777777', 'Benin'),
    (8,  'James Taylor',   'Father', '09088888888', 'Jos'),
    (9,  'Linda Anderson', 'Mother', '09099999999', 'Owerri'),
    (10, 'Richard Thomas', 'Father', '09100000000', 'Uyo');


-- =========================================
-- DROP VIEWS IF THEY EXIST
-- =========================================

DROP VIEW IF EXISTS v_all_student_details;
DROP VIEW IF EXISTS v_student_course_details;
DROP VIEW IF EXISTS v_student_results;
DROP VIEW IF EXISTS v_department_student_count;
DROP VIEW IF EXISTS v_student_fee_payments;
DROP VIEW IF EXISTS v_student_guardians;
DROP VIEW IF EXISTS v_student_attendance;
DROP VIEW IF EXISTS v_students_courses_lecturers;


-- =========================================
-- CREATE VIEWS
-- =========================================

CREATE VIEW v_all_student_details AS
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    s.gender,
    s.date_of_birth,
    s.email,
    s.phone_number,
    s.home_address,
    s.matric_number,

    d.department_name,

    c.course_title,
    c.course_code,

    CONCAT(l.first_name, ' ', l.last_name) AS lecturer_name,

    e.semester,
    e.session,

    r.score,
    r.grade,
    r.remark,

    a.attendance_date,
    a.attendance_status,

    f.amount_paid,
    f.payment_method,

    g.guardian_name,
    g.relationship

FROM students s

LEFT JOIN departments d
    ON s.department_id = d.department_id

LEFT JOIN enrollments e
    ON s.student_id = e.student_id

LEFT JOIN courses c
    ON e.course_id = c.course_id

LEFT JOIN lecturers l
    ON c.lecturer_id = l.lecturer_id

LEFT JOIN results r
    ON e.enrollment_id = r.enrollment_id

LEFT JOIN attendances a
    ON e.enrollment_id = a.enrollment_id

LEFT JOIN fees f
    ON e.enrollment_id = f.enrollment_id

LEFT JOIN guardians g
    ON s.student_id = g.student_id;


CREATE VIEW v_student_results AS
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    c.course_title,
    c.course_code,
    r.score,
    r.grade,
    r.remark

FROM students s

LEFT JOIN enrollments e
    ON s.student_id = e.student_id

LEFT JOIN courses c
    ON e.course_id = c.course_id

LEFT JOIN results r
    ON e.enrollment_id = r.enrollment_id;


CREATE VIEW v_department_student_count AS
SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count

FROM departments d

LEFT JOIN students s
    ON d.department_id = s.department_id

GROUP BY d.department_name;


CREATE VIEW v_students_courses_lecturers AS
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    c.course_title,

    CONCAT(l.first_name, ' ', l.last_name) AS lecturer_name

FROM students s

JOIN enrollments e
    ON s.student_id = e.student_id

JOIN courses c
    ON e.course_id = c.course_id

JOIN lecturers l
    ON c.lecturer_id = l.lecturer_id;


CREATE VIEW v_student_course_details AS
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    c.course_title,
    c.course_code,
    e.semester,
    e.session

FROM students s

JOIN enrollments e
    ON s.student_id = e.student_id

JOIN courses c
    ON e.course_id = c.course_id;


-- =========================================
-- TEST SELECTS
-- =========================================

SELECT * FROM departments;
SELECT * FROM lecturers;
SELECT * FROM students;
SELECT * FROM courses;
SELECT * FROM enrollments;
SELECT * FROM results;
SELECT * FROM attendances;
SELECT * FROM fees;
SELECT * FROM guardians;

SELECT * FROM v_all_student_details;
SELECT * FROM v_student_results        ORDER BY student_id ASC;
SELECT * FROM v_department_student_count;
SELECT * FROM v_students_courses_lecturers ORDER BY student_id ASC;
SELECT * FROM v_student_course_details     ORDER BY student_id ASC;
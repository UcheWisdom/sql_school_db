-- =========================================
-- SCHOOL MANAGEMENT SYSTEM DATABASE
-- =========================================

DROP DATABASE IF EXISTS schools;
CREATE DATABASE schools;
USE schools;
GO


-- =========================================
--  DEPARTMENTS TABLE
-- =========================================

CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE INDEX idx_department_name
    ON departments (department_name);


-- =========================================
--  LECTURERS TABLE
-- =========================================

CREATE TABLE lecturers (
    lecturer_id  INT          AUTO_INCREMENT PRIMARY KEY,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    email        VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(20)  NOT NULL UNIQUE,
    department_id INT         NOT NULL,
    hire_date    DATE         NOT NULL,

    CONSTRAINT fk_lecturer_department
        FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
        ON UPDATE CASCADE
);

CREATE INDEX idx_lecturer_name
    ON lecturers (first_name, last_name);


-- =========================================
--    STUDENTS TABLE
-- =========================================

CREATE TABLE students (
    student_id    INT          AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    gender        ENUM('Male', 'Female') NOT NULL,
    date_of_birth DATE         NOT NULL,
    email         VARCHAR(255) NOT NULL UNIQUE,
    phone_number  VARCHAR(20)  NOT NULL UNIQUE,
    home_address  VARCHAR(255) NOT NULL,
    matric_number VARCHAR(20)  NOT NULL UNIQUE,
    admission_date DATE        NOT NULL,
    department_id INT          NOT NULL,

    CONSTRAINT fk_student_department
        FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
        ON UPDATE CASCADE
);

CREATE INDEX idx_student_name
    ON students (first_name, last_name);


-- =========================================
-- 4. COURSES TABLE
-- =========================================
CREATE TABLE courses (
    course_id    INT          AUTO_INCREMENT PRIMARY KEY,
    course_code  VARCHAR(10)  NOT NULL UNIQUE,
    course_title VARCHAR(100) NOT NULL,
    credit_unit  INT          NOT NULL,
    department_id INT         NOT NULL,
    lecturer_id  INT          NOT NULL,

    CONSTRAINT chk_credit_unit
        CHECK (credit_unit BETWEEN 1 AND 6),

    CONSTRAINT fk_course_department
        FOREIGN KEY (department_id)
        REFERENCES departments (department_id)
        ON UPDATE CASCADE,

    CONSTRAINT fk_course_lecturer
        FOREIGN KEY (lecturer_id)
        REFERENCES lecturers (lecturer_id)
        ON UPDATE CASCADE
);

CREATE INDEX idx_course_code
    ON courses (course_code);


-- =========================================
--  ENROLLMENTS TABLE
-- =========================================

CREATE TABLE enrollments (
    enrollment_id    INT          AUTO_INCREMENT PRIMARY KEY,
    student_id       INT          NOT NULL,
    course_id        INT          NOT NULL,
    semester         ENUM('First', 'Second') NOT NULL,
    academic_session VARCHAR(9)   NOT NULL,   -- e.g. '2024/2025'
    enrollment_date  DATE         NOT NULL,

    -- Enforce session format: 4 digits / 4 digits (e.g. 2024/2025)
    CONSTRAINT chk_academic_session
        CHECK (academic_session REGEXP '^[0-9]{4}/[0-9]{4}$'),

    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (student_id)
        REFERENCES students (student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_enrollment_course
        FOREIGN KEY (course_id)
        REFERENCES courses (course_id)
        ON UPDATE CASCADE,

    CONSTRAINT uq_enrollment
        UNIQUE (student_id, course_id, semester, academic_session)
);

CREATE INDEX idx_enrollment_semester
    ON enrollments (semester);


-- =========================================
-- 6. RESULTS TABLE
-- =========================================

CREATE TABLE results (
    result_id     INT  AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT  NOT NULL UNIQUE,
    score         DECIMAL(5, 2) NOT NULL,

    -- Score must be between 0 and 100
    CONSTRAINT chk_score
        CHECK (score BETWEEN 0 AND 100),

    -- Auto-computed letter grade (MySQL 5.7+ generated column)
    grade AS (
        CASE
            WHEN score >= 70 THEN 'A'
            WHEN score >= 60 THEN 'B'
            WHEN score >= 50 THEN 'C'
            WHEN score >= 45 THEN 'D'
            ELSE 'F'
        END
    ) STORED,

    CONSTRAINT fk_result_enrollment
        FOREIGN KEY (enrollment_id)
        REFERENCES enrollments (enrollment_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_result_score
    ON results (score);


-- =========================================
-- 7. ATTENDANCES TABLE
-- =========================================

CREATE TABLE attendances (
    attendance_id     INT  AUTO_INCREMENT PRIMARY KEY,
    enrollment_id     INT  NOT NULL,
    attendance_date   DATE NOT NULL,
    attendance_status ENUM('Present', 'Absent') NOT NULL,

    CONSTRAINT fk_attendance_enrollment
        FOREIGN KEY (enrollment_id)
        REFERENCES enrollments (enrollment_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_attendance
        UNIQUE (enrollment_id, attendance_date)
);

CREATE INDEX idx_attendance_status
    ON attendances (attendance_status);


-- =========================================
-- 8. FEES TABLE
-- =========================================

CREATE TABLE fees (
    fee_id         INT            AUTO_INCREMENT PRIMARY KEY,
    student_id     INT            NOT NULL,
    enrollment_id  INT            NOT NULL,
    amount_paid    DECIMAL(10, 2) NOT NULL,
    payment_date   DATE           NOT NULL,
    payment_method VARCHAR(30)    NOT NULL,

    -- Amount must be positive
    CONSTRAINT chk_amount_paid
        CHECK (amount_paid > 0),

    CONSTRAINT fk_fee_student
        FOREIGN KEY (student_id)
        REFERENCES students (student_id)
        ON UPDATE CASCADE,

    CONSTRAINT fk_fee_enrollment
        FOREIGN KEY (enrollment_id)
        REFERENCES enrollments (enrollment_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_fee_student
    ON fees (student_id);


-- =========================================
-- 9. GUARDIANS TABLE
-- =========================================

CREATE TABLE guardians (
    guardian_id  INT          AUTO_INCREMENT PRIMARY KEY,
    student_id   INT          NOT NULL,
    guardian_name VARCHAR(100) NOT NULL,
    relationship VARCHAR(30)  NOT NULL,
    phone_number VARCHAR(20)  NOT NULL,
    home_address VARCHAR(255) NOT NULL,

    CONSTRAINT fk_guardian_student
        FOREIGN KEY (student_id)
        REFERENCES students (student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE INDEX idx_guardian_name
    ON guardians (guardian_name);


-- =========================================
-- VERIFY TABLES
-- =========================================

SHOW TABLES;

DESCRIBE departments;
DESCRIBE lecturers;
DESCRIBE students;
DESCRIBE courses;
DESCRIBE enrollments;
DESCRIBE results;
DESCRIBE attendances;
DESCRIBE fees;
DESCRIBE guardians;
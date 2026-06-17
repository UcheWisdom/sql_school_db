-- =========================================
-- CREATE DATABASE
-- =========================================

-- CREATE DATABASE schools

USE schools;
SHOW TABLES
DESCRIBE courses;
DELETE schools;
DESCRIBE lecturers;
DESCRIBE students;



-- ========================================
-- CREATE DEPARTMENT TABLE
-- =========================================

CREATE TABLE IF NOT EXISTS departments (
    department_id INT AUTO_INCREMENT  PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL
);

CREATE INDEX idx_departments_department_name
ON departments(department_name);

-- =========================================
-- CREATE LECTURERS TABLE
-- =========================================

-- Create the Lectures table
CREATE TABLE IF NOT EXISTS lecturers (
    lecturer_id INT AUTO_INCREMENT  PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
	email VARCHAR(255) NOT NULL UNIQUE
    CHECK(email LIKE '%@%.%'),
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    department_id INT NOT NULL,
    hire_date DATE NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);




-- =========================================
-- CREATE STUDENTS TABLE
-- =========================================

CREATE TABLE IF NOT EXISTS students (
    student_id INT AUTO_INCREMENT  PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT  NULL,
	gender ENUM('Male', 'Female')  NOT NULL,
	date_of_birth DATE NOT NULL,
	email VARCHAR(255) NOT NULL UNIQUE
    CHECK(email LIKE '%@%.%'),
	phone_number VARCHAR(50) NOT NULL UNIQUE,
	home_address VARCHAR(225) NOT NULL,
	department_id INT NOT NULL,
	admission_date DATE NOT NULL,
	matric_number VARCHAR(20) NOT NULL,
FOREIGN KEY (department_id) REFERENCES departments (department_id)
);


-- =========================================
-- CREATE COURSES TABLE
-- =========================================
 
CREATE TABLE IF NOT EXISTS courses (
    course_id INT AUTO_INCREMENT  PRIMARY KEY,
    course_title VARCHAR(20) NOT NULL UNIQUE,
    course_code VARCHAR(10) NOT NULL UNIQUE,
    credit_unit INT NOT NULL CHECK(credit_unit > 0),
    department_id INT NOT NULL,
    lecture_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments (department_id),
	FOREIGN KEY (lecture_id) REFERENCES lecturers (lecture_id)
);


-- =========================================
-- CREATE ENROLLMENTS TABLE
-- =========================================

CREATE TABLE IF NOT EXISTS enrollments (
    enrollment_id INT AUTO_INCREMENT  PRIMARY KEY,
    student_id INT NOT NULL UNIQUE,
	course_id INT NOT NULL UNIQUE,
	semester ENUM('First', 'Second') NOT NULL UNIQUE,
	session VARCHAR(10) NOT NULL  UNIQUE ,
	enrollment_date DATE NOT NULL,
	FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
	FOREIGN KEY (course_id) REFERENCES courses(course_id)
);


-- =========================================
-- CREATE RESULTS TABLE
-- =========================================

CREATE TABLE IF NOT EXISTS results (
    result_id INT AUTO_INCREMENT  PRIMARY KEY,
    enrollment_id INT NOT NULL UNIQUE,
	score INT CHECK(score BETWEEN 0 AND 100) NOT NULL,
	grade VARCHAR(2) GENERATED ALWAYS AS  (
		CASE
			WHEN score >= 70 THEN 'A'
			WHEN score >= 60 THEN 'B'
			WHEN score >= 50 THEN 'C'
			WHEN score >= 45 THEN 'D'
			WHEN score >= 40 THEN 'E'
			ELSE 'F'
		END
	) STORED,

	remark VARCHAR(2) GENERATED ALWAYS AS  (
		CASE
			WHEN score >= 70 THEN 'A'
			WHEN score >= 60 THEN 'B'
			WHEN score >= 50 THEN 'C'
			WHEN score >= 45 THEN 'D'
			WHEN score >= 40 THEN 'E'
			ELSE 'F'
		END
	)STORED,

	FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE
);


-- =========================================
-- CREATE ATTENDANCES TABLE
-- =========================================

CREATE TABLE IF NOT EXISTS attendances (
    attendance_id INT AUTO_INCREMENT  PRIMARY KEY,
    enrollment_id INT NOT NULL UNIQUE,
	attendance_date VARCHAR(10) NOT NULL,
	FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE  
);


-- =========================================
-- CREATE FEES TABLE
-- =========================================

CREATE TABLE IF NOT EXISTS fees (
    fee_id INT AUTO_INCREMENT  PRIMARY KEY,
    student_id INT NOT NULL,
	enrollment_id INT NOT NULL,
	amount_paid  DECIMAL(10,2) NOT NULL CHECK(amount_paid > 0),
	payment_date DATE NOT NULL,
	payment_method VARCHAR(20) NOT NULL,
	FOREIGN KEY (student_id) REFERENCES students(student_id),
	FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE
);


-- =========================================
-- CREATE GUARDIANS TABLE
-- =========================================

CREATE TABLE IF NOT EXISTS guardians (
    guardians_id INT AUTO_INCREMENT  PRIMARY KEY,
    student_id INT NOT NULL,
	guardian_name VARCHAR(50) NOT NULL,
	relationship VARCHAR(10) NOT NULL,
	phone_number VARCHAR(11) NOT NULL,
	home_adress VARCHAR(75) NOT NULL,
	FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

CREATE INDEX idx_guardians_name ON guardians(guardian_name);

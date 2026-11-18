-- EduTrack Database Schema - SQLite3 Compatible Version
-- Database Audit and Data Cleaning for Q3

-- ============================================================
-- Drop existing tables (for clean start)
-- ============================================================
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS courses;

-- ============================================================
-- TABLE: students (context only — do not modify)
-- ============================================================
CREATE TABLE students (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            VARCHAR(100) NOT NULL,
    email           VARCHAR(150) NOT NULL UNIQUE,
    signup_date     DATE NOT NULL
);

-- ============================================================
-- TABLE: courses (context only — do not modify)
-- ============================================================
CREATE TABLE courses (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    title           VARCHAR(150) NOT NULL,
    category        VARCHAR(50)  NOT NULL,
    instructor_name VARCHAR(100),
    monthly_fee     DECIMAL(6,2) NOT NULL
);

-- ============================================================
-- TABLE: enrollments (this is where you will work)
-- ============================================================
CREATE TABLE enrollments (
    id                    INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id            INTEGER      NOT NULL,
    student_name          VARCHAR(100) NOT NULL,
    student_email         VARCHAR(150) NOT NULL,
    course_id             INTEGER      NOT NULL,
    course_title          VARCHAR(150) NOT NULL,
    category              VARCHAR(50)  NOT NULL,
    enrollment_date       DATE         NOT NULL,
    completion_percentage INTEGER      NOT NULL DEFAULT 0,
    passed                BOOLEAN      NOT NULL DEFAULT 0,
    monthly_fee_paid      DECIMAL(6,2) NOT NULL,
    instructor            VARCHAR(100)
);

-- ============================================================
-- DATA: students
-- ============================================================
INSERT INTO students (name, email, signup_date) VALUES
('Emily Watson',      'emily.watson@student.edutrack.com',   '2024-01-15'),
('Klaus Weber',       'klaus.weber@student.edutrack.com',    '2024-01-20'),
('Lucia Fernandes',   'lucia.fernandes@student.edutrack.com', '2024-02-03'),
('Marco Rossi',       'marco.rossi@student.edutrack.com',    '2024-02-10'),
('Yuki Nakamura',     'yuki.nakamura@student.edutrack.com',  '2024-03-05'),
('Pierre Dubois',     'pierre.dubois@student.edutrack.com',  '2024-03-18'),
('Priya Sharma',      'priya.sharma@student.edutrack.com',   '2024-04-01'),
('James Miller',      'james.miller@test.com',               '2024-04-12'),
('Alex Chen',         'alex.chen@test.com',                  '2024-04-12'),
('Hans Schneider',    'hans.schneider@student.edutrack.com', '2024-05-07');

-- ============================================================
-- DATA: courses
-- ============================================================
INSERT INTO courses (title, category, instructor_name, monthly_fee) VALUES
('Intro to Python',        'Programming', 'Marta López',  49.99),
('Web Design Basics',      'Design',      'Carlos Vega',  39.99),
('Data Analysis with SQL', 'Data',        'Marta López',  59.99),
('Digital Marketing 101',  'Marketing',   'Lucia Prades', 29.99),
('Advanced Python',        'Programming', 'Carlos Vega',  69.99),
('UI/UX Fundamentals',     'Design',      NULL,           44.99),
('Email Campaigns',        'Marketing',   'Lucia Prades', 19.99);

-- ============================================================
-- DATA: enrollments
-- ============================================================
INSERT INTO enrollments (student_id, student_name, student_email, course_id, course_title, category, enrollment_date, completion_percentage, passed, monthly_fee_paid, instructor) VALUES
(1, 'Emily Watson',      'emily.watson@student.edutrack.com',    1, 'Intro to Python',        'Programming', '2024-03-10', 85, 1,  49.99, 'Marta López'),
(1, 'Emily Watson',      'emily.watson@student.edutrack.com',    2, 'Web Design Basics',      'Design',      '2024-04-15', 60, 0, 39.99, 'Carlos Vega'),
(2, 'Klaus Weber',       'klaus.weber@student.edutrack.com', 1, 'Intro to Python',        'Programming', '2024-03-12', 92, 1,  49.99, 'Marta López'),
(2, 'Klaus Weber',       'klaus.weber@student.edutrack.com', 3, 'Data Analysis with SQL', 'Data',        '2024-05-01', 78, 1,  59.99, 'Marta López'),
(3, 'Lucia Fernandes',   'lucia.fernandes@student.edutrack.com', 2, 'Web Design Basics',      'Design',      '2024-06-20',  5, 0, 39.99, 'Carlos Vega'),
(3, 'Lucia Fernandes',   'lucia.fernandes@student.edutrack.com', 4, 'Digital Marketing 101',  'Marketing',   '2024-07-01',  3, 0, 29.99, 'Lucia Prades'),
(4, 'Marco Rossi',       'marco.rossi@student.edutrack.com',    5, 'Advanced Python',        'Programming', '2024-02-14', 95, 1,  69.99, 'Carlos Vega'),
(4, 'Marco Rossi',       'marco.rossi@student.edutrack.com',    1, 'Intro to Python',        'Programming', '2024-08-09', 88, 1,  49.99, 'Marta López'),
(5, 'Yuki Nakamura',     'yuki.nakamura@student.edutrack.com',  3, 'Data Analysis with SQL', 'Data',        '2024-09-03', 45, 0, 59.99, 'Marta López'),
(5, 'Yuki Nakamura',     'yuki.nakamura@student.edutrack.com',  6, 'UI/UX Fundamentals',     'Design',      '2024-10-11',  0, 0, 44.99, NULL),
(6, 'Pierre Dubois',     'pierre.dubois@student.edutrack.com',   6, 'UI/UX Fundamentals',     'Design',      '2024-11-05',  0, 0, 44.99, NULL),
(7, 'Priya Sharma',      'priya.sharma@student.edutrack.com', 4, 'Digital Marketing 101',  'Marketing',   '2024-12-01', 70, 1,  29.99, 'Lucia Prades'),
(8, 'James Miller',      'james.miller@test.com',         1, 'Intro to Python',        'Programming', '2024-05-22', 30, 0, 49.99, 'Marta López'),
(9, 'Alex Chen',         'alex.chen@test.com',        2, 'Web Design Basics',      'Design',      '2024-06-30', 10, 0, 39.99, 'Carlos Vega'),
(7, 'Priya Sharma',      'priya.sharma@student.edutrack.com', 1, 'Intro to Python',        'Programming', '2025-01-10', 55, 0, 49.99, 'Marta López'),
(6, 'Pierre Dubois',     'pierre.dubois@student.edutrack.com',   3, 'Data Analysis with SQL', 'Data',        '2025-02-20', 20, 0, 59.99, 'Marta López'),
(1, 'Emily Watson',      'emily.watson@student.edutrack.com',    5, 'Advanced Python',        'Programming', '2025-03-05', 40, 0, 69.99, 'Carlos Vega');

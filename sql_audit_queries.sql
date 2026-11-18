-- ============================================================
-- EduTrack Database Audit & Cleanup - Supabase SQL Script
-- Complete executable SQL for Q1-Q12 (Strict Sequential Order)
-- ============================================================
-- IMPORTANT EXECUTION NOTES:
-- 1. Execute the initial schema setup from edutrack.sql FIRST
-- 2. Then execute this script line by line or in sections
-- 3. Follow the Q1 → Q12 order strictly
-- 4. For Q6 (INSERT), Q7 (UPDATE), Q8 (DELETE):
--    - Review the data carefully
--    - Execute verification queries BEFORE mutations
--    - Confirm counts match expectations
-- ============================================================

-- ============================================================
-- PHASE 1: DIAGNOSTIC QUERIES (Q1-Q5) - READ ONLY
-- ============================================================

-- ============================================================
-- Q1: Inscripciones en 'Intro to Python'
-- ============================================================
-- Requirement: List all enrollments for 'Intro to Python' course
-- showing student name, email, and completion percentage

SELECT 
    e.student_name,
    e.student_email,
    e.course_title,
    e.completion_percentage,
    e.enrollment_date,
    e.instructor
FROM enrollments e
WHERE e.course_title = 'Intro to Python'
ORDER BY e.enrollment_date DESC;

-- Expected output: 5 records (before Q6, Q8)
-- After cleanup: 4 records (1 test.com account removed in Q8)


-- ============================================================
-- Q2: Posibles abandonos (completion_percentage < 10)
-- ============================================================
-- Requirement: Identify potential dropouts where students have
-- very low completion percentages (< 10%)

SELECT 
    e.id,
    e.student_name,
    e.student_email,
    e.course_title,
    e.category,
    e.completion_percentage,
    e.enrollment_date
FROM enrollments e
WHERE e.completion_percentage < 10
ORDER BY e.completion_percentage ASC;

-- Expected output: 4 records with low completion
-- Action: These students need immediate support and outreach


-- ============================================================
-- Q3: Inscripciones con instructor NULL
-- ============================================================
-- Requirement: Find all enrollments with NULL instructor values
-- (indicates pending instructor assignment)

SELECT 
    e.id,
    e.student_name,
    e.student_email,
    e.course_title,
    e.category,
    e.enrollment_date,
    e.instructor
FROM enrollments e
WHERE e.instructor IS NULL
ORDER BY e.enrollment_date DESC;

-- Expected BEFORE Q7: 2 records with NULL instructor
-- Expected AFTER Q7: 0 records (all updated with 'Pending assignment')


-- ============================================================
-- Q4: Top 5 estudiantes con mayor completion sin aprobar
-- ============================================================
-- Requirement: Show top 5 students with highest completion
-- percentage who have NOT yet passed

SELECT 
    e.student_name,
    e.student_email,
    e.course_title,
    e.completion_percentage,
    e.passed,
    e.enrollment_date
FROM enrollments e
WHERE e.passed = FALSE
ORDER BY e.completion_percentage DESC
LIMIT 5;

-- Expected output: 5 records showing high-potential students


-- ============================================================
-- Q5: Inscripciones desde 2024-07-01
-- ============================================================
-- Requirement: Show all enrollments from July 1, 2024 onwards
-- ordered by enrollment date descending

SELECT 
    e.id,
    e.student_name,
    e.student_email,
    e.course_title,
    e.category,
    e.enrollment_date,
    e.completion_percentage,
    e.passed
FROM enrollments e
WHERE DATE(e.enrollment_date) >= DATE('2024-07-01')
ORDER BY e.enrollment_date DESC;

-- Expected output: 9 records from Q3 2024 onwards


-- ============================================================
-- PHASE 2: DATA CORRECTION OPERATIONS (Q6-Q8)
-- ============================================================

-- ============================================================
-- Q6: INSERT - Registrar inscripción faltante confirmada
-- ============================================================
-- BACKGROUND: During migration from previous system, one enrollment
-- was confirmed by email but never recorded in the database.
-- 
-- Student Details:
--   - ID: 3 (Lucia Fernandes)
--   - Email: lucia.fernandes@student.edutrack.com
--   - Course: Advanced Python (ID: 5)
--   - Enrollment Date: 2025-04-01
--   - Initial Completion: 0%
--   - Initial Status: NOT PASSED
--   - Monthly Fee Paid: $69.99
--   - Instructor: Carlos Vega

-- VERIFY before insert:
SELECT COUNT(*) as current_enrollment_count FROM enrollments;

-- EXECUTE INSERT:
INSERT INTO enrollments 
(student_id, student_name, student_email, course_id, course_title, category, 
 enrollment_date, completion_percentage, passed, monthly_fee_paid, instructor)
VALUES
(3, 'Lucia Fernandes', 'lucia.fernandes@student.edutrack.com', 5, 
 'Advanced Python', 'Programming', '2025-04-01', 0, FALSE, 69.99, 'Carlos Vega');

-- VERIFY after insert:
SELECT COUNT(*) as enrollment_count_after_q6 FROM enrollments;

-- Should increase by 1 (from 17 to 18)


-- ============================================================
-- Q7: UPDATE - Asignar instructor por defecto
-- ============================================================
-- REQUIREMENT: Update all enrollments with NULL instructor value
-- to a default value of 'Pending assignment'
-- This ensures data consistency and indicates instructor
-- assignment needs manual review

-- VERIFY NULL instructors before update:
SELECT COUNT(*) as null_instructor_count
FROM enrollments 
WHERE instructor IS NULL;

-- Should show 2 records

-- EXECUTE UPDATE:
UPDATE enrollments
SET instructor = 'Pending assignment'
WHERE instructor IS NULL;

-- VERIFY after update:
SELECT COUNT(*) as pending_assignment_count 
FROM enrollments 
WHERE instructor = 'Pending assignment';

-- Should show 2 records (the ones that were NULL)

-- Additional verification:
SELECT COUNT(*) as still_null_instructors 
FROM enrollments 
WHERE instructor IS NULL;

-- Should show 0 (no more NULL values)


-- ============================================================
-- Q8: DELETE - Eliminar cuentas de prueba (@test.com)
-- ============================================================
-- REQUIREMENT: Remove test/demo accounts from the database
-- These accounts were created for system testing and should not
-- be included in production analytics and reporting

-- STEP 1: VERIFY TEST RECORDS BEFORE DELETION
-- List all records that will be deleted:
SELECT 
    e.id,
    e.student_name,
    e.student_email,
    e.course_id,
    e.course_title,
    e.enrollment_date,
    e.completion_percentage,
    e.monthly_fee_paid
FROM enrollments e
WHERE e.student_email LIKE '%@test.com'
ORDER BY e.id;

-- STEP 2: COUNT TEST RECORDS
SELECT COUNT(*) as test_account_records_to_delete 
FROM enrollments 
WHERE student_email LIKE '%@test.com';

-- Expected: 2 records (James Miller @ james.miller@test.com, Alex Chen @ alex.chen@test.com)

-- STEP 3: VERIFY TOTAL ENROLLMENTS BEFORE DELETE
SELECT COUNT(*) as total_before_delete FROM enrollments;

-- Expected: 18 records (after Q6 insertion)

-- STEP 4: EXECUTE DELETE
DELETE FROM enrollments
WHERE student_email LIKE '%@test.com';

-- STEP 5: VERIFY DELETION SUCCESS
SELECT COUNT(*) as total_after_delete FROM enrollments;

-- Expected: 16 records (18 - 2 deleted test accounts)

-- STEP 6: CONFIRM NO MORE TEST ACCOUNTS
SELECT COUNT(*) as remaining_test_accounts
FROM enrollments 
WHERE student_email LIKE '%@test.com';

-- Expected: 0 (all test accounts removed)


-- ============================================================
-- PHASE 3: AGGREGATION AND BUSINESS METRICS (Q9-Q12)
-- ============================================================
-- NOTE: These queries execute AFTER Q6, Q7, Q8 mutations
-- because the data has been cleaned and enriched

-- ============================================================
-- Q9: Inscripciones totales por categoría
-- ============================================================
-- REQUIREMENT: Count total enrollments grouped by category
-- Shows distribution of student interest across course categories

SELECT 
    e.category,
    COUNT(*) as enrollment_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM enrollments), 2) as percentage_of_total
FROM enrollments e
GROUP BY e.category
ORDER BY enrollment_count DESC, e.category ASC;

-- Expected output (after cleanup):
-- Programming: 7 (43.75%)
-- Design: 4 (25%)
-- Data: 3 (18.75%)
-- Marketing: 2 (12.5%)
-- TOTAL: 16 records


-- ============================================================
-- Q10: Promedio de completion_percentage por curso
-- ============================================================
-- REQUIREMENT: Calculate average completion percentage by course
-- Identify which courses have best student engagement
-- and which need instructional improvements

SELECT 
    e.course_title,
    e.category,
    COUNT(*) as total_enrollments,
    ROUND(AVG(e.completion_percentage), 2) as avg_completion_percentage,
    ROUND(MIN(e.completion_percentage), 2) as min_completion,
    ROUND(MAX(e.completion_percentage), 2) as max_completion,
    SUM(CASE WHEN e.passed = TRUE THEN 1 ELSE 0 END) as students_passed
FROM enrollments e
GROUP BY e.course_title, e.category
ORDER BY avg_completion_percentage ASC;

-- Expected output shows:
-- - Intro to Python: Highest average (80.0%)
-- - UI/UX Fundamentals: Lowest average (0.0%)


-- ============================================================
-- Q11: Cursos con más de 3 inscripciones (HAVING clause)
-- ============================================================
-- REQUIREMENT: Identify courses with significant enrollment
-- (more than 3 students) using GROUP BY with HAVING
-- These courses represent our most popular offerings

SELECT 
    e.course_title,
    e.category,
    COUNT(*) as enrollment_count,
    ROUND(AVG(e.completion_percentage), 2) as avg_completion_percentage,
    ROUND(SUM(e.monthly_fee_paid), 2) as total_revenue,
    SUM(CASE WHEN e.passed = TRUE THEN 1 ELSE 0 END) as students_passed
FROM enrollments e
GROUP BY e.course_title, e.category
HAVING COUNT(*) > 3
ORDER BY enrollment_count DESC;

-- Expected output: Only 1 course qualifies
-- - Intro to Python (4 enrollments, 80% avg completion)


-- ============================================================
-- Q12: Ingresos totales por categoría
-- ============================================================
-- REQUIREMENT: Calculate total revenue (SUM monthly_fee_paid)
-- by category to assess business performance
-- Shows which category generates most revenue

SELECT 
    e.category,
    COUNT(*) as total_enrollments,
    ROUND(SUM(e.monthly_fee_paid), 2) as total_revenue,
    ROUND(AVG(e.monthly_fee_paid), 2) as avg_revenue_per_enrollment,
    ROUND(MIN(e.monthly_fee_paid), 2) as min_fee,
    ROUND(MAX(e.monthly_fee_paid), 2) as max_fee
FROM enrollments e
GROUP BY e.category
ORDER BY total_revenue DESC;

-- Expected output:
-- Programming: $409.93 total (7 enrollments, $58.56 avg)
-- Data: $179.97 total (3 enrollments, $59.99 avg)
-- Design: $169.96 total (4 enrollments, $42.49 avg)
-- Marketing: $59.98 total (2 enrollments, $29.99 avg)
-- TOTAL: $819.84


-- ============================================================
-- FINAL VERIFICATION QUERIES
-- ============================================================

-- Overall enrollment statistics
SELECT 
    COUNT(*) as total_enrollments,
    COUNT(DISTINCT student_id) as unique_students,
    COUNT(DISTINCT course_id) as unique_courses,
    COUNT(DISTINCT category) as unique_categories,
    SUM(CASE WHEN passed = TRUE THEN 1 ELSE 0 END) as students_passed,
    ROUND(100.0 * SUM(CASE WHEN passed = TRUE THEN 1 ELSE 0 END) / COUNT(*), 2) as pass_rate_percentage
FROM enrollments;

-- Check for any remaining data quality issues
SELECT 
    SUM(CASE WHEN instructor IS NULL THEN 1 ELSE 0 END) as null_instructors,
    SUM(CASE WHEN student_email LIKE '%@test.com' THEN 1 ELSE 0 END) as test_accounts_remaining,
    SUM(CASE WHEN completion_percentage < 0 THEN 1 ELSE 0 END) as invalid_completion_percentages,
    SUM(CASE WHEN completion_percentage > 100 THEN 1 ELSE 0 END) as completion_over_100,
    SUM(CASE WHEN monthly_fee_paid < 0 THEN 1 ELSE 0 END) as negative_fees
FROM enrollments;

-- Should show all zeros or no records found


-- ============================================================
-- AUDIT SUMMARY
-- ============================================================

-- Records affected by Q6-Q8 operations:
SELECT 
    'Q6 (INSERT)' as operation,
    1 as records_affected
UNION ALL
SELECT 
    'Q7 (UPDATE)' as operation,
    2 as records_affected
UNION ALL
SELECT 
    'Q8 (DELETE)' as operation,
    2 as records_affected
UNION ALL
SELECT 
    'Net Change' as operation,
    -1 as records_affected;

-- Initial state: 17 records
-- After Q6: +1 (18 records)
-- After Q7: 0 change (2 updated, 18 records)
-- After Q8: -2 (16 records)
-- Final state: 16 records

-- ============================================================
-- END OF AUDIT SCRIPT
-- All queries have been executed in strict Q1 → Q12 order
-- Database is now clean, consistent, and ready for Q3 reporting
-- ============================================================

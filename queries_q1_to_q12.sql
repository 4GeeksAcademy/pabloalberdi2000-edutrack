-- ============================================================
-- QUERIES EXECUTION LOG - EduTrack Database Audit & Cleanup
-- Q1 through Q12 - Strict Sequential Execution
-- ============================================================

-- ============================================================
-- Q1: Inscripciones en 'Intro to Python'
-- Listar todas las inscripciones del curso 'Intro to Python', 
-- mostrando nombre del estudiante, email y porcentaje completado
-- ============================================================
SELECT 
    e.student_name,
    e.student_email,
    e.course_title,
    e.completion_percentage,
    e.enrollment_date
FROM enrollments e
WHERE e.course_title = 'Intro to Python'
ORDER BY e.enrollment_date DESC;

-- ============================================================
-- Q2: Posibles abandonos (completion_percentage < 10)
-- Obtener todas las inscripciones donde completion_percentage 
-- sea menor que 10
-- ============================================================
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

-- ============================================================
-- Q3: Inscripciones con instructor NULL
-- Encontrar todas las inscripciones donde el campo instructor 
-- sea NULL
-- ============================================================
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

-- ============================================================
-- Q4: Top 5 estudiantes con mayor completion_percentage 
-- sin aprobar (passed = false)
-- ============================================================
SELECT 
    e.student_name,
    e.student_email,
    e.course_title,
    e.completion_percentage,
    e.passed
FROM enrollments e
WHERE e.passed = 0
ORDER BY e.completion_percentage DESC
LIMIT 5;

-- ============================================================
-- Q5: Inscripciones desde 2024-07-01
-- Mostrar todas las inscripciones con enrollment_date desde 
-- '2024-07-01', ordenadas por enrollment_date descendente
-- ============================================================
SELECT 
    e.id,
    e.student_name,
    e.student_email,
    e.course_title,
    e.category,
    e.enrollment_date,
    e.completion_percentage
FROM enrollments e
WHERE DATE(e.enrollment_date) >= DATE('2024-07-01')
ORDER BY e.enrollment_date DESC;

-- ============================================================
-- Q6: INSERT - Registrar inscripción faltante confirmada
-- Insertar el registro de inscripción faltante:
-- - student_id: 3 (Lucia Fernandes)
-- - course_id: 5 (Advanced Python)
-- - enrollment_date: 2025-04-01
-- - completion_percentage: 0
-- - passed: false
-- - monthly_fee_paid: 69.99
-- - instructor: Carlos Vega
-- ============================================================
INSERT INTO enrollments 
(student_id, student_name, student_email, course_id, course_title, category, enrollment_date, completion_percentage, passed, monthly_fee_paid, instructor)
VALUES
(3, 'Lucia Fernandes', 'lucia.fernandes@student.edutrack.com', 5, 'Advanced Python', 'Programming', '2025-04-01', 0, 0, 69.99, 'Carlos Vega');

-- Verify Q6 insertion
SELECT 'Q6 Verification: Inserted record' as msg;
SELECT COUNT(*) as total_enrollments FROM enrollments;

-- ============================================================
-- Q7: UPDATE - Asignar instructor por defecto
-- Actualizar todas las inscripciones donde instructor sea NULL, 
-- asignando el valor 'Pending assignment'
-- ============================================================
UPDATE enrollments
SET instructor = 'Pending assignment'
WHERE instructor IS NULL;

-- Verify Q7 update
SELECT 'Q7 Verification: Updated NULL instructors' as msg;
SELECT COUNT(*) as records_with_pending_assignment 
FROM enrollments 
WHERE instructor = 'Pending assignment';

-- ============================================================
-- Q8: DELETE - Eliminar cuentas de prueba (@test.com)
-- Verificación previa: SELECT de registros a eliminar
-- ============================================================
SELECT 'Q8 Verification - BEFORE DELETE: Test accounts to remove' as msg;
SELECT 
    e.id,
    e.student_name,
    e.student_email,
    e.course_title,
    e.enrollment_date
FROM enrollments e
WHERE e.student_email LIKE '%@test.com'
ORDER BY e.id;

-- Count of records to be deleted
SELECT COUNT(*) as test_records_to_delete 
FROM enrollments 
WHERE student_email LIKE '%@test.com';

-- Execute DELETE
DELETE FROM enrollments
WHERE student_email LIKE '%@test.com';

-- Verify Q8 deletion
SELECT 'Q8 Verification - AFTER DELETE: Remaining enrollments' as msg;
SELECT COUNT(*) as total_enrollments_after_cleanup FROM enrollments;

-- ============================================================
-- Q9: Contar inscripciones por categoría
-- Contar el número total de inscripciones agrupado por category
-- ============================================================
SELECT 
    e.category,
    COUNT(*) as enrollment_count
FROM enrollments e
GROUP BY e.category
ORDER BY e.category ASC;

-- ============================================================
-- Q10: Promedio de completion_percentage por curso
-- Calcular el promedio de completion_percentage agrupado por 
-- course_title, ordenado de menor a mayor
-- ============================================================
SELECT 
    e.course_title,
    COUNT(*) as total_enrollments,
    ROUND(AVG(e.completion_percentage), 2) as avg_completion_percentage
FROM enrollments e
GROUP BY e.course_title
ORDER BY avg_completion_percentage ASC;

-- ============================================================
-- Q11: Cursos con más de 3 inscripciones (HAVING clause)
-- Mostrar únicamente los cursos que cuenten con más de 3 
-- inscripciones empleando la cláusula HAVING
-- ============================================================
SELECT 
    e.course_title,
    e.category,
    COUNT(*) as enrollment_count,
    ROUND(AVG(e.completion_percentage), 2) as avg_completion
FROM enrollments e
GROUP BY e.course_title, e.category
HAVING COUNT(*) > 3
ORDER BY enrollment_count DESC;

-- ============================================================
-- Q12: Ingresos totales por categoría
-- Calcular los ingresos totales (SUM de monthly_fee_paid) 
-- agrupados por category, ordenados de mayor a menor
-- ============================================================
SELECT 
    e.category,
    COUNT(*) as total_enrollments,
    ROUND(SUM(e.monthly_fee_paid), 2) as total_revenue,
    ROUND(AVG(e.monthly_fee_paid), 2) as avg_fee_per_enrollment
FROM enrollments e
GROUP BY e.category
ORDER BY total_revenue DESC;

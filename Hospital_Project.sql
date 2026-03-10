-- Hospital Data Analysis Project
-- This project focuses on analyzing hospital operational data using SQL to extract meaningful insights related to patient trends, departmental performance, and healthcare expenses. The analysis demonstrates practical database management and data analytics skills using real-world structured data.

--Database Creation
-- The first step in this project involves creating a dedicated database environment to store and manage hospital-related data efficiently. Establishing a structured database ensures that the dataset can be organized, queried, and analyzed systematically for further insights.

CREATE DATABASE hospital;

-- Table Creation – Hospital Data Structure
-- After establishing the database, the next step is to design a structured table to store hospital operational data. The Hospital table captures essential information related to hospital facilities, patient admissions, medical departments, and healthcare expenses.

DROP TABLE IF EXISTS Hospital;

CREATE TABLE Hospital(
	Hospital_Name VARCHAR(50) NOT NULL,
	Location VARCHAR(50),
	Department VARCHAR(50),
	Doctors_Count INT,
	Patients_Count INT,
	Admission_Date TEXT, -- Due to error, we keep the Admission_Date column as text, later convert to DATE type.
	Discharge_Date TEXT, -- Due to error, we keep the Discharge_Date column as text, later convert to DATE type.
	Medical_Expenses NUMERIC(10,2)
);

-- The table includes the following key attributes:

SELECT * FROM Hospital;

-- Data Import from CSV
-- After defining the table structure, the hospital dataset was imported from a CSV file into the database.

COPY
	Hospital (Hospital_Name, Location, Department, Doctors_Count, Patients_Count, Admission_Date, Discharge_Date, Medical_Expenses)
FROM 'C:\Users\PMYLS\Documents\data_science\sql\04_sql_ultimate_chellange\project_hospital\Hospital_Data.csv'
	DELIMITER ','
CSV HEADER;

-- Converting Admission_Date to DATE Format
-- To ensure accurate time-based analysis, the Admission_Date field was converted from text to a proper DATE data type.

ALTER TABLE Hospital
	ALTER COLUMN Admission_Date
TYPE DATE
	USING TO_DATE(Admission_Date, 'DD-MM-YYYY');

-- Converting Discharge_Date to DATE Format
-- To ensure accurate time-based analysis, the Discharge_Date field was converted from text to a proper DATE data type.

ALTER TABLE Hospital
	ALTER COLUMN Discharge_Date
TYPE DATE
	USING TO_DATE(Discharge_Date, 'DD-MM-YYYY');


-- 1. Total Number of Patients Across All Hospitals
-- This query calculates the total number of patients treated across all hospitals in the dataset.

SELECT 
    SUM(patients_count) AS total_patients
FROM Hospital;


-- 2. Average Number of Doctors per Hospital 
-- This analysis determines the average number of doctors available in each hospital.

SELECT
    hospital_name,
    AVG(Doctors_Count) AS Average_Doctors
FROM Hospital
GROUP BY Hospital_Name;

-- 2.1 Retrieve both overall average and per-hospital average within a single query using GROUPING and ROLLUP.

SELECT
    COALESCE(hospital_name, 'ALL HOSPITALS') AS hospital_name,
    AVG(doctors_count) AS average_doctors
FROM Hospital
GROUP BY ROLLUP (hospital_name);

-- 2.2 Sort the results to ensure that the “ALL HOSPITALS” summary row consistently appears at the end of the output.

SELECT
    COALESCE(hospital_name, 'ALL HOSPITALS') AS hospital_name,
    AVG(doctors_count) AS average_doctors
FROM Hospital
GROUP BY ROLLUP (hospital_name) -- Provides one summary row for all hospitals.
ORDER BY
    -- Put NULL (ALL HOSPITALS) last
    CASE WHEN hospital_name IS NULL THEN 1 ELSE 0 END,  -- Gives 1 to the "ALL HOSPITALS" row and 0 to the others.
    hospital_name;

-- 2.3 Present the number of departments per hospital alongside the average number of doctors for comparative analysis.

SELECT
    COALESCE(hospital_name, 'ALL HOSPITALS') AS hospital_name,
    COUNT(DISTINCT department) AS department_count,
    AVG(doctors_count) AS average_doctors
FROM Hospital
GROUP BY ROLLUP (hospital_name)
ORDER BY
    CASE WHEN hospital_name IS NULL THEN 1 ELSE 0 END,
    hospital_name;

-- 2.4 Extend the existing query to include the total number of patients treated per hospital.

SELECT
    COALESCE(hospital_name, 'ALL HOSPITALS') AS hospital_name,
    COUNT(DISTINCT department) AS department_count,
    AVG(doctors_count) AS average_doctors,
    SUM(patients_count) AS total_patients
FROM Hospital
GROUP BY ROLLUP (hospital_name)
ORDER BY
    CASE WHEN hospital_name IS NULL THEN 1 ELSE 0 END,
    hospital_name;

-- 2.5 Calculate and disclose the average medical expenses per patient for each hospital as well as the overall dataset.

SELECT
    COALESCE(hospital_name, 'ALL HOSPITALS') AS hospital_name,
    COUNT(DISTINCT department) AS department_count,
    AVG(doctors_count) AS average_doctors,
    SUM(patients_count) AS total_patients,
    SUM(medical_expenses) AS total_expenses,
    ROUND(SUM(medical_expenses) / NULLIF(SUM(patients_count), 0), 2) 
        AS avg_expense_per_patient
FROM Hospital
GROUP BY ROLLUP (hospital_name)
ORDER BY
    CASE WHEN hospital_name IS NULL THEN 1 ELSE 0 END,
    hospital_name;


-- 3. Identifying High-Demand Hospital Departments
-- This query analyzes patient distribution across hospital departments and identifies the top three departments with the highest patient volume. 

SELECT
    department,
    SUM(Patients_Count) AS Total_Patients
FROM Hospital
GROUP BY Department
ORDER BY Total_Patients DESC
LIMIT 3;


-- 4. Hospital with the Maximum Medical Expenses 
-- This analysis determines which hospital recorded the highest total medical expenses.

SELECT
    Hospital_Name,
    SUM(Medical_Expenses) AS total_expenses
FROM Hospital
GROUP BY Hospital_Name
ORDER BY total_expenses DESC
LIMIT 3;

-- 4.1 Hospital with Highest Expense per Patient

SELECT
    hospital_name,
    SUM(medical_expenses) AS total_expenses,
    SUM(patients_count) AS total_patients,
    ROUND(SUM(medical_expenses) / NULLIF(SUM(patients_count), 0), 2) AS expense_per_patient
FROM Hospital
GROUP BY hospital_name
ORDER BY expense_per_patient DESC
LIMIT 3;


-- 5. Daily Average Medical Expenses per Hospital
-- This query calculates the average daily medical expenses incurred by each hospital based on the duration of patient stays.


SELECT
    hospital_name,
    ROUND(SUM(medical_expenses) / NULLIF(SUM(discharge_date - admission_date + 1), 0), 2)
        AS avg_expenses_per_day
FROM Hospital
GROUP BY hospital_name
ORDER BY avg_expenses_per_day DESC;

-- 5.1 Calculate daily average per patient (How much was spent per patient per day per hospital)

SELECT
    hospital_name,
    ROUND(
        SUM(medical_expenses) 
        / NULLIF(SUM(patients_count * (discharge_date - admission_date + 1)), 0), 
        2
    ) AS avg_expense_per_patient_per_day
FROM Hospital
GROUP BY hospital_name
ORDER BY avg_expense_per_patient_per_day DESC;


-- 6. Longest Hospital Stay
-- This query identifies the patient case with the longest hospitalization period by calculating the difference between admission and discharge dates.

SELECT
    hospital_name, department,
    admission_date, discharge_date,
    (discharge_date - admission_date + 1) AS stay_length_days
FROM Hospital
ORDER BY stay_length_days DESC
LIMIT 3;

-- 6.1 Find the hospital with the highest average stay length

SELECT
    hospital_name,
    ROUND(AVG(discharge_date - admission_date + 1), 2) AS avg_stay_length
FROM Hospital
GROUP BY hospital_name
ORDER BY avg_stay_length DESC
LIMIT 3;


-- 7. Total Patients Treated Per City 
-- This analysis aggregates patient counts by location to determine how many patients were treated in each city.

SELECT
    location AS city,
    SUM(patients_count) AS total_patients
FROM Hospital
GROUP BY location
ORDER BY total_patients DESC;


-- 7.1 Analyze patient distribution per city and per hospital to identify which hospitals contribute the most to each city's total patient count.

SELECT
    location AS city,
    hospital_name,
    SUM(patients_count) AS total_patients
FROM Hospital
GROUP BY location, hospital_name
ORDER BY city, total_patients DESC;

-- 7.2 Extend the analysis by incorporating city-level totals using ROLLUP, enabling a summarized view of patient counts across locations.

SELECT
    COALESCE(location, 'ALL CITIES') AS city,
    COALESCE(hospital_name, 'TOTAL (City Level)') AS hospital_name,
    SUM(patients_count) AS total_patients
FROM Hospital
GROUP BY ROLLUP (location, hospital_name)
ORDER BY
    city,
    CASE WHEN hospital_name IS NULL THEN 1 ELSE 0 END,
    total_patients DESC;

-- 7.3 Enhance the query to include total medical expenses per city, allowing both patient volume and healthcare spending to be analyzed side by side.

SELECT
    COALESCE(location, 'ALL CITIES') AS city,
    COALESCE(hospital_name, 'TOTAL (City Level)') AS hospital_name,
    SUM(patients_count) AS total_patients,
    ROUND(SUM(medical_expenses), 2) AS total_expenses
FROM Hospital
GROUP BY ROLLUP (location, hospital_name)
ORDER BY
    city,
    CASE WHEN hospital_name IS NULL THEN 1 ELSE 0 END,
    total_patients DESC;

-- 8. Average Length of Stay Per Department 
-- This query calculates the average number of days patients spend in each hospital department.

SELECT
    department,
    ROUND(AVG(discharge_date - admission_date + 1), 2) AS avg_stay_days
FROM Hospital
GROUP BY department
ORDER BY avg_stay_days DESC;

-- 8.1 Calculate the average length of patient stay per department for each hospital, enabling comparison of operational efficiency across hospitals within the same medical specialty.

SELECT
    hospital_name,
    department,
    ROUND(AVG(discharge_date - admission_date + 1), 2) AS avg_stay_days
FROM Hospital
GROUP BY hospital_name, department
ORDER BY hospital_name, avg_stay_days DESC;

-- 8.2 Extend the analysis by presenting the average medical expenses per day alongside the average stay duration, allowing evaluation of cost efficiency per department and hospital.

SELECT
    hospital_name,
    department,
    ROUND(AVG(discharge_date - admission_date + 1), 2) AS avg_stay_days,
    ROUND(AVG(medical_expenses / NULLIF(discharge_date - admission_date + 1, 0)), 2) AS avg_expense_per_day
FROM Hospital
GROUP BY hospital_name, department
ORDER BY hospital_name, avg_stay_days DESC;


-- 8.3 Incorporate city-level averages to facilitate meaningful comparisons between hospitals operating within the same geographic location.

SELECT
    location AS city,
    hospital_name,
    department,
    ROUND(AVG(discharge_date - admission_date + 1), 2) AS avg_stay_days,
    ROUND(AVG(medical_expenses / NULLIF(discharge_date - admission_date + 1, 0)), 2) AS avg_expense_per_day
FROM Hospital
GROUP BY location, hospital_name, department
ORDER BY city, hospital_name, avg_stay_days DESC;



-- 9. Department with the Lowest Number of Patients 
-- This query identifies the department with the lowest patient volume.


SELECT Department,
	SUM(patients_count) as Total_patients
FROM Hospital
GROUP BY Department
ORDER BY Total_patients ASC;

-- 9.1 Identify both the highest and lowest performing departments in terms of patient volume within a single query, enabling simultaneous comparison of departments with the most and least patient demand.

(
    SELECT
        department,
        SUM(patients_count) AS total_patients,
        'Lowest' AS category
    FROM Hospital
    GROUP BY department
    ORDER BY total_patients ASC
    LIMIT 3
)
UNION ALL
(
    SELECT
        department,
        SUM(patients_count) AS total_patients,
        'Highest' AS category
    FROM Hospital
    GROUP BY department
    ORDER BY total_patients DESC
    LIMIT 3
);


-- 10. Monthly Medical Expenses Report
-- This query groups the data by month and calculates the total medical expenses incurred during each month.

SELECT
    TO_CHAR(admission_date, 'Month YYYY') AS month_name, -- TO_CHAR(admission_date, 'YYYY-MM') AS month,
    ROUND(SUM(medical_expenses), 2) AS total_expenses
FROM Hospital
GROUP BY TO_CHAR(admission_date, 'Month YYYY')
ORDER BY MIN(admission_date);

-- 10.1 Extend the monthly expense report to include the number of patients treated each month, allowing calculation of the average medical expense per patient on a monthly basis.

SELECT
    TO_CHAR(admission_date, 'YYYY-MM') AS month,
    SUM(patients_count) AS total_patients,
    ROUND(SUM(medical_expenses), 2) AS total_expenses,
    ROUND(SUM(medical_expenses) / NULLIF(SUM(patients_count), 0), 2) AS avg_expense_per_patient
FROM Hospital
GROUP BY TO_CHAR(admission_date, 'YYYY-MM')
ORDER BY month;


-- 10.2 Enhance the analysis by incorporating month-over-month percentage change (growth rate) for both medical expenses and patient volume, providing insight into monthly performance trends and fluctuations.

WITH monthly_data AS (
    SELECT
        TO_CHAR(admission_date, 'YYYY-MM') AS month,
        SUM(patients_count) AS total_patients,
        ROUND(SUM(medical_expenses), 2) AS total_expenses
    FROM Hospital
    GROUP BY TO_CHAR(admission_date, 'YYYY-MM')
)
SELECT
    month,
    total_patients,
    total_expenses,
    ROUND(total_expenses / NULLIF(total_patients, 0), 2) AS avg_expense_per_patient,
    ROUND(
        (total_patients - LAG(total_patients) OVER (ORDER BY month)) 
        * 100.0 / NULLIF(LAG(total_patients) OVER (ORDER BY month), 0), 2
    ) AS patients_mom_change_pct,
    ROUND(
        (total_expenses - LAG(total_expenses) OVER (ORDER BY month)) 
        * 100.0 / NULLIF(LAG(total_expenses) OVER (ORDER BY month), 0), 2
    ) AS expenses_mom_change_pct
FROM monthly_data
ORDER BY month;

-- The SQL analysis highlights patterns in healthcare demand, departmental workload, patient stay durations, and hospital expenses. These insights demonstrate how structured data analysis can support data-driven decision-making in healthcare management.
-- ⭐ If you find this project useful, feel free to give it a star and share your feedback. Your insights are always appreciated.
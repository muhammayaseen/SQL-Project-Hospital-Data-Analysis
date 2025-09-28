-- Hospital Project
-- Create Database for Hospital Project

CREATE DATABASE hospital;

-- Create table Hospital

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

-- Have a look columns of the table

SELECT * FROM Hospital;

-- Upload data from csv file

COPY
	Hospital (Hospital_Name, Location, Department, Doctors_Count, Patients_Count, Admission_Date, Discharge_Date, Medical_Expenses)
FROM 'C:\Users\PMYLS\Documents\data_science\sql\04_sql_ultimate_chellange\project_hospital\Hospital_Data.csv'
	DELIMITER ','
CSV HEADER;

-- Converting Admission_Date to DATE TYPE

ALTER TABLE Hospital
	ALTER COLUMN Admission_Date
TYPE DATE
	USING TO_DATE(Admission_Date, 'DD-MM-YYYY');

-- Converting Discharge_Date to DATE TYPE

ALTER TABLE Hospital
	ALTER COLUMN Discharge_Date
TYPE DATE
	USING TO_DATE(Discharge_Date, 'DD-MM-YYYY');


-- 1. Total Number of Patients 
-- Write an SQL query to find the total number of patients across all hospitals.

SELECT 
    SUM(patients_count) AS total_patients
FROM Hospital;


-- 2. Average Number of Doctors per Hospital 
-- Retrieve the average count of doctors available in each hospital.


SELECT
    hospital_name,
    AVG(Doctors_Count) AS Average_Doctors
FROM Hospital
GROUP BY Hospital_Name;


-- 3. Top 3 Departments with the Highest Number of Patients 
-- Find the top 3 hospital departments that have the highest number of patients.


SELECT
    department,
    SUM(Patients_Count) AS Total_Patients
FROM Hospital
GROUP BY Department
ORDER BY Total_Patients DESC
LIMIT 3;


-- 4. Hospital with the Maximum Medical Expenses 
-- Identify the hospital that recorded the highest medical expenses.


SELECT
    Hospital_Name,
    SUM(Medical_Expenses) AS total_expenses
FROM Hospital
GROUP BY Hospital_Name
ORDER BY total_expenses DESC
LIMIT 1;


-- 5. Daily Average Medical Expenses 
-- Calculate the average medical expenses per day for each hospital.


SELECT
    hospital_name,
    ROUND(SUM(medical_expenses) / NULLIF(SUM(discharge_date - admission_date + 1), 0), 2)
        AS avg_expenses_per_day
FROM Hospital
GROUP BY hospital_name
ORDER BY avg_expenses_per_day DESC;


-- 6. Longest Hospital Stay 
-- Find the patient with the longest stay by calculating the difference between Discharge Date and Admission Date.


SELECT
    hospital_name,
    department,
    admission_date,
    discharge_date,
    (discharge_date - admission_date + 1) AS stay_length_days
FROM Hospital
ORDER BY stay_length_days DESC
LIMIT 1;


-- 7. Total Patients Treated Per City 
-- Count the total number of patients treated in each city.


SELECT
    location AS city,
    SUM(patients_count) AS total_patients
FROM Hospital
GROUP BY location
ORDER BY total_patients DESC;


-- 8. Average Length of Stay Per Department 
-- Calculate the average number of days patients spend in each department.


SELECT
    department,
    ROUND(AVG(discharge_date - admission_date + 1), 2) AS avg_stay_days
FROM Hospital
GROUP BY department
ORDER BY avg_stay_days DESC;


-- 9. Identify the Department with the Lowest Number of Patients 
-- Find the department with the least number of patients.


SELECT Department,
	SUM(patients_count) as Total_patients
FROM Hospital
GROUP BY Department
ORDER BY Total_patients ASC;

-- 10. Monthly Medical Expenses Report
-- Group the data by month and calculate the total medical expenses for each month.


SELECT
    TO_CHAR(admission_date, 'Month YYYY') AS month_name, -- TO_CHAR(admission_date, 'YYYY-MM') AS month,
    ROUND(SUM(medical_expenses), 2) AS total_expenses
FROM Hospital
GROUP BY TO_CHAR(admission_date, 'Month YYYY')
ORDER BY MIN(admission_date);
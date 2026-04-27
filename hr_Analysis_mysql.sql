CREATE DATABASE IF NOT EXISTS HR_MYSQL;
USE HR_MYSQL;

CREATE TABLE departments (
    dept_id   VARCHAR(5),
    dept_name VARCHAR(50)
);

CREATE TABLE employees (
    employee_id        VARCHAR(10),
    name               VARCHAR(100),
    age                INT,
    gender             VARCHAR(10),
    salary             DECIMAL(10,2),
    dept_id            VARCHAR(5),
    performance_rating INT,
    attrition          VARCHAR(5),
    years_at_company   INT,
    hire_date          DATE
);
select * from departments;
select * from employees;

#Shoe data count
select count(*) from employees;
select count(*) from departments;

#View the first 10 rows of the employees table
select * from employees limit 10;

-- Q2. View all records from the departments table
select * from departments limit 10;

-- Q3. How many total employees are in the company?
select count(employee_id) from employees;

-- Q4. How many unique departments exist in the employees table?
select count(distinct dept_id) from employees;

-- Q5. What are the distinct gender values in the dataset?
Select count(distinct attrition) from employees;
-- Q6. What are the distinct performance rating values?
select distinct(performance_rating) from employees order by performance_rating;

-- Q7. What are the distinct attrition values?
select distinct(attrition) from employees;

-- Q8. How many employees are in each department? (use dept_id)
select dept_id,count(employee_id) Total_EMP from employees
group by dept_id
order by dept_id asc;

-- Q9. What is the gender distribution — how many male vs female?
select gender,count(employee_id) Total_Emp_Count from employees
group by gender 
order by Total_Emp_Count ;
 
-- Q10. What is the youngest and oldest age in the company?
select min(age) as Youngest_EMP, MAX(AGE) AS Oldest_EMP from employees;


##PHASE 2 — DATA QUALITY CHECK
##Goal: Find dirty, missing or incorrect data before analysis

-- Q11. How many employees have NULL salary?
select count(employee_id) from employees where salary is null;

-- Q12. How many employees have NULL dept_id?
select count(employee_id) from employees where dept_id is null;

-- Q13. How many employees have NULL performance_rating?
select count(employee_id) from employees where Performance_rating is null;

-- Q14. Check for duplicate employee_id — are there any repeated IDs?
select count(employee_id) from employees;
select count(distinct employee_id) from employees;

-- Q15. Show all employees where salary is NULL
select employee_id,name from employees where salary is null;

-- Q16. How many employees have salary = 0 (invalid value)?
select employee_id,name from employees where salary=0;

-- Q17. Show count of employees per performance rating 
select Performance_rating,count(employee_id) as Total_EMP from employees
group by Performance_rating
order by TOtal_EMP;

##PHASE 3 — DATA CLEANING
##Goal: Fix dirty data so analysis is accurate
-- Step 1: Change column type to accept text temporarily
ALTER TABLE employees MODIFY salary VARCHAR(20);


-- Q18. Replace all empty salary strings with NULL
update employees set salary=null where salary='';

-- Step 3: Convert back to proper number column
ALTER TABLE employees MODIFY salary DECIMAL(10,2);

-- Q19. After cleaning, confirm how many NULL salaries exist now
SELECT COUNT(*) AS null_salary FROM employees WHERE salary IS NULL;
-- Q20. Verify total row count is still 10000 after cleaning
SELECT COUNT(*) FROM employees;

##PHASE 4 — WORKFORCE OVERVIEW (Descriptive Analysis)
##Goal: Give leadership a snapshot of the current workforce
-- Q21. Total headcount of the company
select count(*) as Total_Headcount from employees;

-- Q22. Gender split across the organization
select count(*), Gender from employees
group by gender;

-- Q23. Average age of the workforce
select avg(age) as Avg_Age from employees;
-- Q24. How many employees are in each department? 
select count(*) as Count_Of_EMP, Dept_id from employees 
group by dept_id;

-- Show department NAME not ID (use JOIN)
Select d.dept_name,e.* from employees as e inner join departments d
on e.dept_id=d.dept_id;

-- Q25. What is the average years at company across all employees?
select avg(years_at_company) from employees;

-- Q26. Which department has the highest number of employees?
select dept_id,count(employee_id) as Total_EMP from employees
group by dept_id
order by Total_EMP desc limit 1;

-- Q27. How many employees have been at the company more than 10 years?
SELECT COUNT(*) AS employees_more_than_10_years
FROM employees
WHERE years_at_company > 10;

##PHASE 5 — SALARY & COMPENSATION ANALYSIS
##Goal: Understand pay structure and identify compensation gaps

-- Q28. What is the overall average, minimum and maximum salary?
select max(salary) as Highest_Salary,min(salary) as Lowest_salary,avg(salary) as AVG_Salary
from employees;

-- Q29. What is the average salary per department? 
-- Show department name, order highest to lowest
select d.dept_name,avg(e.salary) as AVG_SALARY from employees e join departments d
on e.dept_id=d.dept_id 
group by d.dept_name
order by AVG_SALARY DESC;

-- Q30. What is the total salary expense per department?
SELECT D.Dept_name,sum(e.salary) as Total_Salary_Exp from employees e join departments d
on e.dept_id=d.dept_id
group by D.Dept_name 
order by Total_Salary_Exp desc;

-- Q31. Is there a gender pay gap? Compare average salary of male vs female employees
select gender,avg(salary) from employees
group by gender ;
-- Q32. What is the average salary per performance rating?
-- (Do higher rated employees earn more?)
select Performance_rating,avg(salary) as AVG_SALARY from employees
group by Performance_rating
order by AVG_SALARY;
-- Q33. Show only departments where average salary is above 70000
--      (use HAVING)
SELECT dept_id,avg(salary) as AVG_SALARY from employees
group by dept_id
having AVG_SALARY>70000;
-- Q34. How many employees earn above the overall company average salary?
SELECT *
FROM (
    SELECT 
        employee_id,
        name,
        salary,
        AVG(salary) OVER () AS avg_salary
    FROM employees
) t
WHERE salary > avg_salary;

select * from(
select employee_id,name,salary,avg(salary) over() as AVG_SALARY from employees) T
where salary>AVG_SALARY;


-- Q35. Show all employees who earn above their own department average
--      Show name, dept_id, salary (use subquery)


select * from
(select name,dept_id,salary,avg(salary) over(partition by dept_id) as dept_avg
from employees) t
where salary>dept_avg;

#PHASE 6 — ATTRITION ANALYSIS (Diagnostic Analysis)
#Goal: Find who is leaving and why

-- Q36. What is the overall attrition rate of the company? (in %)
select 
sum(case when Attrition='Yes' then 1 else 0 end)*100/count(*) as Attrition_Rate
from employees;

-- Q37. How many employees left vs stayed?
select Attrition,count(employee_id) from employees
group by Attrition;
-- Q38. Which department has the highest attrition count?--      Show department name (use JOIN)
select d.dept_name,Count(e.Attrition) as Attrition_Count from employees e
join departments d on e.dept_id=d.dept_id
group by d.dept_name
order by Attrition_Count desc
limit 1;

-- Q39. What is the attrition RATE (%) per department?
--      Show dept name, total emp, left count, attrition %
--      Order by attrition % highest to lowest

select d.dept_name,count(*) AS Total_Employees,
sum(case when attrition='yes' then 1 else 0 end) As Attrition_Count,
ROUND(SUM(CASE WHEN e.attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) As Attrition_Rate
from employees e inner join departments d
on e.dept_id=d.dept_id
group by d.dept_name
ORDER BY attrition_rate DESC;

-- Q40. Is there a gender difference in attrition?
--      Show attrition count and % for male vs female

SELECT 
    gender,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS attrition_count,
    ROUND(
        SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*),2) AS attrition_rate
FROM employees
GROUP BY gender;

-- Q41. Which age group has the highest attrition?
--      Create bands: Below 25 / 25-35 / 36-45 / Above 45
--      Use CASE WHEN

SELECT 
Name,Age,
CASE 
	WHEN AGE < 25 THEN 'Below 25'
    when Age between 25 and 35 then '25-35'
    when Age between 36 and 45 then '36-45'
    else 'Above 45'
end as Age_Group
from employees;

select
CASE 
	WHEN AGE < 25 THEN 'Below 25'
    when Age between 25 and 35 then '25-35'
    when Age between 36 and 45 then '36-45'
    else 'Above 45'
end as Age_Group,
count(*) As Total_Employees,
sum(case when Attrition='Yes' then 1 else 0 end) as Attrition_Count,
Round(sum(case when Attrition='Yes' then 1 else 0 end)*100/count(*),2) AS Attrition_Rate 
from employees
Group by Age_Group
order by Attrition_Rate desc;

-- Q42. Do employees who leave earn less than those who stay?
--      Compare average salary of attrition=Yes vs attrition=No
SELECT 
    Attrition,
    COUNT(*) AS total_employees,
    AVG(salary) AS avg_salary
FROM employees
GROUP BY Attrition;

-- Q43. Which performance rating group has the highest attrition?
--      Show rating, total count, attrition count, attrition %
select performance_rating,count(*),
sum(case when attrition='yes' then 1 else 0 end) as Attrition_Count,
round(sum(case when Attrition='Yes' then 1 else 0 end)*100/count(*)) as Attrition_Rate
from employees
group by performance_rating
order by Attrition_Count desc;

-- Q44. Do short tenure employees leave more?
--      Compare average years_at_company for attrition Yes vs No
SELECT 
    Attrition,
    COUNT(*) AS total_employees,
    AVG(years_at_company) AS avg_tenure
FROM employees
GROUP BY Attrition;
SELECT MIN(salary), MAX(salary), AVG(salary) FROM employees;

#PHASE 7 — PERFORMANCE ANALYSIS
#Goal: Identify top talent and at-risk employees

-- Q45. How many employees fall under each performance rating?
select performance_rating,Count(*) as Total_Emp from employees
group by performance_rating
order by Total_Emp desc;

-- Q46. Which department has the highest average performance rating?
select d.dept_name,avg(e.Performance_rating) as AVG_PR from employees e
join departments d
on e.dept_id=d.dept_id
group by d.dept_name
ORDER BY AVG_PR DESC LIMIT 1;

-- Q47. How many top performers (rating 4 or 5) does each department have?
SELECT D.DEPT_NAME,
COUNT(*) AS Top_Performance
FROM EMPLOYEES E
JOIN DEPARTMENTS D 
ON E.DEPT_ID=D.DEPT_ID
where e.performance_rating in(4,5)
GROUP BY D.DEPT_NAME;
##
select d.dept_name,
count(*) AS Performance_rating,
sum(case when performance_rating in(4,5) then 1 else 0 end) as Top_Perfromers
from employees e
join departments d
on e.dept_id=d.dept_id
group by  d.dept_name;

-- Q48. How many low performers (rating 1 or 2) does each department have?
select d.dept_name,
count(*) as Low_Performers
from employees e join departments d
on e.dept_id=d.dept_id
where performance_rating in(1,2)
group by d.dept_name;

#
select d.dept_name,
count(*) as Total_Perfromancem,
sum(case when performance_rating in (1,2) then 1 else 0 end) as Low_Performers
from employees e join departments d
on e.dept_id=d.dept_id
group by d.dept_name;

-- Q49. Are high performers paid more? 
--   Show average salary for rating 4&5 vs rating 1&2
select 
case
when performance_rating in(4,5) then 'High_Performers (4,5)'
when performance_rating in(1,2) then 'Low_Performers(1,2)'
end as Performace_groups,
avg(salary) AS AVG_Salary
from employees
where performance_rating in (1,2,5,4)
group by Performace_groups;

##
SELECT 
    performance_group,
    COUNT(*) AS total_employees,
    AVG(salary) AS avg_salary
FROM (
    SELECT 
        salary,
        CASE 
            WHEN performance_rating IN (4,5) THEN 'High Performers'
            WHEN performance_rating IN (1,2) THEN 'Low Performers'
        END AS performance_group
    FROM employees
    WHERE performance_rating IN (1,2,4,5)
) t
GROUP BY performance_group;


-- Q50. Which department has the most low performers — show dept name
select d.dept_name,
count(*) as Low_Pefromance_count
from employees e join departments d
on e.dept_id=d.dept_id
where performance_rating in (1,2)
group by d.dept_name
;
#


#PHASE 8 — ADVANCED ANALYSIS (Window Functions)
#Goal: Rank, compare and segment employees within groups

-- Q51. Rank all employees by salary within their department
--      Highest salary = Rank 1 (use ROW_NUMBER)

select dept_id,name,
salary,
row_number() over(partition by dept_id order by salary desc,NAME ASC) as SALARY_RANK_BY_DEP
from employees;

-- Q52. Show top 3 highest paid employees in each department
--      Show name, dept name, salary, rank

select * from
(Select d.dept_name,e.name,e.salary ,
row_number() over(partition by d.dept_name order by e.salary desc) as Hights_salary_Rank
from employees e join departments d
on e.dept_id=d.dept_id) t
where Hights_salary_Rank<=3;

-- Q53. Show each employee with their department's average salary 
--      in the same row — so you can compare individual vs dept avg
--      (use AVG OVER PARTITION BY)

select Dept_id,employee_id,name,salary,
avg(salary) over(partition by dept_id) as Dept_AVG_SALARY
from employees;

##select avg(salary) from employees where dept_id='D01';

-- Q54. Show each employee's salary and the maximum salary 
--      in their department in the same row

Select dept_id,employee_id,name,salary,max(salary) over(partition by dept_id) as MAX_DEP_SALARY
FROM employees;
-- select max(salary) from employees where dept_id='D01'; Just checking

-- Q55. Divide employees into 4 salary bands within each department
--      Label as: Top 25% / Upper Mid / Lower Mid / Bottom 25%
--      Show how many employees fall in each band per department
--      (use NTILE)
select dept_name,
case 
when band= 1 then 'Top 25%'
when band=2 then 'Upper Mid'
when band=3 then 'Lower mid'
else 'Bottom 25%'
end as Salary_Cat,
count(*) as Emp_count
from
(select d.dept_name,e.salary,
ntile(4) over(partition by d.dept_name order by e.salary desc) as band 
from employees e
join departments d on e.dept_id=d.dept_id) t
group by dept_name,salary_cat
;

-- Q56. Rank all employees by salary across the entire company
--      No partitioning — company wide rank
SELECT employee_id,salary,
row_number() over(order by salary desc) as Salary_rank
from employees 
;

-- PHASE 9 — BUSINESS RECOMMENDATIONS (Final Queries)
-- Goal: Answer the 3 core business questions with data

-- Q57. WHO is leaving the most? 
--      Single query showing attrition by dept, gender and rating together

SELECT 
    d.dept_name,
    e.gender,
    e.performance_rating,
    COUNT(*) AS attrition_count
FROM employees e 
JOIN departments d 
    ON e.dept_id = d.dept_id
WHERE e.attrition = 'Yes'
GROUP BY 
    d.dept_name,
    e.gender,
    e.performance_rating
ORDER BY attrition_count DESC;

-- Q58. WHICH employees still in the company are flight risks?
--      Define flight risk as: salary below dept average 
--      AND performance rating below 3
--      Show their name, dept name, salary, rating

SELECT 
    e.employee_id,
    e.name,
    d.dept_name,
    e.salary,
    e.performance_rating
FROM employees e
JOIN departments d 
    ON e.dept_id = d.dept_id
JOIN (
    SELECT 
        dept_id,
        AVG(salary) AS dept_avg_salary
    FROM employees
    GROUP BY dept_id
) x
ON e.dept_id = x.dept_id
WHERE e.attrition = 'No'
AND e.performance_rating < 3
AND e.salary < x.dept_avg_salary;


-- SELECT AVG(SALARY) FROM EMPLOYEES WHERE DEPT_ID='D01';
-- Q59. FUTURE HIRING — which departments are understaffed?
--      Show departments where headcount is below company average headcount

SELECT 
    dept_name,
    headcount
FROM (
    SELECT 
        d.dept_name,
        COUNT(e.employee_id) AS headcount
    FROM employees e
    JOIN departments d 
        ON e.dept_id = d.dept_id
    GROUP BY d.dept_name
) dept_counts
WHERE headcount < (
    SELECT AVG(dept_count)
    FROM (
        SELECT 
            COUNT(*) AS dept_count
        FROM employees
        GROUP BY dept_id
    ) x
);









-- Q60. Final summary — for each department show:
--      dept name, total employees, attrition rate %, 
--      avg salary, avg performance rating
--      Order by attrition rate highest to lowest
--      (This is your EXECUTIVE DASHBOARD query)

SELECT 
    d.dept_name,

    COUNT(e.employee_id) AS total_employees,

    ROUND(
        SUM(CASE WHEN e.attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(e.employee_id), 2
    ) AS attrition_rate_pct,

    ROUND(AVG(e.salary), 2) AS avg_salary,

    ROUND(AVG(e.performance_rating), 2) AS avg_performance_rating

FROM employees e
JOIN departments d
    ON e.dept_id = d.dept_id

GROUP BY d.dept_name

ORDER BY attrition_rate_pct DESC;
create database task_C;
use task_C;
-- task : 1 
-- creating a table 
CREATE TABLE Projects (
    Task_ID INTEGER,
    Start_Date DATE,
    End_Date DATE
);

INSERT INTO Projects (Task_ID, Start_Date, End_Date) VALUES
(1, '2015-10-01', '2015-10-02'),
(2, '2015-10-02', '2015-10-03'),
(3, '2015-10-03', '2015-10-04'),
(4, '2015-10-13', '2015-10-14'),
(5, '2015-10-14', '2015-10-15'),
(6, '2015-10-28', '2015-10-29'),
(7, '2015-10-30', '2015-10-31');

WITH Numbered AS (
    SELECT
        Start_Date,
        End_Date,
        ROW_NUMBER() OVER (ORDER BY Start_Date) AS rn
    FROM Projects
),
Islands AS (
    SELECT
        Start_Date,
        End_Date,
        DATEADD(day, -rn, Start_Date) AS grp
    FROM Numbered
)
SELECT
    MIN(Start_Date) AS Project_Start_Date,
    MAX(End_Date) AS Project_End_Date
FROM Islands
GROUP BY grp
ORDER BY 
    DATEDIFF(day, MIN(Start_Date), MAX(End_Date)),
    MIN(Start_Date);


---- task : 2 
CREATE TABLE Students (
    ID INT PRIMARY KEY,
    Name VARCHAR(50)
);

CREATE TABLE Friends (
    ID INT,
    Friend_ID INT
);

CREATE TABLE Packages (
    ID INT,
    Salary FLOAT
);

-- Students
INSERT INTO Students (ID, Name) VALUES
(1, 'Neha'),
(2, 'Shrutee'),
(3, 'Jass'),
(4, 'Vansh');

-- Friends
INSERT INTO Friends (ID, Friend_ID) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 1);

-- Packages
INSERT INTO Packages (ID, Salary) VALUES
(1, 15.20),
(2, 10.06),
(3, 11.55),
(4, 12.12);

 -- query 
SELECT s.Name
FROM Students s
JOIN Friends f ON s.ID = f.ID
JOIN Packages p1 ON s.ID = p1.ID
JOIN Packages p2 ON f.Friend_ID = p2.ID
WHERE p2.Salary > p1.Salary
ORDER BY p2.Salary;

-- task : 3 
CREATE TABLE Functions (
    X INT,
    Y INT
);
INSERT INTO Functions (X, Y) VALUES
(20, 20),
(20, 20),
(20, 21),
(23, 22),
(22, 23),
(21, 20);
SELECT DISTINCT f1.X, f1.Y
FROM Functions f1
JOIN Functions f2
  ON f1.X = f2.Y AND f1.Y = f2.X
WHERE f1.X <= f1.Y
ORDER BY f1.X, f1.Y;


-- task : 4 
CREATE TABLE Contests (
    contest_id INT,
    hacker_id INT,
    name VARCHAR(100)
);

CREATE TABLE Colleges (
    college_id INT,
    contest_id INT
);

CREATE TABLE Challenges (
    challenge_id INT,
    college_id INT
);

CREATE TABLE View_Stats (
    challenge_id INT,
    total_views INT,
    total_unique_views INT
);

CREATE TABLE Submission_Stats (
    challenge_id INT,
    total_submissions INT,
    total_accepted_submissions INT
);
-- Contests
INSERT INTO Contests VALUES
(66406, 17973, 'Gunnu'),
(66556, 79153, 'Marvin'),
(94828, 80275, 'Diya');

-- Colleges
INSERT INTO Colleges VALUES
(11219, 66406),
(32473, 66556),
(56685, 94828);

-- Challenges
INSERT INTO Challenges VALUES
(18765, 11219),
(47127, 11219),
(60292, 32473),
(72974, 56685);

-- View_Stats
INSERT INTO View_Stats VALUES
(47127, 26, 19),
(47127, 15, 14),
(18765, 43, 10),
(18765, 72, 13),
(75516, 35, 17),
(60292, 11, 10),
(72974, 41, 15),
(75516, 75, 11);

-- Submission_Stats
INSERT INTO Submission_Stats VALUES
(75516, 34, 12),
(47127, 27, 10),
(47127, 56, 18),
(75516, 74, 12),
(75516, 83, 8),
(72974, 68, 24),
(72974, 82, 14),
(47127, 28, 11);
SELECT 
    c.contest_id,
    c.hacker_id,
    c.name,
    ISNULL(SUM(ss.total_submissions), 0) AS total_submissions,
    ISNULL(SUM(ss.total_accepted_submissions), 0) AS total_accepted_submissions,
    ISNULL(SUM(vs.total_views), 0) AS total_views,
    ISNULL(SUM(vs.total_unique_views), 0) AS total_unique_views
FROM Contests c
JOIN Colleges col ON c.contest_id = col.contest_id
JOIN Challenges ch ON col.college_id = ch.college_id
LEFT JOIN Submission_Stats ss ON ch.challenge_id = ss.challenge_id
LEFT JOIN View_Stats vs ON ch.challenge_id = vs.challenge_id
GROUP BY c.contest_id, c.hacker_id, c.name
HAVING
    ISNULL(SUM(ss.total_submissions), 0) > 0
 OR ISNULL(SUM(ss.total_accepted_submissions), 0) > 0
 OR ISNULL(SUM(vs.total_views), 0) > 0
 OR ISNULL(SUM(vs.total_unique_views), 0) > 0
ORDER BY c.contest_id;


-- task : 5 
-- Create tables
CREATE TABLE Hackers (
    hacker_id INT PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE Submissions (
    submission_date DATE,
    submission_id INT,
    hacker_id INT,
    score INT
);

-- Insert sample data for Hackers
INSERT INTO Hackers (hacker_id, name) VALUES
(15758, 'Gunnu'),
(20703, 'Rahul'),
(36396, 'Vanshh'),
(38289, 'Mehta'),
(44065, 'Alisha'),
(53473, 'Shweta'),
(62529, 'Brownie'),
(79722, 'Fiza');

-- Insert sample data for Submissions
INSERT INTO Submissions (submission_date, submission_id, hacker_id, score) VALUES
('2016-03-01', 8494, 20703, 0),
('2016-03-01', 22403, 53473, 15),
('2016-03-01', 23965, 79722, 60),
('2016-03-01', 30173, 36396, 70),
('2016-03-02', 34928, 20703, 0),
('2016-03-02', 38740, 15758, 60),
('2016-03-02', 42769, 79722, 25),
('2016-03-02', 44364, 79722, 60),
('2016-03-03', 45440, 20703, 0),
('2016-03-03', 49050, 36396, 70),
('2016-03-03', 50273, 79722, 5),
('2016-03-04', 50344, 20703, 0),
('2016-03-04', 51360, 44065, 90),
('2016-03-04', 54404, 53473, 65),
('2016-03-04', 61533, 79722, 45),
('2016-03-05', 72852, 20703, 0),
('2016-03-05', 74546, 38289, 0),
('2016-03-05', 76487, 62529, 0),
('2016-03-05', 82439, 36396, 10),
('2016-03-05', 90006, 36396, 40),
('2016-03-06', 90404, 20703, 0);

-- Query to produce the required output
WITH DailyCounts AS (
    SELECT 
        submission_date,
        hacker_id,
        COUNT(*) AS num_submissions
    FROM Submissions
    GROUP BY submission_date, hacker_id
),
MaxSubmissions AS (
    SELECT
        submission_date,
        MAX(num_submissions) AS max_subs
    FROM DailyCounts
    GROUP BY submission_date
),
TopHacker AS (
    SELECT 
        d.submission_date,
        d.hacker_id,
        h.name,
        d.num_submissions,
        ROW_NUMBER() OVER (
            PARTITION BY d.submission_date 
            ORDER BY d.num_submissions DESC, d.hacker_id ASC
        ) AS rn
    FROM DailyCounts d
    JOIN Hackers h ON d.hacker_id = h.hacker_id
)
SELECT 
    t.submission_date,
    COUNT(DISTINCT d.hacker_id) AS total_hackers,
    t.hacker_id,
    t.name
FROM TopHacker t
JOIN DailyCounts d ON t.submission_date = d.submission_date
WHERE t.rn = 1
GROUP BY t.submission_date, t.hacker_id, t.name
ORDER BY t.submission_date;


-- Task : 6: Manhattan Distance between two points

CREATE TABLE STATION (
    ID INT,
    CITY VARCHAR(21),
    STATE VARCHAR(2),
    LAT_N FLOAT,
    LONG_W FLOAT
);

INSERT INTO STATION (ID, CITY, STATE, LAT_N, LONG_W) VALUES
(1, 'CityA', 'AA', 10.0, 20.0),
(2, 'CityB', 'BB', 30.0, 40.0),
(3, 'CityC', 'CC', 50.0, 60.0);

SELECT 
    ROUND(ABS(MAX(LAT_N) - MIN(LAT_N)) + ABS(MAX(LONG_W) - MIN(LONG_W)), 4) AS ManhattanDistance
FROM STATION;

-- Task : 7: Print all prime numbers <= 1000, separated by '&' on one line

WITH Numbers AS (
    SELECT 2 AS num
    UNION ALL
    SELECT num + 1 FROM Numbers WHERE num + 1 <= 1000
),
Primes AS (
    SELECT num
    FROM Numbers n
    WHERE NOT EXISTS (
        SELECT 1 FROM Numbers n2
        WHERE n2.num < n.num AND n2.num > 1 AND n.num % n2.num = 0
    )
)
SELECT STRING_AGG(CAST(num AS VARCHAR(4)), '&') AS Primes
FROM Primes
OPTION (MAXRECURSION 1000);

-- Task : 8: Pivot OCCUPATIONS table

CREATE TABLE OCCUPATIONS (
    Name VARCHAR(50),
    Occupation VARCHAR(50)
);

INSERT INTO OCCUPATIONS (Name, Occupation) VALUES
('Samantha', 'Doctor'),
('Julia', 'Actor'),
('Maria', 'Actor'),
('Meera', 'Singer'),
('Ashely', 'Professor'),
('Ketty', 'Professor'),
('Christeen', 'Professor'),
('Jane', 'Actor'),
('Jenny', 'Doctor'),
('Priya', 'Singer');

WITH Ranked AS (
    SELECT 
        Name,
        Occupation,
        ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS rn
    FROM OCCUPATIONS
)
SELECT
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor
FROM Ranked
GROUP BY rn
ORDER BY rn;

-- task : 9 
-- Create the BST table
CREATE TABLE BST (
    N INT,
    P INT
);

-- Insert the sample data
INSERT INTO BST (N, P) VALUES
(1, 2),
(3, 2),
(6, 8),
(9, 8),
(2, 5),
(8, 5),
(5, NULL);

-- Query to classify each node
SELECT 
    N,
    CASE
        WHEN P IS NULL THEN 'Root'
        WHEN N NOT IN (SELECT DISTINCT P FROM BST WHERE P IS NOT NULL) THEN 'Leaf'
        ELSE 'Inner'
    END AS NodeType
FROM BST
ORDER BY N;


-- task : 10 
-- Create tables
CREATE TABLE Company (
    company_code VARCHAR(10),
    founder VARCHAR(50)
);

CREATE TABLE Lead_Manager (
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

CREATE TABLE Senior_Manager (
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

CREATE TABLE Manager (
    manager_code VARCHAR(10),
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

CREATE TABLE Employee (
    employee_code VARCHAR(10),
    manager_code VARCHAR(10),
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

-- Insert sample data
INSERT INTO Company VALUES
('C1', 'Monika'),
('C2', 'Samantha');

INSERT INTO Lead_Manager VALUES
('LM1', 'C1'),
('LM2', 'C2');

INSERT INTO Senior_Manager VALUES
('SM1', 'LM1', 'C1'),
('SM2', 'LM1', 'C1'),
('SM3', 'LM2', 'C2');

INSERT INTO Manager VALUES
('M1', 'SM1', 'LM1', 'C1'),
('M2', 'SM3', 'LM2', 'C2'),
('M3', 'SM3', 'LM2', 'C2');

INSERT INTO Employee VALUES
('E1', 'M1', 'SM1', 'LM1', 'C1'),
('E2', 'M1', 'SM1', 'LM1', 'C1'),
('E3', 'M2', 'SM3', 'LM2', 'C2'),
('E4', 'M3', 'SM3', 'LM2', 'C2');

-- Query to produce the required output
SELECT
    c.company_code,
    c.founder,
    COUNT(DISTINCT l.lead_manager_code) AS total_lead_managers,
    COUNT(DISTINCT s.senior_manager_code) AS total_senior_managers,
    COUNT(DISTINCT m.manager_code) AS total_managers,
    COUNT(DISTINCT e.employee_code) AS total_employees
FROM Company c
LEFT JOIN Lead_Manager l ON c.company_code = l.company_code
LEFT JOIN Senior_Manager s ON c.company_code = s.company_code
LEFT JOIN Manager m ON c.company_code = m.company_code
LEFT JOIN Employee e ON c.company_code = e.company_code
GROUP BY c.company_code, c.founder
ORDER BY c.company_code;

-- task : 11 
-- Create Students table
CREATE TABLE Students1 (
    ID INT PRIMARY KEY,
    Name VARCHAR(50)
);

-- Create Friends table
CREATE TABLE Friends1 (
    ID INT,
    Friend_ID INT
);

-- Create Packages table
CREATE TABLE Packages1 (
    ID INT,
    Salary FLOAT
);

-- Insert sample data into Students
INSERT INTO Students1 (ID, Name) VALUES
(1, 'Ashley'),
(2, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet');

-- Insert sample data into Friends
INSERT INTO Friends1 (ID, Friend_ID) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 1);

-- Insert sample data into Packages
INSERT INTO Packages1 (ID, Salary) VALUES
(1, 15.20),
(2, 10.06),
(3, 11.55),
(4, 12.12);

-- Query to find students whose best friends got a higher salary
SELECT s.Name
FROM Students1 s
JOIN Friends1 f ON s.ID = f.ID
JOIN Packages1 p1 ON s.ID = p1.ID
JOIN Packages1 p2 ON f.Friend_ID = p2.ID
WHERE p1.Salary < p2.Salary
ORDER BY p2.Salary;



-- -- Task : 12: Display ratio of cost of job family in percentage by India and international

CREATE TABLE JobFamilyCost (
    JobFamily VARCHAR(50),
    Location VARCHAR(50),
    Cost FLOAT
);

INSERT INTO JobFamilyCost (JobFamily, Location, Cost) VALUES
('IT', 'India', 100000),
('IT', 'International', 40000),
('HR', 'India', 30000),
('HR', 'International', 20000);

SELECT 
    JobFamily,
    SUM(CASE WHEN Location = 'India' THEN Cost ELSE 0 END) * 100.0 / SUM(Cost) AS India_Percentage,
    SUM(CASE WHEN Location = 'International' THEN Cost ELSE 0 END) * 100.0 / SUM(Cost) AS International_Percentage
FROM JobFamilyCost
GROUP BY JobFamily;

-- Task : 13: Find ratio of cost and revenue of a BU month on month

CREATE TABLE BU_Finance (
    BU VARCHAR(50),
    [Month] VARCHAR(7),
    Cost FLOAT,
    Revenue FLOAT
);

INSERT INTO BU_Finance (BU, [Month], Cost, Revenue) VALUES
('BU1', '2024-01', 50000, 100000),
('BU1', '2024-02', 60000, 120000),
('BU1', '2024-03', 70000, 150000),
('BU2', '2024-01', 20000, 50000),
('BU2', '2024-02', 30000, 60000);

SELECT
    BU,
    [Month],
    CASE WHEN Revenue = 0 THEN NULL ELSE ROUND(Cost / Revenue, 4) END AS Cost_Revenue_Ratio
FROM BU_Finance
ORDER BY BU, [Month];

-- Task : 14: Show headcounts of sub band and percentage of headcount (without join, subquery and inner query)

CREATE TABLE EmployeeBands (
    EmpID INT,
    SubBand VARCHAR(10)
);

INSERT INTO EmployeeBands (EmpID, SubBand) VALUES
(1, 'A1'),
(2, 'A1'),
(3, 'A2'),
(4, 'A2'),
(5, 'A2'),
(6, 'B1'),
(7, 'B2'),
(8, 'B2');

-- Use SUM and COUNT with GROUP BY and a window function (no join, subquery, or inner query)
SELECT 
    SubBand,
    COUNT(*) AS Headcount,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS PercentageOfTotal
FROM EmployeeBands
GROUP BY SubBand;

-- -- Task : 15: Find top 5 employees according to salary (without ORDER BY)

CREATE TABLE Employees (
    EmpID INT PRIMARY KEY,
    Name VARCHAR(50),
    Salary FLOAT
);

INSERT INTO Employees (EmpID, Name, Salary) VALUES
(1, 'Alice', 70000),
(2, 'Bob', 50000),
(3, 'Carol', 90000),
(4, 'David', 80000),
(5, 'Eva', 60000),
(6, 'Frank', 95000),
(7, 'Grace', 55000);

-- Query: Top 5 salaries using DENSE_RANK (no ORDER BY in outer query)
SELECT EmpID, Name, Salary
FROM (
    SELECT *, DENSE_RANK() OVER (ORDER BY Salary DESC) AS rnk
    FROM Employees
) t
WHERE rnk <= 5;

-- Task : 16: Swap value of two columns in a table without using third variable or a table

CREATE TABLE SwapTest (
    ID INT PRIMARY KEY,
    Col1 INT,
    Col2 INT
);

INSERT INTO SwapTest (ID, Col1, Col2) VALUES (1, 10, 20);

-- Swap Col1 and Col2 without a third variable
UPDATE SwapTest
SET Col1 = Col1 + Col2,
    Col2 = Col1 - Col2,
    Col1 = Col1 - Col2
WHERE ID = 1;



-- Step 1: Create a login at the server level (run in master)
USE master;
GO
IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = N'testuser')
BEGIN
    CREATE LOGIN [testuser] WITH PASSWORD = 'YourStrongPassword1!';
END
GO

-- Step 2: Create a user in your target database (replace TestDB with your database)
USE task_C;
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'testuser')
BEGIN
    CREATE USER [testuser] FOR LOGIN [testuser] WITH DEFAULT_SCHEMA = dbo;
END
GO

-- Step 3: Add user to db_owner role (full database permissions)
ALTER ROLE db_owner ADD MEMBER [testuser];
GO


-- Task  : 18: Find Weighted average cost of employees month on month in a BU

CREATE TABLE EmployeeCost (
    BU VARCHAR(10),
    [Month] VARCHAR(7),
    EmpID INT,
    Cost FLOAT,
    Weight FLOAT
);

INSERT INTO EmployeeCost (BU, [Month], EmpID, Cost, Weight) VALUES
('BU1', '2024-01', 1, 1000, 0.5),
('BU1', '2024-01', 2, 2000, 0.5),
('BU1', '2024-02', 1, 1200, 0.4),
('BU1', '2024-02', 2, 1800, 0.6),
('BU2', '2024-01', 3, 1500, 1.0);

-- Weighted average cost by BU and Month
SELECT
    BU,
    [Month],
    ROUND(SUM(Cost * Weight) / NULLIF(SUM(Weight), 0), 2) AS WeightedAvgCost
FROM EmployeeCost
GROUP BY BU, [Month]
ORDER BY BU, [Month];

-- task : 19 -- 

-- 
IF OBJECT_ID('EMPLOYEES', 'U') IS NOT NULL DROP TABLE EMPLOYEES;
CREATE TABLE EMPLOYEES (
    ID INT PRIMARY KEY,
    Name VARCHAR(50),
    Salary INT
);

INSERT INTO EMPLOYEES (ID, Name, Salary) VALUES
(1, 'Ashley', 2340),
(2, 'Julia', 1198),
(3, 'Britney', 9009),
(4, 'Kristeen', 2341),
(5, 'Dyana', 9990),
(6, 'Diana', 8011),
(7, 'Jenny', 2341),
(8, 'Christeen', 2342),
(9, 'Meera', 2343),
(10, 'Priya', 2344),
(11, 'Priyanka', 2345),
(12, 'Paige', 2346),
(13, 'Jane', 2347),
(14, 'Belvet', 2348),
(15, 'Scarlet', 2349),
(16, 'Salma', 9087),
(17, 'Amanda', 7777),
(18, 'Aamina', 5500),
(19, 'Amina', 2570),
(20, 'Ketty', 2007);

-- Query: 
SELECT CAST(CEILING(
    AVG(CAST(Salary AS FLOAT)) - 
    AVG(CAST(REPLACE(CAST(Salary AS VARCHAR), '0', '') AS FLOAT))
) AS INT) AS ErrorAmount
FROM EMPLOYEES;


-- Task : 20: 

-- 
IF OBJECT_ID('SourceTable', 'U') IS NOT NULL DROP TABLE SourceTable;
IF OBJECT_ID('DestinationTable', 'U') IS NOT NULL DROP TABLE DestinationTable;

CREATE TABLE SourceTable (
    ID INT PRIMARY KEY,
    Data VARCHAR(50)
);

CREATE TABLE DestinationTable (
    ID INT PRIMARY KEY,
    Data VARCHAR(50)
);

--
INSERT INTO SourceTable (ID, Data) VALUES
(1, 'Alpha'),
(2, 'Beta'),
(3, 'Gamma'),
(4, 'Delta');

--
INSERT INTO DestinationTable (ID, Data) VALUES
(1, 'Alpha'),
(2, 'Beta');

-- 
INSERT INTO DestinationTable (ID, Data)
SELECT s.ID, s.Data
FROM SourceTable s
LEFT JOIN DestinationTable d ON s.ID = d.ID
WHERE d.ID IS NULL;

SELECT * FROM DestinationTable ORDER BY ID;

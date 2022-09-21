
USE HAP725

--SELECT TOP 10 * FROM [HAP725].[dbo].[Disabilities]

--SQL Code for ROC Curve for Age
/****** ROC Curve for Age  ******/
DROP TABlE #age 
SELECT [ID]
      ,Cast([Age] as Float)+ Cast(DayFirst as Float) /365.0 AS Age -- Age at first admission + Days later for assessment
      ,[Sex]
      , Alive as Actual  -- Dead is shown as 1
      , Row_Number()Over(ORDER BY Cast([Age] as Float)+ Cast(DayFirst as Float)/365.0) as Row
  INTO #Age
  FROM [HAP725].[dbo].[Disabilities]
  Where sex='M'  -- Focus on males only
  ORDER BY Cast([Age] as Float)+ Cast(DayFirst as Float)/365.0
  
  -- (1096961 rows affected)

-- Cutoffs set at 5 years
DROP TABlE #cutoffs 
CREATE TABLE #Cutoffs (Cutoff Float);
INSERT INTO #Cutoffs (Cutoff) 
	VALUES (40.0), (45.0), (50.0), (55.0), (60.0), (65.0), (70.0), (75.0), (80.0), (85.0), (90.0), (95.0), (100.0);


/*
-- Cutoffs estimated from data
DROP TABlE #cutoffs 
SELECT (b.age+a.age)/2 as Cutoff
INTO #Cutoffs
FROM #Age b inner join #Age a 
ON a.Row = b.Row+1  
WHERE RAND(a.row)<.0001 
Go
-- (129 row(s) affected)
INSERT INTO #Cutoffs (Cutoff) VALUES (0.0), (100.0); 
*/

-- Prediction based on cutoff value
DROP TABLE #temp1
SELECT cutoff
, CASE WHEN a.age > b.[Cutoff] THEN 1. ELSE 0. END AS Predicted
, a.Actual
INTO #Temp1 
FROM #Age a Cross Join #Cutoffs b
-- (168,592,939 row(s) affected) 4 minutes and 45 seconds to run
-- (16,730,597 row(s) affected) 27 seconds 

-- (14260493 rows affected)


-- Calculating sensitvity and specificity 
SELECT Cutoff
, SUM(CAST(Actual AS FLOAT)*CAST(Predicted AS FLOAT))/
Sum(CAST(Actual AS FLOAT)) AS Sensitivity 
 	, SUM((1-Predicted)*(1-Actual))/SUM(1-Actual) AS Specificity 
INTO #sensspec
FROM #Temp1
GROUP BY Cutoff
ORDER BY cutoff
-- (13 row(s) affected) 1 minute 16 seconds

-- Transferring data to Excel to plot
SELECT Cutoff, Sensitivity, 1.-Specificity as [1 - Specificity] FROM #sensspec

 
 ----------------------------------------------------------------------------------------------------------------

 /****** ROC Curve for Age  ******/
DROP TABlE #ageF 
SELECT [ID]
      ,Cast([Age] as Float)+ Cast(DayFirst as Float) /365.0 AS Age -- Age at first admission + Days later for assessment
      ,[Sex]
      , Alive as Actual  -- Dead is shown as 1
      , Row_Number()Over(ORDER BY Cast([Age] as Float)+ Cast(DayFirst as Float)/365.0) as Row
  INTO #AgeF
  FROM [HAP725].[dbo].[Disabilities]
  Where sex='F'  -- Focus on males only
  ORDER BY Cast([Age] as Float)+ Cast(DayFirst as Float)/365.0
  
  -- (35177 rows affected)


-- Cutoffs set at 5 years
DROP TABlE #cutoffs_f 
CREATE TABLE #cutoffs_f (Cutoff Float);
INSERT INTO #cutoffs_f (Cutoff) 
	VALUES (40.0), (45.0), (50.0), (55.0), (60.0), (65.0), (70.0), (75.0), (80.0), (85.0), (90.0), (95.0), (100.0);


/*
-- Cutoffs estimated from data
DROP TABlE #cutoffs 
SELECT (b.age+a.age)/2 as Cutoff
INTO #Cutoffs
FROM #Age b inner join #Age a 
ON a.Row = b.Row+1  
WHERE RAND(a.row)<.0001 
Go
-- (129 row(s) affected)
INSERT INTO #Cutoffs (Cutoff) VALUES (0.0), (100.0); 
*/

-- Prediction based on cutoff value
DROP TABLE #temp1_f
SELECT cutoff
, CASE WHEN a.age > b.[Cutoff] THEN 1. ELSE 0. END AS Predicted
, a.Actual
INTO #Temp1_f 
FROM #Age a Cross Join #Cutoffs b
-- (168,592,939 row(s) affected) 4 minutes and 45 seconds to run
-- (16,730,597 row(s) affected) 27 seconds 

-- (14260493 rows affected)


-- Calculating sensitvity and specificity 
SELECT Cutoff
, SUM(CAST(Actual AS FLOAT)*CAST(Predicted AS FLOAT))/
Sum(CAST(Actual AS FLOAT)) AS Sensitivity 
 	, SUM((1-Predicted)*(1-Actual))/SUM(1-Actual) AS Specificity 
INTO #sensspec_f
FROM #Temp1_f
GROUP BY Cutoff
ORDER BY cutoff
-- (13 row(s) affected) 1 minute 16 seconds

-- Transferring data to Excel to plot
SELECT Cutoff, Sensitivity, 1.-Specificity as [1 - Specificity] FROM #sensspec_f

 
 --------------------------
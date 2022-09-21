
USE HAP725


-- Select * from [HAP725].[dbo].[MM-Index-Data]

--  Step 1 Binarize the DataSet

SELECT iif([MI]='MI',1,0) as MI
	   ,iif([CHF]='CHF',1,0) as CHF
	   ,iif([DM]='DM',1,0) as DM
	   ,iif([AA]='AA',1,0) as AA
	   ,[LOS] as length_of_stay
	   ,[N] as Number_of_patients
into [HAP725].[dbo].[MM-Index-Data_final]
from [HAP725].[dbo].[MM-Index-Data]

-- Select top 10 * from [HAP725].[dbo].[MM-Index-Data_final]

Select 
sum (cast([Number_of_patients] as float) * cast([Length_of_stay] as float))
/sum(cast([Number_of_patients] as float)) as AvgOfLOS
into #average
from [HAP725].[dbo].[MM-Index-Data_final]

select * from #average

-- average length of stay: 3.24028985507246 
/* Assign Patients who have:  
- Above average Length of Stay (LOS = 1)
- Below average Length of Stay (LOS = 0) 
*/

declare @avgLength float 
set @avgLength = (select AvgOfLOS from #average) 

drop table #count
SELECT Count(MI) AS N 
	,Sum(MI*[Number_of_patients]*IIf([Length_of_stay]>@avgLength,1,0)) AS MIandLong
	,Sum(MI*[Number_of_patients]*IIF([Length_of_stay]<=@avgLength,1,0))AS MIandShort
	,Sum((1-MI)*[Number_of_patients]*IIf([Length_of_stay]>@avgLength,1,0))AS NotMIandLong
	,Sum((1-MI)*[Number_of_patients]*IIf([Length_of_stay]<=@avgLength,1,0)) AS NotMIandShort
	INTO #Count
	from [HAP725].[dbo].[MM-Index-Data_final]

	--select * from #Count

--- Calculate the likelihood ratio for MI 

declare @long float 
set @long = (select sum(cast(Number_of_patients as float)) from [HAP725].[dbo].[MM-Index-Data_final] where [length_of_stay]>@avgLength)
declare @short float 
set @short = (select sum(cast(Number_of_patients as float)) from [HAP725].[dbo].[MM-Index-Data_final] where [length_of_stay]<=@avgLength)
SELECT (cast([MIandLong] as float)/@long)/(cast([MIandShort] as float)/@short) AS LRforMI
FROM #Count 

-- Likelihood Ratio for MI = 3.47


------------------------------------------- AA --------------------------------------------------
--------------------------------------------------------------------------------------------------
declare @avgLength float 
set @avgLength = (select AvgOfLOS from #average) 

drop table #count_aa
SELECT Count(MI) AS N 
	,Sum(AA*[Number_of_patients]*IIf([Length_of_stay]>@avgLength,1,0)) AS AAandLong
	,Sum(AA*[Number_of_patients]*IIF([Length_of_stay]<=@avgLength,1,0))AS AAandShort
	,Sum((1-AA)*[Number_of_patients]*IIf([Length_of_stay]>@avgLength,1,0))AS NotAAandLong
	,Sum((1-AA)*[Number_of_patients]*IIf([Length_of_stay]<=@avgLength,1,0)) AS NotAAandShort
	INTO #count_aa
	from [HAP725].[dbo].[MM-Index-Data_final]

	--select * from #count_aa

--- Calculate the likelihood ratio for AA 

declare @long float 
set @long = (select sum(cast(Number_of_patients as float)) from [HAP725].[dbo].[MM-Index-Data_final] where [length_of_stay]>@avgLength)
declare @short float 
set @short = (select sum(cast(Number_of_patients as float)) from [HAP725].[dbo].[MM-Index-Data_final] where [length_of_stay]<=@avgLength)
SELECT (cast([AAandLong] as float)/@long)/(cast([AAandShort] as float)/@short) AS LRforAA
FROM #count_aa 

-- Likelihood Ratio for MI = 3.47


------------------------------------------- CHF --------------------------------------------------
--------------------------------------------------------------------------------------------------
declare @avgLength float 
set @avgLength = (select AvgOfLOS from #average) 

drop table #count_chf
SELECT Count(CHF) AS N 
	,Sum(CHF*[Number_of_patients]*IIf([Length_of_stay]>@avgLength,1,0)) AS CHFandLong
	,Sum(CHF*[Number_of_patients]*IIF([Length_of_stay]<=@avgLength,1,0))AS CHFandShort
	,Sum((1-CHF)*[Number_of_patients]*IIf([Length_of_stay]>@avgLength,1,0))AS NotCHFandLong
	,Sum((1-CHF)*[Number_of_patients]*IIf([Length_of_stay]<=@avgLength,1,0)) AS NotCHFandShort
	INTO #count_chf
	from [HAP725].[dbo].[MM-Index-Data_final]

	--select * from #count_aa

--- Calculate the likelihood ratio for CHF 

declare @long float 
set @long = (select sum(cast(Number_of_patients as float)) from [HAP725].[dbo].[MM-Index-Data_final] where [length_of_stay]>@avgLength)
declare @short float 
set @short = (select sum(cast(Number_of_patients as float)) from [HAP725].[dbo].[MM-Index-Data_final] where [length_of_stay]<=@avgLength)
SELECT (cast([CHFandLong] as float)/@long)/(cast([CHFandShort] as float)/@short) AS LRforCHF
FROM #count_chf

-- Likelihood Ratio for CHF = 5.525


------------------------------------------- DM --------------------------------------------------
--------------------------------------------------------------------------------------------------
declare @avgLength float 
set @avgLength = (select AvgOfLOS from #average) 

drop table #count_dm
SELECT Count(DM) AS N 
	,Sum(DM*[Number_of_patients]*IIf([Length_of_stay]>@avgLength,1,0)) AS DMandLong
	,Sum(DM*[Number_of_patients]*IIF([Length_of_stay]<=@avgLength,1,0))AS DMandShort
	,Sum((1-DM)*[Number_of_patients]*IIf([Length_of_stay]>@avgLength,1,0))AS NotDMandLong
	,Sum((1-DM)*[Number_of_patients]*IIf([Length_of_stay]<=@avgLength,1,0)) AS NotDMandShort
	INTO #count_dm
	from [HAP725].[dbo].[MM-Index-Data_final]

	--select * from #count_aa

--- Calculate the likelihood ratio for CHF 

declare @long float 
set @long = (select sum(cast(Number_of_patients as float)) from [HAP725].[dbo].[MM-Index-Data_final] where [length_of_stay]>@avgLength)
declare @short float 
set @short = (select sum(cast(Number_of_patients as float)) from [HAP725].[dbo].[MM-Index-Data_final] where [length_of_stay]<=@avgLength)
SELECT (cast([DMandLong] as float)/@long)/(cast([DMandShort] as float)/@short) AS LRforDM
FROM #count_dm

-- Likelihood Ratio for CHF = 5.525
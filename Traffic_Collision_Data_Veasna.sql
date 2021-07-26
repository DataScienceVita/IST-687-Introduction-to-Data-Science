




--drop table [dbo].[Traffic_Collision_Data]


SELECT TOP 10 * 
FROM [dbo].[Traffic_Collision_Data]


--CLEANING DATA

--IF OBJECT_ID('dbo.TCD', 'U') IS NOT NULL DROP TABLE dbo.TCD;

;
WITH cte AS(
	SELECT
		[DR Number] AS DRNumber
		, CAST(LEFT([Date Reported], 10) AS DATE) AS [DateReported] 
		, CAST(LEFT([Date Occurred], 10) AS DATE) AS [DateOccurred] 
		--, LEFT([Time Occurred], 10) AS [TimeOccurred] 
		--, CONVERT(VARCHAR, [Time Occurred], 108)
		, CASE WHEN LEN([Time Occurred]) = 3 THEN LEFT([Time Occurred], 1) + ':' + SUBSTRING([Time Occurred], 2, 3)
			   WHEN LEN([Time Occurred]) = 2 THEN '0' + ':' + LEFT([Time Occurred], 2) 
			   WHEN LEN([Time Occurred]) = 4 THEN LEFT([Time Occurred], 2) + ':' + SUBSTRING([Time Occurred], 3, 4)
		  END AS [TimeOccurred]      
		--, cast(([Time Occurred] / 24) as varchar(2)) + ':' + cast(([Time Occurred] % 12) as varchar(2))
		, [Area ID] AS AreaID
		, [Reporting District] AS ReportingDistrict
		, [Crime Code] AS CrimeCode
		, [Crime Code Description] AS CrimeCodeDescription
		, [MO Codes] AS MOCodes
		, [Victim Age] AS VictimAge
		, [Victim Sex] AS VictimSex
		, [Victim Descent] AS VictimDescent
		, [Premise Code] AS PremiseCode
		, [Premise Description] AS PremiseDescription
		, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([Address], ' RD', ''), ' ST', ''), ' AV', ''), ' BL', ''), ' DR', ''), ' PL', ''), ' HY', ''), 'WY', ''), 'CT', ''), 'PN', ''), ' FY', ''), ' LN', '') AS [Address] 
		, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE([Cross Street], ' RD', ''), ' ST', ''), ' AV', ''), ' BL', ''), ' DR', ''), ' PL', ''), ' HY', ''), 'WY', ''), 'CT', ''), 'PN', ''), ' FY', ''), ' LN', '') AS CrossStreet
		, Location
		, SUBSTRING(Location, 16, 7) AS LAT
		, SUBSTRING(Location, 40, 9) AS LON
		, [Zip Codes] AS ZipCode
		, [Census Tracts] AS Census
		, [Precinct Boundaries] AS Precinct
		, [LA Specific Plans] AS LSP
		, [Council Districts] AS Districts
		, [Neighborhood Councils (Certified)] AS NCC 
	FROM [dbo].[Traffic_Collision_Data]
	)
, cte2 AS(

	SELECT --*
		DRNumber
		, [DateReported] 
		, [DateOccurred] 
		, CAST ([TimeOccurred] AS TIME) [TimeOccurred]        
		, AreaID
		, ReportingDistrict
		, CrimeCode
		, CrimeCodeDescription
		, MOCodes
		, CAST(VictimAge AS INT) VictimAge
		, VictimSex
		, VictimDescent
		, PremiseCode
		, PremiseDescription
		, [Address]
		, CrossStreet
		, Location
		, REPLACE(REPLACE(LAT, '''', ''), ',','') AS LAT
		, REPLACE(REPLACE(LON, '''', ''), ',','') AS LON
		, ZipCode
		, Census
		, Precinct
		, LSP
		, Districts
		, NCC  
	FROM cte
	)

	SELECT --*
		DRNumber
		, [DateReported] 
		, [DateOccurred] 
		, [TimeOccurred]        
		, AreaID
		, ReportingDistrict
		, CrimeCode
		, CrimeCodeDescription
		, MOCodes
		,  VictimAge
		, VictimSex
		, VictimDescent
		, PremiseCode
		, PremiseDescription
		, [Address]
		, CrossStreet
		, Location
		, CONVERT(FLOAT, LAT) AS LAT
		, CONVERT(FLOAT, LON) AS LON
		, ZipCode
		, Census
		, Precinct
		, LSP
		, Districts
		, NCC  
	INTO dbo.TCD
	FROM cte2
	WHERE LAT <> '0.0 ' AND LON <> ' human_'

	SELECT TOP 5 * 
	FROM dbo.TCD 

	SELECT DISTINCT LAT, LON FROM dbo.TCD  ORDER BY LAT

	--Filtered 77,451 0 age
	--Filtered 2 at 10 age

	SELECT * 
	FROM dbo.TCD WHERE VictimAge = 0 

	SELECT MIN(VictimAge) AS YoungestAge
		, MAX(VictimAge) AS OldestAge
		, AVG(VictimAge) AS AverageAge
	FROM dbo.TCD
	WHERE VictimAge <> 0 --AND VictimAge <> 10


	SELECT 
		YEARDateOccurred
		, VictimSex
		, VictimDescent 
		, MIN(VictimAge) AS YoungestAge
		, MAX(VictimAge) AS OldestAge
		, AVG(VictimAge) AS AverageAge 
	--INTO dbo.MinMaxAVG_Age	--DROP TABLE dbo.MinMaxAVG_Age
	FROM (	
		SELECT
			YEAR(DateOccurred) AS YEARDateOccurred
			, VictimSex
			, VictimDescent 
			, VictimAge
		FROM dbo.TCD
		--WHERE VictimSex = 'F' AND VictimDescent = 'H' AND YEAR(DateOccurred) = 2010
		--GROUP BY VictimSex
		--	, VictimDescent 
		--	, VictimAge
		) a
	GROUP BY 
		YEARDateOccurred
		, VictimSex
		, VictimDescent 
	HAVING MIN(VictimAge) > 0	

	--SELECT * FROM dbo.MinMaxAVG_Age WHERE YEARDateOccurred < 2019 ORDER BY YEARDateOccurred, VictimSex


	SELECT
		YEAR(DateOccurred) AS YEARDateOccurred
		, [Address]
		, COUNT(Address) AS Collisions
		
	--INTO dbo.AddressOfMostCollisions	--DROP TABLE dbo.AddressOfMostCollisions
	FROM dbo.TCD
	WHERE VictimAge <> 0
		AND YEAR(DateOccurred) < 2019
	GROUP BY DateOccurred, [Address]
	ORDER BY DateOccurred, Collisions DESC

	--SELECT * FROM dbo.AddressOfMostCollisions

	--SELECT 
	--	YEARDateOccurred
	--	, [Address]
	--	, SUM(Collisions) AS Collisions
	----INTO dbo.CollisionTimeSeriesAnalysis	--DROP TABLE dbo.CollisionTimeSeriesAnalysis
	--FROM dbo.AddressOfMostCollisions 
	--GROUP BY YEARDateOccurred
	--	, [Address]
	--HAVING SUM(Collisions) > 1
	--ORDER BY [Address], YEARDateOccurred, Collisions DESC

	----SELECT * FROM dbo.CollisionTimeSeriesAnalysis ORDER BY [Address], YEARDateOccurred

	--SELECT 
	--	[Address]
	--	, AVG(Collisions)
	--FROM dbo.CollisionTimeSeriesAnalysis 
	--GROUP BY [Address]
	----ORDER BY [Address], YEARDateOccurred

	--SELECT AVG(Collisions)
	--	--, YEARDateOccurred
	--	, [Address]
	--FROM(
	--	SELECT ROW_NUMBER() OVER(PARTITION BY [Address] ORDER BY YEARDateOccurred) AS CNT, * 
	--	FROM dbo.CollisionTimeSeriesAnalysis 
	--	--ORDER BY [Address], YEARDateOccurred
	--	) a
	--GROUP BY YEARDateOccurred
	--	, [Address]
	--	, Collisions
	--ORDER BY [Address], YEARDateOccurred




	--Time Series Analysis
	--Collect all the accients within an area and aggregate by month

	SELECT
		DateOccurred --AS YEARDateOccurred
		, [Address]
		, COUNT(Address) AS Collisions
		
	INTO dbo.AddressOfMostCollisions2	--DROP TABLE dbo.AddressOfMostCollisions2
	FROM dbo.TCD
	WHERE VictimAge <> 0
		--AND YEAR(DateOccurred) < 2019
	GROUP BY DateOccurred, [Address]
	ORDER BY DateOccurred, Collisions DESC

	--SELECT * FROM dbo.AddressOfMostCollisions2

	SELECT 
		CAST(DateOccurred AS DATE) AS DateOccurred
		, [Address]
		, SUM(Collisions) AS Collisions
	INTO dbo.CollisionTimeSeriesAnalysis2	--DROP TABLE dbo.CollisionTimeSeriesAnalysis2
	FROM(
		SELECT 
			CAST(LEFT(DateOccurred, 7) AS VARCHAR) + '-01' As DateOccurred
			--DateOccurred
			, [Address]
			, Collisions
		FROM dbo.AddressOfMostCollisions2 
		) a
	GROUP BY DateOccurred
		, [Address]
	HAVING SUM(Collisions) > 1
	ORDER BY [Address], DateOccurred, Collisions DESC

	--SELECT * FROM dbo.CollisionTimeSeriesAnalysis2 ORDER BY [Address], DateOccurred
	--SELECT * FROM dbo.AddressOfMostCollisions2 ORDER BY [Address], DateOccurred
	
	--BAGPLOT
	--> median(SqlStatement4)
	--6
	--> mean(SqlStatement4)
	--134.8847

	--SELECT * FROM dbo.CollisionTimeSeriesAnalysis2 WHERE Collisions > 3 ORDER BY [Address], DateOccurred
	
	--SUM BY YEAR
	--Now aggregate the accidents at the annual level

	SELECT 
		[Address]
		, YEAR(DateOccurred) AS YEAROccurred
		, SUM(Collisions) AS Collisions
	FROM dbo.CollisionTimeSeriesAnalysis2 
	--WHERE Collisions > 3
	GROUP BY [Address], DateOccurred
	ORDER BY Collisions DESC--, DateOccurred

	--SUM TOTAL BY ADDRESS
	SELECT Collisions
	FROM(
		SELECT 
			[Address]
			--, YEAR(DateOccurred) AS YEAROccurred
			, SUM(Collisions) AS Collisions
		FROM dbo.CollisionTimeSeriesAnalysis2 
		--WHERE Collisions > 3
		GROUP BY [Address]	--, DateOccurred
		--ORDER BY Collisions DESC--, DateOccurred
		) a ORDER BY Collisions DESC
			
	SELECT * 
	FROM dbo.CollisionTimeSeriesAnalysis2 
	WHERE Collisions > 3
	ORDER BY Collisions DESC, [Address]--, DateOccurred



	--USE THIS QUERY TO ANALYZE WHICH STREET TO FURTHER TRAFFIC CONTROL
	
	SELECT 
		[Address]
		, YEAR(DateOccurred) AS YEAROccurred
		, SUM(Collisions) AS Collisions
	INTO dbo.Bagplot	--DROP TABLE dbo.Bagplot
	FROM dbo.CollisionTimeSeriesAnalysis2 
	--WHERE Collisions > 3
	GROUP BY [Address], DateOccurred
	ORDER BY Collisions DESC--, DateOccurred



	SELECT DISTINCT
		CAST(DateOccurred AS DATE) AS DateOccurred
		, RTRIM(LTRIM([Address])) AS [Address]
		, SUM(Collisions) AS Collisions 
	INTO dbo.Bagplot_Address --DROP TABLE dbo.Bagplot_Address
	FROM dbo.CollisionTimeSeriesAnalysis2 
	WHERE [Address] IN('WESTERN', 'VERMONT' , 'VENTURA', 'SUNSET', 'SEPULVEDA')
	GROUP BY DateOccurred
		, [Address] 
	ORDER BY [Address], DateOccurred

	--SELECT * FROM dbo.Bagplot_Address

	--SELECT MIN(DateOccurred), MAX(DateOccurred)
	--FROM dbo.Bagplot_Address


	IF OBJECT_ID('tempdb..#Date_Table') IS NOT NULL DROP TABLE #Date_Table

	DECLARE @StartDate DATE = '20100101'
	 , @EndDate DATE = '20190601'

	SELECT  DATEADD(DAY, nbr - 1, @StartDate) AS DateName1
	INTO #Date_Table
	FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY c.object_id ) AS Nbr
			  FROM      sys.columns c
			) nbrs
	WHERE   nbr - 1 <= DATEDIFF(DAY, @StartDate, @EndDate)


	IF OBJECT_ID('tempdb..#Date_Table2') IS NOT NULL DROP TABLE #Date_Table2

	
	SELECT CONVERT(VARCHAR, DateName2, 1) AS DateName2
	INTO #Date_Table2
	FROM(
		SELECT CAST( DateName2 AS DATE) AS DateName2
		FROM(
			SELECT *, LEFT(CAST(DateName1 AS VARCHAR), 4) + '-' +  RIGHT(DateName1, 2) + '-' + SUBSTRING(CAST(DateName1 AS VARCHAR), 6, 2) AS DateName2
			FROM #Date_Table
			WHERE RIGHT(DateName1, 2) <= 12
			) a
		) b

	--SELECT * FROM #Date_Table2
	
	--SELECT a.*, b.*
	--FROM #Date_Table a
	--	LEFT JOIN dbo.Bagplot_Address b
	--		ON b.DateOccurred = a.DateName1


	--TIME SERIES ANALYSIS COMPLETE

	SELECT * 
	--INTO #Temp
	FROM dbo.Bagplot_Address
	ORDER BY Address, DateOccurred

	SELECT b.*, ROW_NUMBER() OVER(PARTITION BY address ORDER BY address) AS rw, a.address, a.collisions
	FROM dbo.Bagplot_Address a
		LEFT JOIN #Date_Table b
			ON b.DateName1 = a.DateOccurred 
	ORDER BY [Address], DateOccurred


;
WITH ORDEREDFOOS AS (
    SELECT ROW_NUMBER() OVER (PARTITION BY address ORDER BY address) RowNum, *
    FROM dbo.Bagplot_Address 
)
, OrderedBars AS (
    SELECT ROW_NUMBER() OVER (ORDER BY DateName2) RowNum, *
    FROM #Date_Table2 (NOLOCK)
				)
SELECT CAST(DateName2 AS DATE) DateName2, Address, CAST(collisions AS INT) AS collisions
INTO dbo.TimeSeriesAnalysis		--DROP TABLE dbo.TimeSeriesAnalysis
FROM ORDEREDFOOS f
    FULL OUTER JOIN OrderedBars u 
		ON u.RowNum = f.RowNum

SELECT DateName2, collisions 
--INTO dbo.SEPULVEDA
FROM dbo.TimeSeriesAnalysis WHERE Address = 'SEPULVEDA' ORDER BY DateName2
--SELECT * FROM dbo.TimeSeriesAnalysis WHERE Address = 'SUNSET' ORDER BY DateName2
--SELECT * FROM dbo.TimeSeriesAnalysis WHERE Address = 'VENTURA' ORDER BY DateName2
--SELECT * FROM dbo.TimeSeriesAnalysis WHERE Address = 'VERMONT' ORDER BY DateName2
--SELECT * FROM dbo.TimeSeriesAnalysis WHERE Address = 'WESTERN' ORDER BY DateName2


	/*
	--HACK TO FILL IN GAPS
	SELECT
		LEFT(CAST(DateOccurred AS VARCHAR), 7) + '-' + CAST(RW AS VARCHAR) AS DateOccurred
		, Collisions
	--INTO dbo.Bagplot_Address --DROP TABLE dbo.Bagplot_Address
	FROM(
		SELECT ROW_NUMBER() OVER(ORDER BY DateOccurred) AS RW
			, DateOccurred
			,  Collisions 
		
		FROM dbo.CollisionTimeSeriesAnalysis2 
		WHERE [Address] = 'WESTERN' 
		) a
	ORDER BY DateOccurred

	--SELECT * FROM dbo.Bagplot_Address
	*/
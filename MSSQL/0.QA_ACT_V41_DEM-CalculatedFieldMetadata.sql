/* ENACT QA view - QA_ACT_V41_DEMOGRAPHICS CALCULATED 
   v 0.1 - 20250331 - Darren W Henderson <darren.henderson@uky.edu>
   
   DESCRIPTION: FOR NON QUERY GENERATOR RELATED WORK WITH THE AGE METADATA THAT USES MYRIAD CALCULATIONS IN C_DIMCODE
   IT CAN BE QUITE DIFFICULT TO WRITE ELEGANT CODE. THIS TABLE IN THE QA SCHEMA WILL BE GENERATED FROM THIS SECTION OF THE
   DEMOGRAPHIC METADATA, AND INSTEAD OF STORING THE C_DIMCODE CALCULATION AS STATIC TEXT, THE LEFT AND RIGHT RANGES OF THE AGE CALCULATION
   WILL BE STORED AS CALCULATED FIELDS THAT WOULD BE ACCURATE AT RUN TIME ANY TIME THE TABLE IS JOINED TO BIRTH_DATE BETWEEN PREDICATE

*/
SET NOCOUNT ON;

DROP TABLE IF EXISTS #ACT_DEM;

SELECT C_NAME
    , C_FULLNAME
	, C_BASECODE AS AGE_CODE
	, TRY_CAST(FLOOR(TRY_CAST(REPLACE(C_BASECODE,'DEM|AGE:','') AS NUMERIC(4,2))) AS INT) AS AGE_CODE_INT
	, C_COLUMNNAME
	, C_OPERATOR
	, C_DIMCODE
	, REPLACE(CASE WHEN C_FULLNAME LIKE '%months\' THEN SUBSTRING(C_DIMCODE,CHARINDEX('MM',C_DIMCODE)+3,4) ELSE SUBSTRING(C_DIMCODE,CHARINDEX('YY',C_DIMCODE)+3,4) END,',','') AS LEFT_ADJUST
	, REPLACE(CASE WHEN C_FULLNAME LIKE '%months\' THEN SUBSTRING(C_DIMCODE,CHARINDEX('MM',C_DIMCODE,(CHARINDEX('MM',C_DIMCODE)+2))+3,4) ELSE SUBSTRING(C_DIMCODE,CHARINDEX('YY',C_DIMCODE,(CHARINDEX('YY',C_DIMCODE)+2))+3,4) END,',','') AS RIGHT_ADJUST
INTO #ACT_DEM
FROM I2B2ACT.DBO.ACT_DEM_V41
WHERE C_FULLNAME LIKE '\ACT\Demographics\Age%'
	AND NULLIF(C_BASECODE,'') IS NOT NULL
	AND C_VISUALATTRIBUTES = 'LA'
	AND C_NAME != 'Not recorded'
ORDER BY 2;

/* EVEN THOUGH I2B2 QUERIES OBFUSCATE AGES > 89 FOR THE QA CHECKS WE WANT TO CHECK AS MANY DISTINCT AGES POSSIBLE
   WE WILL CREATE SOME PSEUDO ACT DEM V41 METADATA FOR 90-120 YEAR OLDS 
   
   THESE EXTRA AGE RANGES CAN BE IGNORED BY FILTERING OUT THE C_FULLNAME NOT LIKE '\QA%'
   */

--90-99
INSERT INTO #ACT_DEM (C_NAME, C_FULLNAME, AGE_CODE, AGE_CODE_INT, C_COLUMNNAME, C_OPERATOR, C_DIMCODE, LEFT_ADJUST, RIGHT_ADJUST)
SELECT CONCAT(REPLACE(REPLACE(AGE_CODE,':8',':9'),'DEM|AGE:',''),' years old') AS C_NAME
	, CONCAT('\QA\Demograhics\Age\90-99 years old\',CONCAT(REPLACE(REPLACE(AGE_CODE,':8',':9'),'DEM|AGE:',''),' years old')) AS C_FULLNAME
	, REPLACE(AGE_CODE,':8',':9') AS AGE_CODE
	, AGE_CODE_INT+10 AS AGE_CODE_INT
	, C_COLUMNNAME
	, C_OPERATOR
	, REPLACE(REPLACE(C_DIMCODE,'-90','-100'),'-8','-9') AS C_DIMCODE
	, LEFT_ADJUST-10 AS LEFT_ADJUST
	, RIGHT_ADJUST-10 AS RIGHT_ADJUST
FROM #ACT_DEM
WHERE AGE_CODE_INT BETWEEN 80 AND 89;

--100-109
INSERT INTO #ACT_DEM (C_NAME, C_FULLNAME, AGE_CODE, AGE_CODE_INT, C_COLUMNNAME, C_OPERATOR, C_DIMCODE, LEFT_ADJUST, RIGHT_ADJUST)
SELECT CONCAT(REPLACE(REPLACE(AGE_CODE,':9',':10'),'DEM|AGE:',''),' years old') AS C_NAME
	, CONCAT('\QA\Demograhics\Age\100-109 years old\',CONCAT(REPLACE(REPLACE(AGE_CODE,':9',':10'),'DEM|AGE:',''),' years old')) AS C_FULLNAME
	, REPLACE(AGE_CODE,':9',':10') AS AGE_CODE
	, AGE_CODE_INT+10 AS AGE_CODE_INT
	, C_COLUMNNAME
	, C_OPERATOR
	, REPLACE(REPLACE(C_DIMCODE,'-100','-110'),'-9','-10') AS C_DIMCODE
	, LEFT_ADJUST-10 AS LEFT_ADJUST
	, RIGHT_ADJUST-10 AS RIGHT_ADJUST
FROM #ACT_DEM
WHERE AGE_CODE_INT BETWEEN 90 AND 99;

--110-119
INSERT INTO #ACT_DEM (C_NAME, C_FULLNAME, AGE_CODE, AGE_CODE_INT, C_COLUMNNAME, C_OPERATOR, C_DIMCODE, LEFT_ADJUST, RIGHT_ADJUST)
SELECT CONCAT(REPLACE(REPLACE(AGE_CODE,':10',':11'),'DEM|AGE:',''),' years old') AS C_NAME
	, CONCAT('\QA\Demograhics\Age\110-119 years old\',CONCAT(REPLACE(REPLACE(AGE_CODE,':10',':11'),'DEM|AGE:',''),' years old')) AS C_FULLNAME
	, REPLACE(AGE_CODE,':10',':11') AS AGE_CODE
	, AGE_CODE_INT+10 AS AGE_CODE_INT
	, C_COLUMNNAME
	, C_OPERATOR
	, REPLACE(REPLACE(C_DIMCODE,'-110','-120'),'-10','-11') AS C_DIMCODE
	, LEFT_ADJUST-10 AS LEFT_ADJUST
	, RIGHT_ADJUST-10 AS RIGHT_ADJUST
FROM #ACT_DEM
WHERE AGE_CODE_INT BETWEEN 100 AND 109;

--110-119
INSERT INTO #ACT_DEM (C_NAME, C_FULLNAME, AGE_CODE, AGE_CODE_INT, C_COLUMNNAME, C_OPERATOR, C_DIMCODE, LEFT_ADJUST, RIGHT_ADJUST)
SELECT CONCAT(REPLACE(REPLACE(AGE_CODE,':119',':120'),'DEM|AGE:',''),' years old') AS C_NAME
	, CONCAT('\QA\Demograhics\Age\120 years old\',CONCAT(REPLACE(REPLACE(AGE_CODE,':119',':120'),'DEM|AGE:',''),' years old')) AS C_FULLNAME
	, REPLACE(AGE_CODE,':119',':120') AS AGE_CODE
	, AGE_CODE_INT+1 AS AGE_CODE_INT
	, C_COLUMNNAME
	, C_OPERATOR
	, REPLACE(REPLACE(C_DIMCODE,'-120','-121'),'-119','-120') AS C_DIMCODE
	, LEFT_ADJUST-1 AS LEFT_ADJUST
	, RIGHT_ADJUST-1 AS RIGHT_ADJUST
FROM #ACT_DEM
WHERE AGE_CODE_INT = 119;

/* CREATE TABLE WITH COMPUTED FIELDS !! NOT PERSISTED !! TO MIMIC QUERY GENERATOR LOGIC AT RUNTIME WHEN JOINING TO THIS TABLE WITH A DATE BETWEEN LEFT_DT_COMPARE AND RIGHT_DT_COMPARE */

DROP TABLE IF EXISTS QA.QA_ACT_V41_DEMOGRAPHICS;

CREATE TABLE QA.QA_ACT_V41_DEMOGRAPHICS (
	C_NAME VARCHAR(2000),
	C_FULLNAME VARCHAR(700),
	C_BASECODE VARCHAR(50),
	AGE_CODE_INT INT,
	C_COLUMNNAME VARCHAR(50),
	C_OPERATOR VARCHAR(10),
	C_DIMCODE VARCHAR(700),
	LEFT_ADJUST INT,
	RIGHT_ADJUST INT,
	LEFT_DT_COMPARE AS CAST(CASE WHEN C_FULLNAME LIKE '%months\' THEN DATEADD(MM,LEFT_ADJUST,DATEADD(DD,1,GETDATE())) ELSE DATEADD(YY,LEFT_ADJUST,DATEADD(DD,1,GETDATE())) END AS DATE),
	RIGHT_DT_COMPARE AS CAST(CASE WHEN C_FULLNAME LIKE '%months\' THEN DATEADD(MM,RIGHT_ADJUST,GETDATE()) ELSE DATEADD(YY,RIGHT_ADJUST,GETDATE()) END AS DATE)
);

INSERT INTO QA.QA_ACT_V41_DEMOGRAPHICS (C_NAME, C_FULLNAME, C_BASECODE, AGE_CODE_INT, C_COLUMNNAME, C_OPERATOR, C_DIMCODE, LEFT_ADJUST, RIGHT_ADJUST)
SELECT C_NAME, C_FULLNAME, AGE_CODE, AGE_CODE_INT, C_COLUMNNAME, C_OPERATOR, C_DIMCODE, LEFT_ADJUST, RIGHT_ADJUST
FROM #ACT_DEM;

-- TESTING
-- SELECT * FROM QA.QA_ACT_V41_DEMOGRAPHICS

SELECT QD.C_NAME, QD.C_BASECODE, QD.AGE_CODE_INT, COUNT(DISTINCT P.PATIENT_NUM) CNTD_PATIENT
FROM PATIENT_DIMENSION P
	JOIN QA.QA_ACT_V41_DEMOGRAPHICS QD
		ON P.BIRTH_DATE BETWEEN QD.LEFT_DT_COMPARE AND QD.RIGHT_DT_COMPARE
GROUP BY QD.C_NAME, QD.C_BASECODE, QD.AGE_CODE_INT
ORDER BY AGE_CODE_INT ASC, C_NAME ASC;
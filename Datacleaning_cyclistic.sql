-- Create the Cyclistic database with physical data/log files
CREATE DATABASE cyclistic
ON PRIMARY(
	NAME = cyclistic_data,
	FILENAME = 'C:\Data_Analytics\Cyclistic_Project\database\cyclistic.mdf'
	)
LOG ON (
	NAME = cyclistic_log,
	FILENAME = 'C:\Data_Analytics\Cyclistic_Project\database\cyclistic_log.ldf'
);
-- Select the Cyclistic database
GO
USE cyclistic;
GO

-- Create the raw_trips table to store unprocessed CSV data
CREATE TABLE raw_trips (
	ride_id VARCHAR(50),
	rideable_type VARCHAR(50),
	start_at DATETIME,
	end_at DATETIME,
	start_station_name VARCHAR(255),
	start_station_id VARCHAR(50),
	end_station_name VARCHAR(255),
	end_station_id VARCHAR(50),
	start_lat FLOAT,
	start_lng FLOAT,
	end_lat FLOAT,
	end_lng FLOAT,
	member_casual VARCHAR(20)
);

-- enable anvanced options
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
-- Enable xp_cmdshell to allow reading file directory from SQL Server
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

-- Folder path containing multiple CSV files
DECLARE @path NVARCHAR(500) = 'C:\Data_Analytics\Cyclistic_Project\raw_seperated_file_divvy-tripdata-2024\';
DECLARE @file NVARCHAR(255);
DECLARE @sql NVARCHAR(MAX);

-- Temp table to store CSV filenames
CREATE TABLE #files (filename NVARCHAR(255));

-- Insert file names using xp_cmdshell (returns bare list of filenames)
INSERT INTO #files
EXEC master.dbo.xp_cmdshell 'dir "C:\Data_Analytics\Cyclistic_Project\raw_seperated_file_divvy-tripdata-2024\*.csv" /b';

-- Remove NULL or empty rows returned by xp_cmdshell
DELETE FROM #files WHERE filename IS NULL OR filename = '';

-- iterate through each CSV file
DECLARE file_cursor CURSOR FOR 
SELECT filename FROM #files;

OPEN file_cursor;
FETCH NEXT FROM file_cursor INTO @file;

WHILE @@FETCH_STATUS = 0
BEGIN
	-- Build dynamic BULK INSERT command for each file
    SET @sql = '
    BULK INSERT raw_trips
    FROM ''' + @path + @file + '''
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        ROWTERMINATOR = ''\n'',
        FORMAT = ''CSV'',
        TABLOCK
    );
    ';

    PRINT 'Importing: ' + @file;
    EXEC (@sql);

    FETCH NEXT FROM file_cursor INTO @file;
END

-- Close and deallocate cursor
CLOSE file_cursor;
DEALLOCATE file_cursor;

-- Drop temporary file list table
DROP TABLE #files;

-- Create cleaned_trips table excluding records with missing BOTH start and end location info
SELECT *
INTO cleaned_trips
FROM raw_trips
WHERE NOT (
	start_station_name IS NULL
	AND start_lat IS NULL
	AND start_lng IS NULL
)
AND NOT (
	end_station_name IS NULL 
	AND end_lat IS NULL 
	AND end_lng IS NULL
);

-- Create reference table for station names and coordinates
SELECT DISTINCT
	start_station_name AS station_name,
	start_lat AS lat,
	start_lng AS lng
INTO station_reference
FROM raw_trips
WHERE start_station_name IS NOT NULL
	AND start_lat IS NOT NULL
	AND start_lng IS NOT NULL;

-- Create reference table for station name → station ID mapping
SELECT DISTINCT
	start_station_name AS sn,
	start_station_id AS si
INTO station_reference_ID
FROM raw_trips
WHERE start_station_name IS NOT NULL AND start_station_id IS NOT NULL

-- Fill missing start_station_name using the nearest station based on coordinates
UPDATE c
SET start_station_name = s.station_name
FROM cleaned_trips c
CROSS APPLY (
	SELECT TOP 1 station_name
	FROM station_reference
	ORDER BY 
		POWER(c.start_lat - lat, 2) +
		POWER(c.start_lng - lng, 2)
) s
WHERE c.start_station_name IS NULL
	AND c.start_lat IS NOT NULL
	and C.start_lng IS NOT NULL;

-- Fill missing end_station_name using the nearest station based on coordinates
UPDATE c
SET end_station_name = s.station_name
FROM cleaned_trips c
CROSS APPLY (
	SELECT TOP 1 station_name
	FROM station_reference
	ORDER BY 
		POWER(c.end_lat - lat, 2) +
		POWER(c.end_lng - lng, 2)
)s
WHERE c.end_station_name IS NULL
	AND C.end_lat IS NOT NULL
	AND c.end_lng IS NOT NULL

-- Fill missing start_station_id
UPDATE c
SET c.start_station_id = s.si
FROM cleaned_trips c
JOIN station_reference_ID AS s
	ON c.start_station_name = s.sn
WHERE c.start_station_name IS NOT NULL AND c.start_station_id IS NULL

-- Fill missing end_station_id
UPDATE c
SET c.end_station_id = s.si
FROM cleaned_trips c
JOIN station_reference_ID AS s
	ON c.end_station_name = s.sn
WHERE c.end_station_name IS NOT NULL AND c.end_station_id IS NULL

-- Identify records where start time >= end time
SELECT 
    start_at, end_at, DATEDIFF(SECOND, start_at, end_at) AS duration
FROM cleaned_trips
WHERE start_at >= end_at

-- Delete trips with zero or negative duration
DELETE FROM cleaned_trips
WHERE DATEDIFF(SECOND, start_at, end_at) <= 0

-- Check duplicate ride_id values
SELECT ride_id, COUNT(*) AS cnt
FROM cleaned_trips
GROUP BY ride_id
HAVING COUNT(*) > 1;

-- Remove duplicate ride_id using ROW_NUMBER
WITH dup AS (
	SELECT *,
	ROW_NUMBER () OVER (
		PARTITION BY ride_id
		ORDER BY (SELECT NULL)
	) AS rn
	FROM cleaned_trips
)
DELETE FROM dup
WHERE rn > 1

SELECT *
FROM cleaned_trips
WHERE DATEDIFF(MINUTE, start_at, end_at) <= 2

-- Remove outliers having duration <= 1 minutes
WITH outlier AS (
	SELECT *
	FROM cleaned_trips
	WHERE DATEDIFF(MINUTE, start_at, end_at) <= 1
)
DELETE FROM outlier


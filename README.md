<img width="150" height="150" alt="1_UR6gxnrCBs7ra72J0UqLRg" src="https://github.com/user-attachments/assets/d94a2d2f-804f-40b6-85ac-cba7bda4d3e8" />

# Case Study: How does a bike-share navigate speedy success?

  ## Introduction:
  Huy Nguyen performed the Cyclistic bike-share analysis case study in December 2025 as a capstone for the Google Data Analytics Certificate. In this case study, I work for a fictonal company, along with the marketing analytics team. This Analysis follow the data analysis process: ASK, PREPARE, PROCESS, ANALYZE, SHARE, ACT and used both SQL and Tableau to answer key business questions and develop data-drive recommendations between January and December in 2024.
  
  ## Scenario:
  You are a junior data analyst working on the marketing analyst team at Cyclistic, a bike-share
  company in Chicago. The director of marketing believes the company’s future success
  depends on maximizing the number of annual memberships. Therefore, your team wants to
  understand how casual riders and annual members use Cyclistic bikes differently. From these
  insights, your team will design a new marketing strategy to convert casual riders into annual
  members. But first, Cyclistic executives must approve your recommendations, so they must be
  backed up with compelling data insights and professional data visualizations.
  
  ## Quick Link:
  
  ##### Data Source: https://divvy-tripdata.s3.amazonaws.com/index.html
  
  ##### SQL Code: https://github.com/minhhuy2112006/Cyclistic_Bike_Share_Analysis
  
  ##### Visualization: https://public.tableau.com/app/profile/nguyen.huy8691/viz/CyclisticBike-ShareAnalysis2024Dashboard/CyclisticDashBoard2024?publish=yes
  ## Description:
  
  #### About company:
  In 2016, Cylistic launched a successful bike-share offering. Since then, the program has grown to a fleet of 5,824 bicycles that are geotracked and locked into a network of 692 stations across Chicago. The bikes can be unlocked from one station and returned to any other station in the system anytime.
  
  ##### Cyclistic sets itself apart by offering:

  - Classic bike
  - Electric bike
  - Electric scooter
  
  #### User types:
  - **Casual riders**: Customers who purchase single-ride or full-day passes
  - **Annual members**: Customers who purchase annual memberships

  #### Business Context:
  Cyclistic's finance analysts have concluded that annual members are much more profitable than casual riders. Although the pricing flexibility helps Cyclistic attract more customers, the director of marketing (Lily Moreno) believes that maximizing the number of annual members will be key to future growth. Rather than creating a marketing campaign that targets all-new customers, Moreno believes there is a solid opportunity to convert casual riders into members since casual riders are already aware of the Cyclistic program and have chosen Cyclistic for their mobility needs.
  
  ## The steps of the data analysis process
  
  ### 1. Ask:
  
  ##### Business Task:
  Analyze Cyclistic historical bike trip data (2024) to identify usage patterns and the difference between casual riders and annual members to inform targeted marketing strategies aimed at converting casual riders into annual members.
  
  ##### Analysis Questions:
  1. How do annual members and casual riders use Cyclistic bikes differently?
  2. Why would casual riders buy Cyclistic annual memberships?
  3. How can Cyclistic use digital media to influence casual riders to become members?
     
  ##### Stakeholder:

  - **Lily Moreno:** Director of Marketing, responsible for campaign development and promotional initiatives.
  - **Cyclistic Marketing Analytics Team:** Data analysts responsible for collecting, analyzing, and reporting data to guide marketing strategy. 
  - **Cyclistic Executive Team:** Detail-oriented team that will approve the recommended marketing program.

  ### 2. Prepare:
  
  #### Data Source Description:
  **Dataset:** Cyclistic trip data for the full year 2024 (January - December).
  **Source:** Divvy Bikes (Operated by Lyft), publicly available.
  **Format:** 12 CSV Files (one per month), containing ride-level data.
  
  **Key Fields:**
  - `ride_id`: Unique identifier for each trip.
  - `rideable_type`: Type of bike (classic_bike, electric_bike, electric_scooter)
  - `start_at`, `end_at`: Datetime of trip start and end
  - `start_station_name` , `start_station_id`: Starting station information
  - `end_station_name` , `end_station_id`: Ending station information
  - `start_lat` , `start_lng` , `end_lat` , `end_lng`: Geographic coordinates (Longitude, Latitude)
  - `member_casual`: User type (member or casual)

  <img width="1395" height="601" alt="image" src="https://github.com/user-attachments/assets/1c8af7b5-6d19-4c03-b7df-be66e3cec362" />

  ##### Data Credibility (ROCCC):
  - **Reliable:** First-party data collected directly from Cyclistic's bike-share system
  - **Original:** Primary source data from actual bike trips.
  - **Comprehensive:** Contains 5.67+ million trip records covering all of 2024. 
  - **Current:** Most recent full-year dataset available (2024).
  - **Cited:** Published by Motivate International Inc. under appropriate license.

  ##### Limitations:
  - Missing station information for some trips (resolved through coordinate-based imputation).
  - No demographics data about riders (age, gender, location).
  - No pricing or revenue information.
  - Data privacy restrictions prevent identifying individual users.
  
  #### License
  The data has been made available by Motivate International Inc. under this https://divvybikes.com/data-license-agreement
  
  ### 3. Process:
  **1. Tool Used**
  
  **- SQL Server:** Data creation, Data cleaning and analysis.
  **- Tableau:** Data visualization and Dashboard Creation
  
  **2. Organize**
  Created a dedicated SQL Server database with physical data files and imported 12 monthly CSV Files using dynamic BULK INSERT operation
  ```sql
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
  ```
  
  **3. Data Cleaning**
	In the SQL Query File database_cyclistic:
  **Reference Tables:** 
  Created tables to support handling missing values

  - `station_reference`: Unique stations with coordinates (longitude, latitude)
  - `station_reference_ID:` station name to ID mappings

  **Missing Values Handling:**

  - Removed records missing BOTH start and end location information (start - end location name and their coordinates)
  ```sql
  SELECT DISTINCT
  	start_station_name AS station_name,
  	start_lat AS lat,
  	start_lng AS lng
  INTO station_reference
  FROM raw_trips
  WHERE start_station_name IS NOT NULL
  	AND start_lat IS NOT NULL
  	AND start_lng IS NOT NULL;
  ```
  - Imputed missing station names using nearest station based on coordinates (Euclidean distance)
  ```sql
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
  ```
  - Imputed missing station IDs by matching station names to reference table.
  ```sql
  UPDATE c
  SET c.start_station_id = s.si
  FROM cleaned_trips c
  JOIN station_reference_ID AS s
  	ON c.start_station_name = s.sn
  WHERE c.start_station_name IS NOT NULL AND c.start_station_id IS NULL
  ```

  **Data Quality Issues:**
  - **Invalid trip durations:** Deleted all trips where start time >= end_time
  ```sql
  DELETE FROM cleaned_trips
  WHERE DATEDIFF(SECOND, start_at, end_at) <= 0
  ```

  - **Duplicate ride IDs:** Removed duplicate entries using `ROW_NUMBER()`
  ```sql
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
  ```

  - **Outlier trips:** Removed trips <= 1 minute duration (False starts or system errors)
  ```sql
  WITH outlier AS (
  	SELECT *
  	FROM cleaned_trips
  	WHERE DATEDIFF(MINUTE, start_at, end_at) <= 1
  )
  DELETE FROM outlier
  ```
  **Final Dataset:** `cleaned_trips` table with 5,674,282 valid trip records
  
  ### 4. Analyze:
  **Key Findings**
  
  **User Distribution:** 
  - **Annual Members:** 63.58% of total rides (3,607,976 trips) 
  - **Casual Riders:** 36.42% of total rides (2,066,306 trips)
  ```sql
  SELECT member_casual, 
  COUNT(ride_id)  AS Total_Rides,
  CAST(100.0 * COUNT(ride_id) / SUM(COUNT(ride_id)) OVER() AS decimal(5,2)) AS pct_over_total
  FROM cleaned_trips
  GROUP BY member_casual
  ```
  ****

  ### 5. Share:
  ### 6. Act:

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

  <img width="600" height="400" alt="image" src="https://github.com/user-attachments/assets/1c8af7b5-6d19-4c03-b7df-be66e3cec362" />

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
  **Final Dataset:** `cleaned_trips` table with 5.674.282 valid trip records
  
  ### 4 + 5. Analyze and Share:
  
  **Key Findings**

  <img width="150" height="90" alt="image" src="https://github.com/user-attachments/assets/b574faa5-3a49-4736-ac0e-965b23662b12" /><br><br>
  **User Distribution:** 
  - **Annual Members:** **63,58%** of total rides (**3.607.976** trips) 
  - **Casual Riders:** **36,42%** of total rides (**2.066.306** trips)

  **SQL Code:**
  ```sql
  SELECT member_casual, 
  COUNT(ride_id)  AS Total_Rides,
  CAST(100.0 * COUNT(ride_id) / SUM(COUNT(ride_id)) OVER() AS decimal(5,2)) AS pct_over_total
  FROM cleaned_trips
  GROUP BY member_casual
  ```
  **Visualization:**
  
  <img width="400" height="200" alt="image" src="https://github.com/user-attachments/assets/354d7e5f-da9d-443a-9b71-e46a35e30dd2" />

  **Insight:**
  
  - While members dominate overall usage, casual riders represent a significant market segment with conversion potential.

  **Ride Duration Pattern:**
  
  **SQL Code:**
  
  ```sql
  -- Average and median ride duration by user type
-- Duration Table
WITH durations AS (
	SELECT member_casual, 
		   DATEDIFF(MINUTE, start_at, end_at) AS duration
	FROM cleaned_trips
),
-- Average durations table
avg_table AS (
	SELECT member_casual,
		   AVG(duration) AS avg_duration
	FROM durations
	GROUP by member_casual
),
-- Median durations table
median_table AS (
	SELECT DISTINCT member_casual,
		   PERCENTILE_CONT(0.5)
		   WITHIN GROUP (ORDER BY duration)
		   OVER (PARTITION BY member_casual) AS median_duration
	FROM durations
)

SELECT a.member_casual,
	   a.avg_duration,
	   m.median_duration
FROM avg_table as a
JOIN median_table as m
ON a.member_casual = m.member_casual
  ```
  **Visualization:**
  
  <img width="350" height="350" alt="image" src="https://github.com/user-attachments/assets/afa613c4-0ca2-47c4-8749-8cf612ddcb0c" />

  **Insights:**
  - Casual riders take loger trips (**average: 21m, median: 13m**) reflecting more leisure-oriented behavior. In constrast, members have shorter and more consistent ride durations (**average: 12m, median: 9m**) indicating frequent, purpose-driven usage.
  
  **Peak Usage Times and Weekly Usage Patterns**

  **Peak Usage Times SQL Code:**

  ```sql
WITH hourly_counts AS (
-- 1. Calculate the total rides per hour for each rider type
	SELECT DATEPART(HOUR,start_at) AS hour_of_days,
		   member_casual,
		   COUNT(*) AS total_ride_hours
	FROM cleaned_trips
	GROUP BY DATEPART(HOUR,start_at),
			 member_casual
),
ranked_hours as (
-- 2. Rank the hours within each rider type based on total_rides (descending)
	SELECT *,
	-- Assign a rank to each hour, partitioned by member_casual
		ROW_NUMBER () OVER (
			PARTITION BY member_casual
			ORDER BY total_ride_hours DESC
		) AS rn
	FROM hourly_counts
)
-- 3. Select only the top 3 ranked hours for both rider types
SELECT hour_of_days,
	   member_casual,
	   total_ride_hours,
	   CAST(
        100.0 * total_ride_hours
        / SUM(total_ride_hours) OVER (PARTITION BY member_casual)
        AS DECIMAL(5,2)
    ) AS percent_of_rides
FROM ranked_hours
WHERE rn <= 3
ORDER BY member_casual, total_ride_hours DESC;
  ```
  **Weekly Usage Patterns SQL Code:**

```sql
WITH day_total_ride AS (
SELECT
    DATENAME(WEEKDAY, start_at) AS day_of_week,
	member_casual,
    COUNT(*) AS total_rides
FROM cleaned_trips
GROUP BY DATENAME(WEEKDAY, start_at),
		member_casual
)
, 
ranked_day_ride AS (
	SELECT *, ROW_NUMBER () OVER (
		PARTITION BY (member_casual)
		ORDER BY total_rides DESC
	) AS rn
	FROM day_total_ride
),
weekly_total AS (
    SELECT
        member_casual,
        SUM(total_rides) AS weekly_rides
    FROM day_total_ride
    GROUP BY member_casual
)
SELECT
    r.day_of_week,
    r.member_casual,
    r.total_rides,
    CAST(
        100.0 * r.total_rides / w.weekly_rides
        AS DECIMAL(5,2)
    ) AS pct_day_over_total
FROM ranked_day_ride r
JOIN weekly_total w
    ON r.member_casual = w.member_casual
WHERE r.rn <= 3
ORDER BY r.member_casual, r.total_rides DESC;
  ```
  **Visualization:**
  
  **Member:**
  
  <img width="400" height="400" alt="image" src="https://github.com/user-attachments/assets/eab6029e-777d-464b-91e0-7af4f175de50" />

  **Casual:**

  <img width="400" height="400" alt="image" src="https://github.com/user-attachments/assets/28d494ee-2b62-43c9-b816-88c945994163" />
  
  **Insights:**
  
  - The chart highlights clear differences in usage behavior between members and casual riders. Members show stable demand on weekdays, with two distinct peak periods in the morning **(7–9 AM)** and especially in the late afternoon **(4–6 PM)**, reflecting typical work–home commuting patterns. Their activity drops significantly on weekends, indicating lower reliance on bikes for leisure purposes.

  - In contrast, casual riders experience a strong increase in usage on weekends, while still exhibiting a clear peak during the **4–6 PM** time window, particularly from Friday to Sunday. Their usage is more evenly distributed throughout the day and less pronounced during the morning peak, suggesting that casual riders primarily use the service for leisure activities, social outings, or flexible post-work travel. These differences imply that operations should prioritize weekday peak-hour efficiency for members, while enhancing service availability and experience during weekend late-afternoon and evening periods for casual riders.

  **Seasonal Trends**
  ```sql
  WITH Month_total_ride AS (
SELECT
    DATENAME(MONTH, start_at) AS month_of_year,
	member_casual,
    COUNT(*) AS total_rides
FROM cleaned_trips
GROUP BY DATENAME(MONTH, start_at),
		member_casual
)
, 
ranked_MONTH_ride AS (
	SELECT *, ROW_NUMBER () OVER (
		PARTITION BY (member_casual)
		ORDER BY total_rides DESC
	) AS rn
	FROM Month_total_ride
)
, monthly_total AS (
	SELECT
        member_casual,
        SUM(total_rides) AS monthly_rides
    FROM Month_total_ride
    GROUP BY member_casual
)
SELECT month_of_year,
	   r.member_casual,
	   total_rides,
	   CAST (100.0 * total_rides / m.monthly_rides AS DECIMAL(5,2)) AS pct_month_over_total
FROM ranked_MONTH_ride as r
JOIN monthly_total as m
ON r.member_casual = m.member_casual
WHERE rn <= 3
ORDER BY r.member_casual, rn;
  ```
**Visualization:**

<img width="450" height="450" alt="image" src="https://github.com/user-attachments/assets/1c2909b7-421d-46ff-a4ba-110e3d2139ab" />

**Insights:**

- Looking at the annual timeline, both members and casual riders show increasing usage as the year moves into warmer months, followed by a sharp decline during winter. However, the way each group responds to seasonality differs significantly.

- For members, trip volumes remain relatively substantial even in colder months, indicating a stable baseline demand driven by routine, utilitarian travel. As conditions improve from spring through summer, total trips increase not because the purpose of use changes, but because frequency and willingness to choose biking rise, which gradually widens the gap compared to casual riders.

- In contrast, casual riders display a strongly seasonal pattern. Their trip volumes drop sharply in winter and increase meaningfully only during warmer months, suggesting that their usage is largely voluntary and highly dependent on favorable weather. When conditions are less suitable, demand largely disappears.

- Overall, the data tells a clear story: members provide year-round stability for the system, while casual riders amplify demand during peak seasons. This implies that operational and growth strategies should follow two different rhythms-ensuring consistent reliability for members throughout the year, while leveraging peak seasons to attract, engage, and potentially convert casual riders.

  **Station Hotspots**

  	```sql
	WITH station_stats AS (
	    SELECT 
	        start_station_name,
	        member_casual,
	        COUNT(*) AS total_rides,
	        CAST(
	            100.0 * COUNT(*) 
	            / SUM(COUNT(*)) OVER (PARTITION BY member_casual)
	            AS DECIMAL(5,2)
	        ) AS pct_hotspot_location,
	        ROW_NUMBER() OVER (
	            PARTITION BY member_casual 
	            ORDER BY COUNT(*) DESC
	        ) AS rn
	    FROM cleaned_trips
	    GROUP BY start_station_name, member_casual
	)
	SELECT 
	    start_station_name,
	    member_casual,
	    total_rides,
	    pct_hotspot_location
	FROM station_stats
	WHERE rn <= 10
	ORDER BY member_casual, total_rides DESC;
	 ```

  **Visualization:**
  
  <img width="400" height="400" alt="image" src="https://github.com/user-attachments/assets/018f7a48-5fa3-414c-8c7c-e62a284415be" />
  &nbsp;&nbsp;&nbsp;
  <img width="400" height="400" alt="image" src="https://github.com/user-attachments/assets/c8aa1d04-d014-4a9a-9802-e57fa8cf37ae" />


  **Insight:**
  
  - Casual riders are highly concentrated at tourism and leisure-oriented stations, with a higher level of concentration compared to member riders.
  - **Streeter Dr & Grand Ave** leads among casual users, accounting for **2,43**% of total casual trips, indicating strong demand in areas near parks, waterfronts, and major attractions.
  - In contrast, member riders exhibit a more even distribution of trips, with no single station exceeding **1,15%**, reflecting routine, commute-driven usage patterns.
  
  **Bike Type Preferences**
  ```sql
  SELECT
    member_casual,
    rideable_type,
    COUNT(*) AS total_rides,
    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY member_casual) AS decimal(5,2)
    ) AS pct_within_user
  FROM cleaned_trips
  GROUP BY
    member_casual,
    rideable_type
  ORDER BY member_casual, pct_within_user DESC;
  ```
  **Visualization:**
  
  <img width="850" height="400" alt="image" src="https://github.com/user-attachments/assets/8e2a247b-f226-4c5e-9f2d-6b6193b44036" />

  **Insights:**
  
- Casual users are not a weak customer segment, they are users who have not been converted at the right moment. During peak periods-especially in summer-Casual usage increases significantly, indicating a high willingness to use the service frequently, but without a strong enough incentive to commit long-term.

- Members maintain stable usage throughout the year, reflecting the core value of the subscription model and highlighting a substantial conversion opportunity from the existing Casual base.

- Electric Bikes represent the most natural conversion channel, as Casual usage behavior in this segment is closer to that of Members compared to Classic Bikes, making it the most suitable product to drive long-term subscriptions.

- Electric Scooters, despite being available only in August–September, generated approximately 80.000 Casual trips in September alone, demonstrating a strong and meaningful demand for short-term, experience-driven usage. Scooters should not be treated as a direct Member conversion channel, but rather as a top-of-funnel touchpoint that attracts and activates Casual users before guiding them toward Electric Bikes.

### 6. Act:

Based on the analysis, I recommend the following three-pillar marketing strategy to convert casual riders into annual members:

**1. Targeted Messaging Campaign: "Commuter Casual"**

**Target Audience: Casual riders who:**

- Ride during weekday peak commuting hours, particularly evening commute **(4 - 6 PM)**.

- Using bikes consistently on weekdays.
  
**Tactics**

- **In-app messaging:** Trigger membership benefit messages after users complete a weekday commute-pattern trip.

- **Cost Comparison Calculator:** Display potential monthly saving after 3 - 4 weekday rides.

- **Testimonials:** Feature stories from members who previously used Cyclistic for one-way commuting.

- **Limited-time offer:** "Commuter Pass" - a discounted annual membership for riders with 3+ weekday commute rides.

**Expected Impact:**
  
Target approximately **26,5%** of the casual rider base **(~548.000 riders)** who exhibit member-like commuting behavior and high conversion potential.
  
**2. Seasonal Conversion Campaign: "Autumn Savings"**

**Timing:** Launch in **July**, with peak messaging in **September**

**Target Audience:** High-frequency casual riders during late summer - early fall months **(July - September)**

**Tactics:**
  
- **Early - Fall Offer:** "Lock in fall rates" with discounted membership in July - August
  
- **Ride Milestone Rewards:** "You’ve taken 10 rides this month! A membership would save you $X" **(Triggered during August – September when usage peaks)**
  
- **Weekend Explorer package:** Emphasize **unlimited weekend rides** for fall activities, events and cooler - weather commuting.
  
- **Referal Program:** Existing members receive incentives for referring casual riders during **peak September demand**.
  
**Expected Impact:**
Leverage peak fall ridership, especially in September, when casual rider engagement is highest and weather conditions remain favorable - maximizing conversion to membership before winter decline.

**3. Station-Based Geo-Targeted Campaigns**

**Target Audience:** High - Frequency Casual riders

**Location Strategy:** Focus on top Casual-heavy stations with high repeat usage
- Streeter Dr & Grand Ave
- DuSable Lake Shore Dr & Monroe St
- Michigan Ave & Oak St
- Wells St & Concord Ln

**Tactics:**
    
- **QR Code Signage:** Placed at high-traffic stations, linking to a Membership landing page with station-specific, personalized savings information.
  
- **Digital Kiosks:** Interactive kiosks at dock stations that let users input their ride frequency to see a “See Your Savings” comparison (Casual vs Member).
  
- **Geofenced Mobile Ads:** In-app or mobile ads shown only to users within a 0.5-mile radius of key stations.
  
- **Partnership Promotions:** Collaborations with nearby businesses (coffee shops, gyms, retail) to offer member-only perks, increasing the perceived value of Membership.
  
**Expected Impact:** These tactics are expected to increase Casual → Membership conversion by **15–25%** at key stations, while shortening time-to-convert by **20–30%** by targeting the right pricing context, location, and decision moments.

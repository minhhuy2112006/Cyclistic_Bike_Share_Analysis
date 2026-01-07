SELECT  [ride_id]
      ,[rideable_type]
      ,[start_at]
      ,[end_at]
      ,[start_station_name]
      ,[start_station_id]
      ,[end_station_name]
      ,[end_station_id]
      ,[start_lat]
      ,[start_lng]
      ,[end_lat]
      ,[end_lng]
      ,[member_casual]
  FROM [cyclistic].[dbo].[cleaned_trips]


-- Total Rides by user type and Percentage of member and casual rides over total rides
SELECT member_casual, 
	COUNT(ride_id)  AS Total_Rides,
	CAST(100.0 * COUNT(ride_id) / SUM(COUNT(ride_id)) OVER() AS decimal(5,2)) AS pct_over_total

FROM cleaned_trips
GROUP BY member_casual



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

-- Total stations:
SELECT COUNT(DISTINCT start_station_id) AS Total_station
FROM cleaned_trips


-- Total rides in each station by user type 
WITH station_rides AS (
    SELECT
        start_station_name,
        member_casual,
        COUNT(*) AS rides
    FROM cleaned_trips
    GROUP BY
        start_station_name,
        member_casual
),
station_total AS (
    SELECT
        start_station_name,
        SUM(rides) AS total_rides
    FROM station_rides
    GROUP BY start_station_name
)
SELECT
    s.start_station_name,
    s.member_casual,
    s.rides,
    CAST(100.0 * s.rides / t.total_rides AS decimal(5,2)) AS pct_rides
FROM station_rides s
JOIN station_total t
    ON s.start_station_name = t.start_station_name
ORDER BY s.rides DESC, s.member_casual;



-- Top 3 Peak hours by user type and Percentage distribution of rides by time of day.

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

-- Peak Demand by Day of the Week

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


-- Peak Demand by Month
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

-- Hotspot Usage by member and casual:
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


-- Rideable bike by user_type
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


-- Peak demand of electricc_scooter by month
SELECT
	member_casual,
	rideable_type,
	MONTH(start_at) as month,
	count(*) as total_ride
FROM cleaned_trips
WHERE rideable_type = 'electric_scooter'
GROUP BY member_casual,
	rideable_type,
	MONTH(start_at)
ORDER BY month

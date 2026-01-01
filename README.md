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
  In 2016, Cylistic launched a successful bike-share offering. Since then, the program has grown to a fleet of 5.824 bicycles that are geotracked and locked into a network of 692 stations across Chicago. The bikes can be unlocked from one station and returned to any other station in the system anytime.
  
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
  - `start_at`, `end_at`: Timestamp of trip start and end
  - `start_station_name` , `start_station_id`: Starting station information
  - `end_station_name` , `end_station_id`: Ending station information
  - `start_lat` , `start_lng` , `end_lat` , `end_lng`: Geographic coordinates
  - `member_casual`: User type (member or casual) 
  
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
  ### 4. Analyze:
  ### 5. Share:
  ### 6. Act:

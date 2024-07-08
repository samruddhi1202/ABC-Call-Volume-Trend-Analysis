create database Call_data;
use Call_data;
create table calls_analysis
(
Agent_Name varchar(50),
Agent_ID varchar(50),
Customer_Phone_No varchar(50),
Queue_Time int,
Data_and_Time datetime,
Call_Time time,
Time_Bucket varchar(50),
Duration time,
Call_Seconds int,
Call_Status varchar(50),
Wrapped_By varchar(50),
Ringing varchar(50),
IVR_Duration time
);

select * from calls_analysis;

# Average Call Duration:
select Time_Bucket, avg(Call_Seconds) as Avg_Total_Call_Duration, 
AVG(CASE WHEN call_status = 'answered' THEN Call_Seconds ELSE NULL END) AS answered,
AVG(CASE WHEN call_status = 'transfer' THEN Call_Seconds ELSE NULL END) AS transfer,
AVG(CASE WHEN call_status = 'abandon' THEN Call_Seconds ELSE NULL END) AS abandon
from calls_analysis
group by Time_Bucket
order by Time_Bucket;

# Call Volume Analysis:
select Time_Bucket, count(Customer_Phone_No) as Total_Count_of_Calls,
count(case when call_status = 'answered' then Customer_Phone_No else null end) as answered,
count(case when call_status = 'transfer' then Customer_Phone_No else null end) as transfer,
count(case when call_status = 'abandon' then Customer_Phone_No else null end) as abandon
from calls_analysis
group by Time_Bucket
order by Time_Bucket;

select avg(Call_Seconds) as Avg_Call
from calls_analysis;

# Manpower Planning:
select avg(Call_Seconds) as Avg_Call_Duration
from calls_analysis;

WITH Subquery AS (
    SELECT
        Time_Bucket,
        COUNT(CASE WHEN call_status IN ('answered', 'abandon') THEN Customer_Phone_No ELSE NULL END) as Calls_Per_Time_Bucket
    FROM calls_analysis
    GROUP BY Time_Bucket
),
AvgSubquery AS (
    SELECT
        Time_Bucket,
        AVG(Calls_Per_Time_Bucket / 23) as Avg_Calls_Per_Time_Bucket
    FROM Subquery
    GROUP BY Time_Bucket
)
SELECT 
    Time_Bucket,
    Avg_Calls_Per_Time_Bucket,
    (Avg_Calls_Per_Time_Bucket * 139.532 * 0.9) / 3600 as Call_Duration_Per_Time_Bucket,
    round(((Avg_Calls_Per_Time_Bucket * 139.532 * 0.9) / 3600) / 4.5) as No_of_Agents_Required
FROM  AvgSubquery
ORDER BY Time_Bucket;
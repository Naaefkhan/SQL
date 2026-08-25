select job_schedule_type, round(AVG(salary_hour_avg), 2) as salary_hour_avg,
 round(AVG(salary_year_avg), 2) as salary_year_avg
from job_postings_fact
where job_posted_date >='01-06-2023'
GROUP BY job_schedule_type;

SELECT count(job_id) as total_jobs, job_schedule_type,
extract(YEAR FROM job_posted_date AT TIME ZONE 'UTC' at time zone 'America/New_York') as year,
EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' at time zone 'America/New_York') as month    
FROM job_postings_fact
where 
 Extract(YEAR FROM job_posted_date AT TIME ZONE 'UTC' at time zone 'America/New_York')=2023
GROUP BY job_schedule_type,
extract(YEAR FROM job_posted_date AT TIME ZONE 'UTC' at time zone 'America/New_York'),
EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' at time zone 'America/New_York')
 
order BY year,month; 

select c.name as company_name, count(j.job_id) as total_jobs
from job_postings_fact j
join company_dim c 
on j.company_id = c.company_id
where extract(quarter from job_posted_date AT TIME ZONE 'UTC' at time zone 'America/New_York')=2
and extract(year from job_posted_date AT TIME ZONE 'UTC' at time zone 'America/New_York')=2023
and j.job_health_insurance=True
group by c.name
order by total_jobs desc;

create table january_jobs as
select*from job_postings_fact
where extract(month from job_posted_date)=1;

create table february_jobs as
select*from job_postings_fact
where extract(month from job_posted_date)=2;

create table march_jobs as
    select*from job_postings_fact
    where extract(month from job_posted_date)=3;

select*from february_jobs;

select count(job_id) as total_jobs,
    case 
    when job_location='Anywhere' then 'Remote'
    when job_location LIKE '%New York%, %NY%' then 'Local'
    else 'Onsite'
    end as job_location_type
from job_postings_fact
group by job_location_type;

select job_location
from job_postings_fact
where job_location like '%New York%';

with Remote as(
    select distinct c.name 
    from company_dim c
    join job_postings_fact j
        on c.company_id=j.company_id
    where j.job_location like 'Anywhere%'
    order by c.name)
    
select *from remote;

select job_id,salary_year_avg 
from job_postings_fact
where salary_year_avg <
(select AVG(salary_year_avg) from job_postings_fact);

with remote as (
                select 
                s.skill_id,count(*) as skill_count
                from skills_job_dim s 
                inner join job_postings_fact j
                on s.job_id=j.job_id
                where j.job_work_from_home=True and
                 j.job_title_short='Data Analyst'
                GROUP BY s.skill_id
                order by skill_count desc
                )
select r.skill_id,sd.skills,r.skill_count from remote r
inner join skills_dim sd 
on r.skill_id=sd.skill_id
order by skill_count desc 
limit 10;

--Using CTE
WITH jobs as(
    SELECT company_id, COUNT(*) AS total_jobs
FROM job_postings_fact
GROUP BY company_id
)
select jobs.company_id,c.name, jobs.total_jobs,
    Case 
    when total_jobs >50 then 'High'
    when total_jobs between 10 and 50 then 'Medium'
    when total_jobs <10 then 'Low'
    end as job_posting_category
    from jobs inner join company_dim c
    on jobs.company_id=c.company_id
    ORDER BY total_jobs desc
    limit 5;

--Using Subquery
select c.company_id,c.name,total_jobs,
    Case 
    when total_jobs >50 then 'High'
    when total_jobs between 10 and 50 then 'Medium'
    when total_jobs <10 then 'Low'
    end as job_posting_category   
FROM (
    SELECT j.company_id,COUNT(*) AS total_jobs
    FROM job_postings_fact j
    GROUP BY j.company_id
) AS jobs
join company_dim c
on jobs.company_id=c.company_id
ORDER BY total_jobs desc
limit 5;


select q.job_id,q.job_posted_date::DAte,
q.job_title_short,q.salary_year_avg from
(select*from january_jobs
union ALL
select*from february_jobs
union ALL
select*from march_jobs) as q
where q.salary_year_avg>70000
and q.job_title_short='Data Analyst' 
order by q.salary_year_avg desc;

select job_id,job_title_short,company_id,
sum(salary_year_avg) over(partition by company_id) total
from job_postings_fact 
where salary_year_avg is not null;

--Find the top 3 highest-paying jobs for each job category.
select job_title,salary_year_avg,RANK() over( partition by job_title_short ORDER BY salary_year_avg desc) as rank 
from job_postings_fact
where rank<=3
group by job_title_short,salary_year_avg
;

WITH ranked_jobs AS (
    SELECT
        job_title,
        job_title_short,
        salary_year_avg,
        RANK() OVER (
            PARTITION BY job_title_short
            ORDER BY salary_year_avg DESC
        ) AS rank
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
)

SELECT
    job_title,
    salary_year_avg,
    rank
FROM ranked_jobs
WHERE rank <= 3;
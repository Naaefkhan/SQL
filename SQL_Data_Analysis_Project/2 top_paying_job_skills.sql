--I wanted to see the skills combined in a single row, so i wrote this query.
with top_paying_jobs as (
    select job_id,job_title,
    salary_year_avg,
    name as company_name from
    job_postings_fact 
    LEFT JOIN company_dim on 
    job_postings_fact.company_id=company_dim.company_id
    WHERE job_title_short='Data Engineer' AND
    job_location='Anywhere'
    and salary_year_avg is not NULL
    order by salary_year_avg desc
    LIMIT 10
    )
select top_paying_jobs.*,
string_agg(skills,chr(10) order by skills) as skills
 from top_paying_jobs
inner join skills_job_dim on top_paying_jobs.job_id=skills_job_dim.job_id
inner join skills_dim on skills_job_dim.skill_id=skills_dim.skill_id
group by top_paying_jobs.job_id,
top_paying_jobs.job_title,
top_paying_jobs.salary_year_avg,
top_paying_jobs.company_name
order by salary_year_avg desc;


--If you want to see the skills seperately, then:
with top_paying_jobs as (
    select job_id,job_title,salary_year_avg,
    name as company_name from job_postings_fact 
    LEFT JOIN company_dim on 
    job_postings_fact.company_id=company_dim.company_id
    WHERE job_title_short='Data Engineer' 
    AND job_location='Anywhere'
    and salary_year_avg is not NULL
    order by salary_year_avg desc
    LIMIT 10
)
select top_paying_jobs.*, skills
 from top_paying_jobs
inner join skills_job_dim on top_paying_jobs.job_id=skills_job_dim.job_id
inner join skills_dim on skills_job_dim.skill_id=skills_dim.skill_id
order BY salary_year_avg desc;

/*
Conclusion
After analyzing the results for Data Analyst jobs, we can conclude that
SQL, Python, and Tableau are the most prominent skills, appearing consistently across the top-paying positions. 
Other skills such as R, Excel, Pandas, Snowflake, Power BI, AWS, Azure, and Databricks also appear in several high-salary roles.
An important observation is that the highest-paying positions generally require a combination of multiple skills rather than being an expert in a single tool. 
Core skills like SQL and Python are extremely important while also keepin in mind the importance of visualization tools, cloud platforms, and advanced data technologies.
This concludes that developing a broader technical skill set can be beneficial when targeting senior and higher-paying Data Analyst positions.
*/

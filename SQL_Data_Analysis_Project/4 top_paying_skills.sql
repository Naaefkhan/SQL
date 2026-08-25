
WITH top_skills AS (SELECT
skills_dim.skills,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary,job_title_short,
    ROW_NUMBER() OVER (PARTITION BY job_title_short
    ORDER BY ROUND(AVG(salary_year_avg), 0) DESC
        ) AS rn
    FROM job_postings_fact
INNER JOIN skills_job_dim 
    ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim 
    ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short IN('Data Engineer','Data Analyst')
    AND salary_year_avg IS NOT NULL
    AND job_location ='Anywhere'
    GROUP BY skills_dim.skills,
    job_title_short
    )
select top_skills.*
from top_skills
where rn<=10
order by job_title_short ,rn ;
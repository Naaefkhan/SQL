--WITH CTE
WITH demand_skills AS (
    SELECT 
        skills_dim.skill_id,skills_dim.skills,
        COUNT(skills_job_dim.job_id) AS total_jobs
    FROM job_postings_fact
    INNER JOIN skills_job_dim 
        ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim 
        ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE job_title_short = 'Data Engineer'
      AND job_location IN('India','Anywhere')
      AND salary_year_avg IS NOT NULL
    GROUP BY 
        skills_dim.skill_id,skills_dim.skills
),
average_salary AS (
    SELECT 
        skills_dim.skill_id,
        skills_dim.skills,
        ROUND(AVG(salary_year_avg), 0) AS avg_salary
    FROM job_postings_fact
    INNER JOIN skills_job_dim 
        ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim 
        ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE job_title_short = 'Data Engineer'
      AND salary_year_avg IS NOT NULL
      AND job_location IN('India','Anywhere')
    GROUP BY 
        skills_dim.skill_id,skills_dim.skills
)
SELECT 
    demand_skills.skill_id,
    demand_skills.skills,
    demand_skills.total_jobs,
    average_salary.avg_salary
FROM demand_skills
INNER JOIN average_salary
    ON demand_skills.skill_id = average_salary.skill_id
WHERE total_jobs > 10
ORDER BY avg_salary DESC, total_jobs DESC
LIMIT 20;

--Final concise query(without CTE)
SELECT 
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS total_jobs,
    ROUND(AVG(salary_year_avg),0) AS avg_salary
    FROM job_postings_fact
    INNER JOIN skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE job_title_short = 'Data Engineer'
    AND salary_year_avg IS NOT NULL
    AND job_location IN('India','Anywhere')
    GROUP BY 
    skills_dim.skill_id,
    skills_dim.skills
    HAVING COUNT(skills_job_dim.job_id) > 10
    ORDER BY avg_salary DESC, total_jobs DESC
    LIMIT 20;


SELECT
    skills_dim.skills,
    ROUND(AVG(CASE WHEN job_title_short = 'Data Engineer' THEN salary_year_avg END), 0) AS de_avg_salary,
    COUNT(CASE WHEN job_title_short = 'Data Engineer' THEN job_postings_fact.job_id END) AS de_job_count,
    ROUND(AVG(CASE WHEN job_title_short = 'Data Analyst' THEN salary_year_avg END), 0) AS da_avg_salary,
    COUNT(CASE WHEN job_title_short = 'Data Analyst' THEN job_postings_fact.job_id END) AS da_job_count
FROM job_postings_fact
INNER JOIN skills_job_dim 
    ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim 
    ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short IN ('Data Engineer', 'Data Analyst')
    AND salary_year_avg IS NOT NULL
    AND job_location = 'Anywhere'
GROUP BY skills_dim.skills
HAVING COUNT(CASE WHEN job_title_short = 'Data Engineer' THEN job_postings_fact.job_id END) > 10
   AND COUNT(CASE WHEN job_title_short = 'Data Analyst' THEN job_postings_fact.job_id END) > 10
ORDER BY  
    ROUND(AVG(CASE WHEN job_title_short = 'Data Engineer' THEN salary_year_avg END), 0) 
    - ROUND(AVG(CASE WHEN job_title_short = 'Data Analyst' THEN salary_year_avg END), 0) DESC;
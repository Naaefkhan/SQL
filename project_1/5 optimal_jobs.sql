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
      AND job_location = 'Anywhere'
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
      AND job_location = 'Anywhere'
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
    AND job_work_from_home=True
    GROUP BY 
    skills_dim.skill_id,
    skills_dim.skills
    HAVING COUNT(skills_job_dim.job_id) > 10
    ORDER BY avg_salary DESC, total_jobs DESC
    LIMIT 20;
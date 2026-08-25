
WITH ranked_jobs AS (
    SELECT 
         job_id,job_title, job_title_short,
        salary_year_avg,
        name AS company_name,
        ROW_NUMBER() OVER (
            PARTITION BY  job_title_short
            ORDER BY salary_year_avg DESC
        ) AS rn
    FROM job_postings_fact
    LEFT JOIN company_dim 
        ON job_postings_fact.company_id = company_dim.company_id
    WHERE job_title_short IN ('Data Engineer', 'Data Analyst')
        AND job_location = 'Anywhere'
        AND salary_year_avg IS NOT NULL
)
SELECT ranked_jobs.*,string_agg(skills,chr(10) order by skills) as skills
FROM ranked_jobs
INNER JOIN skills_job_dim on ranked_jobs.job_id=skills_job_dim.job_id
INNER JOIN skills_dim on skills_job_dim.skill_id=skills_dim.skill_id
WHERE rn <= 10
GROUP BY ranked_jobs.job_id,
ranked_jobs.job_title,
ranked_jobs.job_title_short,
ranked_jobs.salary_year_avg,
ranked_jobs.company_name,
ranked_jobs.rn
ORDER BY job_title_short, salary_year_avg DESC;
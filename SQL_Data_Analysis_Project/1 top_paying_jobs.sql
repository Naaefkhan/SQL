

WITH ranked_jobs AS (
    SELECT 
        job_id, job_title, job_title_short,
        salary_year_avg,
        name AS company_name,
        ROW_NUMBER() OVER (
            PARTITION BY job_title_short 
            ORDER BY salary_year_avg DESC
        ) AS rn
    FROM job_postings_fact
    LEFT JOIN company_dim 
        ON job_postings_fact.company_id = company_dim.company_id
    WHERE job_title_short IN ('Data Engineer', 'Data Analyst')
        AND job_location = 'Anywhere'
        AND salary_year_avg IS NOT NULL
)
SELECT job_id, job_title, job_title_short, salary_year_avg, company_name
FROM ranked_jobs
WHERE rn <= 10
ORDER BY job_title_short, salary_year_avg DESC;
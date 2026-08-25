

WITH demand_skills AS (
    SELECT 
        job_title_short,
        skills,
        COUNT(skills_job_dim.job_id) AS total_jobs
    FROM job_postings_fact
    INNER JOIN skills_job_dim 
        ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim 
        ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE job_title_short IN ('Data Engineer', 'Data Analyst')
        AND job_location = 'Anywhere'
    GROUP BY job_title_short, skills
),
ranked_skills AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY job_title_short
            ORDER BY total_jobs DESC
        ) AS rn
    FROM demand_skills
)
SELECT *
FROM ranked_skills
WHERE rn <= 10
ORDER BY job_title_short, total_jobs DESC;
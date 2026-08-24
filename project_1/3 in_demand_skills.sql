SELECT skills,
count(skills_job_dim.job_id) as total_jobs FROM job_postings_fact
inner join skills_job_dim ON 
job_postings_fact.job_id=skills_job_dim.job_id
inner join skills_dim ON
skills_job_dim.skill_id=skills_dim.skill_id
where job_title_short='Data Engineer' AND
job_location='India'
group by skills
order by total_jobs desc
limit 5;


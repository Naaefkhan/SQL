# Introduction
Choosing between Data Engineering and Data Analytics can be difficult because both careers involve working with data, but they require different skill sets and offer different career opportunities.

This project uses SQL and job posting data to compare the Data Engineer and Data Analyst job markets from multiple perspectives.

Rather than looking only at salary, this analysis focuses on:
💰 Highest-paying jobs
🛠️ Skills required for the highest-paying jobs
📈 Most in-demand skills
💵 Highest-paying skills
⚖️ Skills that can be compared across both career paths

The goal is to identify the differences between the two roles and understand which skills provide the strongest combination of salary and job-market demand.


The analysis was performed using SQL on a job-postings dataset. I used SQL joins, filtering, aggregation, CASE, CTEs, `COUNT()`, `AVG()`, `GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT`, and `STRING_AGG()` to explore the data.

SQL queries? check them out here: [project_sql](./SQL_Data_Analysis_Project/)
# Background
The main objectives of this project are:

Identify the highest-paying Data Engineer and Data Analyst jobs.
Find the skills required by high-paying positions.
Identify the most in-demand skills for both roles.
Determine which skills are associated with the highest average salaries.
Compare common skills between Data Engineering and Data Analytics.
Understand which skills may provide better opportunities for someone deciding between the two career paths.

# Tools I Used
For my deep dive into the data engineer job market,
I harnessed the power of several key tools:
- **SQL**: The backbone of my analysis, allowing me to query the database and unearth critical insights.
- **PostgreSQL**: The chosen database management system, ideal for handling the job posting data.
- **Visual Studio Code**: My go-to for database management and executing SQL queries.
- **Git & GitHub**: Essential for version control and sharing my SQL scripts and analysis, ensuring collaboration and project tracking.
# The Analysis

1. What are the top-paying Data Engineer V/S Data Analyst jobs?
The first analysis identifies the top 10 highest-paying jobs separately for Data Engineers and Data Analysts.

I used the `ROW_NUMBER()` window function with `PARTITION BY `job_title_short to rank jobs independently for each career. The analysis also filters for:

Data Engineer and Data Analyst roles
Remote jobs (Anywhere)
Jobs with available annual salary information

SQL Concepts Used
`ROW_NUMBER()
PARTITION BY
ORDER BY
LEFT JOIN
CTE
WHERE`
### Key Insight

This analysis provides a direct comparison of the upper end of the salary market for both careers.

It also helps identify whether the highest-paying opportunities are concentrated in specific job titles or companies.
The first analysis identifies the highest-paying Data Engineer positions.

### SQL approach

```sql
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
```


---

## 2. What skills are required for these top-paying jobs?

Finding a high-paying job is only the first step.

The next question is:

What skills do these high-paying jobs require?

For this analysis, I took the top 10 jobs from each career and joined them with the skills tables.

I used `STRING_AGG()` to combine all skills associated with each job into a single result, making it easier to understand the complete skill requirements of high-paying positions.

SQL Concepts Used
`CTE
ROW_NUMBER()
PARTITION BY
INNER JOIN
STRING_AGG()
GROUP BY`

I also used `STRING_AGG()` to combine multiple skills into a single row for each job, making the results easier to read.

```sql

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
```

### Why This Matters
A salary number alone doesn't tell us what we need to learn.

By connecting high-paying jobs with their required skills, this analysis helps identify the technical skills that appear in premium job opportunities.


## 3. What skills are most in demand for Data Engineers?
Salary isn't the only important factor.

A skill can have a high salary association but appear in relatively few job postings.
Therefore, this analysis focuses on skill demand.
The query counts how many job postings mention each skill and ranks the skills separately for Data Engineers and Data Analysts.
Only remote (Anywhere) positions are considered.

SQL Concepts Used
`CTE
COUNT()
GROUP BY
ROW_NUMBER()
PARTITION BY
ORDER BY`


### SQL approach

```sql
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
```
### Key Question
Which skills are employers asking for most frequently?
This provides a practical view of the skills that candidates are most likely to encounter when applying for jobs.

---

## 4. Which skills are associated with higher salaries?
For every skill, I calculate the average annual salary and rank the skills separately for Data Engineers and Data Analysts.
The query uses `ROW_NUMBER()` with PARTITION BY job_title_short to create a separate ranking for each career.

SQL Concepts Used
`AVG()
ROUND()
GROUP BY
CTE
ROW_NUMBER()
PARTITION BY
Important Distinction`

This analysis is different from the previous demand analysis.

In-demand skills answer:

"Which skills appear in the most jobs?"

Top-paying skills answer:

"Which skills are associated with the highest average salaries?"

This distinction is important when deciding which skills to prioritize.

### SQL approach

```sql

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
```
The fourth analysis looks at the relationship between individual skills and salary.

---

## 5. What are the most optimal skills to learn?
The final analysis compares skills that appear in both Data Engineering and Data Analytics.

For each skill, I calculate:

Data Engineer average salary
Data Engineer job count
Data Analyst average salary
Data Analyst job count

The query only keeps skills that appear in more than 10 jobs in both career categories, helping avoid conclusions based on skills with extremely small sample sizes.

SQL Concepts Used
`CASE WHEN
AVG()
COUNT()
GROUP BY
HAVING
Conditional aggregation`

The query:
### SQL Approach
```sql
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
```
The final analysis combines the two most important factors:

**Demand + Salary**

Instead of asking only:

> "Which skills are popular?"

or:

> "Which skills have the highest salary?"
I wanted to find skills that have a reasonable level of job demand while also being associated with higher salaries.

Why This Analysis Is Useful
This is the most direct comparison between the two career paths.

Instead of asking:
"Is Data Engineering better than Data Analytics?"

we can ask:
"For the same skill, how does its demand and salary differ between Data Engineering and Data Analytics?"
This provides a more skill-focused comparison.

# Key Insights

The analysis highlights several important differences between the two career paths.

### 💰 Salary
The highest-paying positions provide an indication of the salary ceiling available in each career.
However, individual job salaries can vary significantly depending on the company, job title, experience requirements, and skill requirements.

### 📈 Demand
The most frequently requested skills provide a better indication of what employers are currently looking for.
A skill appearing frequently across job postings can be particularly valuable when building an entry-level skill set.

### 🛠️ Skills Behind High-Paying Jobs
The skills found in high-paying positions provide insight into what employers expect from candidates targeting premium opportunities.
This is especially useful for moving beyond basic job requirements and identifying skills associated with more specialized positions.

### ⚖️ Salary vs Demand
One of the most important lessons from this project is:
The most demanded skill is not necessarily the highest-paying skill.
A skill can have very high demand but a moderate average salary, while another skill can have a much higher average salary but appear in fewer job postings.
Therefore, looking at both demand and salary provides a more complete picture.


# 🎯 What I Learned
Through this project, I learned how SQL can be used not just to retrieve data, but to answer real-world business and career questions.

Some of the key concepts I practiced include:
Using CTEs to break complex problems into smaller steps
Using window functions to rank records within categories
Comparing multiple groups using PARTITION BY
Connecting multiple relational tables using joins
Using conditional aggregation to compare two categories
Distinguishing between skill demand and salary
Designing SQL queries around practical questions rather than simple data retrieval

# 🚀 Future Improvements
This project can be extended by adding:
- 📍 Location-based salary comparisons
- 🏢 Company-level analysis
- 📅 Salary trends over time
- ☁️ Cloud skill comparisons
- 📊 Data visualization using Power BI or Tableau
- 🧑‍💼 Experience-level analysis
- 🌎 Comparison of remote vs non-remote opportunities
- 📈 Skill combinations that frequently appear together
- 💼 Entry-level vs senior-level job analysis

# 🏁 Conclusion
This project provides a SQL-based comparison of the Data Engineer and Data Analyst job markets.
Instead of using salary alone to compare the careers, the analysis looks at the market from multiple perspectives:
Top-paying jobs → Skills behind high-paying jobs → Skill demand → Top-paying skills → Cross-career skill comparison
This approach provides a more practical understanding of the skills employers value and how those skills relate to salary and demand.
Ultimately, the project demonstrates how SQL can transform raw job-posting data into actionable insights for career and skill development decisions.

# 👨‍💻 Author
- Naaef Khan
- Data Science | SQL | Data Analytics | Data Engineering
- Project Focus: SQL-based Data Engineer vs Data Analyst Job Market Analysis

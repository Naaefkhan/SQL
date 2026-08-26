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
1. Find the skills required by high-paying positions.
2. Identify the most in-demand skills for both roles.
3. Determine which skills are associated with the highest average salaries.
4. Compare common skills between Data Engineering and Data Analytics.5.
5. Understand which skills may provide better opportunities for someone deciding between the two career paths.

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

## SQL approach

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
## Analysis -Top Paying Jobs
The first analysis identifies the top 10 highest-paying Data Analyst and Data Engineer positions based on average yearly salary.
To ensure a fair comparison, the analysis focuses on remote (Anywhere) positions with available annual salary data. `ROW_NUMBER()` with `PARTITION BY job_title_short` is used to rank the highest-paying jobs separately for Data Analysts and Data Engineers.

### 🔍 Key Findings
###  Data Analyst

The highest-paying Data Analyst position in the analysis is **Data Analyst at Mantys** with an annual salary of $650,000.

Other highly paid positions include:

- Director of Analytics — Meta: $336,500
- Associate Director – Data Insights — AT&T: $255,829.50
- Data Analyst, Marketing — Pinterest: $232,423
- Data Analyst (Hybrid/Remote) — UCLA Health: $217,000

The results also show several Principal and Director-level positions, indicating that seniority and specialization have a strong relationship with higher salaries.

### Data Engineer

The highest-paying Data Engineering positions include:

- Data Engineer — Engtal: $325,000
- Data Engineer — Durlston Partners: $300,000
- Director of Engineering – Data Platform — Twitch: $251,000
- Staff Data Engineer — Signify Technology: $250,000
- Principal Data Engineer — Signify Technology: $250,000

Several positions are at the Staff, Principal, and Manager/Director levels, showing that advanced Data Engineering roles can also command very high salaries.

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
## Key Findings
### 📊 Data Analyst

Several skills appear repeatedly across the highest-paying Data Analyst positions.

Most noticeable skills:

- SQL — appears across almost every listed position
- Python — frequently required
- Tableau — common in several senior analyst roles
- R — appears in multiple positions
- Pandas & NumPy — found in more technical analyst roles
- Excel — still appears in senior/high-paying analyst positions
- Snowflake — appears in several positions
- AWS / Azure — cloud skills appear in senior roles
- Power BI — appears in analytics and business intelligence-oriented positions

For example, the Associate Director – Data Insights role at AT&T requires a broad combination of **AWS, Azure, Databricks, Excel, Pandas, Power BI, PySpark, Python, R, SQL, and Tableau.**

This suggests that higher-paying Data Analyst roles can extend well beyond basic reporting and dashboard creation.

⚙️ Data Engineer

The Data Engineering positions show a different skill pattern.

Commonly observed skills include:

- Python
- Spark
- PySpark
- Hadoop
- Kafka
- Kubernetes
- Databricks
- Scala
- Cloud platforms such as AWS, Azure and GCP
- SQL

The two $325,000 Data Engineer positions at Engtal, for example, list:

`Hadoop + Kafka + Kubernetes + NumPy + Pandas + PySpark + Python + Spark`

This combination demonstrates the more infrastructure- and distributed-processing-oriented nature of high-paying Data Engineering roles.

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
### 📊 Data Analyst

| Rank | Skill | Job Postings |
|------|-------|--------------|
| 1 | SQL | 7,291 |
| 2 | Excel | 4,611 |
| 3 | Python | 4,330 |
| 4 | Tableau | 3,745 |
| 5 | Power BI | 2,609 |
| 6 | R | 2,142 |
| 7 | SAS | 1,866 |
| 8 | Looker | 868 |
| 9 | Azure | 821 |
| 10 | PowerPoint | 819 |

### ⚙️ Data Engineer

| Rank | Skill | Job Postings |
|------|-------|--------------|
| 1 | SQL | 14,213 |
| 2 | Python | 13,893 |
| 3 | AWS | 8,570 |
| 4 | Azure | 6,997 |
| 5 | Spark | 6,612 |
| 6 | Airflow | 4,329 |
| 7 | Snowflake | 4,053 |
| 8 | Java | 3,801 |
| 9 | Databricks | 3,716 |
| 10 | Kafka | 3,391 |

### Key Findings

**SQL** is the strongest common skill across both career paths.

It ranks #1 for both Data Analysts and Data Engineers, with 7,291 Data Analyst postings and 14,213 Data Engineer postings.

**Python** also ranks extremely highly for both roles, making **SQL + Python** a strong foundational combination for someone who wants to keep both career options open.

At the same time, the data shows that specialization matters:

Data Analytics → `SQL + Excel + Python + BI/Visualization`

Data Engineering → `SQL + Python + Cloud + Data Infrastructure`

This analysis helps establish what employers are actually asking for, while the next analysis looks at the other side of the equation: which skills are associated with the highest salaries.

For Data Engineers, SQL and Python dominate the job market, followed by cloud and data-engineering technologies.

**AWS** and **Azure** have particularly strong demand, while **Spark, Airflow, Snowflake, Databricks, and Kafka** highlight the importance of data pipelines, distributed processing, cloud platforms, and modern data infrastructure.

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
### Analysis
The fourth analysis identifies the 10 skills associated with the highest average annual salaries for Data Analysts and Data Engineers.

Unlike the previous analysis, which measures skill demand based on the number of job postings, this analysis focuses on the average salary associated with each skill. The skills are ranked separately for each role using `ROW_NUMBER()` with `PARTITION BY`.

### 📊 Data Analyst

| Rank | Skill | Average Salary |
|---|---|---:|
| 1 | PySpark | $208,172 |
| 2 | Bitbucket | $189,155 |
| 3 | Watson | $160,515 |
| 4 | Couchbase | $160,515 |
| 5 | DataRobot | $155,486 |
| 6 | GitLab | $154,500 |
| 7 | Swift | $153,750 |
| 8 | Jupyter | $152,777 |
| 9 | Pandas | $151,821 |
| 10 | Elasticsearch | $145,000 |

### ⚙️ Data Engineer

| Rank | Skill | Average Salary |
|---|---|---:|
| 1 | Assembly | $192,500 |
| 2 | Mongo | $182,223 |
| 3 | ggplot2 | $176,250 |
| 4 | Rust | $172,819 |
| 5 | Clojure | $170,867 |
| 6 | Perl | $169,000 |
| 7 | Neo4j | $166,559 |
| 8 | Solidity | $166,250 |
| 9 | GraphQL | $162,547 |
| 10 | Julia | $160,500 |
### 🔍 Key Findings

For Data Analysts, **PySpark** has the highest average salary association at $208,172, followed by **Bitbucket** at $189,155.

For Data Engineers, **Assembly** ranks first with an average salary of $192,500, followed by **Mongo** at $182,223 and ggplot2 at $176,250.

An important observation is that many of these skills are specialized technologies rather than the most commonly demanded skills from the previous analysis.

For example, **SQL** ranks #1 in demand for both Data Analysts and Data Engineers, but it does not appear among the top 10 highest-paying skills.
### ⚠️ Important Consideration

These figures represent the average salary of job postings where each skill appeared. They should not be interpreted as the expected salary someone will receive simply by learning that skill.

Some specialized skills may also have fewer job postings, meaning their average salary can be influenced by a smaller sample size.

Therefore, salary should be considered together with demand when deciding which skills to learn.

---

## 5. What are the most optimal skills to learn?
The final analysis compares skills that appear in both Data Engineering and Data Analytics.

For each skill, I calculate:

- Data Engineer average salary
- Data Engineer job count
- Data Analyst average salary
- Data Analyst job count

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
### 🔍 Key Findings

The most noticeable result is that Data Engineering(DE) has a higher average salary than Data Analytics(DA) for every skill in this comparison.

For example:

- Spark: $139,838 DE vs $99,077 DA
- SQL: $129,191 DE vs $97,237 DA
- Python: $132,200 DE vs $101,397 DA
- AWS: $132,865 DE vs $108,317 DA
- Snowflake: $134,373 DE vs $112,948 DA

This suggests that the same technical skill can be associated with significantly different salary levels depending on the career path.

🏆 Strong Skills for Data Engineering

Several skills stand out because they combine high salary with substantial demand:

- SQL — $129,191 average salary and 568 jobs
- Python — $132,200 and 535 jobs
- AWS — $132,865 and 367 jobs
- Spark — $139,838 and 237 jobs
- Snowflake — $134,373 and 202 jobs
- Azure — $129,574 and 254 jobs

These are particularly interesting because they aren't simply high-paying niche skills; they also have significant job demand.

📊 Strong Skills for Data Analytics

For Data Analysts, some skills combine relatively strong salaries with substantial demand:

- SQL — $97,237 and 398 jobs
- Python — $101,397 and 236 jobs
- Tableau — $99,288 and 230 jobs
- Excel — $87,288 and 256 jobs
- R — $100,499 and 148 jobs
- Power BI — $97,431 and 110 jobs

This reinforces the importance of **SQL**, **Python**, **visualization tools**, and **spreadsheet skills** in the *Data Analyst* market.

### 💡 Most Important Insight

**SQL** and **Python** stand out as the strongest transferable skills between the two careers.

SQL has:

568 Data Engineer jobs and 398 Data Analyst jobs

Python has:

535 Data Engineer jobs and 236 Data Analyst jobs

Both skills also have relatively strong average salaries in both fields.

This makes them particularly valuable for someone who hasn't yet decided whether to specialize in Data Engineering or Data Analytics.

### 🎯 Career Takeaway

The analysis suggests a useful skill progression:

For Data Analytics:

`SQL → Excel → Python → Tableau / Power BI → Cloud & Data Platforms`

For Data Engineering:

`SQL → Python → Cloud → Spark → Airflow / Snowflake / Databricks`

If the goal is to keep both career options open, **SQL** and **Python** provide the strongest foundation, after which specialization can be built depending on the desired career direction.

Overall, the results indicate that Data Engineering tends to offer higher salary associations for shared skills, while Data Analytics has strong demand for **SQL, Excel, Python, Tableau, Power BI, and R**.


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

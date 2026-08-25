# Introduction
I have created this project to analyze the market of **Data Engineer Job Profile** to understand the skills, salaries, and job-market demand associated with the role.

The goal of this analysis is to answer five practical questions:

1. What are the top-paying Data Engineer jobs?
2. What skills are required for these top-paying jobs?
3. What skills are most in demand for Data Engineers?
4. Which skills are associated with higher salaries?
5. What are the most optimal skills to learn?

The analysis was performed using SQL on a job-postings dataset. I used SQL joins, filtering, aggregation, CTEs, `COUNT()`, `AVG()`, `GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT`, and `STRING_AGG()` to explore the data.

SQL queries? check them out here: [project_sql](./SQL_Data_Analysis_Project/)
# Background
The questions I wanted to answer were:
1. What are the top paying data engineer jobs?
2. What skills are required for these top-paying jobs?
3. What skills are most in demand for data engineers?
4. Which skills are associated with higher salaries?
5. What are the most optimal skills to learn?
# Tools I Used
For my deep dive into the data engineer job market,
I harnessed the power of several key tools:
- **SQL**: The backbone of my analysis, allowing me to query the database and unearth critical insights.
- **PostgreSQL**: The chosen database management system, ideal for handling the job posting data.
- **Visual Studio Code**: My go-to for database management and executing SQL queries.
- **Git & GitHub**: Essential for version control and sharing my SQL scripts and analysis, ensuring collaboration and project tracking.
# The Analysis

1. What are the top-paying Data Engineer jobs?
The first analysis identifies the highest-paying Data Engineer positions.
The query:
- Filters the dataset for **Data Engineer** positions.
- Keeps jobs where salary information is available.
- Focuses on remote/anywhere jobs.
- Joins the job-postings table with the company table to obtain company names.
- Sorts jobs by annual salary in descending order.
- Returns the top 10 positions.

### SQL approach

```sql
SELECT
    job_id,
    job_title,
    job_location,
    salary_year_avg,
    job_posted_date,
    name AS company_name
FROM job_postings_fact
LEFT JOIN company_dim
    ON job_postings_fact.company_id = company_dim.company_id
WHERE job_title_short = 'Data Engineer'
  AND job_location = 'Anywhere'
  AND salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;
```
! [Top Paying Jobs](/assets/01_top_paying_data_engineer_jobs_sorted.png)
### Analysis

This gives an overview of the highest-paying Data Engineer opportunities in the dataset and helps identify companies and job titles associated with the highest salaries.

---

## 2. What skills are required for these top-paying jobs?

After identifying the top-paying Data Engineer jobs, I analyzed the skills associated with those positions.

I used a **CTE** to first identify the top 10 highest-paying jobs. I then joined those jobs with:

- `skills_job_dim`
- `skills_dim`

This allowed me to connect each job with the skills mentioned in the dataset.

I used `STRING_AGG()` to combine multiple skills into a single row for each job, making the results easier to read.

```sql
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
```
### Why I used a CTE

The CTE separates the analysis into two logical steps:

1. Find the top-paying jobs.
2. Find the skills required for those jobs.

This makes the query easier to understand and maintain.
![Top paying job skills](./assets/02_top_paying_job_skills.png)
### Analysis

The important takeaway is that high-paying Data Engineering roles generally require a **combination of skills**, rather than one technology alone.

The skills appearing across these jobs can be grouped into areas such as:

- Programming
- Databases and SQL
- Cloud platforms
- Data processing
- Data warehousing
- Big data technologies
- Data engineering tools

This suggests that building a broad technical skill set is important when targeting higher-paying Data Engineering positions.

---

## 3. What skills are most in demand for Data Engineers?

The third analysis focuses on the number of Data Engineer job postings requiring each skill.

For this analysis, I focused on **Data Engineer jobs in India** and counted how many job postings were associated with each skill.

### SQL approach

```sql
SELECT
    skills,
    COUNT(skills_job_dim.job_id) AS total_jobs
FROM job_postings_fact
INNER JOIN skills_job_dim
    ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Data Engineer'
  AND job_location = 'Anywhere'
GROUP BY skills
ORDER BY total_jobs DESC
LIMIT 5;
```
![In Demand skills](./assets/03_in_demand_skills.png)
### Analysis

This identifies the five skills appearing most frequently in Data Engineer job postings in India.

The purpose of this analysis is to understand what employers are asking for most often, rather than simply focusing on the highest-paying technologies.

---

## 4. Which skills are associated with higher salaries?

The fourth analysis looks at the relationship between individual skills and salary.

Instead of counting demand, I calculated the **average annual salary** of jobs associated with each skill.

The query:

- Filters for Data Engineer roles.
- Removes jobs without salary information.
- Groups jobs by skill.
- Calculates average salary.
- Sorts skills by average salary.
- Returns the top 25 skills by average salary.

### SQL approach

```sql
SELECT
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
GROUP BY skills_dim.skills
ORDER BY avg_salary DESC
LIMIT 25;
```
![Top paying skills](./assets/04_top_paying_skills.png)
### Analysis

This analysis shows which skills are associated with higher average salaries.

However, a high average salary does **not necessarily mean that learning the skill alone will result in a high salary**. Some skills may appear mainly in senior or specialized roles, which can raise their average salary.

Therefore, salary should be considered together with demand.

---

## 5. What are the most optimal skills to learn?

The final analysis combines the two most important factors:

**Demand + Salary**

Instead of asking only:

> "Which skills are popular?"

or:

> "Which skills have the highest salary?"

I wanted to find skills that have a reasonable level of job demand while also being associated with higher salaries.

### Method

I calculated:

- `total_jobs` → number of job postings requiring each skill
- `avg_salary` → average salary associated with each skill

I then used:

```sql
HAVING COUNT(skills_job_dim.job_id) > 10
```

This removes skills that appear in only a small number of jobs.

Finally, the results are ordered by:

1. Average salary — highest first
2. Total jobs — highest first

```sql
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
```
![Optimal skills](./assts/05_optimal_skills.png)
# What I Learned

Through this project, I learned how SQL can be used to answer real-world career and job-market questions rather than simply retrieving data.

### 1. Demand and salary are different measures

A skill can be highly demanded without being associated with the highest salaries.

Therefore, looking at only one metric can give an incomplete picture of the market.

### 2. High-paying jobs require multiple skills

The top-paying Data Engineer positions generally require combinations of programming, databases, cloud technologies, and data-processing tools.

This shows that becoming a Data Engineer is not about mastering one technology.

### 3. CTEs make complex analysis easier

I used CTEs to break the problem into smaller steps.

For example:

```text
Find high-demand skills
        ↓
Calculate average salary
        ↓
Combine the results
        ↓
Filter and rank skills
```

This made the logic easier to understand and allowed me to build a more structured analysis.

### 4. SQL joins are essential for real-world datasets

The analysis required combining information from multiple tables:

- Job postings
- Companies
- Skills
- Job-skill relationships

Understanding how these tables connect is essential when working with relational datasets.

### 5. I learned to think beyond basic SQL queries

Instead of only writing simple `SELECT` statements, this project helped me practice:

- Joins
- Aggregations
- CTEs
- Window of analysis
- Grouping
- Filtering aggregated results with `HAVING`
- Ranking results
- Combining multiple metrics

---

# Conclusion

This project provided a practical look at the Data Engineering job market by analyzing **salary, job demand, and required skills**.

The analysis shows that choosing skills based on only one factor can be misleading. The most useful approach is to consider both **how frequently employers request a skill and the salary associated with jobs requiring it**.

The analysis of top-paying jobs also shows that higher-paying Data Engineering roles tend to require a combination of technical skills rather than expertise in a single tool.

Overall, the project helped me understand how SQL can be used to turn a large job-postings dataset into actionable career insights.

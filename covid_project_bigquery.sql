-- We are using the full .csv from https://ourworldindata.org/covid-deaths 
-- downloaded on 20230328 as well as two seperated .csv files of the same
-- data but ending on 20210430 (used here only to show joining and CTE ability) 

-- First we create a project and a dataset in BiqQuery. Then we upload our .csv to a table.

--Take a quick look at the data from our table we are most interested in for this project

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `portfolio-project-number-1.CovidDataset.CovidData` 
ORDER BY 1,2;


-- Looking at total cases vs total deaths in a new column called percent_deaths as a percentage

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percent_deaths
FROM `portfolio-project-number-1.CovidDataset.CovidData` 
WHERE continent is not null
ORDER BY 1,2;


-- Focusing in on only the above results in the United States

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) AS percent_deaths
FROM `portfolio-project-number-1.CovidDataset.CovidData` 
WHERE location = 'United States'
ORDER BY 1,2;


-- Likelihood that you will die from covid if you contract the virus, in the United States

SELECT date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percent_deaths
FROM `portfolio-project-number-1.CovidDataset.CovidData` 
WHERE location = 'United States'
ORDER BY 1,2;


-- Looking at total cases vs population in the United States (total percentage of population that's been infected)

SELECT location, date, total_cases, population, (total_cases/population)*100 AS percent_infected
FROM `portfolio-project-number-1.CovidDataset.CovidData` 
WHERE location = 'United States'
ORDER BY 1,2;


-- Looking for country with highest infection rate percentage

SELECT location, population, MAX(total_cases) AS highest_inf_count, MAX(total_cases/population)*100 AS perc_pop_inf
FROM `portfolio-project-number-1.CovidDataset.CovidData` 
WHERE continent is not null
GROUP BY location, population
ORDER BY perc_pop_inf DESC;


-- Looking for country with the highest death rate percentage

SELECT location, population, MAX(total_deaths) AS highest_death_count, MAX(total_deaths/population)*100 AS perc_pop_deaths
FROM `portfolio-project-number-1.CovidDataset.CovidData` 
WHERE continent is not null
GROUP BY location, population
ORDER BY perc_pop_deaths DESC;


-- Looking for country with the most total deaths in number

SELECT location, MAX(total_deaths) AS highest_death_count
FROM `portfolio-project-number-1.CovidDataset.CovidData` 
WHERE continent is not null
GROUP BY location
ORDER BY highest_death_count DESC;


-- Looking for continent with the most total deaths in number

SELECT continent, MAX(total_deaths) AS highest_death_count
FROM `portfolio-project-number-1.CovidDataset.CovidData` 
WHERE continent is not null
GROUP BY continent
ORDER BY highest_death_count DESC;


-- Lets try grouping by location instead

SELECT location, MAX(total_deaths) AS highest_death_count
FROM `portfolio-project-number-1.CovidDataset.CovidData` 
WHERE continent is null 
GROUP BY location
ORDER BY highest_death_count DESC;


-- Same info as above, but excluding income indicators

SELECT location, MAX(total_deaths) AS highest_death_count
FROM `portfolio-project-number-1.CovidDataset.CovidData` 
WHERE continent is null AND location NOT IN ("High income", "Low income", "Lower middle income", "Upper middle income")
GROUP BY location
ORDER BY highest_death_count DESC;


-- Sum of all new cases, by date

SELECT date, SUM(new_cases) AS new_case_sum, total_deaths, (total_deaths/total_cases)*100 AS percent_deaths
FROM `portfolio-project-number-1.CovidDataset.CovidData`
WHERE continent is not null AND location NOT IN ("High income", "Low income", "Lower middle income", "Upper middle income")
GROUP BY date, total_deaths, total_cases
ORDER BY 1,2;


-- Sum of all new cases, new deaths, and the daily death percentage by date

SELECT date, SUM(new_cases) AS total_nc, SUM(new_deaths) AS total_nd, 
  CASE 
    WHEN SUM(new_cases) = 0 THEN 0 
    ELSE SUM(new_deaths)/SUM(new_cases)*100 
  END AS daily_death_perc
FROM `portfolio-project-number-1.CovidDataset.CovidData` 
WHERE continent IS NOT NULL AND location NOT IN ("High income", "Low income", "Lower middle income", "Upper middle income")
GROUP BY date
ORDER BY date, total_nc

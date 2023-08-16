/*
Covid 19 Data Exploration

Skill Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT * FROM [dbo].[ CovidDeaths01]

SELECT * FROM [dbo].[ CovidVaccinations01 ]

-- select data that we are going to be starting with

SELECT location, date,total_cases, new_cases, total_deaths, population
FROM [dbo].[ CovidDeaths01]
WHERE continent IS NOT NULL
ORDER BY 1,2


 -- Looking at Total Cases Vs Total Deaths
 -- shows the likelihood of dying if you contract covid in your country

SELECT location, date,total_cases, total_deaths, (1.0 * total_deaths/total_cases)*100 as DeathPercentage
FROM [dbo].[ CovidDeaths01]
WHERE location LIKE '%India%'
ORDER BY 1,2


-- Looking at Total Cases Vs Population in India
-- Shows what Percentage of Population got Covid

SELECT location, date,total_cases, population, (1.0 * total_cases/Population)*100  AS PercentPopulationInfected
FROM [dbo].[ CovidDeaths01]
-- WHERE location LIKE '%India%'
ORDER BY 1,2


 --Looking at countries with highest infection rate compared to population

SELECT location, population , Max(total_cases) AS HighestInfectionCount ,Max(1.0 * total_cases/Population)*100  AS PercentPopulationInfected
FROM [dbo].[ CovidDeaths01]
-- WHERE location LIKE '%India%'
GROUP BY LOCATION, Population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count Per Populatipon

SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM [dbo].[ CovidDeaths01]
-- WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC


-- Let's Look at The Continent
-- Showing the Continents with the Highest Death Counts per Population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM [dbo].[ CovidDeaths01]
-- WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT date, SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_deaths, SUM(1.0*new_Deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM [dbo].[ CovidDeaths01]
WHERE continent IS NOT NULL
GROUP BY DATE
ORDER BY 1,2


-- Aggregate

SELECT SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_deaths, SUM(1.0*new_Deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM [dbo].[ CovidDeaths01]
WHERE continent IS NOT NULL
-- GROUP BY DATE
ORDER BY 1,2


-- Looking at Total Population Vs Total Vaccintaions
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Join Both Table


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM [dbo].[ CovidDeaths01] dea
JOIN [dbo].[ CovidVaccinations01] vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query


WITH PopvsVac (continent, loacation, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM [dbo].[ CovidDeaths01] dea
JOIN [dbo].[ CovidVaccinations01] vac
  ON dea.date = vac.date
  AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (1.0 * RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(250),
Location NVARCHAR(250),
Date Datetime ,
Population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM [dbo].[ CovidDeaths01] dea
JOIN [dbo].[ CovidVaccinations01] vac
ON dea.date = vac.date
AND dea.location = vac.location
-- WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3

SELECT *, (1.0 * RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later Visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM [dbo].[ CovidDeaths01] dea
JOIN [dbo].[ CovidVaccinations01] vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3


SELECT * 
FROM PercentPopulationVaccinated


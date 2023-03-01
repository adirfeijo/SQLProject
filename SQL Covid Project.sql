-- Verify that import was successful and that we can view the tables correctly

SELECT *
FROM `sqlproject-378722.sqlproject.CovidDeaths`;

SELECT *
FROM `sqlproject-378722.sqlproject.CovidVaccinations`;



-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `sqlproject-378722.sqlproject.CovidDeaths`;


-- Total Cases vs Total Deaths
-- Shows the likelihood of dying after contracting covid19 in France

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage 
FROM `sqlproject-378722.sqlproject.CovidDeaths`
WHERE location = "France"
ORDER BY 2;


-- Total Cases vs Population
-- Shows what percentage of population got covid19 in France 

SELECT location, date, total_cases, population, (total_cases/population) * 100 as cases_percentage 
FROM `sqlproject-378722.sqlproject.CovidDeaths`
WHERE location = "France"
ORDER BY 2;


-- Countries with highest infection rate compared to population

SELECT location, population, max(total_cases) as higest_infections, max((total_cases/population)) * 100 as cases_percentage 
FROM `sqlproject-378722.sqlproject.CovidDeaths`
GROUP BY population, location
ORDER BY cases_percentage DESC;


-- Countries with the highest death count per population

SELECT location, max(total_deaths) as total_death_count
FROM `sqlproject-378722.sqlproject.CovidDeaths`
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC;


-- Continents with the highest death count per population

SELECT location, max(total_deaths) as total_death_count
FROM `sqlproject-378722.sqlproject.CovidDeaths`
WHERE continent is null
GROUP BY location
ORDER BY total_death_count DESC;


-- Global numbers

SELECT date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases) * 100 as death_percentage 
FROM `sqlproject-378722.sqlproject.CovidDeaths`
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2;


-- Total Population vs Vaccinations

SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, sum(CovidVaccinations.new_vaccinations) OVER (partition by CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) as rolling_people_vaccinated
FROM `sqlproject-378722.sqlproject.CovidDeaths` as CovidDeaths
JOIN `sqlproject-378722.sqlproject.CovidVaccinations` as CovidVaccinations
ON CovidDeaths.location = CovidVaccinations.location AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is not null
ORDER BY 2, 3;


-- USING A CTE 

WITH PopvsVac
AS 
(SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, sum(CovidVaccinations.new_vaccinations) OVER (partition by CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) as rolling_people_vaccinated
FROM `sqlproject-378722.sqlproject.CovidDeaths` as CovidDeaths
JOIN `sqlproject-378722.sqlproject.CovidVaccinations` as CovidVaccinations
ON CovidDeaths.location = CovidVaccinations.location AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is not null
ORDER BY 2, 3)
SELECT *, (rolling_people_vaccinated/population) * 100
FROM PopvsVac;

-- Using a TEMP table

CREATE TEMP TABLE PercentPopulationVaccinated
(
  continent string(255),
  location string(255),
  date date,
  population float,
  new_vaccinations float,
  rolling_people_vaccinated float
)
INSERT INTO PercentPopulationVaccinated
(SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, sum(CovidVaccinations.new_vaccinations) OVER (partition by CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) as rolling_people_vaccinated
FROM `sqlproject-378722.sqlproject.CovidDeaths` as CovidDeaths
JOIN `sqlproject-378722.sqlproject.CovidVaccinations` as CovidVaccinations
ON CovidDeaths.location = CovidVaccinations.location AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is not null
ORDER BY 2, 3)
SELECT *, (rolling_people_vaccinated/population) * 100
FROM PercentPopulationVaccinated;


-- Creating a view to store data for later visualizations

CREATE VIEW `sqlproject-378722.sqlproject.PercentPopulationVaccinated` AS
SELECT CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations, sum(CovidVaccinations.new_vaccinations) OVER (partition by CovidDeaths.location ORDER BY CovidDeaths.location, CovidDeaths.date) as rolling_people_vaccinated
FROM `sqlproject-378722.sqlproject.CovidDeaths` as CovidDeaths
JOIN `sqlproject-378722.sqlproject.CovidVaccinations` as CovidVaccinations
ON CovidDeaths.location = CovidVaccinations.location AND CovidDeaths.date = CovidVaccinations.date
WHERE CovidDeaths.continent is not null;

SELECT *
FROM `sqlproject-378722.sqlproject.PercentPopulationVaccinated`
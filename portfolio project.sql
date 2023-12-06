SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- TOTAL CASES VS TOTAL DEATHS

SELECT location,date,total_cases,total_deaths,(CONVERT (float,total_deaths)/NULLIF(CONVERT(FLOAT,total_cases),0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Kenya%'
ORDER BY 1,2

-- TOTAL CASES VS POPULATION
-- SHOW PERCENTAGE OF POPULATION GOT COVID

SELECT location,date,population,total_cases,(CONVERT(FLOAT,total_cases) / population)*100 as PopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Kenya%'
ORDER BY 1,2

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location,population,MAX (total_cases) AS HighestInfectionCount,MAX((CONVERT(FLOAT,total_cases) / population))*100 as PopulationPercentageInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Kenya%'
GROUP BY location,population
ORDER BY PopulationPercentageInfected DESC

-- COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION


SELECT location,MAX (CONVERT(FLOAT,total_deaths)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Kenya%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

-- LOOKING AT THE CONTINENTS

SELECT location,MAX (CONVERT(FLOAT,total_deaths)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Kenya%'
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

SELECT continent,MAX (CONVERT(FLOAT,total_deaths)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Kenya%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- GLOBAL STATISTICS

--SELECT date, SUM(new_cases),SUM(CONVERT(FLOAT,new_deaths)), SUM(CONVERT(FLOAT,new_deaths)) / SUM(new_cases)*100
--FROM PortfolioProject..CovidDeaths
----WHERE location like '%Kenya%'
-- WHERE continent IS NOT NULL
-- GROUP BY date
--ORDER BY 1,2


-- TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USING CTE
WITH Pop_vs_Vac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
	FROM Pop_vs_Vac

-- TEMP TABLE

CREATE TABLE #PercentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population NUMERIC,
new_vaccinations nvarchar(255),
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
	FROM #PercentPeopleVaccinated

-- CREATING VIEW FOR VISUALIZATION

CREATE VIEW RollingPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

-- TABLEAU TABLE 1

SELECT SUM(new_cases) AS total_cases, SUM(CONVERT(float,new_deaths)) AS total_deaths , SUM(CONVERT(float,new_deaths))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'World'
ORDER BY 1,2

-- TABLE 2

SELECT location,SUM(CONVERT(float,new_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World','European Union','International','High Income','Upper middle income','Lower middle income','Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- TABLE 3

SELECT location,population,MAX(total_cases) AS HighestInfectionCount, MAX(total_cases)/population*100 AS PopulationPercentInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location,population
ORDER BY PopulationPercentInfected DESC


-- TABLE 4


SELECT location,population,date,MAX(total_cases) AS HighestInfectionCount, MAX(total_cases)/population*100 AS PopulationPercentInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location,population,date
ORDER BY PopulationPercentInfected DESC

-- TABLE 5

WITH Pop_vs_Vac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
	FROM Pop_vs_Vac


-- TABLE 6

SELECT location,date,population,total_cases,total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations$
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Total Cases VS Total deaths
--show likelihood of dying if you contracted covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where location like '%states%'
ORDER BY 1,2

--looking at total case vs population
--shows what percentage of the population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
Where location like '%states%'
ORDER BY 1,2

--looking at the country with the highest infection rate to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--BREAKING IT DOWN BY CONTINENT


--Showing the continent with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotaldeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotaldeathCount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases)AS TotalCases, SUM(CAST(new_deaths AS INT))AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population VS Vaccination

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations AS INT)) OVER(PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths$ Dea
JOIN PortfolioProject..CovidVaccinations$ Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
ORDER BY 2,3


--USING CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations AS INT)) OVER(PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths$ Dea
JOIN PortfolioProject..CovidVaccinations$ Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--USING TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations AS INT)) OVER(PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths$ Dea
JOIN PortfolioProject..CovidVaccinations$ Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations AS INT)) OVER(PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths$ Dea
JOIN PortfolioProject..CovidVaccinations$ Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3

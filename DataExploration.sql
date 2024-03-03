SELECT * FROM PortfolioProject ..CovidDeaths;

SELECT 
    location, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
FROM 
   PortfolioProject..CovidDeaths
ORDER BY 
    1,2;


-- Looking Total Cases vs Total Deaths
-- Likelihood of if you want contract covid in your country
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 AS death_rate
FROM
    PortfolioProject..CovidDeaths
WHERE
    location like '%States%'
    AND continent is not null
ORDER BY
    1, 2;

-- Looking Total Cases vs Population
-- Likelihood percentage of population effected by Covid
SELECT
    location,
    date,
    total_cases,
    population,
    (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS covid_rate
FROM
    PortfolioProject..CovidDeaths
WHERE
    location like '%States%'
    AND continent is not null
ORDER BY
    1, 2;

-- Looking at Countries with highest Infection rate compared to Population
SELECT
     location,
	 population,
	 MAX(total_cases) AS HighestCovidCount,
	 MAX((total_cases/population)) * 100 AS covid_rate
FROM
    PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY 
       location, population
ORDER BY 
       covid_rate DESC;

-- Showing Countries with Highest Death Count compared to Population

SELECT
     location,
	 MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM
    PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY 
       location
ORDER BY 
       HighestDeathCount DESC;

-- Let's break things by Continent
SELECT
     continent,
	 MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM
    PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY 
       continent
ORDER BY 
       HighestDeathCount DESC;

-- Showing continets with Highest Death Count
SELECT
     continent,
	 MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM
   PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
Order BY HighestDeathCount DESC;

-- Global Numbers
SELECT
    --date,
    SUM(new_cases) AS total_cases,
    SUM(new_deaths) AS total_deaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL
        ELSE SUM(new_deaths) * 100.00/ NULLIF(SUM(new_cases), 0)
    END AS death_rate
FROM
    PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY death_rate;


--Looking at Total Population vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  And dea.date = vac.date
WHERE dea.Continent is not null
ORDER BY 2,3;

--Use CTE
With PopvsVac (continent, location, date, population, new_vaacinations, RollingPeopleVaccinated)
As
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  And dea.date = vac.date
WHERE dea.Continent is not null
)

SELECT *, (RollingPeopleVaccinated/population)/100
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC(18, 2),
    New_vaccinations NUMERIC(18, 2),
    RollingPeopleVaccinated NUMERIC(18, 2)
);

INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    CONVERT(NUMERIC(18, 2), vac.new_vaccinations), -- Ensure new_vaccinations is numeric
    SUM(CONVERT(NUMERIC(18, 2), vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date;

SELECT 
    *, 
    (RollingPeopleVaccinated / Population) * 100
FROM 
    #PercentPopulationVaccinated;

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    CONVERT(NUMERIC(18, 2), vac.new_vaccinations) AS New_vaccinations, -- Provide a column alias
    SUM(CONVERT(NUMERIC(18, 2), vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;


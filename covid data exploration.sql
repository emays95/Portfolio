/*
Exploring Covid 19 Data for later visualization

Utilizing separate tables describing recorded deaths and vaccination details to gain insight on per capita trends using SQL basics including joins, CTE's, views, and temp tables.

*/
SELECT *
  FROM Portfolioproject..['covid-deaths$']
 ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM Portfolioproject..['covid-deaths$']
 ORDER BY 1,2

 -- Comparing total cases to total deaths
 -- Death rate by country

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
  FROM Portfolioproject..['covid-deaths$']
 WHERE location like '%states%'
 ORDER BY 1,2

-- Total cases vs. population

SELECT location, date, total_cases, new_cases, total_deaths, population, (total_cases / population) * 100 as InfectionRate
  FROM Portfolioproject..['covid-deaths$']
 WHERE location like '%states%'
 ORDER BY 1,2



-- countries with highest infection rate per capita TABLE 

 SELECT location,population, MAX(total_cases) MaxIfectionCt,  Max((total_cases / population)) * 100 as InfectionRate
  FROM Portfolioproject..['covid-deaths$']
 GROUP BY location, population
 ORDER BY InfectionRate DESC
  --Same query with date for use in time series visualization
SELECT location, population, date,  MAX(total_cases) MaxIfectionCt,  Max((total_cases / population)) * 100 as InfectionRate
  FROM Portfolioproject..['covid-deaths$']
 GROUP BY location, population, date
 ORDER BY InfectionRate DESC



-- countries with highest death count and rate

 SELECT location, MAX(CAST (total_deaths AS INT)) TotalDeathCt,  Max((CAST (total_deaths AS INT)/ population)) * 100 as DeathRate
   FROM Portfolioproject..['covid-deaths$']
  WHERE continent is not null
  GROUP BY location
  ORDER BY TotalDeathCt DESC



-- Continents with highest death count

 SELECT continent, MAX(CAST (total_deaths AS INT)) TotalDeathCt,  Max((CAST (total_deaths AS INT)/ population)) * 100 as DeathRate
   FROM Portfolioproject..['covid-deaths$']
  WHERE continent is not null
  GROUP BY continent
  ORDER BY TotalDeathCt DESC



-- Global total numbers
 SELECT SUM(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, sum(cast(new_deaths as int)) / sum(new_cases) *100 as DeathPercentage
  FROM Portfolioproject..['covid-deaths$']
  WHERE continent is not null
  ORDER BY 1,2



-- Total deaths by continent
SELECT location, SUM(CAST(new_deaths as int)) TotalDeathCt
  FROM Portfolioproject..['covid-deaths$']
 WHERE continent is null
       and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Low income', 'Lower middle income')
 GROUP BY  location
 ORDER BY TotalDeathCt desc



 --Using a CTE like a single use temp table, can be initialized for an individual query

 WITH popvac (continent, location, date, population, new_vaccinations, cumulative_vaccinations)
 AS
 (
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
	   SUM(CAST (vax.new_vaccinations as float)) OVER (partition by dea.location ORDER BY dea.location, dea.date) cumulative_vaccinations
  FROM Portfolioproject..['covid-deaths$'] dea
  JOIN Portfolioproject..covid_vaccinations$ vax
	   ON dea.location = vax.location
	   and dea.date = vax.date
 WHERE dea.continent is not null
 )

 Select *, (cumulative_vaccinations / population)*100 percent_vaccinated
 FROM popvac
 order by location;


 --Unlike CTE's temp tables are accessible beyond a single query, which is more useful when the table will be used multiple times.


DROP TABLE IF EXISTS #percentpopvaccinated

CREATE TABLE #percentpopvaccinated(
	   continent nvarchar(255),
	   location nvarchar(255),
	   date datetime,
	   population numeric,
	   new_vaccinations numeric,
	   cummulative_vaccinations numeric
	   )

 INSERT INTO #percentpopvaccinated 
  SELECT dea.continent, dea.location, dea.date, dea.population , vax.new_vaccinations, 
	   SUM(CAST (vax.new_vaccinations as float)) OVER (partition by dea.location ORDER BY dea.location, dea.date) cummulative_vaccinations

  FROM Portfolioproject..['covid-deaths$'] dea
  JOIN Portfolioproject..covid_vaccinations$ vax
	   ON dea.location = vax.location
	   and dea.date = vax.date

 
 Select * 
  from #percentpopvaccinated
 WHERE continent is not null


 --Creating view for viz later, can be imported or queried directly from database in PowerBI or Tableau

CREATE View popvaccinated as

  SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
	   SUM(CAST (vax.new_vaccinations as float)) OVER (partition by dea.location ORDER BY dea.location, dea.date) cumulative_vaccinations

  FROM Portfolioproject..['covid-deaths$'] dea
  JOIN Portfolioproject..covid_vaccinations$ vax
	  ON dea.location = vax.location
	  and dea.date = vax.date
 WHERE dea.continent is not null


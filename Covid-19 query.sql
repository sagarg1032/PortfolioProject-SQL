
SELECT * 
FROM [Portfolio Project].dbo.Coviddeaths

--SELECT * 
--FROM [Portfolio Project].dbo.CovidVaccinations



SELECT location, date, population, total_cases, new_cases, total_deaths
FROM [Portfolio Project].dbo.Coviddeaths
where continent is not null 
and location like '%India%'
order by 1, 2

-- TOTAL CASES VS TOTAL DEATHS
-- Likelihood of dying if you contract COVID-19 in India

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Case_Wise_Death_Percentage
FROM [Portfolio Project].dbo.Coviddeaths
where continent is not null 
and location like '%India%'
order by Case_Wise_Death_Percentage desc


-- TOTAL CASES VS POPULATION

SELECT location, date, population, total_cases, (total_cases/population) * 100 as Percent_Population_Infected
FROM [Portfolio Project].dbo.Coviddeaths
where continent is not null 
and location like '%India%'
order by 5 desc

-- Countries with Higher Infection Rate Compared to Population

SELECT location, population, MAX(total_cases) as Infection_Count, MAX(total_cases/population) * 100 as Higher_Infection_Rate
FROM [Portfolio Project].dbo.Coviddeaths
where continent is not null 
--and location like '%India%'
Group by Location, population
order by 4 desc 


-- Highest Death Count By Location

SELECT location, population, Max(Cast(total_deaths as int)) as Highest_Death_Count
FROM [Portfolio Project].dbo.Coviddeaths
where continent is not null 
--and location like '%India%'
Group by Location, population
order by 3 desc 

-- Highest Death Count By Continent
-- North America is showing only US data

SELECT continent, Max(Cast(total_deaths as int)) as Highest_Death_Count
FROM [Portfolio Project].dbo.Coviddeaths
where continent is not null 
--and location like '%India%'
Group by continent

-- North America Death Count Fixed by CTE

With NA (Continent, location, Total_deaths)
as
(
SELECT continent, location, Sum(cast(new_deaths as int)) as Total_Deaths
FROM [Portfolio Project].dbo.Coviddeaths
where continent is not null 
and continent like '%North%'
Group by continent, location
)
Select Continent, Sum(total_deaths)
from NA
Group by continent


-- Global Numbers

SELECT SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/SUM(new_cases)) * 100 as 
Death_Percentage
FROM [Portfolio Project].dbo.Coviddeaths
where continent is not null 
--and location like '%India%'
--Group by date
order by 1,2


-- Total Population VS Vaccinations
-- Shows Percentage of Population that have received atleast one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


-- Using CTE to perform Calculation on previous query

With PopVsVac (Continent, Location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population) * 100
from PopVsVac
Where location = 'India';


-- Using TEMP Table to perform calculation in previous query

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (

continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

Select * 
from #PercentPopulationVaccinated


--Creating a View to store data for visualizations

Create View #PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- Order by 2,3

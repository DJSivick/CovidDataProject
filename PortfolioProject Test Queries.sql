Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/ NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--  Total Cases vs Population
--	Shows what percentage of population infected with Covid
Select Location, date, total_cases, total_deaths, (CONVERT(float,total_cases)/ NULLIF(CONVERT(float, population), 0))*100 as PercentOfPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, Max(CONVERT(float,total_cases)/ NULLIF(CONVERT(float, population), 0))*100 as HighestPercentOfPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, population
order by HighestPercentOfPopulationInfected desc

-- Countries with Highest Death Count per Location
Select Location, MAX(total_deaths) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by HighestDeathCount desc

--Continent with Highest Death Count
Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers
Select SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths, (CONVERT(float, SUM(new_deaths))/ NULLIF(CONVERT(float, SUM(new_cases)), 0))*100 as NewDeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null


--Total Population vs Vaccinations
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
--from PortfolioProject..CovidVaccinations vac
--JOIN PortfolioProject..CovidDeaths dea
--	on dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


--CTE
With PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select Continent, location, New_Vaccinations, RollingPeopleVaccinated, (CONVERT(float, RollingPeopleVaccinated) / NULLIF(CONVERT(float, population), 0)) * 100 as PercentageOfPopVaccinated from PopvsVac;

--View for data
GO

CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
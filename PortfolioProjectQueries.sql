Select *
From PortfolioProject..CovidDeaths
Where location = 'World' 

-- Standardize Date Format

Select date, Convert(Date, date)
from PortfolioProject..CovidDeaths;

Update CovidDeaths
SET date = CONVERT(Date, date);

Select date, Convert(Date, date)
from PortfolioProject..CovidVaccinations;

Update CovidVaccinations
SET date = CONVERT(Date, date);

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
Select Location, population,date, MAX(total_cases) as HighestInfectionCount, Max(CONVERT(float,total_cases)/ NULLIF(CONVERT(float, population), 0))*100 as HighestPercentOfPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, population, date
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinations
from PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


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

---------------------------------------------------------------------------------------------------
--Standardize Data

--Update missing continent
Select * 
From PortfolioProject..CovidDeaths
where continent = location

update CovidDeaths
set continent = location
where continent = null;



---------------------------------------------------------------------------------------------------
-- Delete Duplicates

with RowCTE AS(
Select *,
	ROW_NUMBER() Over(
	Partition By [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[population]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
      ,[new_deaths_smoothed]
      ,[total_cases_per_million]
      ,[new_cases_per_million]
      ,[new_cases_smoothed_per_million]
      ,[total_deaths_per_million]
      ,[new_deaths_per_million]
      ,[new_deaths_smoothed_per_million]
      ,[reproduction_rate]
      ,[icu_patients]
      ,[icu_patients_per_million]
      ,[hosp_patients]
      ,[hosp_patients_per_million]
      ,[weekly_icu_admissions]
      ,[weekly_icu_admissions_per_million]
      ,[weekly_hosp_admissions]
      ,[weekly_hosp_admissions_per_million]
	Order by iso_code) row_num

from PortfolioProject..CovidDeaths
)

select * 
from RowCTE
where row_num > 1

with RowCTE AS(
Select *,
	ROW_NUMBER() Over(
	Partition By [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[new_tests]
      ,[total_tests]
      ,[total_tests_per_thousand]
      ,[new_tests_per_thousand]
      ,[new_tests_smoothed]
      ,[new_tests_smoothed_per_thousand]
      ,[positive_rate]
      ,[tests_per_case]
      ,[tests_units]
      ,[total_vaccinations]
      ,[people_vaccinated]
      ,[people_fully_vaccinated]
      ,[new_vaccinations]
      ,[new_vaccinations_smoothed]
      ,[total_vaccinations_per_hundred]
      ,[people_vaccinated_per_hundred]
      ,[people_fully_vaccinated_per_hundred]
      ,[new_vaccinations_smoothed_per_million]
      ,[stringency_index]
      ,[population_density]
      ,[median_age]
      ,[aged_65_older]
      ,[aged_70_older]
      ,[gdp_per_capita]
      ,[extreme_poverty]
      ,[cardiovasc_death_rate]
      ,[diabetes_prevalence]
      ,[female_smokers]
      ,[male_smokers]
      ,[handwashing_facilities]
      ,[hospital_beds_per_thousand]
      ,[life_expectancy]
      ,[human_development_index]
	Order by iso_code) row_num

from PortfolioProject..CovidVaccinations
)

select * 
from RowCTE
where row_num > 1

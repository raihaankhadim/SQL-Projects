
--Looking at the data we have
Select *
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order By 3, 4 

Select *
From PortfolioProject.dbo.CovidVaccinations
Order By 3,4

--Select Data that we are going to be using
Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order By 1, 2

--Total Cases vs Total Deaths (in the UK)
--Shows the likelihood of dying if you contract Covid in your country
Select Location, Date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where Location like '%kingdom%' and continent is not null
Order By 1, 2

--Total Cases vs Population (in the UK)
--Shows what percentage of population got Covid
Select Location, Date, Population, total_cases, ((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where Location like '%kingdom%' and continent is not null
Order By 1, 2

--Countries with the highest infection rate compared to population
--Shows which countries had the highest infection rates 
Select Location, Population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group By location, population
Order By PercentPopulationInfected desc

--Looking at countries with the highest death count per population
--Shows which countries had the highest number of deaths
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group By location
Order By TotalDeathCount desc

--Looking at the continents with the highest death count per population
--Shows which continents had the highest number of deaths
Select Continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount desc

--Global numbers per day for total cases, total deaths & death rate
Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by date
Order By 1, 2

--Global numbers for total cases, total deaths & death rate 
Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order By 1, 2

--Total Population vs Number of Vaccinations
--Shows in the number of vaccinations per day in each country and a rolling count of these
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
From PortfolioProject.dbo.CovidDeaths as dea 
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

--Using a CTE to calculate the number of and percentage of people vaccinated 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinvationCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
From PortfolioProject.dbo.CovidDeaths as dea 
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3
)
Select *, (RollingVaccinvationCount/Population)*100 as PercentPopulationVaccinated
from PopvsVac

--Using a Temp Table to calculate the number of and percentage of people vaccinated 
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingVaccinationCount numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
From PortfolioProject.dbo.CovidDeaths as dea 
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

Select *, (RollingVaccinationCount/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated


--Creating a view to store data for visualisations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
From PortfolioProject.dbo.CovidDeaths as dea 
join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2, 3

select *
from PercentPopulationVaccinated
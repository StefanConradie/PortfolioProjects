--Covid-19 SQL Exploration
--Skills that were used where : Joins, Inserts, Selects, CTE's, Temp Tables, Creating tables and views and Converting Data Types
-- Link to data set used : https://ourworldindata.org/covid-deaths

Select * 
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;


--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

--Looking at total cases vs total deaths
--Shows likelihood of dying of Covid in my country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%south africa%'
where continent is not null
order by 1,2;

--Looking at total cases vs population
--Shows what percentage of population got Covid

Select Location, date,population, total_cases, (total_cases/population)*100 as CovidPercentage
From PortfolioProject..CovidDeaths
Where Location like '%south africa%'
where continent is not null
order by 1,2;

--What country has highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInfection
From PortfolioProject..CovidDeaths
--Where Location like '%south africa%'
where continent is not null
Group by location,population
order by PercentPopInfection desc;

--Showing countries with highest death count per population

Select Location,MAX(Convert(int,total_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%south africa%'
where continent is not null
Group by location
order by TotalDeathCount desc;



--By continent

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%south africa%'
where continent is not null
Group by continent
order by TotalDeathCount desc;




--Global numbers


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%south africa%'
where continent is not null
--Group by date
order by 1,2;


ALTER TABLE CovidDeaths  ALTER COLUMN location nvarchar(150);

--How many people have been vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;



--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)/100
From PopvsVac;


--Use Temp table

Drop Table if exists #PercentPopVaccinated;
Create table #PercentPopVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
);


Insert into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * , (RollingPeopleVaccinated/Population)/100
From #PercentPopVaccinated;




--Creating View to store data

Create View PercentPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null




Select *
From PercentPopVaccinated;

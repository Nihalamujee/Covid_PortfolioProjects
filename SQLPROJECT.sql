select * from
PortfolioProject..covidDeaths
where continent is not null
order by 3,4

--select * from
--PortfolioProject..covidvaccinations
--order by 3,4

--select the data that we are going to using

select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..covidDeaths
where continent is not null
order by 1,2

--Looking at Total cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..covidDeaths
where location like '%india%' and
continent is not null
order by 1,2



--Looking at the total cases vs population
--shows what percentage of population got covid

select Location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
where location like '%india%'
and continent is not null
order by 1,2


--Looking at countries highest infection rate compared to population


select Location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
where continent is not null
group by Location,population
order by PercentPopulationInfected desc


--showing the countries with the highest death count per population

select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

--showing the continents with the highest death count per population


select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths
where continent is not null
order by 1,2 


--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
     On dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null
order by 2,3


--use CTE

with PopvsVac(Continent,Location,Date,population,New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
     On dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null

)
select * ,(RollingPeopleVaccinated/population)*100
from PopvsVac



--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date)
   as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
     On dea.location=vac.location
	 and dea.date=vac.date
--where dea.continent is not null

select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--creating view to store data for later visualisations

create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.Date)
   as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
     On dea.location=vac.location
	 and dea.date=vac.date
where dea.continent is not null
--order by 2,3


Select * from PercentPopulationVaccinated
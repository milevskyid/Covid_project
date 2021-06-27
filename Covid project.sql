select *
from [Portfolio Project]..CovidDeaths
order by 3,4;

--select *
--from [Portfolio Project]..CovidVaccionations
--order by 3,4;

-- Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location = 'Ukraine' and continent is not null
order by 1,2;


--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
select location, date, total_cases, population, (total_cases/population)*100 as Percentage_of_Patients
from [Portfolio Project]..CovidDeaths
where location = 'Ukraine'
order by 1,2;

--Looking at countries with Highest Infection Rate compare to Population
select location, population, max(total_cases) as highest_infaction_count, max((total_cases/population))*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths
group by location, population  
order by PercentPopulationInfected desc

--Showing counties with Highest Deaths Count per Population
select location, max(cast(total_deaths as int)) as total_death_count
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location
order by total_death_count desc

--LET'S	BREAK THINGS DOWN BY CONTINENT
--Showing continets with the highest death count per population
select location, max(cast(total_deaths as int)) as total_death_count
from [Portfolio Project]..CovidDeaths
where continent is null
group by location
order by total_death_count desc


--GLOBAL NUMBERS
select date, sum(new_cases) new_cases, sum(cast(new_deaths as int)) new_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null
group by date
order by 1,2;

-- Looking at Total Population vs Vaccinations
with popvsvac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as (
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from [Portfolio Project]..CovidDeaths dea
	join [Portfolio Project]..CovidVaccionations vac on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 people_vaccinated_percent
from popvsvac
order by location, date;	


--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from [Portfolio Project]..CovidDeaths dea
	join [Portfolio Project]..CovidVaccionations vac on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
	select *, (RollingPeopleVaccinated/population)*100 people_vaccinated_percent
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations
drop view if exists PercentPopulationVaccinated
create View PercentPopulationVaccinated as
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from [Portfolio Project]..CovidDeaths dea
	join [Portfolio Project]..CovidVaccionations vac on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null

select *
from PercentPopulationVaccinated
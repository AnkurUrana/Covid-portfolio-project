--select *
--from Portfolioproject..covidvaccination
--order by 3,4 


select *
from Portfolioproject..CovidDeaths$
where continent is not null
order by 3,4 

select location,date,total_cases,new_cases,total_deaths,population
from Portfolioproject..CovidDeaths$
where continent is not null
order by 1,2

-- looking at total cases vs total deaths
-- show likehood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage  
from Portfolioproject..CovidDeaths$
where location like '%india%'
and continent is not null
order by 1,2

-- looking at total cases vs population
-- show what percentage of population got covid
select location,date,population,total_cases,(total_cases/population)*100 as percentageofpopulationinfected
from Portfolioproject..CovidDeaths$
--where location like '%india%'
where continent is not null
order by 1,2

-- look at contries with highest infection rate compare to popluation
select location,population,MAX(total_cases) as highestinfectioncount,MAX((total_cases/population))*100 as percentageofpopulationinfected
from Portfolioproject..CovidDeaths$
--where location like '%india%'
group by location , population
order by percentageofpopulationinfected desc

-- showing countriees with highest death count population

select location,max(cast(total_Deaths as int)) as totaldeathcount
from Portfolioproject..CovidDeaths$
--where location like '%india
where continent is not null
group by location 
order by totaldeathcount desc

-- let's break things down by continent

-- showing the continents with the highest death count per populuation

select continent ,max(cast(total_Deaths as int)) as totaldeathcount
from Portfolioproject..CovidDeaths$
--where location like '%india
where continent is not null
group by continent 
order by totaldeathcount desc


-- Global numbers
select date, sum(new_cases) as total_cases, sum (cast (new_deaths as int)) as total_deaths, sum (cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage  
from Portfolioproject..CovidDeaths$
--where location like '%india%'
where continent is not null
group by date
order by 1,2

select  sum(new_cases) as total_cases, sum (cast (new_deaths as int)) as total_deaths, sum (cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage  
from Portfolioproject..CovidDeaths$
--where location like '%india%'
where continent is not null
--group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent,  dea.location , dea.date , dea.population , vac.new_vaccinations , sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated

from portfolioproject..CovidDeaths$ dea
join portfolioproject..covidvaccination vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- with CTE
 with popvsVac (continent , location , date , population ,new_vaccinations,  rollingpeoplevaccinated)
 as
 (
 select dea.continent,  dea.location , dea.date , dea.population , vac.new_vaccinations , sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from portfolioproject..CovidDeaths$ dea
join portfolioproject..covidvaccination vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(rollingpeoplevaccinated/population)*100
from popvsVac

-- temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent,  dea.location , dea.date , dea.population , vac.new_vaccinations , sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from portfolioproject..CovidDeaths$ dea
join portfolioproject..covidvaccination vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select * ,(rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated



-- creating view to store data for later visulations

create view percentpopulationvaccinated as 
select dea.continent,  dea.location , dea.date , dea.population , vac.new_vaccinations , sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
from portfolioproject..CovidDeaths$ dea
join portfolioproject..covidvaccination vac
	on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
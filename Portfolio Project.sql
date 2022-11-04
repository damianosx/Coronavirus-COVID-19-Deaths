select * from [PortFolio Project]..CovidDeaths$  order by 1,2


select * from [PortFolio Project]..CovidVaccinations$
order by 1,2

--selecting data that we are going to be using

select location , date , total_cases , new_cases,
total_deaths , population 
from [PortFolio Project]..CovidDeaths$
order by 1,2


--looking at total cases vs total deaths 
 -- showing the propability of dying if you get covid in a specific country

select location , date , total_cases ,
total_deaths , (total_deaths/total_cases)*100 
as DeathPercentage
from [PortFolio Project]..CovidDeaths$
order by 1,2


--looking at total cases vs population 
--showing the percentage of population that got covid
select location , date , total_cases ,
population , (total_deaths/population)*100 
as PercentPopulationInfected
from [PortFolio Project]..CovidDeaths$
order by 1,2

--looking to countries with the highest infection rate compared to population

select location,population, max(total_cases) as HighestInfectionCount,
max(total_cases/population)*100 as PercentPopulationInfected
from [PortFolio Project]..CovidDeaths$
group by location , population
order by PercentPopulationInfected desc



--showing countries with highest death count per population
select location , max(cast(total_deaths as int)) as TotalDeathCount
from [PortFolio Project]..CovidDeaths$
where continent is not null
group by location 
order by TotalDeathCount desc



--lets break things down by continent
-- we can do all the things we calculated earlier with the countries for continents as well 
--showing continents with the highest death count per population 

select continent , max(cast(total_deaths as int)) as TotalDeathCount
from [PortFolio Project]..CovidDeaths$
where continent is not null
group by continent 
order by TotalDeathCount desc



-- global numbers 
-- we find the total cases , total deaths , and the global death percentage 
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from [PortFolio Project]..CovidDeaths$
where continent is not null 
group by date 
order by 1,2

-- total cases
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from [PortFolio Project]..CovidDeaths$
where continent is not null 
--group by date 
order by 1,2

-- using vacc table 

--looking at total population vs vaccinations 

--select dea.continent, dea.location, dea.date, dea.population, 
--vac.new_vaccinations
--from [PortFolio Project]..CovidDeaths$ dea
--join [PortFolio Project]..CovidVaccinations$ vac
--on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3 



select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))
over(partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
from [PortFolio Project]..CovidDeaths$ dea
join [PortFolio Project]..CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3 

--use cte
with popvsvac (continent ,location,date,population,new_vaccinations,
rollingpeoplevaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
from [PortFolio Project]..CovidDeaths$ dea
join [PortFolio Project]..CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
--order by 2,3 
)
select * , (rollingpeoplevaccinated/population)*100
from popvsvac



--create a temp table 
 drop table if exists #percentpopulationvaccinated
 create table #percentpopulationvaccinated
 (
 continent nvarchar(255) , 
 location nvarchar(255) , 
 date datetime,
 population numeric,
 new_vaccinations numeric ,
 rollingpeoplevaccinated numeric
 )

 insert into #percentpopulationvaccinated
 select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
from [PortFolio Project]..CovidDeaths$ dea
join [PortFolio Project]..CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
--order by 2,3 

select * , (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated



--creating view to store data for later visualizations 
create view percentpopulationvaccinated as
 select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location,
dea.date) as rollingpeoplevaccinated
from [PortFolio Project]..CovidDeaths$ dea
join [PortFolio Project]..CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
--order by 2,3 


 


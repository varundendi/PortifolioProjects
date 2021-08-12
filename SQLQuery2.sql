select *
from dbo.CovidDeaths$
order by 3,4

--select *
--from dbo.CovidVaccination$
--order by 3,4

--select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population

from dbo.CovidDeaths$
order by 1,2


--total cases vs total deaths:
--shows the likelihood of dying if you contract  covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths$
where location like '%states%'
order by 1,2

--looking at total cases vs popullation
--shows what percentage of population got covid
select location,date,population,total_cases, (total_cases/population)*100 as pecentageofpopulationInfected
from dbo.CovidDeaths$
where location like '%states%'
order by 1,2

--what countries have highest infection rate compared to population
--
select location,population,max(total_cases) as HighestInfectionCount , max((total_cases/population))*100 as pecentageofpopulationInfected
from dbo.CovidDeaths$
where location like 'I%a'
group by location,population
order by pecentageofpopulationInfected desc


--showing countries with highest death count population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths$
where continent is not null
group by location
order by  TotalDeathCount desc


--lets break things down by continent\
--showing countries with highest death count population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths$
where continent is  null
group by location
order by  TotalDeathCount desc

--showing the continent with highest death count
select continent,max(cast(total_deaths as int))as totaldeathCountContinent
from dbo.CovidDeaths$
where continent is not null
group by continent
order by totaldeathCountContinent desc



--global numbers according to date
select date,sum(new_cases)as total_Cases,sum(cast(new_deaths as int ))as total_Deaths,sum(cast(new_deaths as int ))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths$
where continent is not null
group by date
order by 1,2



--global numbers entirely
select sum(new_cases)as total_Cases,sum(cast(new_deaths as int ))as total_Deaths,sum(cast(new_deaths as int ))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths$
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as rollingPeopleVAccinated

from dbo.CovidDeaths$ dea
join dbo.CovidVaccination$ vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null
order by 2,3

    

	--use cte
with popvsvac (continent,location,date,population,new_vaccinations,rollingPeopleVAccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as rollingPeopleVAccinated

from dbo.CovidDeaths$ dea
join dbo.CovidVaccination$ vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingPeopleVAccinated/population)*100 as wholerolling
from popvsvac



--using temp table

Drop Table if exists  #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location varchar(255),
date datetime ,
population numeric,
new_vaccination numeric,
rollingPeopleVAccinated numeric
)

Insert into  #PercentPopulationVaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as rollingPeopleVAccinated

from dbo.CovidDeaths$ dea
join dbo.CovidVaccination$ vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null
--order by 2,3
select *,(rollingPeopleVAccinated/population)*100 as wholerolling
from #PercentPopulationVaccinated




--creating view to store data foe later visualisationns

create view  PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) 
over(partition by dea.location order by dea.location,dea.date) as rollingPeopleVAccinated

from dbo.CovidDeaths$ dea
join dbo.CovidVaccination$ vac
     on dea.location=vac.location
     and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated
select * from dbo.CovidDeaths$









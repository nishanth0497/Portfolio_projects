select *
from [project-1-database]..covidvaccination
order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
From [project-1-database].. coviddeaths
order by 1,2

--Total cases vs Total deaths : death_percentage in India
select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage
From [project-1-database].. coviddeaths
Where location like 'India'
order by 1,2

--Total cases vs Total deaths : covid_contraction_percentage in India
select Location, date, total_cases, population, (total_cases/population) * 100 as Contraction_percentage
From [project-1-database].. coviddeaths
Where location like 'India'
order by 1,2

--Countries with highest infection rates: 
select Location, Population, MAX(total_cases) as highest_cases, MAX((total_cases/population) * 100) as Contraction_percentage
From [project-1-database].. coviddeaths
Group by Location, Population
order by Contraction_percentage desc

--Countries with highest death count:
select Location, Population, MAX(cast(total_deaths as int)) as Highest_deaths
From [project-1-database].. coviddeaths
where continent is not NULL
Group by Location, Population
order by Highest_deaths desc

--Continents with highest death count per population
select continent, MAX(cast(total_deaths as int)) as Highest_deaths
From [project-1-database]..coviddeaths
where continent is not NULL
group by continent
order by Highest_deaths desc

--Global Numbers
select SUM(cast(new_deaths as bigint))as total_deaths, SUM(cast(new_cases as bigint)) as total_cases, SUM(cast(total_cases as bigint))/SUM(cast(total_deaths as bigint)) as death_percentage
From [project-1-database]..coviddeaths
where continent is not NULL
--group by date
order by 1,2

-- Total Population vs vaccination
with Popuvsvaci ( continent, location, date, population, new_vaccinations, PeopleBeingVaccinated )
as (
select cod.continent, cod.location, cod.date, cod.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by cod.location order by cod.location, cod.date ROWS UNBOUNDED PRECEDING) as PeopleBeingVaccinated

from [project-1-database]..coviddeaths cod
join [project-1-database]..covidvaccination vac
	on cod.location = vac.location
	and cod.date = vac.date
where cod.continent is not NULL
--order by 2,3
)

select *, (PeopleBeingVaccinated/population)
from Popuvsvaci


--TEMP TABLE
Drop table if exists #percentageofpopulationvaccinated
create table #percentageofpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleBeingVaccinated numeric
)

Insert into #percentageofpopulationvaccinated
select cod.continent, cod.location, cod.date, cod.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by cod.location order by cod.location, cod.date ROWS UNBOUNDED PRECEDING) as PeopleBeingVaccinated

from [project-1-database]..coviddeaths cod
join [project-1-database]..covidvaccination vac
	on cod.location = vac.location
	and cod.date = vac.date
where cod.continent is not NULL
--order by 2,3

select *, (PeopleBeingVaccinated/population)
from #percentageofpopulationvaccinated


--create view

create view percentageofpopulationvaccinated1 as
select cod.continent, cod.location, cod.date, cod.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by cod.location order by cod.location, cod.date ROWS UNBOUNDED PRECEDING) as PeopleBeingVaccinated

from [project-1-database]..coviddeaths cod
join [project-1-database]..covidvaccination vac
	on cod.location = vac.location
	and cod.date = vac.date
where cod.continent is not NULL
--order by 2,3







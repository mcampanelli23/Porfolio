
-- looking at data
select *
from portfolio..coviddeaths
where continent is not null
order by 3,4

--select *
--from portfolio..covidvacinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from portfolio..coviddeaths
order by 1,2

-- Compairing total cases and total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentdead
from portfolio..coviddeaths
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentdead
from portfolio..coviddeaths
where location like '%states%'
order by 1,2

-- total cases vs population in Canada. What is the population that got covid

select location, date, total_cases, population, (total_cases/population)*100 as popwithcovie
from portfolio..coviddeaths
where location like 'Canada'
order by 1,2

-- What countries have highest infection rate


select location, population, max(total_cases) as peak_infection_count, max((total_cases/population))*100 as percentinfected
from portfolio..coviddeaths
group by population, location
order by percentinfected desc

-- countries with highest death count

select location, max(cast(total_deaths as int)) as total_death_count
from portfolio..coviddeaths
where continent is not null
group by location
order by total_death_count desc

-- By contient 
select continent, max(cast(total_deaths as int)) as total_death_count
from portfolio..coviddeaths
where continent is not null
group by continent
order by total_death_count desc

-- Global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as deathpercentage
from portfolio..coviddeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as deathpercentage
from portfolio..coviddeaths
where continent is not null
order by 1,2

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from portfolio..coviddeaths dea
join portfolio..covidvacinations vac
on dea.location = vac.location
and dea.date = vac.date
order by 1,2,3

with popvsvac (continent, location, date, population, rollingpeoplevaccinated, new_vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rollingpopulation
from portfolio..coviddeaths dea
join portfolio..covidvacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *
from popvsvac

create table #PercentPopulationVaccinated
(
contient varchar(255), location varchar(255), date datetime, population int, new_vaccinations int,
rollingpeoplevaccinated
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as rollingpopulation
from portfolio..coviddeaths dea
join portfolio..covidvacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

-- created views for canada population with covid
create view CanadaNumbers as
select location, date, total_cases, population, (total_cases/population)*100 as popwithcovie
from portfolio..coviddeaths
where location like 'Canada'

select * 
from CanadaNumbers

-- View for global cases
create view GlobaCases as
select location, population, max(total_cases) as peak_infection_count, max((total_cases/population))*100 as percentinfected
from portfolio..coviddeaths
group by population, location

--view for highest death count

create view HighestDeathCount as
select location, max(cast(total_deaths as int)) as total_death_count
from portfolio..coviddeaths
where continent is not null
group by location

-- total vaccinations
select dea.continent, dea.location, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location) as rollingpopulation
from portfolio..coviddeaths dea
join portfolio..covidvacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

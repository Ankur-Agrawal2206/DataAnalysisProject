select *
from coviddata
where continent is not null
order by location,date

--select *
--from CovidVaccinations
--order by location,date

select location,date,total_cases,new_cases,
total_deaths,population
from coviddata
where continent is not null
order by location,date

-- total cases vs total deaths

select location,date ,total_cases,total_deaths, 
format((total_deaths/total_cases)*100,'N7')
AS rate_of_death
from coviddata
where continent is not null
--where location = 'india'
order by 1,2

--total cases vs population

select location,date ,total_cases,population, 
format((total_cases/population)*100,'N7')
AS rate_of_cases
from coviddata
where continent is not null
--where location = 'india'
order by 1,2

-- country which has the highest infection rate compared to population

select location, population,
max(total_cases) as HighestCases,
max((total_cases/population))*100 as HighestCovidRate
from Coviddata
where continent is not null
group by location, population
order by HighestCovidRate desc

-- highest deaths per population

select location, population,
max(cast(total_deaths as int)) as TotalDeathCount
--max((total_deaths/population))*100 as HighestDeathRate
from Coviddata
where continent is not null
group by location, population
order by TotalDeathCount desc

-- grouping by continent

select location, 
max(cast(total_deaths as int)) as TotalDeathCount
from Coviddata
where continent is null
group by location
order by TotalDeathCount desc

select continent, 
max(cast(total_deaths as int)) as TotalDeathCount
from Coviddata
where continent is not null
group by continent
order by TotalDeathCount desc

-- global stats

select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,--total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100
as DeathPercentage
from coviddata
where continent is not null
--where location = 'india'
group by date
order by 1,2

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,--total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100
as DeathPercentage
from coviddata
where continent is not null
--where location = 'india'
--group by date
order by 1,2

select *
from CovidVaccinations

-- total population vs vaccinations

select dat.continent, dat.location,dat.date,
dat.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dat.location 
order by dat.location,dat.date) as rolling_count_vaccination
from coviddata dat
join CovidVaccinations vac
	on dat.location = vac.location and
	dat.date = vac.date
where dat.continent is not null
order by 2,3

-- using cte

with PopvsVac (continent, location, date, population,
new_vaccinations,rollingpeoplevaccinated)
as 
(
select dat.continent, dat.location,dat.date,
dat.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dat.location 
order by dat.location,dat.date) as rolling_count_vaccination
from coviddata dat
join CovidVaccinations vac
	on dat.location = vac.location and
	dat.date = vac.date
where dat.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as
percentage_rolling_people
From PopvsVac
--where location = 'india'
order by 2,3

--temp table

DROP table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dat.continent, dat.location,dat.date,
dat.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as numeric)) over (partition by dat.location 
order by dat.location,dat.date) as rolling_count_vaccination
from coviddata dat
join CovidVaccinations vac
	on dat.location = vac.location and
	dat.date = vac.date
--where dat.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as
percentage_rolling_people
From #PercentPopulationVaccinated

-- views for visualizations

create view PercentPopulationVaccinated as
select dat.continent, dat.location,dat.date,
dat.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as numeric)) over (partition by dat.location 
order by dat.location,dat.date) as rolling_count_vaccination
from coviddata dat
join CovidVaccinations vac
	on dat.location = vac.location and
	dat.date = vac.date
where dat.continent is not null

select *
from PercentPopulationVaccinated

create view RateOfDeath as
select location,date ,total_cases,total_deaths, 
format((total_deaths/total_cases)*100,'N7')
AS rate_of_death
from coviddata
where continent is not null

select *
from RateOfDeath






-- Looking into covid deaths data

select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
where continent is not null
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in India

select location, date, total_cases, total_deaths, (total_deaths/total_cases * 100) as DeathPercentage
from dbo.CovidDeaths
where location = 'India' and continent is not null
order by 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid in India
select location, date, total_cases, population, (total_cases/population * 100) as CasesPercentage
from dbo.CovidDeaths
where location = 'India' continent is not null
order by 1,2;

-- Looking at countries with the highest infaction rate as compared to population

select location, population, max(total_cases), max((total_cases/population) * 100) as CasesPercentage
from dbo.CovidDeaths 
where continent is not null
group by location, population
order by CasesPercentage desc;

-- Looking at countries with the highest death count as compared to population

select location, population, max(cast(total_deaths as int)) as TotalDeaths
from dbo.CovidDeaths 
where continent is not null
group by location, population
order by TotalDeaths desc;

-- Looking at continents with the highest death count as compared to population

select continent, max(cast(total_deaths as int)) as TotalDeaths
from dbo.CovidDeaths 
where continent is not null
group by continent
order by TotalDeaths desc;

-- GLOBAL NUMBERS

select sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathCount
from dbo.CovidDeaths
where continent is not null
order by 1,2;

-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from
dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from
dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, RollingPeopleVaccinated/population * 100
from PopvsVac;

-- TEMP TABLE

DROP Table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from
dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on
dea.location = vac.location and
dea.date = vac.date
--where dea.continent is not null

select *, RollingPeopleVaccinated/population * 100
from #PercentagePopulationVaccinated;

create view PercentagePopulationVaccination as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from
dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
select * 
from PortfolioProject_SQLDataExploration..Covid_deaths$

select * 
from PortfolioProject_SQLDataExploration..Covid_vaccinations$
order by 3,4

select * 
from PortfolioProject_SQLDataExploration..Covid_deaths$
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population_density
from PortfolioProject_SQLDataExploration..Covid_deaths$
order by 1,2

--Looking at total cases v/s total deaths

select location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 AS death_percentage
from PortfolioProject_SQLDataExploration..Covid_deaths$
where location='India'
order by 1,2

--Looking at total cases v/s population

select location, date, total_cases, population_density, (CAST(total_cases AS float) / CAST(population_density AS float)) * 100 AS death_percentage
from PortfolioProject_SQLDataExploration..Covid_deaths$
where location='India'
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, MAX(total_cases) AS highestinfectioncount, MAX(CAST(total_cases AS float) / CAST(population_density AS float)) * 100 AS percentpopulatedinfected
from PortfolioProject_SQLDataExploration..Covid_deaths$
group by location, population_density
order by percentpopulatedinfected desc

--Looking at countries with highest death count per population

select location, MAX(total_deaths) AS highestdeathcount, MAX(CAST(total_deaths AS float) / CAST(population_density AS float)) * 100 AS percentpopulateddied
from PortfolioProject_SQLDataExploration..Covid_deaths$
where continent is not null
group by location, population_density
order by percentpopulateddied desc

--Looking at continents with highest death count per population

select location, MAX(total_deaths) AS highestdeathcount, MAX(CAST(total_deaths AS float) / CAST(population_density AS float)) * 100 AS percentpopulateddied
from PortfolioProject_SQLDataExploration..Covid_deaths$
group by location
order by percentpopulateddied desc

select *
from PortfolioProject_SQLDataExploration..Covid_deaths$ dea
join PortfolioProject_SQLDataExploration..Covid_vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Total population v/s vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject_SQLDataExploration..Covid_deaths$ dea
join PortfolioProject_SQLDataExploration..Covid_vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where (dea.continent is not null)
	order by 2,3

-- Using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject_SQLDataExploration..Covid_deaths$ dea
join PortfolioProject_SQLDataExploration..Covid_vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where (dea.continent is not null)
	--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from PopvsVac

-- temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccincations numeric,
rollingpeoplevaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject_SQLDataExploration..Covid_deaths$ dea
join PortfolioProject_SQLDataExploration..Covid_vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where (dea.continent is not null)
	--order by 2,3
select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated
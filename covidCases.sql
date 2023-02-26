SELECT * 
FROM PortfolioProject.coviddeaths;

-- SELECT * 
-- FROM PortfolioProject.covidvaccinations
-- order by 1,2

-- select the data that i am going to be using 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
order by 1,2;

-- looking at total cases vs total deaths
-- shows likelihood of you dying from covid in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathsPercentage
FROM PortfolioProject.coviddeaths 
where location like '%netherland%'
order by 1,2
limit 0, 85000;

-- looking at the Total cases vs the Population 
-- shows what percentage of the population got covid
SELECT location, date, total_cases, population, (total_cases/population) *100 as PercentagePopulationInfected
FROM PortfolioProject.coviddeaths 
where location like '%netherland%'
order by 1,2
limit 0, 85000;

-- looking at countries with highest infection rate compare to population
SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)) *100 as 
	PercentagePopulationInfected
FROM PortfolioProject.coviddeaths 
-- where location like '%netherland%'
group by location, population
order by PercentagePopulationInfected desc
limit 0, 85000;

-- showing the countries with the highest death count per population
Select Location, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject.CovidDeaths
-- Where location like '%netherland%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc
limit 0, 85000; 

-- BREAKING IT BY CONTINENT
-- Showing continents with the highest death count per population

Select continent, MAX(Total_deaths) as TotalDeathCount
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc
limit 0, 85000; 

-- GLOBAL 
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.CovidDeaths
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2
limit 0, 85000; 

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3
limit 0, 85000; 


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
limit 0, 85000; 


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated; 
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population text,
New_vaccinations text,
RollingPeopleVaccinated text
);

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;



-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject.CovidDeaths dea
Join PortfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null





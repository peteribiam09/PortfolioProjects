--MY PortFolio Projec 2022

SELECT *
FROM PortfoilioProject..CovidDeaths
ORDER BY 3,4;

SELECT *
FROM PortfoilioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4;
--SELECT *
--FROM PortfoilioProject..CovidVaccinations
--ORDER BY 3,4;

--SELECT Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths FROM PortfoilioProject..CovidDeaths
ORDER BY 1,2;


--Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfoilioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

--Looking at the Total cases vs Population
--Showing what percentage of population got covid

SELECT Location, date,Population, (total_cases/Population)*100 as PercentPopulationInfected
FROM PortfoilioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2; 

--Looking at Countries with Highest Infection Rate Compared to Populaqtion

SELECT Location,Population, Max(total_cases) as HighestInfectionCount, Max (total_cases/Population)*100 as PercentagePopulationInfected
FROM PortfoilioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected DESC; 

--Showing Countries with Highest Death Count per Population

SELECT Location, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfoilioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC; 



--LET'S BREAK THINGS DOWN BY COUNTNENT
--Showing the Continent with the highest death count

SELECT continent, Max(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfoilioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC; 

--Glober Numbers

SELECT sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,Sum(cast(new_deaths as int))/Sum(New_cases)*100 as DeathPercentage
FROM PortfoilioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;

SELECT date, sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,Sum(cast(new_deaths as int))/Sum(New_cases)*100 as DeathPercentage
FROM PortfoilioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

--joining the two table

SELECT *
FROM PortfoilioProject..CovidDeaths dea
join PortfoilioProject..CovidVaccinations vac
     on dea.location= vac.location
	 and dea.date =vac.date

--Looking at TOTAL POPULATION VS  VACCINATION

SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)as Rollingpeoplevaccinated
FROM PortfoilioProject..CovidDeaths dea
join PortfoilioProject..CovidVaccinations vac
     on dea.location= vac.location
	 and dea.date =vac.date
	 WHERE dea.continent is not null
	 ORDER BY 2,3

--use CTE
with PopvsVac (continent, location,Date, population, new_vaccinations,Rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)as Rollingpeoplevaccinated
FROM PortfoilioProject..CovidDeaths dea
join PortfoilioProject..CovidVaccinations vac
     on dea.location= vac.location
	 and dea.date =vac.date
 WHERE dea.continent is not null
--ORDER BY 2,3
)
select *, (Rollingpeoplevaccinated/population)*100
from PopvsVac










--TEM TABLE

DROP Table if exists #Percentpopulationvaccinated
Create Table #Percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric, 
New_vaccination numeric,
Rollingpeoplevaccinated numeric
)

insert into #Percentpopulationvaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)as Rollingpeoplevaccinated
FROM PortfoilioProject..CovidDeaths dea
join PortfoilioProject..CovidVaccinations vac
     on dea.location= vac.location
	 and dea.date =vac.date
 --WHERE dea.continent is not null
--ORDER BY 2,3

select *, (Rollingpeoplevaccinated/population)*100
from #Percentpopulationvaccinated


--Creating view to store data for later visualization

Create view Percentpopulationvaccinated as
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date)as Rollingpeoplevaccinated
--, (Rollingpeoplevaccinated)*100
FROM PortfoilioProject..CovidDeaths dea
join PortfoilioProject..CovidVaccinations vac
     on dea.location= vac.location
	 and dea.date =vac.date
WHERE dea.continent is not null
--ORDER BY 2,3



select *
from Percentpopulationvaccinated

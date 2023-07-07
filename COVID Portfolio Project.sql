/*
Covid 19 Data Exploration
skills used: Joins, CTE's, Temp Tables, Window Functions, Aggregate Functions, Creating views, Converting Data Types
*/


select *
from PortfolioProject..CovidDeaths$
order by 3,4

select *
from PortfolioProject..CovidVaccinations$
order by 3,4

select location,date,total_cases,new_cases,total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2


--Total Cases Vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths, cast(total_deaths as numeric)/cast(total_cases as numeric)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

--Total Cases Vs Population
--Shows the Percentage of Population infected with covid

select location,date, population,total_cases, cast(total_cases as numeric)/cast(population as numeric)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
order by 1,2


--Countries with Highest Infection Rate compared to the Population

select location ,population,MAX(total_cases) as HighestInfectionCount, MAX(cast(total_cases as numeric)/cast(population as numeric))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
Group by Population, location
order by PercentagePopulationInfected desc


--Countries with Highest Death Count Per Population

select location ,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount desc


--Global DeathRate based on Continent wise
--showing continents with the Hioghest Deathe rate per population

select continent ,max(cast(total_deaths as numeric)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

--shows the Total cases, Deaths and percentage in the order of date

select  date ,sum(New_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/NULLIF(sum(New_cases),0) *100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

--Shows the overall Total Cases, Deaths in the world

select  sum(New_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/NULLIF(sum(New_cases),0) *100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


--Starting with the Data from the CovidVaccination Table

select *
from PortfolioProject..CovidVaccinations$

--Combining data from both tables to show Total Population VS Vaccinations

select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
from PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
     on death.location=vaccine.location
	 and death.date=vaccine.date
where death.continent is not null
order by 2,3


--Shows the Rollingvalue for the vaccinations

select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
sum(convert(numeric,vaccine.new_vaccinations)) over(partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
     on death.location=vaccine.location
	 and death.date=vaccine.date
where death.continent is not null
order by 2,3


--Using CTE to Calculate the No. Of People vaccinated in each country Respectively using the Previous Query


with Popvsvac( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
sum(convert(numeric,vaccine.new_vaccinations)) over(partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
     on death.location=vaccine.location
	 and death.date=vaccine.date
where death.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100 as Percentagepeoplevaccinated
from Popvsvac


--Using Temp Table to do the above Query

DROP Table if exists  #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
sum(convert(numeric,vaccine.new_vaccinations)) over(partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
     on death.location=vaccine.location
	 and death.date=vaccine.date
where death.continent is not null

select *,(RollingPeopleVaccinated/population)*100 as Percentagepeoplevaccinated
from #PercentPopulationVaccinated


--Creating views to store data for visualization

create view PercentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
sum(convert(numeric,vaccine.new_vaccinations)) over(partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ death
join PortfolioProject..CovidVaccinations$ vaccine
     on death.location=vaccine.location
	 and death.date=vaccine.date
where death.continent is not null

select *
from PercentPopulationVaccinated
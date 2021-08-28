Select * 
From PortfolioProject1..CovidDeaths$

order by 3,4

--Select * 
--From PortfolioProject1..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths$
order by 1,2

--Looking at the Total Cases vs Total Deaths
-- Shows likeliehood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject1..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population) * 100 as DeathPercentage
From PortfolioProject1..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Looking at Countries with highest infection rate compared to population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths$
Group by Location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths$
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Break things down by continent

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths$
Where continent is not null
Group by  continent
order by TotalDeathCount desc

-- Global numbers

Select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, 
Sum(cast(new_deaths as int)) / Sum(new_cases) * 100 as DeathPercentage
From PortfolioProject1..CovidDeaths$
Where continent is not null
Group By date
order by 1,2


-- Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
From PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3,4

-- Use CTE
-- must create a CTE to use the RollingPeopleVaccinated column becaise it's not in the original table
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as ( 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
From PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population) * 100 
From PopvsVac

-- Can also do a Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
From PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Create a View
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(Convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths$ dea
Join PortfolioProject1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select * 
From PercentPopulationVaccinated
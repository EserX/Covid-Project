DROP TABLE IF EXISTS `portfolioproject`.`coviddeaths`;
CREATE TABLE IF NOT EXISTS `portfolioproject`.`coviddeaths` (
  `iso_code` VARCHAR(45) NULL,
  `continent` VARCHAR(45) NULL,
  `location` VARCHAR(45) NULL,
  `date` DATE NULL,
  `population` INT NULL,
  `total_cases` INT NULL,
  `new_cases` INT NULL,
  `new_cases_smoothed` DOUBLE NULL,
  `total_deaths` INT NULL,
  `new_deaths` INT NULL,
  `new_deaths_smoothed` DOUBLE NULL,
  `total_cases_per_million` DOUBLE NULL,
  `new_cases_per_million` DOUBLE NULL,
  `new_cases_smoothed_per_million` DOUBLE NULL,
  `total_deaths_per_million` DOUBLE NULL,
  `new_deaths_per_million` DOUBLE NULL,
  `new_deaths_smoothed_per_million` DOUBLE NULL,
  `reproduction_rate` DOUBLE NULL,
  `icu_patients` INT NULL,
  `icu_patients_per_million` DOUBLE NULL,
  `hosp_patients` INT NULL,
  `hosp_patients_per_million` DOUBLE NULL,
  `weekly_icu_admissions` INT NULL,
  `weekly_icu_admissions_per_million` DOUBLE NULL,
  `weekly_hosp_admissions` INT NULL,
  `weekly_hosp_admissions_per_million` DOUBLE NULL);

-- Set local infile to 1 to be able to loand data.  
  SET GLOBAL local_infile=1;
  SHOW GLOBAL VARIABLES LIKE 'local_infile';
  
  -- Load data from csv file
LOAD DATA LOCAL INFILE "C:\\Users\\Richard\\Downloads\\CovidDeaths.csv" INTO TABLE CovidDeaths
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(iso_code,continent,location,@date,population,total_cases,new_cases,new_cases_smoothed,total_deaths,new_deaths,new_deaths_smoothed,total_cases_per_million,new_cases_per_million,new_cases_smoothed_per_million,total_deaths_per_million,new_deaths_per_million,new_deaths_smoothed_per_million,reproduction_rate,icu_patients,icu_patients_per_million,hosp_patients,hosp_patients_per_million,weekly_icu_admissions,weekly_icu_admissions_per_million,weekly_hosp_admissions,weekly_hosp_admissions_per_million)
SET date = DATE_FORMAT(STR_TO_DATE(@date,'%m/%d/%Y'), '%Y-%m-%d');


-- Create table covidvaccinations
DROP TABLE IF EXISTS `portfolioproject`.`covidvaccinations`;
CREATE TABLE IF NOT EXISTS `portfolioproject`.`covidvaccinations` (
  `iso_code` VARCHAR(45) NULL,
  `continent` VARCHAR(45) NULL,
  `location` VARCHAR(45) NULL,
  `date` DATE NULL,
  `new_tests` INT NULL,
  `total_tests` INT NULL,
  `total_tests_per_thousand` DOUBLE NULL,
  `new_tests_per_thousand` DOUBLE NULL,
  `new_tests_smoothed` DOUBLE NULL,
  `new_tests_smoothed_per_thousand` DOUBLE NULL,
  `positive_rate` DOUBLE NULL,
  `tests_per_case` DOUBLE NULL,
  `tests_units` DOUBLE NULL,
  `total_vaccinations` INT NULL,
  `people_vaccinated` INT NULL,
  `people_fully_vaccinated` INT NULL,
  `total_boosters` INT NULL,
  `new_vaccinations` INT NULL,
  `new_vaccinations_smoothed` DOUBLE NULL,
  `total_vaccinations_per_hundred` DOUBLE NULL,
  `people_vaccinated_per_hundred` DOUBLE NULL,
  `people_fully_vaccinated_per_hundred` DOUBLE NULL,
  `total_boosters_per_hundred` DOUBLE NULL,
  `new_vaccinations_smoothed_per_million` DOUBLE NULL,
  `new_people_vaccinated_smoothed` DOUBLE NULL,
  `new_people_vaccinated_smoothed_per_hundred` DOUBLE NULL,
  `stringency_index` DOUBLE NULL,
  `population_density` DOUBLE NULL,
  `median_age` DOUBLE NULL,
  `aged_65_older` DOUBLE NULL,
  `aged_70_older` DOUBLE NULL,
  `gdp_per_capita` DOUBLE NULL,
  `extreme_poverty` DOUBLE NULL,
  `cardiovasc_death_rate` DOUBLE NULL,
  `diabetes_prevalence` DOUBLE NULL,
  `female_smokers` DOUBLE NULL,
  `male_smokers` DOUBLE NULL,
  `handwashing_facilities` DOUBLE NULL,
  `hospital_beds_per_thousand` DOUBLE NULL,
  `life_expectancy` DOUBLE NULL,
  `human_development_index` DOUBLE NULL,
  `excess_mortality_cumulative_absolute` DOUBLE NULL,
  `excess_mortality_cumulative` DOUBLE NULL,
  `excess_mortality` DOUBLE NULL,
  `excess_mortality_cumulative_per_million` DOUBLE NULL);
  
    -- Load data from csv file
LOAD DATA LOCAL INFILE "C:\\Users\\Richard\\Downloads\\CovidVaccinations.csv" INTO TABLE covidvaccinations
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(iso_code,continent,location,@date,new_tests,total_tests,total_tests_per_thousand,new_tests_per_thousand,new_tests_smoothed,new_tests_smoothed_per_thousand,positive_rate,tests_per_case,tests_units,total_vaccinations,people_vaccinated,people_fully_vaccinated,total_boosters,new_vaccinations,new_vaccinations_smoothed,total_vaccinations_per_hundred,people_vaccinated_per_hundred,people_fully_vaccinated_per_hundred,total_boosters_per_hundred,new_vaccinations_smoothed_per_million,new_people_vaccinated_smoothed,new_people_vaccinated_smoothed_per_hundred,stringency_index,population_density,median_age,aged_65_older,aged_70_older,gdp_per_capita,extreme_poverty,cardiovasc_death_rate,diabetes_prevalence,female_smokers,male_smokers,handwashing_facilities,hospital_beds_per_thousand,life_expectancy,human_development_index,excess_mortality_cumulative_absolute,excess_mortality_cumulative,excess_mortality,excess_mortality_cumulative_per_million)
SET date = DATE_FORMAT(STR_TO_DATE(@date,'%m/%d/%Y%'), '%Y-%m-%d');

-- Add new primary key column to table coviddeaths
ALTER TABLE coviddeaths
ADD ID int NOT NULL AUTO_INCREMENT primary key
FIRST;

-- Add new primary key column to table covidvaccinations
ALTER TABLE covidvaccinations
ADD ID int NOT NULL AUTO_INCREMENT primary key
FIRST;

-- Replace empty string with null values
UPDATE coviddeaths 
SET continent=NULL 
WHERE continent='';

-- Drop rows where incorrect location is provided (3660 wrong entries)
DELETE FROM coviddeaths
WHERE location IN ('Upper middle income','High income','Lower middle income','Low income');

-- GLOBAL COVID cases and deaths
SELECT 
	continent,
	SUM(new_cases) AS TotalCases,
    SUM(new_deaths) AS TotalDeaths
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC;

-- Total Death count by location
SELECT 
		location,
        MAX(total_deaths) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Global Death Rate
SELECT 	date, 
		SUM(new_cases) AS TotalNewCases, 
		SUM(new_deaths) AS TotalNewDeaths,
        ROUND(((SUM(new_deaths) / SUM(new_cases)) * 100),2) AS GlobalDeathRate
FROM coviddeaths
WHERE continent IS NOT NULL;

-- New cases and deaths by location
SELECT	location,
		date,
        new_cases,
        new_deaths
FROM coviddeaths
GROUP BY location
ORDER BY location,date;

-- Total cases vs Total deaths as percentage by date
SELECT 	id,
		location,
		date,
        total_cases,
        total_deaths,
        (total_deaths / total_cases) * 100 AS 'Death Rate'
FROM coviddeaths
ORDER BY location,date;

-- Total cases and deaths per population by date
SELECT	location,
		date,
        population,
        total_cases,
        (total_cases / population ) * 100 AS 'CasesPerPop',
        total_deaths,
        (total_deaths / population ) * 100 AS 'DeathsPerPop'
FROM coviddeaths
ORDER BY location,date;

-- Top 5 countries with highest infected percentage
SELECT 	location,
		population,
		MAX(total_cases) AS 'Highest Infection Count',
        MAX((total_cases /population)) * 100 AS PercentagePopulationInfected 
FROM coviddeaths
GROUP BY location,population
ORDER BY PercentagePopulationInfected DESC
LIMIT 5;

-- Countries with highest death count per population
SELECT 
		location,
        population,
        MAX(total_deaths) AS HighestDeathCount,
        ROUND(MAX((total_deaths/population)) * 100000) AS DeathPer100k
FROM coviddeaths
GROUP BY location
ORDER BY DeathPer100k DESC;

-- Vaccines Progress by date
SELECT 	cd.continent,
		cd.location,
        cd.date,
        cd.population,
        cv.new_vaccinations,
        SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location, cd.date)
        AS VaccinesProgress
FROM coviddeaths cd
JOIN covidvaccinations cv
	ON cd.ID = cv.ID
WHERE cd.continent IS NOT NULL;


-- USE temp table
DROP TABLE IF EXISTS PopulationVaccinated;
CREATE TEMPORARY TABLE IF NOT EXISTS PopulationVaccinated
(
continent VARCHAR(45),
location VARCHAR(45),
date DATE,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
);

INSERT INTO PopulationVaccinated (continent,location,date,population,new_vaccinations,PeopleVaccinated)
SELECT 	cd.continent,
		cd.location,
        cd.date,
        cd.population,
        cv.new_vaccinations,
        SUM(cv.new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location, cd.date)
        AS PeopleVaccinated
FROM coviddeaths cd
JOIN covidvaccinations cv
	ON cd.ID = cv.ID
WHERE cd.continent IS NOT NULL;

SELECT *, (PeopleVaccinated/population)*100
AS 'PeopleVaccinated %'
FROM PopulationVaccinated


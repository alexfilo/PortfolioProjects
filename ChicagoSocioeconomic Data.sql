---Explore Datasets

Select * 
From Chicago..ChicagoPublicSchools$

Select * 
From Chicago..ChicagoCrimeData$

Select * 
From Chicago..ChicagoCensusData$

-- Explore relevant factors in Census Data
Select HARDSHIP_INDEX, COMMUNITY_AREA_NAME, PER_CAPITA_INCOME, PERCENT_OF_HOUSING_CROWDED, PERCENT_AGED_25__WITHOUT_HIGH_SCHOOL_DIPLOMA
From Chicago..ChicagoCensusData$
Where HARDSHIP_INDEX is not null
order by HARDSHIP_INDEX Desc

--Look at key factors in Public School Dataset
Select COLLEGE_ENROLLMENT, SAFETY_SCORE, TEACHERS_SCORE, PARENT_ENGAGEMENT_SCORE, AVERAGE_STUDENT_ATTENDANCE
From Chicago..ChicagoPublicSchools$
order by COLLEGE_ENROLLMENT 

-- See which area is most crime prone
Select COMMUNITY_AREA_NUMBER, COUNT(COMMUNITY_AREA_NUMBER) as TOTAL_INSTANCES_OF_CRIME
From Chicago..ChicagoCrimeData$
Where YEAR Between 2010 and 2015
GROUP BY COMMUNITY_AREA_NUMBER
order by COUNT(COMMUNITY_AREA_NUMBER) DESC

--Checking school information in the community area with the highest harship index (Riverdale)

Select COLLEGE_ENROLLMENT, SAFETY_SCORE, TEACHERS_SCORE, PARENT_ENGAGEMENT_SCORE, AVERAGE_STUDENT_ATTENDANCE
From Chicago..ChicagoPublicSchools$
Where COMMUNITY_AREA_NAME LIKE 'Riverdale'
order by COLLEGE_ENROLLMENT

-- See what kinds of crimes were recorded at schools
Select Distinct(description)
From Chicago..ChicagoCrimeData$
Where location_description Like'School%'

-- Calculate average safety score for schools
SELECT AVG(cast(safety_score as int))
FROM Chicago..ChicagoPublicSchools$


-- Use sub-query to see communities with above average per capita income
Select COMMUNITY_AREA_NAME
FROM Chicago..ChicagoCensusData$
Where PER_CAPITA_INCOME > (Select AVG(PER_CAPITA_INCOME) FROM Chicago..ChicagoCensusData$)

-- use implict join to see crimes in Riverdale that took place at a residence or an apartment
Select *
From Chicago..ChicagoCrimeData$ crime
Join Chicago..ChicagoCensusData$ census
	on crime.COMMUNITY_AREA_NUMBER = census.COMMUNITY_AREA_NUMBER
Where census.COMMUNITY_AREA_NAME = 'Riverdale'
AND crime.LOCATION_DESCRIPTION IN ('Residence', 'Apartment')

--Calculate rolling number of arrests for each location

Select ID, Date, LOCATION_DESCRIPTION,
	Sum(cast(arrest as int)) Over (Partition by location_description order by location_description, date) as rolling_arrest_count_by_location
From Chicago..ChicagoCrimeData$

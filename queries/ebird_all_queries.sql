/* 
Feature name: Bird of the day
Feature location: Home page
Feature description: Returns a random bird species and description (common_name, scientific_name, species_description, species_img)
from the species table. This will be shown in the "Have you seen the ... today?" feature 
*/

SELECT species_code,
       common_name,
       scientific_name,
       species_description,
       species_img_link
FROM   species
WHERE  common_name IS NOT NULL
       AND scientific_name IS NOT NULL
       AND species_description IS NOT NULL
       AND species_img_link IS NOT NULL
ORDER  BY RAND()
LIMIT  1; 

/* 
Feature name: Heat map of bird observations by name, location, and date range
Feature location: Home page
Feature description: Returns bird sightings based upon inputs provided by users for name (2), 
location (3), date range(4) on the home range. If no inputs are given, all possible values for
that particular attribute are returned, or if no date range is provided, the date range is limited 
to the past 30 days. i.e., if the user inputs "Pennsylvania", 1/01/2023-1/04/2023, all bird sightings
in Pennsylvania for the date range would be returned. 
*/

/*
Example Query That Works: 
WITH 
	sightings_filtered AS (
	SELECT 
		location_id, 
		scientific_name,
		common_name,
		observation_count
	FROM
		observation
	JOIN species 
		ON observation.species_code = species.species_code
	WHERE CAST(observation_date AS DATE)
		BETWEEN '2023-01-01' AND '2023-03-05'
		AND common_name = "Eastern Screech-Owl"
		OR scientific_name = "Megascops asio"
), 
	locations_filtered AS (
	SELECT 
		location_id,
		latitude,
		longitude
	FROM 
		ebird_location E
	JOIN subnational2 S2
		ON E.subnational2_code = S2.subnational2_code
	JOIN subnational1 S1
		ON S2.subnational1_code = S1.subnational1_code
	WHERE S1.subnational1_name = "Kansas" 
		OR S2.subnational2_name = ""
)
SELECT latitude,
       longitude,
       scientific_name,
       common_name,
       Sum(observation_count) AS total_count
FROM sightings_filtered S
JOIN locations_filtered L
	ON S.location_id = L.location_id
GROUP BY 1,
         2,
         3,
         4;
*/

WITH 
	sightings_filtered AS (
	SELECT 
		location_id, 
		scientific_name,
		common_name,
		observation_count
	FROM
		observation
	JOIN species 
		ON observation.species_code = species.species_code
	WHERE CAST(observation_date AS DATE)
		BETWEEN '{start_date}' AND '{end_date}'
		AND common_name = '{common_name}'
		OR scientific_name = '{scientific_name}'
), 
	locations_filtered AS (
	SELECT 
		location_id,
		latitude,
		longitude
	FROM 
		ebird_location E
	JOIN subnational2 S2
		ON E.subnational2_code = S2.subnational2_code
	JOIN subnational1 S1
		ON S2.subnational1_code = S1.subnational1_code
	WHERE S1.subnational1_name = '{subnational1_name}'
		OR S2.subnational2_name = ""
)
SELECT latitude,
       longitude,
       scientific_name,
       common_name,
       Sum(observation_count) AS total_count
FROM sightings_filtered S
JOIN locations_filtered L
	ON S.location_id = L.location_id
GROUP BY 1,
	 2,
	 3,
	 4;

/*
Feature name: Top birds found by name, location, date range
Feature location: Home page 
Feature description: Based upon the observed bird sightings selected by the user, aggregate and return
bird sightings by bird name from highest to lowest count of birds
*/
-- to test, replace start_date with "2023-01-02" and end date with "2023-03-26"
-- replace name_input 1 with "Graylag Goose", and name_input 2 with "Anser anser"
-- replace location_input 1 with "New York" and location_input with ""

-- Example test:
--{start_date} = 2023-01-01
--{end_date} = 2023-01-30
--common_name = Long-eared Owl
--scientific_name = Asio otus
--S1.subnational1_name = Colorado
--S2.subnational2_name = Arapahoe

WITH sightings_filtered
     AS (SELECT location_id,
                scientific_name,
                common_name,
                observation_count
         FROM   observation
                JOIN species
                  ON observation.species_code = species.species_code
         WHERE  observation_date BETWEEN '{start_date}' AND '{end_date}'
                AND ( '{name_input}' = common_name
                       OR '{name_input}' = scientific_name )),
     locations_filtered
     AS (SELECT location_id,
                latitude,
                longitude
         FROM   ebird_location E
                JOIN subnational2 S2
                  ON E.subnational2_code = S2.subnational2_code
                JOIN subnational1 S1
                  ON S2.subnational1_code = S1.subnational1_code
         WHERE  ( '{location_input}' = S1.subnational1_name
                   OR '{location_input}' = S2.subnational2_name ))
SELECT scientific_name,
       common_name,
       Sum(observation_count) AS total_count
FROM   sightings_filtered S
       JOIN locations_filtered L
         ON S.location_id = L.location_id
GROUP  BY 1,
          2
ORDER  BY all_birds DESC;


/*
Feature name: Species info 
Feature location: Species info page
Feature description: For a particular bird species, returns the common_name, scientific_name, species_img_link, 
family_common_name, family_scientific_name, and species_description. 
*/

SELECT common_name,
       scientific_name,
       species_description,
       species_img_link,
       family.family_common_name,
       family.family_scientific_name
FROM   species
       JOIN family
        ON species.family_code = family.family_code
WHERE  species_code = '{page_species_code}' 
--NOTE: Use bkcchi for species code


/*
Feature name: Recent sightings
Feature location: Species info page 
Feature description: For the species shown on the species page, return the 5 most recent sightings with location
and user display name for the observation in the form of '5 were spotted by birdwatcher Harry at Kiesel Park'
*/

SELECT observation_count,
       ebird_user.first_name,
       location_name
FROM   observation
       JOIN ebird_location
         ON observation.location_id = ebird_location.location_id
       JOIN ebird_user
         ON observation.user_id = ebird_user.user_id
WHERE  species_code = '{page_species_code}' AND ebird_user.first_name IS NOT NULL
ORDER  BY observation_date DESC
LIMIT  5; 
--NOTE: Use bkcchi for species code


/*
Feature name: Family info 
Feature location: Family info page
Feature description: For a particular bird family, returns the family_common_name, family_scientific_name, 
family_description, and a randomly selected image of a bird species from that family.  
*/

--Replace {page_family_code} with sample family code trogon1 to see result

SELECT family.family_code,
       family_scientific_name,
       family_common_name,
       family_description,
       species_img_link
FROM   family
       JOIN species
         ON family.family_code = species.family_code
WHERE  family.family_code = '{page_family_code}'
ORDER  BY RAND ()
LIMIT  1 

/*
Feature name: Species within family
Feature location: Family info page
Feature description: For a particular bird family, returns all species with their common names in that family.
*/

--Replace {page_family_code} with sample family code trogon1 to see result

SELECT common_name,
       species_code
FROM   species
WHERE  family_code = '{page_family_code}'
ORDER  BY RAND(); 

/*
Feature name: Heat map of bird species
Feature location: Family info page
Feature description: For a particular bird family, returns bird sightings within a user input date range
on the heat map. If no date range is provided, returns sightings over the past 30 days. Each species is 
visualized using a different color on the heatmap 
*/
-- to try out try replacing where clause with:
-- WHERE  observation_date BETWEEN "2022-12-01" AND "2023-03-26"
       -- AND family_code = "haemat1"
SELECT latitude,
       longitude,
       scientific_name,
       common_name,
       SUM(observation_count) AS total_count
FROM   observation
       JOIN species
         ON observation.species_code = species.species_code
       JOIN ebird_location
         ON observation.location_id = ebird_location.location_id
WHERE  observation_date BETWEEN '{start_date}' AND '{end_date}'
       AND family_code = '{page_family_code}'
GROUP  BY 1,
          2,
          3,
          4 

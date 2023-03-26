/* 
Feature name: Bird of the day
Feature location: Home page
Feature description: Returns a random bird species (common_name, scientific_name, species_img)
from the species table. This will be shown in the "Have you seen the ... today?" feature (1) 
*/

SELECT common_name,
       scientific_name,
       species_img_link
FROM   species
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

CREATE OR replace VIEW heatmap
AS (
  WITH sightings_filtered
       AS (SELECT location_id,
                  scientific_name,
                  common_name,
                  observation_count
           FROM   observation
                  join species
                    ON observation.species_code = species.species_code
           WHERE  observation_date BETWEEN '{start_date}' AND '{end_date}'
                  AND ( '{name_input}' = common_name
                         OR '{name_input}' = scientific_name )),
       locations_filtered
       AS (SELECT location_id,
                  latitude,
                  longitude
           FROM   ebird_location E
                  join subnational2 S2
                    ON E.subnational2_code = S2.subnational2_code
                  join subnational1 S1
                    ON S2.subnational1_code = S1.subnational1_code
           WHERE  ( '{location_input}' = S1.subnational1_name
                     OR '{location_input}' = S2.subnational2_name ))
  SELECT latitude,
         longitude,
         scientific_name,
         common_name,
         SUM(observation_count) AS total_count
   FROM   sightings_filtered S
          join locations_filtered L
            ON S.location_id = L.location_id
   GROUP  BY 1,
             2,
             3,
             4) 

/*
Feature name: Top birds found by name, location, date range
Feature location: Home page 
Feature description: Based upon the observed bird sightings selected by the user, aggregate and return
bird sightings by bird name from highest to lowest count of birds
*/

SELECT scientific_name,
       common_name,
       SUM(total_count) AS all_birds
FROM   heatmap
GROUP  BY 1,
          2
ORDER  BY all_birds DESC; 

/* 
-- for the table that is returned in the feature above, we need to aggregate by bird name
and display the top birds on the page. Is this a view since it is used post the query? 
--


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


/*
Feature name: Recent sightings
Feature location: Species info page 
Feature description: For the species shown on the species page, return the 5 most recent sightings with location
and user display name for the observation in the form of '5 chickadees were spotted by birdwatcher Harry Katzen at Kiesel Park'
*/

SELECT observation_count,
       display_name,
       location_name
FROM   observation
       JOIN ebird_location
         ON observation.location_id = ebird_location.location_id
       JOIN user
         ON observation.user_id = user.user_id
WHERE  species_code = '{page_species_code}'
ORDER  BY observation_date DESC
LIMIT  5; 

/*
Feature name: Family info 
Feature location: Family info page
Feature description: For a particular bird family, returns the family_common_name, family_scientific_name, 
family_description, and a randomly selected image of a bird species from that family.  
*/

SELECT family_code,
       family_scientific_name,
       family_common_name,
       family_description,
       species_img_link
FROM   family
       JOIN species
         ON family.family_code = species.family_code
WHERE  family_code = '{page_family_code}'
ORDER  BY RAND ()
LIMIT  1 

/*
Feature name: Species within family
Feature location: Family info page
Feature description: For a particular bird family, returns all species with their common names in that family.
*/

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

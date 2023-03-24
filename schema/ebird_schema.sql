CREATE DATABASE IF NOT EXISTS ebird;
USE ebird;

CREATE TABLE IF NOT EXISTS family (
	family_code INT,
    family_scientific_name VARCHAR(256),
    family_common_name VARCHAR(256),
    family_description TEXT,
    PRIMARY KEY (family_code)
);

CREATE TABLE IF NOT EXISTS species (
	species_code INT,
    family_code INT,
    scientific_name VARCHAR(256),
    common_name VARCHAR(256),
    species_description TEXT,
    species_img_link VARCHAR(1024),
    extinct BOOLEAN,
    extinct_year YEAR,
    PRIMARY KEY (species_code),
    FOREIGN KEY (family_code) REFERENCES family(family_code)
);

CREATE TABLE IF NOT EXISTS ebird_user (
	user_id INT,
    first_name VARCHAR(64),
    last_name VARCHAR(64),
    display_name VARCHAR(128),
    PRIMARY KEY (user_id)
);

CREATE TABLE IF NOT EXISTS subnational1 (
	subnational1_code INT, 
    subnational1_name VARCHAR(256) NOT NULL,
    min_x DECIMAL(8,6),
    max_x DECIMAL(8,6),
    min_y DECIMAL(9,6),
    max_y DECIMAL(9,6),
    PRIMARY KEY (subnational1_code)
);

CREATE TABLE IF NOT EXISTS subnational2 (
	subnational2_code INT,
    subnational1_code INT,
    subnational2_name VARCHAR(256) NOT NULL,
    PRIMARY KEY (subnational2_code),
    FOREIGN KEY (subnational1_code) REFERENCES subnational1(subnational1_code)
);

CREATE TABLE IF NOT EXISTS ebird_location (
	location_id INT,
    subnational2_code INT,
    location_name VARCHAR(512),
    latitude DECIMAL(8,6),
    longitude DECIMAL(9,6),
    location_private BOOLEAN,
    PRIMARY KEY (location_id),
    FOREIGN KEY (subnational2_code) REFERENCES subnational2(subnational2_code)
);

CREATE TABLE IF NOT EXISTS observation (
	observation_id INT,
    species_code INT,
    user_id INT,
    location_id INT,
    observation_date DATE,
    observation_count SMALLINT,
	observation_valid BOOLEAN,
    observation_reviewed BOOLEAN,
	PRIMARY KEY (observation_id),
    FOREIGN KEY (species_code) REFERENCES species(species_code),
    FOREIGN KEY (user_id) REFERENCES ebird_user(user_id),
    FOREIGN KEY (location_id) REFERENCES ebird_location(location_id)
);
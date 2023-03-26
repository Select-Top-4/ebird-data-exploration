CREATE DATABASE IF NOT EXISTS ebird;
USE ebird;

CREATE TABLE IF NOT EXISTS family (
	family_code VARCHAR(16),
    family_scientific_name VARCHAR(256),
    family_common_name VARCHAR(256),
    family_description TEXT,
    PRIMARY KEY (family_code)
);

CREATE TABLE IF NOT EXISTS species (
	species_code VARCHAR(16),
    family_code VARCHAR(16),
    scientific_name VARCHAR(256),
    common_name VARCHAR(256),
    species_description TEXT,
    species_img_link TEXT,
    extinct BOOLEAN,
    extinct_year VARCHAR(4),
    PRIMARY KEY (species_code),
    FOREIGN KEY (family_code) REFERENCES family(family_code)
);

CREATE TABLE IF NOT EXISTS ebird_user (
	user_id VARCHAR(128),
    first_name VARCHAR(64),
    last_name VARCHAR(64),
    PRIMARY KEY (user_id)
);

CREATE TABLE IF NOT EXISTS subnational1 (
	subnational1_code VARCHAR(8), 
    subnational1_name VARCHAR(256) NOT NULL,
    min_x DECIMAL(16, 10),
    max_x DECIMAL(16, 10),
    min_y DECIMAL(16, 10),
    max_y DECIMAL(16, 10),
    PRIMARY KEY (subnational1_code)
);

CREATE TABLE IF NOT EXISTS subnational2 (
	subnational2_code VARCHAR(16),
    subnational1_code VARCHAR(8),
    subnational2_name VARCHAR(256) NOT NULL,
    PRIMARY KEY (subnational2_code),
    FOREIGN KEY (subnational1_code) REFERENCES subnational1(subnational1_code)
);

CREATE TABLE IF NOT EXISTS ebird_location (
	location_id VARCHAR(16),
    subnational2_code VARCHAR(16),
    location_name VARCHAR(512),
    latitude DECIMAL(16, 10),
    longitude DECIMAL(16, 10),
    location_private BOOLEAN,
    PRIMARY KEY (location_id),
    FOREIGN KEY (subnational2_code) REFERENCES subnational2(subnational2_code)
);

CREATE TABLE IF NOT EXISTS observation (
	observation_id VARCHAR(16),
    species_code VARCHAR(16),
    user_id VARCHAR(16),
    location_id VARCHAR(16),
    observation_date DATE,
    observation_count SMALLINT,
	observation_valid BOOLEAN,
    observation_reviewed BOOLEAN,
	PRIMARY KEY (observation_id),
    FOREIGN KEY (species_code) REFERENCES species(species_code),
    FOREIGN KEY (user_id) REFERENCES ebird_user(user_id),
    FOREIGN KEY (location_id) REFERENCES ebird_location(location_id)
);
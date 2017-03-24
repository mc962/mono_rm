--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner:
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner:
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;


CREATE TABLE riders (
  id INTEGER PRIMARY KEY,
  fname character varying(255) NOT NULL,
  lname character varying(255) NOT NULL
);

CREATE TABLE dragons (
  id INTEGER PRIMARY KEY,
  name character varying(255) NOT NULL,
  picture_url character varying(255) DEFAULT '',
  rider_id INTEGER NOT NULL


);

CREATE TABLE memories (
  id INTEGER PRIMARY KEY,
  content text NOT NULL,
  location character varying(255) NOT NULL,  
  dragon_id INTEGER NOT NULL

);

INSERT INTO riders (id, fname, lname) VALUES
(1,  'Bob',      'Builder'),
(2,  'Super',    'Man'),
(3,  'Eragon',   'Shadeslayer'),
(4,  'Oromis',   'Thrandurin'),
(5,  'Arya',     'Shadeslayer');


INSERT INTO dragons (id, name, picture_url, rider_id) VALUES
      (1,  'Ryuu',    '/public/ryuu-pic.jpg',  1),
      (2, 'Draco',    '/public/draco-pic.png',  1),
      (3, 'Saphira',  '/public/saphira-pic.jpg',  3),
      (4, 'Glaedr',   '/public/glaedr-pic.jpg',  4),
      (5, 'Firnen',   '/public/firnen-pic.jpg',  5);


INSERT INTO memories (id, content, location, dragon_id) VALUES
      (1, 'Made some fire', 'Dragon Town', 1),
      (2, 'Did some hunting', 'Dragon Land', 1),
      (3, 'Flew around the world', 'Dragon World', 1),
      (4, 'Ate some sheep', 'Mountain', 3),
      (5, 'Hoarded some gold', 'Cave', 2),
      (6, 'Talked to some hobbits', 'Also a cave', 2),
      (7, 'Escaped the Empire', 'Forest', 3),
      (8, 'Did some magic', 'Underground', 3),
      (9, 'Flew across the desert', 'A Hot Place', 3),
      (10, 'Taught some younglings', 'A Tree', 4),
      (11, 'Imparted some wisdom', 'A Moutaintop', 4),
      (12, 'Flew across the continent', 'Many spots', 4),
      (13, 'Fought with Draco', 'In the air', 5),
      (14, 'Sharpened my claws', 'On a Rock', 2),
      (15, 'Roared at some humans', 'In a city', 5);

ALTER TABLE dragons ADD FOREIGN KEY (rider_id) REFERENCES riders;
ALTER TABLE memories ADD FOREIGN KEY (dragon_id) REFERENCES dragons;



REVOKE ALL ON SCHEMA public FROM PUBLIC;

GRANT ALL ON SCHEMA public TO PUBLIC;

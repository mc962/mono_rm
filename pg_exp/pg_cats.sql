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

CREATE TABLE cats (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER

  -- FOREIGN KEY(owner_id) REFERENCES human(id)
);

CREATE TABLE humans (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  house_id INTEGER

  -- FOREIGN KEY(house_id) REFERENCES human(id)
);

CREATE TABLE houses (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

INSERT INTO
  houses (id, address)
VALUES
  (1, '26th and Guerrero'),
  (2, 'Dolores and Market');

INSERT INTO
  humans (id, fname, lname, house_id)
VALUES
  (1, 'Devon', 'Watts', 1),
  (2, 'Matt', 'Rubens', 1),
  (3, 'Ned', 'Ruggeri', 2),
  (4, 'Catless', 'Human', NULL);

INSERT INTO
  cats (id, name, owner_id)
VALUES
  (1, 'Breakfast', 1),
  (2, 'Earl', 2),
  (3, 'Haskell', 3),
  (4, 'Markov', 3),
  (5, 'Stray Cat', NULL);

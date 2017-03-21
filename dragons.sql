

CREATE TABLE riders (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE dragons (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  rider_id INTEGER,

  FOREIGN KEY(rider_id) REFERENCES rider(id)
);

CREATE TABLE memories (
  id INTEGER PRIMARY KEY,
  memory VARCHAR(255) NOT NULL,
  location VARCHAR(255) NOT NULL,
  dragon_id INTEGER,

  FOREIGN KEY(dragon_id) REFERENCES dragon(id)
);

INSERT INTO
  riders (id, fname, lname)
VALUES
  (1, "Bob", "Builder"), (2, "Super", "Man"), (3, 'Eragon', 'Shadeslayer');

INSERT INTO
  dragons (id, name, rider_id)
VALUES
  (1, "Ryuu", 1),
  (2, "Draco", 2),
  (3, "Saphira", 3),
  (4, "Glaedr", 3),
  (5, "Drago", 1);

INSERT INTO
  memories (id, memory, location, dragon_id)
VALUES
  (1, "Made some fire", "Dragon Town", 1),
  (2, "Did some hunting", "Dragon Land", 1),
  (3, "Flew around the world", "Dragon World", 1),
  (4, "Ate some sheep", "Mountain", 3),
  (5, "Hoarded some gold", "Cave", 2),
  (6, "Talked to some hobbits", "Also a cave", 2),
  (7, "Escaped the Empire", "Forest", 3),
  (8, "Did some magic", "Underground", 3),
  (9, "Flew across the desert", "A Hot Place", 3),
  (10, "Taught some younglings", "A Tree", 4),
  (11, "Imparted some wisdom", "A Moutaintop", 4),
  (12, "Flew across the continent", "Many spots", 4),
  (13, "Fought with Draco", "In the air", 5),
  (14, "Sharpened my claws", "On a Rock", 2),
  (15, "Roared at some humans", "In a city", 5);

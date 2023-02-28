/*Animals whose name ends in "mon"*/
SELECT * FROM animals WHERE name LIKE '%mon';

/*List the name of all animals born between 2016 and 2019.*/
SELECT name FROM animals WHERE date_of_birth BETWEEN '2016-01-01' AND '2019-12-31';

/*List the name of all animals that are neutered and have less than 3 escape attempts.*/
SELECT name FROM animals WHERE neutered = true AND escape_attempts <= 3;

/*List the date of birth of all animals named either "Agumon" or "Pikachu".*/
SELECT date_of_birth FROM animals WHERE name='Agumon' OR name='Pikachu';

/*List name and escape attempts of animals that weigh more than 10.5kg*/
SELECT name, date_of_birth FROM animals WHERE weight_kg >10.5;

/*All animals that are neutered.*/
SELECT * FROM animals WHERE neutered = true;

/*All animals not named Gabumon.*/
SELECT * FROM animals WHERE name != 'Gabumon';

/*All animals with a weight between 10.4kg and 17.3kg (including the animals with the weights that equals precisely 10.4kg or 17.3kg)*/
SELECT * FROM animals WHERE weight_kg >= 10.4 AND weight_kg <= 17.3;

/*Update species to unspecified for all rows and Rollback*/
BEGIN TRANSACTION;
UPDATE animals 
SET species  = 'unspecified';
SELECT * FROM animals;
ROLLBACK;

/*Setting the species column to digimon for all animals that have a name ending in mon.  */
BEGIN TRANSACTION;
UPDATE animals
SET species = 'digimon'
WHERE name LIKE '%mon';
SELECT * FROM animals;

-- setting the species column to pokemon for all animals that don't have species already set
UPDATE animals
SET species = 'pokemon'
WHERE species IS NULL;
SELECT * FROM animals;
/*Commit the transaction*/
COMMIT;

/*Delete all animals */
BEGIN TRANSACTION;
DELETE FROM animals;
SELECT * FROM animals;
/*Rollback the transaction*/
ROLLBACK;

/*Display all elements of the animals table*/
SELECT * FROM animals;

/*Delete all animals born after Jan 1st, 2022*/
BEGIN TRANSACTION;
DELETE FROM animals
WHERE date_of_birth > '2022-01-01';
SAVEPOINT savepoint1;
UPDATE  animals
SET weight_kg = -1 * weight_kg ;
ROLLBACK TO savepoint1;
UPDATE animals
SET weight_kg = -1 * weight_kg
WHERE weight_kg < 0;
COMMIT;

/*How many animals are there?*/
SELECT COUNT(*) FROM animals;

/*How many animals have never tried to escape?*/
SELECT COUNT(escape_attempts) FROM animals WHERE escape_attempts =0;

/*What is the average weight of animals?*/
SELECT AVG(weight_kg) FROM animals;

/*Who escapes the most, neutered or not neutered animals?*/
SELECT neutered, COUNT(neutered) FROM animals GROUP BY neutered;

/*What is the minimum and maximum weight of each type of animal?*/
SELECT species, MIN(weight_kg), MAX(weight_kg) FROM animals GROUP BY species;

/*What is the average number of escape attempts per animal type of those born between 1990 and 2000?*/
SELECT date_of_birth, AVG(escape_attempts) FROM animals WHERE date_of_birth BETWEEN '1990-01-01' AND '2000-12-31' GROUP BY date_of_birth;

/* Queries using JOINS */

/*What animals belong to Melody Pond?*/
SELECT a.name ,o.full_name
FROM animals a
INNER JOIN owners o ON a.owner_id = o.id
WHERE o.full_name = 'Melody Pond';

/*List of all animals that are pokemon (their type is Pokemon).*/
SELECT a.name 
FROM animals a
INNER JOIN species s ON s.id = a.species_id
WHERE s.name = 'Pokemon';

/*List all owners and their animals, remember to include those that don't own any animal.*/

SELECT a.name ,o.full_name
FROM animals a RIGHT JOIN owners o ON a.owner_id = o.id;

/*How many animals are there per species?*/
SELECT s.name, COUNT(a.species_id)
FROM animals a
INNER JOIN species s ON s.id = a.species_id
GROUP BY s.name;

/*List all Digimon owned by Jennifer Orwell.*/
SELECT a.name, o.full_name
FROM animals a
INNER JOIN owners o ON o.id = a.owner_id
INNER JOIN species s ON s.id = a.species_id
WHERE o.full_name = 'Jennifer Orwell' AND s.name = 'Digimon';


SELECT a.name, o.full_name
FROM animals a
INNER JOIN owners o ON o.id = a.owner_id
WHERE o.full_name = 'Dean Winchester' AND a.escape_attempts = 0;

/*Who owns the most animals?*/
SELECT o.full_name, COUNT(owner_id)
FROM animals a
INNER JOIN owners o ON o.id = a.owner_id
GROUP BY o.full_name
ORDER BY COUNT(owner_id) DESC
LIMIT 1;

/*Who was the last animal seen by William Tatcher?*/
SELECT animals.name, vets.name AS "vets name",
date_of_visit  FROM visits
LEFT JOIN vets
ON vets.id = visits.vet_id
LEFT JOIN animals
ON animals.id = visits.animal_id
WHERE vets.name = 'William Tatcher'
ORDER BY date_of_visit DESC
LIMIT 1;

/*How many different animals did Stephanie Mendez see?*/
SELECT COUNT(DISTINCT a ) AS "number of animals" FROM animals a
INNER JOIN visits vi
ON a.id = vi.animal_id
INNER JOIN vets ve
ON ve.id = vi.vet_id
WHERE ve.name = 'Stephanie Mendez';

/*List all vets and their specialties, including vets with no specialties.*/
SELECT * FROM vets
LEFT JOIN specializations
ON vets.id = specializations.vet_id
LEFT JOIN species
ON species.id = specializations.species_id;

/*List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.*/
SELECT animals.name ,
visits.date_of_visit FROM animals
INNER JOIN visits
ON animals.id = visits.animal_id
INNER JOIN vets
ON vets.id = visits.vet_id
WHERE vets.name = 'Stephanie Mendez' AND visits.date_of_visit BETWEEN '2020-04-01' AND '2020-08-30';

/*What animal has the most visits to vets?*/
SELECT animals.name AS "Animals name",
COUNT(*) AS "number of visits" FROM animals
INNER JOIN visits
ON animals.id = visits.animal_id
GROUP BY animals.name
ORDER BY COUNT(*) DESC
LIMIT 1;

/*Who was Maisy Smith's first visit?*/
SELECT animals.name AS "Animals name" FROM visits
INNER JOIN animals
ON animals.id = visits.animal_id
LEFT JOIN vets
ON vets.id = visits.vet_id
WHERE vets.name = 'Maisy Smith'
ORDER BY visits.date_of_visit ASC
LIMIT 1;

/*Details for most recent visit: animal information, vet information, and date of visit.*/
SELECT vets.name AS "vets name",
animals.name AS "Animals name",
visits.date_of_visit AS "date of visit" FROM visits
LEFT JOIN vets
ON vets.id = visits.vet_id
LEFT JOIN animals
ON animals.id = visits.animal_id
ORDER BY visits.date_of_visit DESC
LIMIT 1;

/*How many visits were with a vet that did not specialize in that animal's species?*/
SELECT COUNT(*) AS "number of visits" FROM vets
INNER JOIN visits
ON vets.id = visits.vet_id
LEFT JOIN specializations
ON vets.id = specializations.vet_id
LEFT JOIN species
ON specializations.species_id = species.id
WHERE species IS NULL;

/*What specialty should Maisy Smith consider getting? Look for the species she gets the most.*/
SELECT species.name AS "species name",
COUNT(*) AS "number of visits" FROM vets
INNER JOIN visits
ON vets.id = visits.vet_id
INNER JOIN animals
ON animals.id = visits.animal_id
INNER JOIN species
ON animals.species_id = species.id
WHERE vets.name = 'Maisy Smith'
GROUP BY species.name
ORDER BY COUNT(*) DESC
LIMIT 1;
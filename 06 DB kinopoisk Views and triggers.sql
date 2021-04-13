USE kinopoisk;

-- Новинки за последний год 
DROP VIEW IF EXISTS view_top_new_films;

CREATE VIEW view_top_new_films AS 
  (SELECT f.id, f.original_name, GROUP_CONCAT(g.name) as genres,f.premiere_world FROM films_genre AS fg 
		JOIN films AS f ON (f.id = fg.film_id)
		JOIN genre AS g ON (g.id = fg.genre_id)
	WHERE TO_DAYS(NOW()) - TO_DAYS(f.premiere_world) <= 365	
	GROUP BY f.id
	ORDER BY f.premiere_world DESC
   );
  
SELECT * FROM view_top_new_films;

  
-- Toп мультфильмов для детей
DROP VIEW IF EXISTS view_animation_for_children;

CREATE VIEW view_animation_for_children AS 
  (SELECT f.id, f.original_name, GROUP_CONCAT(DISTINCT g.name) AS genres, f.premiere_world, 
	   (SUM(r.rating)/COUNT(r.user_id)) as total_rating, SUM(r.rating), COUNT(r.user_id) 
		FROM films_genre AS fg
				JOIN films AS f ON (f.id = fg.film_id)
				JOIN genre AS g ON (g.id = fg.genre_id && g.name='Детский')
				JOIN ratings AS r ON (r.film_id = f.id)
		GROUP by f.id
		ORDER BY total_rating DESC
   );

SELECT * FROM view_animation_for_children;


-- Триггеры

#1. Добавляем поле в фильмы
ALTER TABLE kinopoisk.films ADD rating_users FLOAT DEFAULT 0 NOT NULL COMMENT 'Рейтинг фильма, обновляется через триггер';

#2. Добавляем триггер на таблицу с рейтингами 

DROP TRIGGER IF EXISTS kinopoisk.trg_ratings_insert;
DROP TRIGGER IF EXISTS kinopoisk.trg_ratings_update;
DROP TRIGGER IF EXISTS kinopoisk.trg_ratings_delete;


DELIMITER //

CREATE TRIGGER `trg_ratings_insert` AFTER INSERT ON `ratings` FOR EACH ROW BEGIN
 UPDATE films SET rating_users=(
 		SELECT SUM(ratings.rating)/COUNT(ratings.user_id) FROM ratings WHERE film_id=NEW.film_id
 	) 
 WHERE films.id=NEW.film_id;
END//

DELIMITER ;


DELIMITER //

CREATE TRIGGER `trg_ratings_update` AFTER UPDATE ON `ratings` FOR EACH ROW BEGIN
 UPDATE films SET rating_users=(
 		SELECT SUM(ratings.rating)/COUNT(ratings.user_id) FROM ratings WHERE film_id=NEW.film_id
 	) 
 WHERE films.id=NEW.film_id;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER `trg_ratings_delete` AFTER DELETE ON `ratings` FOR EACH ROW BEGIN
 UPDATE films SET rating_users=(
 		SELECT SUM(ratings.rating)/COUNT(ratings.user_id) FROM ratings WHERE film_id=OLD.film_id
 	) 
 WHERE films.id=OLD.film_id;
END//

DELIMITER ;


#3. Проверяем.

SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO ratings (id, film_id, user_id, rating) VALUES (101,99,12,5);

SET FOREIGN_KEY_CHECKS = 1;

SELECT rating_users FROM films WHERE id=99;

UPDATE ratings SET rating=8 WHERE id=101;

SELECT rating_users FROM films WHERE id=99;

DELETE FROM ratings WHERE id=101;

SELECT rating_users FROM films WHERE id=99;


use kinopoisk;

-- ФУНКЦИЯ 

#Получает ID фильмов заданного жанра, отсортированных по уровню положительных отзывов и дате выхода, сначала старые
DROP FUNCTION IF EXISTS top_films_viewpoint_user;

DELIMITER //

CREATE FUNCTION top_films_viewpoint_user (count_top INT, genre_name VARCHAR(255))
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN	
	RETURN (
		SELECT GROUP_CONCAT(id) FROM (
			SELECT f.id,f.premiere_world,SUM(IF(rv.rhesus="+",1,IF(rv.rhesus="-",-1,0))) as user_raitings 
				FROM films AS f
				JOIN reviews AS rv ON (f.id=rv.film_id)
				JOIN films_genre AS fg ON (f.id=fg.film_id)
				JOIN genre AS g ON (fg.genre_id=g.id && g.name LIKE genre_name)
			GROUP BY id
			ORDER BY user_raitings DESC, premiere_world
			LIMIT count_top
		) as tmp)
	;
END//

DELIMITER ;

#Проверяем 
SELECT top_films_viewpoint_user(5,'Боевик');

SELECT top_films_viewpoint_user(5,'%Мульт%');

SELECT * FROM films WHERE id IN (top_films_viewpoint_user(5,'Боевик'));

-- ПРОЦЕДУРА 

# Посчитаем количество малобюджетных и высокобюджетных фильмов

DROP PROCEDURE IF EXISTS films_budgets_counts;

DELIMITER //

CREATE PROCEDURE films_budgets_counts (INOUT number_films INT, IN film_budget INT, IN small_or_high CHAR(1))
BEGIN
CASE small_or_high 
WHEN 's' THEN
	SELECT COUNT(id) INTO number_films FROM films WHERE budget<=film_budget;		
WHEN 'h' THEN  
	SELECT COUNT(id) INTO number_films FROM films WHERE budget>=film_budget;		
ELSE 
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Last parametr need set 's' or 'h'";
END CASE;
END//

DELIMITER ;

# Кол-во фильмов с бюджетом меньше 5М
CALL films_budgets_counts(@my_count,5000000,'s');
SELECT @my_count;

# Кол-во фильмов с бюджетом больше 60М
CALL films_budgets_counts(@my_count,60000000,'h');
SELECT @my_count;

#Ошибка 
CALL films_budgets_counts(@my_count,60000000,'r');


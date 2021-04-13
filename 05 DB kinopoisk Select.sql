use kinopoisk;

-- Фильмы с жанрами и сортировкой по бюджету.
SELECT f.id, f.original_name, g.name, f.budget FROM films_genre AS fg
	JOIN films AS f ON (f.id = fg.film_id)
	JOIN genre AS g ON (g.id = fg.genre_id)
GROUP BY f.id
ORDER BY f.budget DESC
;

-- Фильмы cо средним рейтингом с релизом во втором десятилетии 21 века.
SELECT r.film_id, f.original_name, (SUM(rating)/COUNT(user_id)) AS medium_rating 
FROM ratings AS r
	JOIN films AS f ON (f.id = r.film_id)
	JOIN films_genre AS fg ON (fg.film_id = f.id)
	JOIN genre AS g ON (g.id = fg.genre_id && g.name="Триллер")
WHERE f.`release` LIKE '201%'
GROUP BY film_id
ORDER BY medium_rating DESC
;

-- GROUP_CONCAT объединяет все ненулевые значения из группы и возвращает их в виде строки с разделителями-запятыми.
-- в сочетании с оператором GROUP BY она позволяет поместить сгруппированные данные в одну строку

-- выводим актеров с сортировкой по дате рождения, которые играли главные роли, кого они играли в фильмах и во скольких, 
-- выпущенных в период с 2007 по 2017 годы, считаем сколько ролей у них было в фильме.
SELECT CONCAT(p.first_name," ",p.last_name) AS actor, p.birthday, 
       COUNT(DISTINCT fp.film_id) AS count_films, 
       GROUP_CONCAT(DISTINCT r.name), wp.title, count(wp.title) 
FROM films_people AS fp 
	JOIN people AS p ON (p.id = fp.people_id)
	JOIN roles AS r ON (r.id = fp.role_id AND r.name="Актер")
	JOIN people_who_plays AS pwp ON (pwp.films_people_id = fp.id AND pwp.type_role='main')
	JOIN who_plays AS wp ON (pwp.who_plays_id = wp.id)
	JOIN films ON (films.id = fp.film_id AND films.`release`>='2007-01-01' and films.`release`<='2017-12-31')
GROUP BY fp.people_id
ORDER BY p.birthday DESC
;


DROP DATABASE IF EXISTS kinopoisk;  
CREATE DATABASE kinopoisk;
USE kinopoisk;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	firstname VARCHAR(100) NOT NULL,
	lastname VARCHAR(100) NOT NULL,
	gender CHAR(1),
	birthday DATE NOT NULL,
	email VARCHAR(120) UNIQUE, -- исключаем одинаковые адреса почты за пользователем
	hometown VARCHAR(100),
	created_at DATETIME DEFAULT NOW() -- дата создания пользователя
) COMMENT 'Пользователи';

DROP TABLE IF EXISTS films;
CREATE TABLE films (
	id SERIAL PRIMARY KEY,
	original_name VARCHAR(255) NOT NULL,
	rus_name VARCHAR(255) NOT NULL,
	`release` DATE NOT NULL,
	slogan VARCHAR(255) DEFAULT NULL,
	description VARCHAR(1024) DEFAULT NULL,
	premiere_world DATE NOT NULL,
	premiere_russia DATE,
	budget INT(15) NOT NULL DEFAULT 0,
	fees_world INT(15) NOT NULL DEFAULT 0,
	fees_russia INT(15) NOT NULL DEFAULT 0,
	length_minutes INT(10) NOT NULL,
	rating_old INT(2) DEFAULT 0
) COMMENT 'Фильмы';


DROP TABLE IF EXISTS people;
CREATE TABLE people (
	id SERIAL PRIMARY KEY,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
	gender CHAR(1),
	birthday DATE NOT NULL,
	height INT(3) UNSIGNED NOT NULL
) COMMENT 'Люди, участвующие в фильмах';


DROP TABLE IF EXISTS films_people;
CREATE TABLE films_people (
	id SERIAL PRIMARY KEY,
	film_id BIGINT UNSIGNED NOT NULL,
	people_id BIGINT UNSIGNED NOT NULL,
	role_id BIGINT UNSIGNED NOT NULL
) COMMENT 'Связь фильмов и людей, участвующих в них';


DROP TABLE IF EXISTS who_plays;
CREATE TABLE who_plays (
	id SERIAL PRIMARY KEY,
	title VARCHAR(255) NOT NULL
) COMMENT 'Кого играют';


DROP TABLE IF EXISTS people_who_plays;
CREATE TABLE people_who_plays (
	films_people_id BIGINT UNSIGNED NOT NULL,
	who_plays_id BIGINT UNSIGNED NOT NULL,
	type_role ENUM('main','episode','other') NOT NULL DEFAULT 'other'
) COMMENT 'Кого играет актер в фильме';


DROP TABLE IF EXISTS roles;
CREATE TABLE roles (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL
) COMMENT 'Роли людей';


DROP TABLE IF EXISTS genre;
CREATE TABLE genre (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL
) COMMENT 'Жанры кино';

								
DROP TABLE IF EXISTS films_genre;
CREATE TABLE films_genre (
	film_id BIGINT UNSIGNED NOT NULL,
	genre_id BIGINT UNSIGNED NOT NULL
) COMMENT 'Связь фильмов и жанров';


DROP TABLE IF EXISTS media;
CREATE TABLE media (
	id SERIAL PRIMARY KEY,
	film_id BIGINT UNSIGNED NOT NULL,
	media_type ENUM('poster','trailer','picture','other') NOT NULL DEFAULT 'other',
	name VARCHAR(255) NOT NULL,
	file_name VARCHAR(255),
	title TEXT DEFAULT NULL
) COMMENT 'Постеры, трейлеры и кадры к фильму';


DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (
	id SERIAL PRIMARY KEY,
	film_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL, 
	rating INT(2) UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT 'Рейтинги пользователей к фильмам';


DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews (
	id SERIAL PRIMARY KEY,
	film_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	label VARCHAR(255) NOT NULL,
	description VARCHAR(512) NOT NULL,
	full_text_file VARCHAR(255) NOT NULL,
	rhesus ENUM('-','0','+') NOT NULL DEFAULT '0',
	created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT 'Обзоры пользователей';


# Укажем жанры кино

INSERT INTO genre (name) VALUES ('Аниме'),('Биография'),('Боевик'),('Вестерн'),('Военный'),('Детектив'),('Детский'),
								('Документальный'),('Драма'),('Исторический'),('Комедия'),('Концерт'),('Короткометражка'),
								('Криминальный'),('Мелодрама'),('Музыкальный'),('Мультфильм'),('Мюзикл'),('Приключения'),
								('Реальное ТВ'),('Семейный'),('Спортивные'),('Ток-шоу'),('Триллер'),('Ужасы'),('Фантастика'),
								('Фильмы-нуар'),('Фэнтези'),('Сериал');


INSERT INTO roles (name) VALUES ('Актер'), ('Режиссер'), ('Сценарист'), ('Композитор'), ('Монтажер'), ('Продюсер'),('Оператор'),('Художник'),('Актер дубляжа');

# Создадим  внешние ключи

ALTER TABLE films_genre
	ADD CONSTRAINT fk_films_genre_film_id
		FOREIGN KEY (film_id) REFERENCES films(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT fk_films_genre_genre_id
		FOREIGN KEY (genre_id) REFERENCES genre(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE films_people
	ADD CONSTRAINT fk_films_people_film_id
		FOREIGN KEY (film_id) REFERENCES films(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT fk_films_people_people_id
		FOREIGN KEY (people_id) REFERENCES people(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT fk_films_people_role_id
		FOREIGN KEY (role_id) REFERENCES roles(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT;

	
ALTER TABLE media
	ADD CONSTRAINT fk_media_film_id
		FOREIGN KEY (film_id) REFERENCES films(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT;
	
ALTER TABLE ratings
	ADD CONSTRAINT fk_ratings_film_id
		FOREIGN KEY (film_id) REFERENCES films(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT fk_ratings_user_id
		FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE reviews
	ADD CONSTRAINT fk_reviews_film_id
		FOREIGN KEY (film_id) REFERENCES films(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT fk_reviews_user_id
		FOREIGN KEY (user_id) REFERENCES users(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE people_who_plays
	ADD CONSTRAINT fk_people_who_plays_films_people_id
		FOREIGN KEY (films_people_id) REFERENCES films_people(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT,
	ADD CONSTRAINT fk_people_who_plays_who_plays_id
		FOREIGN KEY (who_plays_id) REFERENCES who_plays(id)
		ON DELETE RESTRICT ON UPDATE RESTRICT;

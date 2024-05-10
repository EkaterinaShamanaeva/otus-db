-- ЗАПОЛНЕНИЕ ТАБЛИЦ
-- Добавление производителей самолетов (с выводом информации о добавленных строках)
INSERT INTO aircraft.aircraft_manufacturers (manufacturer)
VALUES ('Airbus'), ('Boeing'), ('Cessna Aircraft')
RETURNING *;

-- Добавление семейства самолетов А320
INSERT INTO aircraft.aircraft_families (family, manufacturer_id)
VALUES ('Airbus A320', (SELECT id FROM aircraft.aircraft_manufacturers WHERE manufacturer = 'Airbus'));

-- Добавление типов самолетов
INSERT INTO aircraft.aircraft_types (type, code, family_id)
VALUES
    ('Airbus A318', 'A318', (SELECT id FROM aircraft.aircraft_families WHERE family = 'Airbus A320')),
    ('Airbus A319', 'A319', (SELECT id FROM aircraft.aircraft_families WHERE family = 'Airbus A320')),
    ('Airbus A320', 'A320', (SELECT id FROM aircraft.aircraft_families WHERE family = 'Airbus A320')),
    ('Airbus A321', 'A321', (SELECT id FROM aircraft.aircraft_families WHERE family = 'Airbus A320'));

-- Добавление авиакомпаний
INSERT INTO aircraft.aircraft_owners (owner)
VALUES ('Utair'), ('SCAT'), ('Белавиа');

-- Добавление самолетов
INSERT INTO aircraft.aircraft (type_id, reg_num, owner_id)
VALUES
    ((SELECT id FROM aircraft.aircraft_types WHERE type = 'Airbus A320'), 'RA-786456', (SELECT id FROM aircraft.aircraft_owners WHERE owner = 'Utair')),
    ((SELECT id FROM aircraft.aircraft_types WHERE type = 'Airbus A320'), 'RA-987167', (SELECT id FROM aircraft.aircraft_owners WHERE owner = 'Utair')),
    ((SELECT id FROM aircraft.aircraft_types WHERE type = 'Airbus A320'), 'RA-123765', (SELECT id FROM aircraft.aircraft_owners WHERE owner = 'Utair'));
    ((SELECT id FROM aircraft.aircraft_types WHERE type = 'Airbus A320'), 'RA-100000', NULL);

-- Добавление полетов
INSERT INTO aircraft.flights (code, dep, arr, owner_id)
VALUES
    ('UT123', 'SVO', 'LED', (SELECT id FROM aircraft.aircraft_owners WHERE owner = 'Utair')),
    ('UT456', 'LED', 'KZN', (SELECT id FROM aircraft.aircraft_owners WHERE owner = 'Utair')),
    ('UT789', 'KZN', 'DME', (SELECT id FROM aircraft.aircraft_owners WHERE owner = 'Utair'));

INSERT INTO aircraft.flights_history (ac_id, flt_date, flt_id, atd, tdown, acms_path, qar_path)
VALUES
    ((SELECT id FROM aircraft.aircraft WHERE reg_num = 'RA-786456'), '2024-04-01', (SELECT id FROM aircraft.flights WHERE code = 'UT123'), '2024-04-01 08:00:00', '2024-04-01 10:00:00', '/path/to/acms1', '/path/to/qar1'),
    ((SELECT id FROM aircraft.aircraft WHERE reg_num = 'RA-786456'), '2024-04-02', (SELECT id FROM aircraft.flights WHERE code = 'UT456'), '2024-04-02 09:00:00', '2024-04-02 11:00:00', '/path/to/acms2', '/path/to/qar2'),
    ((SELECT id FROM aircraft.aircraft WHERE reg_num = 'RA-786456'), '2024-04-03', (SELECT id FROM aircraft.flights WHERE code = 'UT789'), '2024-04-03 10:00:00', '2024-04-03 12:00:00', '/path/to/acms3', '/path/to/qar3');

-- ЗАПРОС С РЕГУЛЯРНЫМ ВЫРАЖЕНИЕМ
-- Этот запрос найдет все записи в таблице aircraft_owners, где название авиакомпании начинается с буквы "S"
SELECT * FROM aircraft.aircraft_owners
WHERE owner ~ '^S';

-- ЗАПРОС С ИСПОЛЬЗОВАНИЕМ LEFT JOIN и INNER JOIN
-- Первый запрос вернет 4 записи, поле owner последней записи будет NULL.
-- Второй запрос вернет 3 записи (все, кроме последней), так как запрос вернет только те записи из таблицы aircraft,
-- для которых есть соответствующие записи в таблице aircraft_owners (т.е. записи с совпадающим owner_id).
-- Если в таблице aircraft_owners нет соответствующей записи для владельца в таблице aircraft, эти самолеты не будут возвращены.
SELECT ac.reg_num, ac_own.owner
FROM aircraft.aircraft as ac
LEFT JOIN aircraft.aircraft_owners as ac_own ON ac.owner_id = ac_own.id;

SELECT ac.reg_num, ac_own.owner
FROM aircraft.aircraft as ac
INNER JOIN aircraft.aircraft_owners as ac_own ON ac.owner_id = ac_own.id;

-- ЗАПРОС НА ОБНОВЛЕНИЕ
-- Запрос обновит путь к ACMS репортам самолета с регистационным номером 'RA-786456' (например, если изменилась директория в хранилище)
UPDATE aircraft.flights_history
SET acms_path = REPLACE(acms_path, 'path', 'pathNEW')
FROM aircraft.aircraft
WHERE aircraft.flights_history.ac_id = aircraft.aircraft.id
AND aircraft.aircraft.reg_num = 'RA-786456';

-- ЗАПРОС НА УДАЛЕНИЕ
-- Запрос удалит все записи о полетах самолета с регистрационным номером 'RA-786456'
DELETE FROM aircraft.flights_history
USING aircraft.aircraft
WHERE aircraft.flights_history.ac_id = aircraft.aircraft.id
AND aircraft.aircraft.reg_num = 'RA-786456';

-- COPY
-- Используется для загрузки или выгрузки данных между файлами и таблицами PostgreSQL
-- Пример загрузки данных через PgAdmin - copy.PNG

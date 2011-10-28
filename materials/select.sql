-- Нам известен язык пользователя
{LANGUAGE_ID}

-- Выборка идентификаторов категории, ограничивающей области и атрибута объектов по идентификатору игры {GAME_ID}
-- Ещё нужно будет проверить, что имеется игра на языке пользователя! (смотреть таблицу games_languages)
SELECT `category_id`,
	   `object_id`,
	   `field_id`
FROM games
WHERE `id` = {GAME_ID}; -> {CATEGORY_ID}, {OBJECT_ID}, {FIELD_ID}

-- Выборка всех объектов, соответствующих категории
SELECT `object_id` FROM objects_categories WHERE `category_id` = {CATEGORY_ID};

-- Выборка координат (lat и lng) и значений атрибута объектов
SELECT o.lat, o.lng, of.value
FROM objects o
INNER JOIN objects_fields of ON (of.object_id = o.id AND of.field_id = {FIELD_ID} AND of.language_id = {LANGUAGE_ID})
WHERE o.is_approved = 1;
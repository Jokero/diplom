SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `WorldMap` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `WorldMap` ;

-- -----------------------------------------------------
-- Table `WorldMap`.`languages`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`languages` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Идентификатор' ,
  `language` CHAR(2) CHARACTER SET 'utf8' COLLATE 'utf8_general_ci' NOT NULL COMMENT '2-хбуквенное обозначение (ru, en, ge, fr, sp, it)' ,
  PRIMARY KEY (`id`) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`users`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Идентификатор' ,
  `name` VARCHAR(30) CHARACTER SET 'utf8' COLLATE 'utf8_general_ci' NOT NULL COMMENT 'Имя пользователя' ,
  `surname` VARCHAR(30) CHARACTER SET 'utf8' COLLATE 'utf8_general_ci' NOT NULL COMMENT 'Фамилия пользователя' ,
  `email` VARCHAR(40) CHARACTER SET 'utf8' COLLATE 'utf8_general_ci' NOT NULL COMMENT 'Адрес электронной почты' ,
  `password` CHAR(64) CHARACTER SET 'utf8' COLLATE 'utf8_general_ci' NOT NULL COMMENT 'Пароль в SHA-256 (64 символа)' ,
  `languageID` INT UNSIGNED NOT NULL COMMENT 'Язык, определённый посредством внешнего сервиса геолокации или установленный пользователем по умолчанию' ,
  `points` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Набранные очки' ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_users_languages` (`languageID` ASC) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`tags`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`tags` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Идентификатор' ,
  `isApproved` TINYINT(1) NOT NULL COMMENT 'Флаг проверки тега модератором' ,
  PRIMARY KEY (`id`) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`tags_languages`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`tags_languages` (
  `tagID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор тега' ,
  `languageID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор языка' ,
  `name` VARCHAR(20) CHARACTER SET 'utf8' COLLATE 'utf8_general_ci' NOT NULL COMMENT 'Название' ,
  PRIMARY KEY (`tagID`, `languageID`) ,
  INDEX `fk_tags_has_languages_languages1` (`languageID` ASC) ,
  INDEX `fk_tags_has_languages_tags1` (`tagID` ASC) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`games`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`games` (
  `id` INT UNSIGNED NOT NULL COMMENT 'Идентификатор' ,
  `userID` INT UNSIGNED NOT NULL COMMENT 'Создатель игры' ,
  `time` SMALLINT(3) UNSIGNED NOT NULL DEFAULT 60 COMMENT 'Временной лимит в секундах (0 – время не ограничивается, по умолчанию 60)' ,
  `rating` FLOAT(3,2) UNSIGNED NOT NULL DEFAULT 0.00 COMMENT 'Пользовательский рейтинг игры по 10-балльной шкале' ,
  `votes` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Количество голосов' ,
  `isApproved` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Флаг проверки игры' ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_games_users1` (`userID` ASC) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`games_languages`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`games_languages` (
  `gameID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор игры' ,
  `languageID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор языка' ,
  `description` VARCHAR(140) CHARACTER SET 'utf8' COLLATE 'utf8_general_ci' NOT NULL COMMENT 'Описание' ,
  PRIMARY KEY (`gameID`, `languageID`) ,
  INDEX `fk_games_has_languages_languages1` (`languageID` ASC) ,
  INDEX `fk_games_has_languages_games1` (`gameID` ASC) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`games_tags`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`games_tags` (
  `gameID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор игры' ,
  `tagID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор тега' ,
  PRIMARY KEY (`gameID`, `tagID`) ,
  INDEX `fk_games_has_tags_tags1` (`tagID` ASC) ,
  INDEX `fk_games_has_tags_games1` (`gameID` ASC) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`users_games`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`users_games` (
  `userID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор пользователя' ,
  `gameID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор игры' ,
  `points` INT UNSIGNED NOT NULL COMMENT 'Лучший результат' ,
  `launches` INT UNSIGNED NOT NULL DEFAULT '1' COMMENT 'Количество запусков игры' ,
  PRIMARY KEY (`userID`, `gameID`) ,
  INDEX `fk_users_has_games_games1` (`gameID` ASC) ,
  INDEX `fk_users_has_games_users1` (`userID` ASC) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`objects`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`objects` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Идентификатор' ,
  `userID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор пользователя, добавившего объект' ,
  `parentID` INT UNSIGNED NULL COMMENT 'Идентификатор объекта уровнем выше (для достопримечательности – ID города, для города – ID страны, для страны – ID континента)\nЕсли NULL, выше ничего нет' ,
  `lat` FLOAT(9,6) NOT NULL COMMENT 'Широта географического центра' ,
  `lng` FLOAT(9,6) NOT NULL COMMENT 'Долгота географического центра' ,
  `isApproved` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Флаг проверки объекта' ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_objects_users1` (`userID` ASC) ,
  INDEX `fk_objects_objects1` (`parentID` ASC) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`objects_boundaries`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`objects_boundaries` (
  `objectID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор объекта' ,
  `boundaries` GEOMETRY NOT NULL COMMENT 'Описание границ' ,
  PRIMARY KEY (`objectID`) ,
  INDEX `fk_objects_boundaries_objects1` (`objectID` ASC) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`fields_types`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`fields_types` (
  `id` TINYINT(1) NOT NULL COMMENT 'Идентификатор' ,
  `type` VARCHAR(6) CHARACTER SET 'utf8' COLLATE 'utf8_general_ci' NOT NULL COMMENT 'Тип (text, object, image)' ,
  PRIMARY KEY (`id`) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`fields`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`fields` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Идентификатор' ,
  `typeID` TINYINT(1) NOT NULL COMMENT 'Тип атрибута (text, object, image)' ,
  `isApproved` TINYINT(1) NOT NULL COMMENT 'Флаг проверки' ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_fields_fields_types1` (`typeID` ASC) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`fields_languages`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`fields_languages` (
  `fieldID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор атрибута' ,
  `languageID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор языка' ,
  `name` VARCHAR(20) CHARACTER SET 'utf8' COLLATE 'utf8_general_ci' NOT NULL COMMENT 'Название' ,
  PRIMARY KEY (`fieldID`, `languageID`) ,
  INDEX `fk_fields_has_languages_languages1` (`languageID` ASC) ,
  INDEX `fk_fields_has_languages_fields1` (`fieldID` ASC) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`object_fields`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`object_fields` (
  `objectID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор объекта' ,
  `fieldID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор атрибута' ,
  PRIMARY KEY (`objectID`, `fieldID`) ,
  INDEX `fk_objects_has_fields_fields1` (`fieldID` ASC) ,
  INDEX `fk_objects_has_fields_objects1` (`objectID` ASC) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`categories`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`categories` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Идентификатор' ,
  `isApproved` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Флаг проверки' ,
  PRIMARY KEY (`id`) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`categories_languages`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`categories_languages` (
  `categoryID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор категории' ,
  `languageID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор языка' ,
  `name` VARCHAR(20) CHARACTER SET 'utf8' COLLATE 'utf8_general_ci' NOT NULL COMMENT 'Название' ,
  PRIMARY KEY (`categoryID`, `languageID`) ,
  INDEX `fk_categories_has_languages_languages1` (`languageID` ASC) ,
  INDEX `fk_categories_has_languages_categories1` (`categoryID` ASC) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`objects_categories`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`objects_categories` (
  `objectID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор объекта' ,
  `categoryID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор категории' ,
  PRIMARY KEY (`objectID`, `categoryID`) ,
  INDEX `fk_objects_has_categories_categories1` (`categoryID` ASC) ,
  INDEX `fk_objects_has_categories_objects1` (`objectID` ASC) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`games_objects`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`games_objects` (
  `gameID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор игры' ,
  `objectID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор объекта' ,
  `fieldID` INT UNSIGNED NOT NULL COMMENT 'Атрибут объекта, который будет использоваться в задании' ,
  `variantsID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор допустимой области ответов (если равен 0, только среди выбранных объектов, иначе объектом, соответствующим указанному ID в таблице objects, например, страной)' ,
  `taskTemplateID` TINYINT(1) NOT NULL COMMENT 'Идентификатор шаблона «Что показывать?»' ,
  `answerTemplateID` TINYINT(1) NOT NULL COMMENT 'Идентификатор шаблона «Что делать пользователю?»' ,
  PRIMARY KEY (`gameID`, `objectID`, `fieldID`) ,
  INDEX `fk_games_has_objects_objects1` (`objectID` ASC) ,
  INDEX `fk_games_has_objects_games1` (`gameID` ASC) ,
  INDEX `fk_games_objects_fields1` (`fieldID` ASC) ,
  INDEX `fk_games_objects_objects1` (`variantsID` ASC) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`roles`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`roles` (
  `id` TINYINT(1) NOT NULL AUTO_INCREMENT COMMENT 'Идентификатор роли' ,
  `name` VARCHAR(20) CHARACTER SET 'utf8' COLLATE 'utf8_general_ci' NOT NULL COMMENT 'Название роли' ,
  `description` VARCHAR(200) CHARACTER SET 'utf8' COLLATE 'utf8_general_ci' NOT NULL COMMENT 'Описание роли' ,
  PRIMARY KEY (`id`) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`users_roles`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`users_roles` (
  `userID` INT UNSIGNED NOT NULL ,
  `roleID` TINYINT(1) NOT NULL ,
  PRIMARY KEY (`userID`, `roleID`) ,
  INDEX `fk_users_has_roles_roles1` (`roleID` ASC) ,
  INDEX `fk_users_has_roles_users1` (`userID` ASC) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `WorldMap`.`bans`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `WorldMap`.`bans` (
  `userID` INT UNSIGNED NOT NULL COMMENT 'Идентификатор забаненного пользователя' ,
  `date` DATETIME NOT NULL COMMENT 'Дата и время бана' ,
  `comment` VARCHAR(200) CHARACTER SET 'utf8' COLLATE 'utf8_general_ci' NULL COMMENT 'Причина бана' ,
  PRIMARY KEY (`userID`) ,
  INDEX `fk_bans_users1` (`userID` ASC) )
ENGINE = Aria
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `WorldMap`.`languages`
-- -----------------------------------------------------
START TRANSACTION;
USE `WorldMap`;
INSERT INTO `WorldMap`.`languages` (`id`, `language`) VALUES (1, 'ru');

COMMIT;

-- -----------------------------------------------------
-- Data for table `WorldMap`.`roles`
-- -----------------------------------------------------
START TRANSACTION;
USE `WorldMap`;
INSERT INTO `WorldMap`.`roles` (`id`, `name`, `description`) VALUES (1, 'login', 'Роль назначается всем зарегистрировавшимся пользователям. Пользователи могут добавлять и редактировать объекты, создавать игры');
INSERT INTO `WorldMap`.`roles` (`id`, `name`, `description`) VALUES (2, 'moderator', 'Назначается пользователям, которые проверяют добавляемые объекты и игры');
INSERT INTO `WorldMap`.`roles` (`id`, `name`, `description`) VALUES (3, 'administrator', 'Назначает модераторов');

COMMIT;

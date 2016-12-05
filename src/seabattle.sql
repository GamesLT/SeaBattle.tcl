# noinspection SqlNoDataSourceInspectionForFile
CREATE TABLE `Users` (
  id         INT UNSIGNED           AUTO_INCREMENT PRIMARY KEY,
  Nick       VARCHAR(30)            NOT NULL,
  Admin      ENUM ('true', 'false') NOT NULL,
  `Host`     VARCHAR(255)           NOT NULL,
  `Password` VARCHAR(30)            NOT NULL,
  `E-Mail`   VARCHAR(255)           NOT NULL,
  StatNA     INT                    NOT NULL DEFAULT 0,
  StatWon    INT                    NOT NULL DEFAULT 0,
  StatLost   INT                    NOT NULL DEFAULT 0,
  LastLogged TIMESTAMP              NULL ON UPDATE CURRENT_TIMESTAMP,
  LastAction TIMESTAMP              DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE `Help` (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `Item`        VARCHAR(255) NOT NULL,
  `Description` TEXT,
  `Syntax`      VARCHAR(255)
);

CREATE TABLE settings (
  id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `Setting` VARCHAR(255) NOT NULL,
  `Value`   VARCHAR(255) NOT NULL
);

CREATE UNIQUE INDEX settings_setting ON settings (`Setting`);

CREATE TABLE TodoList (
  id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `Command` VARCHAR(255) NOT NULL,
  Arguments VARCHAR(255) NOT NULL
);

CREATE TABLE Seabattle (
  id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  Nick    VARCHAR(30) NOT NULL,
  Value   CHAR(1)     NOT NULL,
  row     CHAR(1)     NOT NULL,
  collumn CHAR(1)     NOT NULL
);



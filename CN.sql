CREATE TABLE IF NOT EXISTS `users_current` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `model` longtext NOT NULL,
  `drawables` longtext NOT NULL,
  `props` longtext NOT NULL,
  `drawtextures` longtext NOT NULL,
  `proptextures` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `users_face` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `hairColor` longtext NOT NULL,
  `headBlend` longtext NOT NULL,
  `headOverlay` longtext NOT NULL,
  `headStructure` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `users_outfits` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `model` longtext NOT NULL,
  `name` longtext NOT NULL,
  `slot` longtext NOT NULL,
  `drawables` longtext NOT NULL,
  `props` longtext NOT NULL,
  `drawtextures` longtext NOT NULL,
  `proptextures` longtext NOT NULL,
  `hairColor` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `users_tattoos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL DEFAULT '0',
  `tattoos` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` VARCHAR(40) NOT NULL,
  `firstname` varchar(50) NOT NULL,
  `lastname` varchar(50) NOT NULL,
  `dateofbirth` varchar(50) NOT NULL,
  `sex` varchar(50) NOT NULL,
  `story` varchar(100) NOT NULL DEFAULT 'Default story - new char system',
  `accounts` LONGTEXT NULL DEFAULT NULL,
  `group` VARCHAR(50) NULL DEFAULT 'user',
  `inventory` LONGTEXT NULL DEFAULT NULL,
  `job` VARCHAR(20) NULL DEFAULT 'unemployed',
  `job_grade` INT NULL DEFAULT 0,
  `loadout` LONGTEXT NULL DEFAULT NULL,
  `position` VARCHAR(255) NULL DEFAULT '{"x":-269.4,"y":-955.3,"z":31.2,"heading":205.8}',
  PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `user_bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(100) NOT NULL,
  `license` varchar(100) NOT NULL,
  `time` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `giver` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `users_hospital_patients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `illness` varchar(50) NOT NULL DEFAULT 'none',
  `level` int(11) NOT NULL DEFAULT '0',
  `time` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `users_housing` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `housing_id` int(11) NOT NULL,
  `Street` text NOT NULL,
  `assigned` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `users_housing_keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `housing_id` int(11) NOT NULL,
  `giver` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `users_motel` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` int(11) NOT NULL,
  `building_type` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4;


CREATE TABLE `rating` (
  `id` varchar(45) NOT NULL default '',
  `name` varchar(255) NOT NULL default '',
  `title` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;


CREATE TABLE `ratingsvote` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `ratingId` varchar(45) default NULL,
  `userId` varchar(45) default NULL,
  `rate` int(10) unsigned default '0',
  PRIMARY KEY  (`id`)
) TYPE=InnoDB;

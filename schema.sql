-- Create syntax for TABLE 'tg_auth_keys'
CREATE TABLE `tg_auth_keys` (
  `tg_session_id` bigint(20) unsigned NOT NULL,
  `dc_id` tinyint(2) unsigned NOT NULL,
  `auth_key` mediumblob NOT NULL,
  PRIMARY KEY (`tg_session_id`,`dc_id`),
  CONSTRAINT `tg_auth_keys_ibfk_1` FOREIGN KEY (`tg_session_id`) REFERENCES `tg_sessions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Create syntax for TABLE 'tg_peers'
CREATE TABLE `tg_peers` (
  `tg_user_id` int(11) NOT NULL,
  `tg_peer_id` int(11) NOT NULL,
  `access_hash` bigint(20) NOT NULL,
  PRIMARY KEY (`tg_user_id`,`tg_peer_id`),
  CONSTRAINT `tg_peers_ibfk_1` FOREIGN KEY (`tg_user_id`) REFERENCES `tg_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Create syntax for TABLE 'tg_sessions'
CREATE TABLE `tg_sessions` (
  `id` bigint(20) unsigned NOT NULL,
  `tg_user_id` int(11) NOT NULL,
  `dc_id` int(3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `tg_user` (`tg_user_id`),
  CONSTRAINT `tg_sessions_ibfk_1` FOREIGN KEY (`tg_user_id`) REFERENCES `tg_users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Create syntax for TABLE 'tg_users'
CREATE TABLE `tg_users` (
  `id` int(11) NOT NULL,
  `phone` bigint(20) unsigned DEFAULT NULL,
  `username` varchar(32) DEFAULT NULL,
  `is_bot` bool NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `phone` (`phone`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE library MODIFY COLUMN seq_centre_id smallint(5) unsigned DEFAULT '1';
ALTER TABLE library MODIFY COLUMN seq_tech_id smallint(5) unsigned DEFAULT '1';
update latest_library set seq_centre_id =1 where seq_centre_id is NULL;
update latest_library set seq_tech_id =1 where seq_tech_id is NULL;

ALTER TABLE organizer ADD FOREIGN KEY (event_year) REFERENCES event (year);

ALTER TABLE organizer ADD FOREIGN KEY (person_email) REFERENCES person (email);

ALTER TABLE person ADD FOREIGN KEY (department_code) REFERENCES department (code);

ALTER TABLE department ADD FOREIGN KEY (college_code) REFERENCES college (code);

ALTER TABLE person_workshop ADD FOREIGN KEY (person_email) REFERENCES person (email);

ALTER TABLE person_workshop ADD FOREIGN KEY (workshop_id) REFERENCES workshop (id);

ALTER TABLE workshop ADD FOREIGN KEY (event_year) REFERENCES event (year);

ALTER TABLE workshop ADD FOREIGN KEY (room_name) REFERENCES room (name);

ALTER TABLE timeslot ADD FOREIGN KEY (event_year) REFERENCES event (year);

ALTER TABLE workshop_timeslot ADD FOREIGN KEY (workshop_id) REFERENCES workshop (id);

ALTER TABLE workshop_timeslot ADD FOREIGN KEY (timeslot_event_year, timeslot_id) REFERENCES timeslot (event_year, id);

ALTER TABLE room_feature ADD FOREIGN KEY (room_name) REFERENCES room (name);

ALTER TABLE room_feature ADD FOREIGN KEY (feature_name) REFERENCES feature (name);

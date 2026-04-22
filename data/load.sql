\copy college FROM '../data/college.csv' CSV HEADER
\copy department FROM '../data/department.csv' CSV HEADER

\copy room FROM '../data/room.csv' CSV HEADER
\copy feature FROM '../data/feature.csv' CSV HEADER
\copy room_feature FROM '../data/room_feature.csv' CSV HEADER

INSERT INTO event VALUES
  (2024, '2024-03-23');

INSERT INTO timeslot VALUES
  (2024, 1, 'Workshop Period 1', '09:50', '10:50'),
  (2024, 2, 'Workshop Period 2', '11:00', '12:00'),
  (2024, 3, 'Workshop Period 3', '13:35', '14:35');

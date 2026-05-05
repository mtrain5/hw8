-- ============================================================
-- load.sql  –  Static data load for HW8 Hotel Database
-- Query anchors:
--   Hotel A = The Grand Shenandoah  (Q1: Jul 15-17 2025)
--   Hotel B = Blue Ridge Inn        (Q2/Q3/Q4: Jul 18-20 2025)
--   Guest 2 = Mrs. Smith (gold)     (Q2/Q3 reserver)
--   Guest 3 = Robert Chen (gold)    (Q5: 2 hotels in 2025)
-- ============================================================

BEGIN;

-- ── TRUNCATE (safe reset) ─────────────────────────────────────
TRUNCATE Services, BILL, OCCUPANTS, RESERVED_ROOM, RESERVATION,
         GUEST, ROOM, ROOM_TYPE_FEATURE, ROOM_PRICE, ROOM_TYPE,
         SEASON, HOTEL_FEATURE, HOTEL_PHONE, CATEGORY, HOTEL
RESTART IDENTITY CASCADE;

-- ── CATEGORIES ───────────────────────────────────────────────
INSERT INTO CATEGORY (CategoryName, DiscountPercent) VALUES
    ('standard', 0.00),
    ('gold',     0.15);

-- ── HOTELS ───────────────────────────────────────────────────
INSERT INTO HOTEL (Name, Address) VALUES
    ('The Grand Shenandoah',    '100 Valley Rd, Harrisonburg, VA 22801'),   -- 1: Hotel A
    ('Blue Ridge Inn',          '200 Ridge Ave, Waynesboro, VA 22980'),     -- 2: Hotel B
    ('Skyline Summit Hotel',    '300 Summit Dr, Luray, VA 22835'),          -- 3: Hotel C
    ('Piedmont Plaza Hotel',    '400 Plaza Blvd, Staunton, VA 24401'),      -- 4: Hotel D
    ('Appalachian Peaks Resort','500 Peaks Ln, Monterey, VA 24465');        -- 5: Hotel E

-- ── HOTEL PHONES ─────────────────────────────────────────────
INSERT INTO HOTEL_PHONE (HotelID, PhoneNumber) VALUES
    (1, '540-555-1001'),
    (2, '540-555-2001'),
    (3, '540-555-3001'),
    (4, '540-555-4001'),
    (5, '540-555-5001');

-- ── HOTEL FEATURES ───────────────────────────────────────────
INSERT INTO HOTEL_FEATURE (HotelID, Name) VALUES
    (1, 'Pool'), (1, 'Fitness Center'), (1, 'Restaurant'),
    (2, 'Spa'),  (2, 'Free Parking'),   (2, 'Bar'),
    (3, 'Hot Tub'), (3, 'Mountain Views'), (3, 'Hiking Trails'),
    (4, 'Business Center'), (4, 'Restaurant'), (4, 'Pool'),
    (5, 'Fireplace Lounge'), (5, 'Hiking Trails'), (5, 'Hot Tub');

-- ── SEASONS ──────────────────────────────────────────────────
-- Hotel A High Season covers Jul 15-17 2025 (Q1)
-- Hotel B Summer Season covers Jul 18-20 2025 (Q3)
INSERT INTO SEASON (HotelID, Name, StartDate, EndDate) VALUES
    (1, 'High Season',     '2025-06-01', '2025-08-31'),   -- 1
    (1, 'Low Season',      '2025-09-01', '2026-05-31'),   -- 2
    (2, 'Summer Season',   '2025-05-25', '2025-09-01'),   -- 3
    (2, 'Off Season',      '2025-09-02', '2026-05-24'),   -- 4
    (3, 'Peak Summer',     '2025-06-15', '2025-09-15'),   -- 5
    (3, 'Winter',          '2025-09-16', '2026-06-14'),   -- 6
    (4, 'Festival Season', '2025-07-01', '2025-10-31'),   -- 7
    (4, 'Regular Season',  '2025-11-01', '2026-06-30'),   -- 8
    (5, 'Spring/Summer',   '2025-04-01', '2025-10-15'),   -- 9
    (5, 'Fall/Winter',     '2025-10-16', '2026-03-31');   -- 10

-- ── SERVICE TYPES ─────────────────────────────────────────────
INSERT INTO SERVICE_TYPE (ServiceTypeName) VALUES
    ('Room Service'),    -- 1
    ('Spa Treatment'),   -- 2
    ('Parking'),         -- 3
    ('Minibar'),         -- 4
    ('Laundry');         -- 5

-- ── ROOM TYPES ───────────────────────────────────────────────
-- Hotel A (HotelID=1)
INSERT INTO ROOM_TYPE (HotelID, type_name, size_sq, capacities) VALUES
    (1, 'Standard Single', 20.00, 1),   -- 1
    (1, 'Double',          30.00, 2),   -- 2
    (1, 'Suite',           55.00, 4),   -- 3
-- Hotel B (HotelID=2)
    (2, 'Standard Single', 18.00, 1),   -- 4
    (2, 'Double',          28.00, 2),   -- 5
-- Hotel C (HotelID=3)
    (3, 'Double',          32.00, 2),   -- 6
    (3, 'King Deluxe',     45.00, 2),   -- 7
-- Hotel D (HotelID=4)
    (4, 'Standard Single', 22.00, 1),   -- 8
    (4, 'Double',          29.00, 2),   -- 9
    (4, 'Suite',           60.00, 4),   -- 10
-- Hotel E (HotelID=5)
    (5, 'Cabin Suite',     68.00, 4),   -- 11
    (5, 'Standard Double', 30.00, 2);   -- 12

-- ── ROOM TYPE FEATURES ────────────────────────────────────────
INSERT INTO ROOM_TYPE_FEATURE (RoomTypeID, FeatureName) VALUES
    (1,  'Free Wi-Fi'), (1,  'Air Conditioning'),
    (2,  'Free Wi-Fi'), (2,  'Air Conditioning'), (2,  'Mini-Fridge'),
    (3,  'Free Wi-Fi'), (3,  'Jacuzzi'),           (3,  'King Bed'), (3, 'Kitchenette'),
    (4,  'Free Wi-Fi'), (4,  'Air Conditioning'),
    (5,  'Free Wi-Fi'), (5,  'Air Conditioning'), (5,  'Mini-Fridge'),
    (6,  'Free Wi-Fi'), (6,  'Air Conditioning'), (6,  'Mini-Fridge'),
    (7,  'Free Wi-Fi'), (7,  'Mountain View'),     (7,  'King Bed'),
    (8,  'Free Wi-Fi'), (8,  'Air Conditioning'),
    (9,  'Free Wi-Fi'), (9,  'Air Conditioning'), (9,  'Mini-Fridge'),
    (10, 'Free Wi-Fi'), (10, 'Jacuzzi'),           (10, 'King Bed'), (10, 'Kitchenette'),
    (11, 'Free Wi-Fi'), (11, 'Fireplace'),          (11, 'Hot Tub'),
    (12, 'Free Wi-Fi'), (12, 'Patio');

-- ── ROOM PRICES ──────────────────────────────────────────────
-- Weekday prices use a per-day multiplier so Mon≠Tue≠Wed etc.
-- Weekend (Fri/Sat/Sun) prices are higher with a surcharge.
-- Q1 needs Tue ≠ Wed at Hotel A (RoomTypeID 1,2,3 Season 1).
-- Q3 needs Fri ≠ Sat at Hotel B (RoomTypeID 5, Season 3).

-- Hotel A – High Season (SeasonID=1): RoomTypeIDs 1,2,3
INSERT INTO ROOM_PRICE (RoomTypeID, SeasonID, DayOfTheWeek, Price) VALUES
-- Standard Single (rt=1, season=1)
    (1,1,'Mon',102.00),(1,1,'Tue',105.00),(1,1,'Wed',108.00),(1,1,'Thu',104.00),
    (1,1,'Fri',138.00),(1,1,'Sat',145.00),(1,1,'Sun',132.00),
-- Double (rt=2, season=1)
    (2,1,'Mon',152.00),(2,1,'Tue',158.00),(2,1,'Wed',163.00),(2,1,'Thu',155.00),
    (2,1,'Fri',210.00),(2,1,'Sat',220.00),(2,1,'Sun',205.00),
-- Suite (rt=3, season=1)
    (3,1,'Mon',295.00),(3,1,'Tue',305.00),(3,1,'Wed',312.00),(3,1,'Thu',300.00),
    (3,1,'Fri',390.00),(3,1,'Sat',405.00),(3,1,'Sun',380.00);

-- Hotel A – Low Season (SeasonID=2): RoomTypeIDs 1,2,3
INSERT INTO ROOM_PRICE (RoomTypeID, SeasonID, DayOfTheWeek, Price) VALUES
    (1,2,'Mon',72.00),(1,2,'Tue',74.00),(1,2,'Wed',76.00),(1,2,'Thu',73.00),
    (1,2,'Fri',95.00),(1,2,'Sat',100.00),(1,2,'Sun',92.00),
    (2,2,'Mon',108.00),(2,2,'Tue',111.00),(2,2,'Wed',114.00),(2,2,'Thu',110.00),
    (2,2,'Fri',145.00),(2,2,'Sat',152.00),(2,2,'Sun',140.00),
    (3,2,'Mon',208.00),(3,2,'Tue',213.00),(3,2,'Wed',218.00),(3,2,'Thu',210.00),
    (3,2,'Fri',270.00),(3,2,'Sat',282.00),(3,2,'Sun',265.00);

-- Hotel B – Summer Season (SeasonID=3): RoomTypeIDs 4,5
-- Fri ≠ Sat required for Q3 (Smith checkout billing)
INSERT INTO ROOM_PRICE (RoomTypeID, SeasonID, DayOfTheWeek, Price) VALUES
    (4,3,'Mon',92.00),(4,3,'Tue',95.00),(4,3,'Wed',97.00),(4,3,'Thu',94.00),
    (4,3,'Fri',128.00),(4,3,'Sat',135.00),(4,3,'Sun',122.00),
    (5,3,'Mon',138.00),(5,3,'Tue',142.00),(5,3,'Wed',146.00),(5,3,'Thu',140.00),
    (5,3,'Fri',192.00),(5,3,'Sat',205.00),(5,3,'Sun',185.00);

-- Hotel B – Off Season (SeasonID=4): RoomTypeIDs 4,5
INSERT INTO ROOM_PRICE (RoomTypeID, SeasonID, DayOfTheWeek, Price) VALUES
    (4,4,'Mon',65.00),(4,4,'Tue',67.00),(4,4,'Wed',69.00),(4,4,'Thu',66.00),
    (4,4,'Fri',88.00),(4,4,'Sat',93.00),(4,4,'Sun',84.00),
    (5,4,'Mon',98.00),(5,4,'Tue',101.00),(5,4,'Wed',104.00),(5,4,'Thu',99.00),
    (5,4,'Fri',132.00),(5,4,'Sat',140.00),(5,4,'Sun',127.00);

-- Hotel C – Peak Summer (SeasonID=5): RoomTypeIDs 6,7
INSERT INTO ROOM_PRICE (RoomTypeID, SeasonID, DayOfTheWeek, Price) VALUES
    (6,5,'Mon',142.00),(6,5,'Tue',146.00),(6,5,'Wed',150.00),(6,5,'Thu',144.00),
    (6,5,'Fri',192.00),(6,5,'Sat',202.00),(6,5,'Sun',185.00),
    (7,5,'Mon',210.00),(7,5,'Tue',216.00),(7,5,'Wed',222.00),(7,5,'Thu',213.00),
    (7,5,'Fri',282.00),(7,5,'Sat',296.00),(7,5,'Sun',272.00);

-- Hotel C – Winter (SeasonID=6): RoomTypeIDs 6,7
INSERT INTO ROOM_PRICE (RoomTypeID, SeasonID, DayOfTheWeek, Price) VALUES
    (6,6,'Mon',100.00),(6,6,'Tue',103.00),(6,6,'Wed',106.00),(6,6,'Thu',101.00),
    (6,6,'Fri',135.00),(6,6,'Sat',142.00),(6,6,'Sun',130.00),
    (7,6,'Mon',148.00),(7,6,'Tue',152.00),(7,6,'Wed',156.00),(7,6,'Thu',150.00),
    (7,6,'Fri',198.00),(7,6,'Sat',208.00),(7,6,'Sun',192.00);

-- Hotel D – Festival Season (SeasonID=7): RoomTypeIDs 8,9,10
INSERT INTO ROOM_PRICE (RoomTypeID, SeasonID, DayOfTheWeek, Price) VALUES
    (8,7,'Mon',108.00),(8,7,'Tue',111.00),(8,7,'Wed',114.00),(8,7,'Thu',109.00),
    (8,7,'Fri',145.00),(8,7,'Sat',152.00),(8,7,'Sun',140.00),
    (9,7,'Mon',168.00),(9,7,'Tue',173.00),(9,7,'Wed',178.00),(9,7,'Thu',170.00),
    (9,7,'Fri',225.00),(9,7,'Sat',236.00),(9,7,'Sun',218.00),
    (10,7,'Mon',330.00),(10,7,'Tue',340.00),(10,7,'Wed',350.00),(10,7,'Thu',335.00),
    (10,7,'Fri',440.00),(10,7,'Sat',460.00),(10,7,'Sun',428.00);

-- Hotel D – Regular Season (SeasonID=8): RoomTypeIDs 8,9,10
INSERT INTO ROOM_PRICE (RoomTypeID, SeasonID, DayOfTheWeek, Price) VALUES
    (8,8,'Mon',78.00),(8,8,'Tue',80.00),(8,8,'Wed',82.00),(8,8,'Thu',79.00),
    (8,8,'Fri',105.00),(8,8,'Sat',110.00),(8,8,'Sun',102.00),
    (9,8,'Mon',118.00),(9,8,'Tue',121.00),(9,8,'Wed',124.00),(9,8,'Thu',119.00),
    (9,8,'Fri',158.00),(9,8,'Sat',165.00),(9,8,'Sun',153.00),
    (10,8,'Mon',232.00),(10,8,'Tue',238.00),(10,8,'Wed',244.00),(10,8,'Thu',235.00),
    (10,8,'Fri',308.00),(10,8,'Sat',322.00),(10,8,'Sun',300.00);

-- Hotel E – Spring/Summer (SeasonID=9): RoomTypeIDs 11,12
INSERT INTO ROOM_PRICE (RoomTypeID, SeasonID, DayOfTheWeek, Price) VALUES
    (11,9,'Mon',248.00),(11,9,'Tue',255.00),(11,9,'Wed',262.00),(11,9,'Thu',250.00),
    (11,9,'Fri',332.00),(11,9,'Sat',348.00),(11,9,'Sun',322.00),
    (12,9,'Mon',152.00),(12,9,'Tue',156.00),(12,9,'Wed',160.00),(12,9,'Thu',154.00),
    (12,9,'Fri',204.00),(12,9,'Sat',214.00),(12,9,'Sun',198.00);

-- Hotel E – Fall/Winter (SeasonID=10): RoomTypeIDs 11,12
INSERT INTO ROOM_PRICE (RoomTypeID, SeasonID, DayOfTheWeek, Price) VALUES
    (11,10,'Mon',188.00),(11,10,'Tue',193.00),(11,10,'Wed',198.00),(11,10,'Thu',190.00),
    (11,10,'Fri',252.00),(11,10,'Sat',264.00),(11,10,'Sun',245.00),
    (12,10,'Mon',115.00),(12,10,'Tue',118.00),(12,10,'Wed',121.00),(12,10,'Thu',116.00),
    (12,10,'Fri',154.00),(12,10,'Sat',161.00),(12,10,'Sun',150.00);

-- ── ROOMS (3 per room type, loaded from room.csv) ─────────────
-- Hotel A
INSERT INTO ROOM (HotelID, RoomTypeID, room_number, floor) VALUES
    (1,1,'101',1),(1,1,'102',1),(1,1,'103',1),   -- Standard Single
    (1,2,'201',2),(1,2,'202',2),(1,2,'203',2),   -- Double
    (1,3,'301',3),(1,3,'302',3),(1,3,'303',3);   -- Suite
-- Hotel B
INSERT INTO ROOM (HotelID, RoomTypeID, room_number, floor) VALUES
    (2,4,'101',1),(2,4,'102',1),(2,4,'103',1),   -- Standard Single
    (2,5,'201',2),(2,5,'202',2),(2,5,'203',2);   -- Double
-- Hotel C
INSERT INTO ROOM (HotelID, RoomTypeID, room_number, floor) VALUES
    (3,6,'101',1),(3,6,'102',1),(3,6,'103',1),   -- Double
    (3,7,'201',2),(3,7,'202',2),(3,7,'203',2);   -- King Deluxe
-- Hotel D
INSERT INTO ROOM (HotelID, RoomTypeID, room_number, floor) VALUES
    (4,8,'101',1),(4,8,'102',1),(4,8,'103',1),   -- Standard Single
    (4,9,'201',2),(4,9,'202',2),(4,9,'203',2),   -- Double
    (4,10,'301',3),(4,10,'302',3),(4,10,'303',3); -- Suite
-- Hotel E
INSERT INTO ROOM (HotelID, RoomTypeID, room_number, floor) VALUES
    (5,11,'101',1),(5,11,'102',1),(5,11,'103',1), -- Cabin Suite
    (5,12,'201',2),(5,12,'202',2),(5,12,'203',2); -- Standard Double

-- ── GUESTS ───────────────────────────────────────────────────
-- GuestID 1: gold – Q1 new VIP (Mrs. Garcia, inserted by query1.sql)
-- GuestID 2: gold – Q2/Q3 Mrs. Smith (reserver, must pre-exist)
-- GuestID 3: gold – Q5 Robert Chen (2 hotels in 2025)
-- GuestID 4: gold – Diana Patel
-- GuestIDs 5-11: standard guests
INSERT INTO GUEST (IdType, IdNumber, Address, HomePhone, MobilePhone, Category_name) VALUES
    ('passport',       'PA11111111', '10 Oak St, Harrisonburg, VA 22801', '540-555-0101', '540-555-0111', 'gold'),     -- 1  Garcia (Q1)
    ('drivers_license','DL22222222', '20 Elm St, Waynesboro, VA 22980',   '540-555-0202', '540-555-0212', 'gold'),     -- 2  Mrs. Smith (Q2/Q3)
    ('passport',       'PA33333333', '30 Pine Rd, Luray, VA 22835',       '540-555-0303', '540-555-0313', 'gold'),     -- 3  Robert Chen (Q5)
    ('passport',       'PA44444444', '40 Maple Ave, Staunton, VA 24401',  '540-555-0404', '540-555-0414', 'gold'),     -- 4  Diana Patel
    ('drivers_license','DL55555555', '50 Cedar Ln, Monterey, VA 24465',   '540-555-0505', '540-555-0515', 'standard'), -- 5  Q1 blocker guest
    ('passport',       'PA66666666', '60 Birch Blvd, Luray, VA 22835',    '540-555-0606', '540-555-0616', 'standard'), -- 6  Q2 blocker guest
    ('drivers_license','DL77777777', '70 Walnut Dr, Staunton, VA 24401',  '540-555-0707', '540-555-0717', 'standard'), -- 7
    ('passport',       'PA88888888', '80 Spruce Ct, Monterey, VA 24465',  '540-555-0808', '540-555-0818', 'standard'), -- 8
    ('drivers_license','DL99999999', '90 Ash Way, Waynesboro, VA 22980',  '540-555-0909', '540-555-0919', 'standard'), -- 9
    ('passport',       'PA10101010', '100 Fir Rd, Harrisonburg, VA 22801','540-555-1010', '540-555-1011', 'standard'); -- 10

-- ── Q1 BLOCKER: Standard Single at Hotel A checked_in Jul 15-17 ──
-- Ensures Standard Single does NOT appear in the Q1 availability SELECT.
INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES
    (5, 1, '2025-07-10 10:00:00', 'active');                  -- ReservationID 1

INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES
    (1, 1, 1, '2025-07-15', '2025-07-17', 'checked_in');      -- ReservedRoomID 1  (RoomID 1 = Hotel A Standard Single room 101)

INSERT INTO OCCUPANTS (ReservedRoomID, Name, GuestID) VALUES
    (1, 'Marcus Reed', 5);

-- ── Q2 BLOCKER: one Double at Hotel B checked_in Jul 18-21 ───
-- Ensures room 201 (RoomID 10) does NOT appear in the Q2 availability SELECT.
INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES
    (6, 2, '2025-07-12 11:00:00', 'active');                  -- ReservationID 2

INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES
    (2, 5, 10, '2025-07-18', '2025-07-21', 'checked_in');     -- ReservedRoomID 2  (RoomID 10 = Hotel B Double room 201)

INSERT INTO OCCUPANTS (ReservedRoomID, Name, GuestID) VALUES
    (2, 'Laura Torres', 6);

-- ── Q2/Q3/Q4: Mrs. Smith – Double at Hotel B, Jul 18-20 ──────
-- Jul 18=Fri ($192.00), Jul 19=Sat ($205.00) → prices differ for Q3.
-- Starts as 'reserved'; updated to checked_in then checked_out below.
-- RoomID 11 = Hotel B Double room 202 (room 201 is already occupied above).
INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES
    (2, 2, '2025-07-10 09:00:00', 'active');                  -- ReservationID 3

INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES
    (3, 5, 11, '2025-07-18', '2025-07-20', 'reserved');       -- ReservedRoomID 3  (RoomID 11 = Hotel B Double room 202)

-- Q2: Mr. Smith inserted as new guest at check-in
INSERT INTO GUEST (IdType, IdNumber, Address, HomePhone, MobilePhone, Category_name) VALUES
    ('drivers_license', 'DL00112233', '12 Oak Lane, Harrisonburg, VA 22801', NULL, NULL, NULL); -- GuestID 11

-- Q2: assign room and check in
UPDATE RESERVED_ROOM SET RoomID = 11, Status = 'checked_in' WHERE ReservedRoomID = 3;

-- Q4: both occupants (reserver + new occupant → query returns ≥2 rows)
INSERT INTO OCCUPANTS (ReservedRoomID, Name, GuestID) VALUES
    (3, 'Jane Smith', 2),
    (3, 'John Smith', 11);

-- Q3: bill  (room total with 15% gold discount applied)
--     Night 1 Fri $192.00 + Night 2 Sat $205.00 = $397.00 × 0.85 = $337.45
--     Room service $32.00  →  grand total $369.45
INSERT INTO BILL (ReservedRoomID, Information, TotalAmount, DateGenerated, Status) VALUES
    (3,
     'Double: Fri $192.00, Sat $205.00. Gold 15% discount. Room: $337.45. Room service: $32.00.',
     369.45,
     '2025-07-20',
     'paid');                                                  -- BillID 1

INSERT INTO Services (BillID, GuestID, ServiceTypeID, Quantity, DateTime, Price) VALUES
    (1, 2, 1, 1, '2025-07-18 20:00:00', 32.00);              -- Room Service

-- Q3: check out
UPDATE RESERVED_ROOM SET Status = 'checked_out' WHERE ReservedRoomID = 3;
UPDATE RESERVATION    SET Status = 'checked_out' WHERE ReservationID  = 3;

-- ── Q5: Robert Chen – stays at 2 hotels in 2025 ──────────────

-- Stay A: Hotel A, Aug 5-7 2025 (High Season, Tue+Wed)
--   Double Tue $158.00 + Wed $163.00 = $321.00 × 0.85 = $272.85
--   + Parking $18.00  →  total $290.85
INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES
    (3, 1, '2025-08-01 09:00:00', 'checked_out');             -- ReservationID 4

INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES
    (4, 2, 4, '2025-08-05', '2025-08-07', 'checked_out');     -- ReservedRoomID 4  (RoomID 4 = Hotel A Double room 201)

INSERT INTO OCCUPANTS (ReservedRoomID, Name, GuestID) VALUES
    (4, 'Robert Chen', 3);

INSERT INTO BILL (ReservedRoomID, Information, TotalAmount, DateGenerated, Status) VALUES
    (4, 'Double 2 nights Hotel A. Gold discount.', 290.85, '2025-08-07', 'paid'); -- BillID 2

INSERT INTO Services (BillID, GuestID, ServiceTypeID, Quantity, DateTime, Price) VALUES
    (2, 3, 3, 2, '2025-08-05 15:00:00', 18.00);              -- Parking

UPDATE BILL SET TotalAmount = 290.85 WHERE BillID = 2;        -- already includes parking

-- Stay B: Hotel B, Sep 5-7 2025 (Off Season, Fri+Sat)
--   Standard Single Fri $88.00 + Sat $93.00 = $181.00 × 0.85 = $153.85
--   + Minibar $15.00  →  total $168.85
INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES
    (3, 2, '2025-09-01 10:00:00', 'checked_out');             -- ReservationID 5

INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES
    (5, 4, 7, '2025-09-05', '2025-09-07', 'checked_out');     -- ReservedRoomID 5  (RoomID 7 = Hotel B Standard Single room 101)

INSERT INTO OCCUPANTS (ReservedRoomID, Name, GuestID) VALUES
    (5, 'Robert Chen', 3);

INSERT INTO BILL (ReservedRoomID, Information, TotalAmount, DateGenerated, Status) VALUES
    (5, 'Standard Single 2 nights Hotel B. Gold discount.', 168.85, '2025-09-07', 'paid'); -- BillID 3

INSERT INTO Services (BillID, GuestID, ServiceTypeID, Quantity, DateTime, Price) VALUES
    (3, 3, 4, 1, '2025-09-05 21:00:00', 15.00);              -- Minibar

-- ── ADDITIONAL RESERVATIONS (future / filler) ─────────────────
-- Guest 4 – Hotel D, future
INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES
    (4, 4, '2026-04-20 08:00:00', 'confirmed');               -- ReservationID 6
INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES
    (6, 10, NULL, '2026-05-12', '2026-05-14', 'reserved');

-- Guest 7 – Hotel C, future
INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES
    (7, 3, '2026-04-10 14:00:00', 'confirmed');               -- ReservationID 7
INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES
    (7, 7, NULL, '2026-05-03', '2026-05-04', 'reserved');

-- Guest 8 – Hotel E, future
INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES
    (8, 5, '2026-04-15 11:00:00', 'confirmed');               -- ReservationID 8
INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES
    (8, 11, NULL, '2026-05-17', '2026-05-19', 'reserved');

-- Guest 9 – Hotel D, future
INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES
    (9, 4, '2026-04-18 09:00:00', 'confirmed');               -- ReservationID 9
INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES
    (9, 9, NULL, '2026-05-22', '2026-05-23', 'reserved');

-- Guest 10 – Hotel C, future
INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES
    (10, 3, '2026-04-22 16:00:00', 'confirmed');              -- ReservationID 10
INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES
    (10, 6, NULL, '2026-05-10', '2026-05-12', 'reserved');

COMMIT;
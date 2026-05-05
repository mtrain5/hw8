-- ============================================================
-- HW7 Query Demonstrations
-- Run each block separately in PgAdmin.
-- Hotel A = The Grand Shenandoah
-- Hotel B = Blue Ridge Inn
-- ============================================================


-- ============================================================
-- QUERY SET 1: Reservations
-- New VIP (gold) guest wants a room at Hotel A, Jul 15-17 2025.
-- ============================================================

-- 1a) SELECT: available room types at Hotel A for Jul 15-17,
--     with average cost per night adjusted for the season,
--     day of week, and gold customer discount.
--     Standard Single should NOT appear (already occupied).

SELECT
    rt.type_name                                        AS room_type,
    ROUND(
        AVG(rp.Price) * (1 - c.DiscountPercent), 2
    )                                                   AS avg_cost_per_night
FROM ROOM_TYPE rt
JOIN HOTEL h
    ON h.HotelID = rt.HotelID
JOIN ROOM_PRICE rp
    ON rp.RoomTypeID = rt.RoomTypeID
JOIN SEASON s
    ON s.SeasonID = rp.SeasonID
   AND s.HotelID  = rt.HotelID
JOIN CATEGORY c
    ON c.CategoryName = 'gold'
WHERE h.Name = 'The Grand Shenandoah'
  AND s.StartDate <= '2025-07-15'
  AND s.EndDate   >= '2025-07-16'
  AND rp.DayOfTheWeek IN ('Tue', 'Wed')          -- Jul 15=Tue, Jul 16=Wed
  AND rt.RoomTypeID NOT IN (
      SELECT rr.RoomTypeID
      FROM   RESERVED_ROOM rr
      JOIN   RESERVATION   res ON res.ReservationID = rr.ReservationID
      WHERE  res.HotelID        = h.HotelID
        AND  rr.Status          = 'checked_in'
        AND  rr.CheckInDate    <= '2025-07-15'
        AND  rr.CheckOutDate   >= '2025-07-16'
  )
GROUP BY rt.type_name, c.DiscountPercent
ORDER BY rt.type_name;


-- 1b) INSERT: new gold guest
--     (replace placeholder values with actual guest data as needed)
INSERT INTO GUEST (IdType, IdNumber, Address, HomePhone, MobilePhone, Category_name)
VALUES ('passport', 'PA99001122',
        '45 Maple Ave, Harrisonburg, VA 22801',
        '540-555-0011', '540-555-0022',
        'gold')
RETURNING GuestID;   -- note this ID for the next insert


-- 1c) INSERT: reservation + reserved room for the new guest
--     (substitute the GuestID returned above and desired RoomTypeID)
INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status)
SELECT <new_guest_id>,
       h.HotelID,
       NOW(),
       'confirmed'
FROM   HOTEL h
WHERE  h.Name = 'The Grand Shenandoah'
RETURNING ReservationID;

INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status)
SELECT <new_reservation_id>,
       rt.RoomTypeID,
       NULL,
       '2025-07-15',
       '2025-07-17',
       'reserved'
FROM   ROOM_TYPE rt
JOIN   HOTEL h ON h.HotelID = rt.HotelID
WHERE  h.Name        = 'The Grand Shenandoah'
  AND  rt.type_name  = 'Double';   -- pick an available type from 1a result


-- ============================================================
-- QUERY SET 2: Checking In
-- Mr. and Mrs. Smith arrive at Hotel B (Blue Ridge Inn).
-- Mrs. Smith already has a reservation for a Double room.
-- ============================================================

-- 2a) SELECT: all Double room numbers at Hotel B currently unoccupied
--     (at least one Double should already be checked_in and excluded)

SELECT r.room_number,
       r.RoomID
FROM   ROOM r
JOIN   ROOM_TYPE rt ON rt.RoomTypeID = r.RoomTypeID
JOIN   HOTEL h      ON h.HotelID     = r.HotelID
WHERE  h.Name        = 'Blue Ridge Inn'
  AND  rt.type_name  = 'Double'
  AND  r.RoomID NOT IN (
       SELECT rr.RoomID
       FROM   RESERVED_ROOM rr
       WHERE  rr.RoomTypeID  = rt.RoomTypeID
         AND  rr.Status       = 'checked_in'
         AND  rr.CheckInDate <= '2025-07-18'
         AND  rr.CheckOutDate > '2025-07-18'
         AND  rr.RoomID IS NOT NULL
  )
ORDER BY r.room_number;


-- 2b) INSERT: assign the room and update reservation status
--     (the loader already does this; shown here for demonstration)

-- Assign a specific available room to Mrs. Smith's reserved room row
UPDATE RESERVED_ROOM
SET    RoomID = (
           SELECT r.RoomID
           FROM   ROOM r
           JOIN   ROOM_TYPE rt ON rt.RoomTypeID = r.RoomTypeID
           JOIN   HOTEL h      ON h.HotelID     = r.HotelID
           WHERE  h.Name       = 'Blue Ridge Inn'
             AND  rt.type_name = 'Double'
             AND  r.RoomID NOT IN (
                      SELECT rr.RoomID
                      FROM   RESERVED_ROOM rr
                      WHERE  rr.Status = 'checked_in'
                        AND  rr.RoomID IS NOT NULL
                  )
           LIMIT 1
       ),
       Status = 'checked_in'
WHERE  ReservedRoomID = (
           SELECT rr.ReservedRoomID
           FROM   RESERVED_ROOM rr
           JOIN   RESERVATION   res ON res.ReservationID = rr.ReservationID
           JOIN   GUEST g            ON g.GuestID        = res.GuestID
           JOIN   HOTEL h            ON h.HotelID        = res.HotelID
           WHERE  h.Name    = 'Blue Ridge Inn'
             AND  rr.Status = 'reserved'
             AND  rr.CheckInDate = '2025-07-18'
           LIMIT 1
       );

-- Add Mr. Smith as a new guest (not previously in the database)
INSERT INTO GUEST (IdType, IdNumber, Address, HomePhone, MobilePhone, Category_name)
VALUES ('drivers_license', 'DL55500000',
        '88 Elm Street, Harrisonburg, VA 22801',
        NULL, NULL, NULL)
RETURNING GuestID;

-- Add both occupants to the reserved room
INSERT INTO OCCUPANTS (ReservedRoomID, Name, GuestID)
SELECT rr.ReservedRoomID,
       g.IdNumber,          -- placeholder; swap for actual name display
       g.GuestID
FROM   RESERVED_ROOM rr
JOIN   RESERVATION   res ON res.ReservationID = rr.ReservationID
JOIN   HOTEL h            ON h.HotelID        = res.HotelID
JOIN   GUEST g            ON g.GuestID        = res.GuestID
WHERE  h.Name      = 'Blue Ridge Inn'
  AND  rr.Status   = 'checked_in'
  AND  rr.CheckInDate = '2025-07-18'
LIMIT 1;


-- ============================================================
-- QUERY SET 3: Checking Out
-- Two nights have passed; Mr. and Mrs. Smith check out.
-- ============================================================

-- 3a) INSERT: add a room-service charge to Mrs. Smith's bill
INSERT INTO Services (BillID, GuestID, ServiceTypeID, Quantity, DateTime, Price)
SELECT b.BillID,
       res.GuestID,
       st.ServiceTypeID,
       1,
       '2025-07-19 21:00:00',
       32.00
FROM   BILL b
JOIN   RESERVED_ROOM rr  ON rr.ReservedRoomID = b.ReservedRoomID
JOIN   RESERVATION   res ON res.ReservationID  = rr.ReservationID
JOIN   HOTEL h           ON h.HotelID          = res.HotelID
JOIN   SERVICE_TYPE  st  ON st.ServiceTypeName  = 'Room Service'
WHERE  h.Name          = 'Blue Ridge Inn'
  AND  rr.CheckInDate  = '2025-07-18';


-- 3b) SELECT: billing statement for Mrs. Smith
--     Shows date range, room type, extra services, and total.
--     Nightly room prices will differ (Fri vs Sat rates).

SELECT
    rr.CheckInDate,
    rr.CheckOutDate,
    rt.type_name                                AS room_type,
    rp_fri.Price                                AS night1_price_fri,
    rp_sat.Price                                AS night2_price_sat,
    ROUND((rp_fri.Price + rp_sat.Price)
          * (1 - cat.DiscountPercent), 2)       AS room_subtotal_after_discount,
    COALESCE(SUM(svc.Price), 0)                 AS services_total,
    ROUND((rp_fri.Price + rp_sat.Price)
          * (1 - cat.DiscountPercent)
          + COALESCE(SUM(svc.Price), 0), 2)     AS grand_total
FROM   RESERVED_ROOM rr
JOIN   RESERVATION   res ON res.ReservationID = rr.ReservationID
JOIN   HOTEL h           ON h.HotelID         = res.HotelID
JOIN   GUEST g           ON g.GuestID         = res.GuestID
JOIN   CATEGORY cat      ON cat.CategoryName  = g.Category_name
JOIN   ROOM_TYPE rt      ON rt.RoomTypeID     = rr.RoomTypeID
JOIN   SEASON s          ON s.HotelID         = h.HotelID
                        AND s.StartDate       <= rr.CheckInDate
                        AND s.EndDate         >= rr.CheckOutDate
JOIN   ROOM_PRICE rp_fri ON rp_fri.RoomTypeID   = rr.RoomTypeID
                        AND rp_fri.SeasonID      = s.SeasonID
                        AND rp_fri.DayOfTheWeek  = 'Fri'
JOIN   ROOM_PRICE rp_sat ON rp_sat.RoomTypeID   = rr.RoomTypeID
                        AND rp_sat.SeasonID      = s.SeasonID
                        AND rp_sat.DayOfTheWeek  = 'Sat'
LEFT JOIN BILL b         ON b.ReservedRoomID  = rr.ReservedRoomID
LEFT JOIN Services svc   ON svc.BillID        = b.BillID
WHERE  h.Name          = 'Blue Ridge Inn'
  AND  rr.CheckInDate  = '2025-07-18'
GROUP BY rr.CheckInDate, rr.CheckOutDate, rt.type_name,
         rp_fri.Price, rp_sat.Price, cat.DiscountPercent;


-- 3c) UPDATE: check out the Smiths
UPDATE RESERVED_ROOM
SET    Status = 'checked_out'
WHERE  ReservedRoomID IN (
    SELECT rr.ReservedRoomID
    FROM   RESERVED_ROOM rr
    JOIN   RESERVATION   res ON res.ReservationID = rr.ReservationID
    JOIN   HOTEL h           ON h.HotelID         = res.HotelID
    WHERE  h.Name         = 'Blue Ridge Inn'
      AND  rr.CheckInDate = '2025-07-18'
);

UPDATE RESERVATION
SET    Status = 'checked_out'
WHERE  ReservationID IN (
    SELECT res.ReservationID
    FROM   RESERVATION res
    JOIN   HOTEL h ON h.HotelID = res.HotelID
    WHERE  h.Name = 'Blue Ridge Inn'
      AND  res.Status = 'active'
      AND  res.GuestID IN (
               SELECT g.GuestID FROM GUEST g
               JOIN   RESERVED_ROOM rr  ON TRUE
               JOIN   RESERVATION   r2  ON r2.ReservationID = rr.ReservationID
               WHERE  r2.GuestID = g.GuestID
                 AND  rr.CheckInDate = '2025-07-18'
           )
);


-- ============================================================
-- QUERY SET 4: Find the Occupants
-- For a specific room on a specific date,
-- return the reserver and all occupants.
-- ============================================================

SELECT
    g_reserver.IdNumber                         AS reserver_id,
    res.GuestID                                 AS reserver_guest_id,
    o.Name                                      AS occupant_name,
    o.GuestID                                   AS occupant_guest_id,
    r.room_number,
    rr.CheckInDate
FROM   RESERVED_ROOM rr
JOIN   RESERVATION   res ON res.ReservationID = rr.ReservationID
JOIN   GUEST g_reserver  ON g_reserver.GuestID = res.GuestID
JOIN   ROOM r            ON r.RoomID          = rr.RoomID
JOIN   HOTEL h           ON h.HotelID         = res.HotelID
JOIN   OCCUPANTS o       ON o.ReservedRoomID  = rr.ReservedRoomID
WHERE  h.Name          = 'Blue Ridge Inn'
  AND  r.room_number   = (
           SELECT rm.room_number
           FROM   ROOM rm
           WHERE  rm.RoomID = (
                      SELECT rr2.RoomID
                      FROM   RESERVED_ROOM rr2
                      JOIN   RESERVATION   r2 ON r2.ReservationID = rr2.ReservationID
                      JOIN   HOTEL         h2 ON h2.HotelID       = r2.HotelID
                      WHERE  h2.Name          = 'Blue Ridge Inn'
                        AND  rr2.CheckInDate  = '2025-07-18'
                        AND  rr2.RoomID IS NOT NULL
                      LIMIT 1
                  )
       )
  AND  rr.CheckInDate  = '2025-07-18';


-- ============================================================
-- QUERY SET 5: Total Spending Over a Year
-- Find total amount spent by a guest who stayed at
-- 2+ different hotels in the chain during 2025.
-- ============================================================

SELECT
    g.IdNumber                                  AS guest_identifier,
    g.Category_name,
    COUNT(DISTINCT h.HotelID)                   AS hotels_visited,
    COUNT(DISTINCT res.ReservationID)           AS total_reservations,
    SUM(b.TotalAmount)                          AS total_spent_2025
FROM   GUEST g
JOIN   RESERVATION   res ON res.GuestID = g.GuestID
JOIN   HOTEL h           ON h.HotelID   = res.HotelID
JOIN   RESERVED_ROOM rr  ON rr.ReservationID = res.ReservationID
JOIN   BILL b            ON b.ReservedRoomID = rr.ReservedRoomID
WHERE  rr.CheckInDate  >= '2025-01-01'
  AND  rr.CheckInDate  <  '2026-01-01'
GROUP BY g.GuestID, g.IdNumber, g.Category_name
HAVING COUNT(DISTINCT h.HotelID) >= 2;
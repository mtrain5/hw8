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

-- 1b) run after above
WITH new_guest AS (
    INSERT INTO GUEST (IdType, IdNumber, Address, HomePhone, MobilePhone, Category_name)
    VALUES ('passport', 'PA99001122',
            '45 Maple Ave, Harrisonburg, VA 22801',
            '540-555-0011', '540-555-0022',
            'gold')
    RETURNING GuestID
),
new_reservation AS (
    INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status)
    SELECT g.GuestID,
           h.HotelID,
           NOW(),
           'confirmed'
    FROM new_guest g, HOTEL h
    WHERE h.Name = 'The Grand Shenandoah'
    RETURNING ReservationID
)
INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status)
SELECT r.ReservationID,
       rt.RoomTypeID,
       NULL,
       '2025-07-15',
       '2025-07-17',
       'reserved'
FROM new_reservation r,
     ROOM_TYPE rt
JOIN HOTEL h ON h.HotelID = rt.HotelID
WHERE h.Name       = 'The Grand Shenandoah'
  AND rt.type_name = 'Double';

  -- 1c) explitgiclty show stuff
  SELECT
    rt.type_name,
    rp.DayOfTheWeek,
    rp.Price,
    ROUND(rp.Price * (1 - c.DiscountPercent), 2) AS discounted_price
FROM ROOM_TYPE rt
JOIN HOTEL h ON h.HotelID = rt.HotelID
JOIN ROOM_PRICE rp ON rp.RoomTypeID = rt.RoomTypeID
JOIN SEASON s ON s.SeasonID = rp.SeasonID AND s.HotelID = rt.HotelID
JOIN CATEGORY c ON c.CategoryName = 'gold'
WHERE h.Name = 'The Grand Shenandoah'
  AND s.StartDate <= '2025-07-15'
  AND s.EndDate >= '2025-07-16'
  AND rp.DayOfTheWeek IN ('Tue', 'Wed')
ORDER BY rt.type_name, rp.DayOfTheWeek;
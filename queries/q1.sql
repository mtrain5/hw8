-- ============================================================
-- QUERY 1: Reservations
-- ============================================================

-- 1a) SELECT: available room types with season- and day-adjusted
--     average cost per night, after gold discount.
--     Filters to the correct season covering Jul 15-16 and only
--     pulls prices for Tue and Wed (the two nights of the stay).

SELECT
    rt.type_name                                              AS room_type,
    ROUND(AVG(rp.Price) * (1 - c.DiscountPercent), 2)        AS avg_cost_per_night
FROM   ROOM_TYPE rt
JOIN   HOTEL h       ON h.HotelID     = rt.HotelID
JOIN   SEASON s      ON s.HotelID     = rt.HotelID
JOIN   ROOM_PRICE rp ON rp.RoomTypeID = rt.RoomTypeID
                    AND rp.SeasonID   = s.SeasonID
JOIN   CATEGORY c    ON c.CategoryName = 'gold'
WHERE  h.Name              = 'The Grand Shenandoah'
  AND  s.StartDate        <= '2025-07-15'
  AND  s.EndDate          >= '2025-07-16'
  AND  rp.DayOfTheWeek    IN ('Tue', 'Wed')   -- Jul 15=Tue, Jul 16=Wed
  AND  rt.RoomTypeID NOT IN (
           SELECT rr.RoomTypeID
           FROM   RESERVED_ROOM rr
           JOIN   RESERVATION res ON res.ReservationID = rr.ReservationID
           WHERE  res.HotelID      = h.HotelID
             AND  rr.Status        = 'checked_in'
             AND  rr.CheckInDate  <= '2025-07-15'
             AND  rr.CheckOutDate >= '2025-07-16'
       )
GROUP BY rt.type_name, c.DiscountPercent
ORDER BY rt.type_name;


-- 1b) INSERT: add the new gold guest to the database.
--     This guest did not previously exist. IdNumber PA99001122
--     is used to look them up in the subsequent inserts.

INSERT INTO GUEST (IdType, IdNumber, Address, HomePhone, MobilePhone, Category_name)
VALUES ('passport', 'PA99001122',
        '45 Maple Ave, Harrisonburg, VA 22801',
        '540-555-0011', '540-555-0022',
        'gold');


-- 1c) INSERT: create a reservation for the new guest at Hotel A.
--     Uses a subquery to find the GuestID by IdNumber so no
--     hardcoded ID is needed.

INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status)
SELECT g.GuestID,
       h.HotelID,
       NOW(),
       'confirmed'
FROM   GUEST g
JOIN   HOTEL h ON h.Name = 'The Grand Shenandoah'
WHERE  g.IdNumber = 'PA99001122';


-- 1d) INSERT: reserve a Double room for Jul 15-17.
--     Double was chosen because it appeared as available in 1a.
--     RoomID is NULL at booking time — a specific room is only
--     assigned at check-in.

INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status)
SELECT res.ReservationID,
       rt.RoomTypeID,
       NULL,
       '2025-07-15',
       '2025-07-17',
       'reserved'
FROM   RESERVATION res
JOIN   GUEST g      ON g.GuestID  = res.GuestID
JOIN   HOTEL h      ON h.HotelID  = res.HotelID
JOIN   ROOM_TYPE rt ON rt.HotelID = h.HotelID
WHERE  g.IdNumber   = 'PA99001122'
  AND  h.Name       = 'The Grand Shenandoah'
  AND  rt.type_name = 'Double';

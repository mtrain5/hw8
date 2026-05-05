
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

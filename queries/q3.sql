-- ============================================================
-- QUERY SET 3: Checking Out
-- ============================================================

-- 3a) INSERT: add a room service charge to Mrs. Smith's bill.
--     This demonstrates adding an extra service to an existing bill.

INSERT INTO SERVICES (BillID, GuestID, ServiceTypeID, Quantity, DateTime, Price)
SELECT b.BillID,
       res.GuestID,
       st.ServiceTypeID,
       1,
       '2025-07-19 21:00:00',
       32.00
FROM   BILL b
JOIN   RESERVED_ROOM rr ON rr.ReservedRoomID = b.ReservedRoomID
JOIN   RESERVATION res  ON res.ReservationID  = rr.ReservationID
JOIN   HOTEL h          ON h.HotelID          = res.HotelID
JOIN   SERVICE_TYPE st  ON st.ServiceTypeName  = 'Room Service'
WHERE  h.Name          = 'Blue Ridge Inn'
  AND  rr.CheckInDate  = '2025-07-18';


-- 3b) SELECT: billing statement for Mrs. Smith.
--     Joins through SEASON to get the correct seasonal prices,
--     then explicitly fetches the Fri and Sat ROOM_PRICE entries
--     to show the nightly rate variation. Applies the gold
--     category discount to the room subtotal. Sums all service
--     charges from SERVICES via the BILL.

SELECT
    rr.CheckInDate,
    rr.CheckOutDate,
    rt.type_name                                         AS room_type,
    s.Name                                               AS season,
    rp_fri.Price                                         AS fri_night_rate,
    rp_sat.Price                                         AS sat_night_rate,
    ROUND((rp_fri.Price + rp_sat.Price)
          * (1 - cat.DiscountPercent), 2)                AS room_subtotal,
    COALESCE(SUM(svc.Price), 0)                          AS services_total,
    ROUND((rp_fri.Price + rp_sat.Price)
          * (1 - cat.DiscountPercent)
          + COALESCE(SUM(svc.Price), 0), 2)              AS grand_total
FROM   RESERVED_ROOM rr
JOIN   RESERVATION res   ON res.ReservationID  = rr.ReservationID
JOIN   HOTEL h           ON h.HotelID          = res.HotelID
JOIN   GUEST g           ON g.GuestID          = res.GuestID
JOIN   CATEGORY cat      ON cat.CategoryName   = g.Category_name
JOIN   ROOM_TYPE rt      ON rt.RoomTypeID      = rr.RoomTypeID
JOIN   SEASON s          ON s.HotelID          = h.HotelID
                        AND s.StartDate        <= rr.CheckInDate
                        AND s.EndDate          >= rr.CheckOutDate
JOIN   ROOM_PRICE rp_fri ON rp_fri.RoomTypeID   = rr.RoomTypeID
                        AND rp_fri.SeasonID      = s.SeasonID
                        AND rp_fri.DayOfTheWeek  = 'Fri'
JOIN   ROOM_PRICE rp_sat ON rp_sat.RoomTypeID   = rr.RoomTypeID
                        AND rp_sat.SeasonID      = s.SeasonID
                        AND rp_sat.DayOfTheWeek  = 'Sat'
LEFT JOIN BILL b         ON b.ReservedRoomID   = rr.ReservedRoomID
LEFT JOIN SERVICES svc   ON svc.BillID         = b.BillID
WHERE  h.Name           = 'Blue Ridge Inn'
  AND  rr.CheckInDate   = '2025-07-18'
GROUP BY rr.CheckInDate, rr.CheckOutDate, rt.type_name, s.Name,
         rp_fri.Price, rp_sat.Price, cat.DiscountPercent;


-- 3c) UPDATE: mark the reserved room as checked_out.

UPDATE RESERVED_ROOM
SET    Status = 'checked_out'
WHERE  ReservedRoomID IN (
    SELECT rr.ReservedRoomID
    FROM   RESERVED_ROOM rr
    JOIN   RESERVATION res ON res.ReservationID = rr.ReservationID
    JOIN   HOTEL h         ON h.HotelID         = res.HotelID
    WHERE  h.Name         = 'Blue Ridge Inn'
      AND  rr.CheckInDate = '2025-07-18'
);


-- 3d) UPDATE: mark the reservation itself as checked_out.

UPDATE RESERVATION
SET    Status = 'checked_out'
WHERE  ReservationID IN (
    SELECT res.ReservationID
    FROM   RESERVATION res
    JOIN   HOTEL h ON h.HotelID = res.HotelID
    WHERE  h.Name     = 'Blue Ridge Inn'
      AND  res.Status = 'active'
      AND  res.GuestID IN (
               SELECT res2.GuestID
               FROM   RESERVATION res2
               JOIN   RESERVED_ROOM rr ON rr.ReservationID = res2.ReservationID
               JOIN   HOTEL h2         ON h2.HotelID        = res2.HotelID
               WHERE  h2.Name        = 'Blue Ridge Inn'
                 AND  rr.CheckInDate = '2025-07-18'
           )
);


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
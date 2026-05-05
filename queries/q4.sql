-- ============================================================
-- QUERY SET 4: Find the Occupants
-- ============================================================

SELECT
    g_res.IdNumber      AS reserver_id_number,
    o.Name              AS occupant_name,
    o.GuestID           AS occupant_guest_id,
    r.room_number,
    rr.CheckInDate
FROM   RESERVED_ROOM rr
JOIN   RESERVATION res ON res.ReservationID = rr.ReservationID
JOIN   GUEST g_res     ON g_res.GuestID     = res.GuestID
JOIN   ROOM r          ON r.RoomID          = rr.RoomID
JOIN   HOTEL h         ON h.HotelID         = res.HotelID
JOIN   OCCUPANTS o     ON o.ReservedRoomID  = rr.ReservedRoomID
WHERE  h.Name         = 'Blue Ridge Inn'
  AND  rr.CheckInDate = '2025-07-18'
  AND  rr.RoomID IS NOT NULL;

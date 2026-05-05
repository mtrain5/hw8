
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

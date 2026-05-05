
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
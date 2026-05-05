-- ============================================================
-- QUERY SET 2: Checking In
-- ============================================================

-- 2a) SELECT: Double rooms at Blue Ridge Inn not currently occupied
--     on Jul 18. Excludes any room where a checked_in reservation
--     overlaps that date.

SELECT r.room_number,
       r.RoomID
FROM   ROOM r
JOIN   ROOM_TYPE rt ON rt.RoomTypeID = r.RoomTypeID
JOIN   HOTEL h      ON h.HotelID     = r.HotelID
WHERE  h.Name       = 'Blue Ridge Inn'
  AND  rt.type_name = 'Double'
  AND  r.RoomID NOT IN (
       SELECT rr.RoomID
       FROM   RESERVED_ROOM rr
       WHERE  rr.RoomTypeID   = rt.RoomTypeID
         AND  rr.Status       = 'checked_in'
         AND  rr.CheckInDate <= '2025-07-18'
         AND  rr.CheckOutDate > '2025-07-18'
         AND  rr.RoomID IS NOT NULL
  )
ORDER BY r.room_number;


-- 2b) INSERT: add Mr. Smith as a new guest.
--     He was not previously in the database. No category assigned
--     since he is not a registered loyalty member.

INSERT INTO GUEST (IdType, IdNumber, Address, HomePhone, MobilePhone, Category_name)
VALUES ('drivers_license', 'DL55500000',
        '88 Elm Street, Harrisonburg, VA 22801',
        NULL, NULL, NULL);


-- 2c) UPDATE: assign an available Double room to Mrs. Smith's
--     reserved room row and set Status to checked_in.
--     The subquery picks the first available Double room at
--     Blue Ridge Inn that is not already checked_in.

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
           JOIN   RESERVATION res ON res.ReservationID = rr.ReservationID
           JOIN   HOTEL h         ON h.HotelID         = res.HotelID
           WHERE  h.Name         = 'Blue Ridge Inn'
             AND  rr.CheckInDate = '2025-07-18'
             AND  rr.Status      = 'reserved'
           LIMIT 1
       );


-- 2d) INSERT: record Mrs. Smith as an occupant of the room.
--     Her GuestID is linked because she is a registered guest.

INSERT INTO OCCUPANTS (ReservedRoomID, Name, GuestID)
SELECT rr.ReservedRoomID,
       g.IdNumber,
       g.GuestID
FROM   RESERVED_ROOM rr
JOIN   RESERVATION res ON res.ReservationID = rr.ReservationID
JOIN   HOTEL h         ON h.HotelID         = res.HotelID
JOIN   GUEST g         ON g.GuestID         = res.GuestID
WHERE  h.Name         = 'Blue Ridge Inn'
  AND  rr.CheckInDate = '2025-07-18'
  AND  rr.Status      = 'checked_in';


-- 2e) INSERT: record Mr. Smith as an occupant.
--     He was just added in 2b. His GuestID is looked up by
--     IdNumber since he has no prior record.

INSERT INTO OCCUPANTS (ReservedRoomID, Name, GuestID)
SELECT rr.ReservedRoomID,
       g.IdNumber,
       g.GuestID
FROM   RESERVED_ROOM rr
JOIN   RESERVATION res ON res.ReservationID = rr.ReservationID
JOIN   HOTEL h         ON h.HotelID         = res.HotelID
JOIN   GUEST g         ON g.IdNumber        = 'DL55500000'
WHERE  h.Name         = 'Blue Ridge Inn'
  AND  rr.CheckInDate = '2025-07-18'
  AND  rr.Status      = 'checked_in';

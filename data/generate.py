"""
HW7 - Hotel Database Data Loader
Run: python load_data.py

Minimum requirements met:
  5 hotels, 2 seasons each, 2 categories (standard/gold),
  2-3 room types per hotel, 3 rooms per type,
  prices every day of week in each season,
  10 registered guests + Mr. Smith inserted at check-in,
  all reservation checklist items satisfied.

Query anchors (do not change):
  Hotel A = hotel_ids[0]  (Grand Shenandoah)  -- Q1: Jul 15-17 2025
  Hotel B = hotel_ids[1]  (Blue Ridge Inn)    -- Q2/Q3/Q4: Jul 18-20 2025
  guest_ids[1] = Mrs. Smith  (gold, Q2/Q3 reserver)
  guest_ids[2] = multi-hotel guest for Q5 (gold, 2 stays in 2025)
"""

import psycopg2
from faker import Faker
import random
from datetime import date

fake = Faker()
fake.seed_instance(42)

conn = psycopg2.connect(
    host="data.cs.jmu.edu",
    port=5433,
    dbname="sp26",
    user="berggrmb",
    password="113944400",
    options="-c search_path=berggrmb"
)
cur = conn.cursor()
print("Connected.")

# ── TRUNCATE ──────────────────────────────────────────────────
cur.execute("""
    TRUNCATE Services, BILL, OCCUPANTS, RESERVED_ROOM, RESERVATION,
             GUEST, ROOM, ROOM_TYPE_FEATURE, ROOM_PRICE, ROOM_TYPE,
             SEASON, HOTEL_FEATURE, HOTEL_PHONE, CATEGORY, HOTEL
    RESTART IDENTITY CASCADE;
""")

# ── CATEGORIES ────────────────────────────────────────────────
cur.execute("INSERT INTO CATEGORY (CategoryName, DiscountPercent) VALUES ('standard', 0.00)")
cur.execute("INSERT INTO CATEGORY (CategoryName, DiscountPercent) VALUES ('gold',     0.15)")

# ── HOTELS ────────────────────────────────────────────────────
hotel_names = [
    "The Grand Shenandoah",
    "Blue Ridge Inn",
    "Skyline Summit Hotel",
    "Piedmont Plaza Hotel",
    "Appalachian Peaks Resort",
]
hotel_ids = []
for name in hotel_names:
    cur.execute(
        "INSERT INTO HOTEL (Name, Address) VALUES (%s, %s) RETURNING HotelID",
        (name, f"{fake.building_number()} {fake.street_name()}, {fake.city()}, VA {fake.zipcode()}")
    )
    hotel_ids.append(cur.fetchone()[0])

hA, hB, hC, hD, hE = hotel_ids

for hid in hotel_ids:
    cur.execute(
        "INSERT INTO HOTEL_PHONE (HotelID, PhoneNumber) VALUES (%s,%s) ON CONFLICT DO NOTHING",
        (hid, fake.phone_number()[:30])
    )
    cur.execute(
        "INSERT INTO HOTEL_FEATURE (HotelID, Name) VALUES (%s,%s)",
        (hid, fake.word().capitalize() + ' Center')
    )

# ── SEASONS (2 per hotel) ─────────────────────────────────────
# Hotel A High Season covers Jul 15-17 (Q1)
# Hotel B Summer Season covers Jul 18-20 (Q3)
season_rows = [
    (hA, 'High Season',     date(2025,  6,  1), date(2025,  8, 31)),
    (hA, 'Low Season',      date(2025,  9,  1), date(2026,  5, 31)),
    (hB, 'Summer Season',   date(2025,  5, 25), date(2025,  9,  1)),
    (hB, 'Off Season',      date(2025,  9,  2), date(2026,  5, 24)),
    (hC, 'Peak Summer',     date(2025,  6, 15), date(2025,  9, 15)),
    (hC, 'Winter',          date(2025,  9, 16), date(2026,  6, 14)),
    (hD, 'Festival Season', date(2025,  7,  1), date(2025, 10, 31)),
    (hD, 'Regular Season',  date(2025, 11,  1), date(2026,  6, 30)),
    (hE, 'Spring/Summer',   date(2025,  4,  1), date(2025, 10, 15)),
    (hE, 'Fall/Winter',     date(2025, 10, 16), date(2026,  3, 31)),
]
season_ids = {}
for (hid, name, sd, ed) in season_rows:
    cur.execute(
        "INSERT INTO SEASON (HotelID, Name, StartDate, EndDate) VALUES (%s,%s,%s,%s) RETURNING SeasonID",
        (hid, name, sd, ed)
    )
    season_ids.setdefault(hid, []).append(cur.fetchone()[0])

# ── HELPERS ───────────────────────────────────────────────────
DAYS    = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
WEEKEND = {'Fri','Sat','Sun'}

def day_abbr(d):
    return DAYS[d.weekday()]

def season_for(hid, d):
    for sid in season_ids[hid]:
        cur.execute("SELECT StartDate, EndDate FROM SEASON WHERE SeasonID=%s", (sid,))
        r = cur.fetchone()
        if r[0] <= d <= r[1]:
            return sid
    return season_ids[hid][0]

def night_price(rtid, sid, d):
    cur.execute(
        "SELECT Price FROM ROOM_PRICE WHERE RoomTypeID=%s AND SeasonID=%s AND DayOfTheWeek=%s",
        (rtid, sid, day_abbr(d))
    )
    r = cur.fetchone()
    return float(r[0]) if r else 100.00

def disc_mult(gid):
    cur.execute("SELECT Category_name FROM GUEST WHERE GuestID=%s", (gid,))
    cat = cur.fetchone()[0]
    if not cat:
        return 1.0
    cur.execute("SELECT DiscountPercent FROM CATEGORY WHERE CategoryName=%s", (cat,))
    return 1.0 - float(cur.fetchone()[0])

# ── ROOM TYPES + PRICES + FEATURES + ROOMS ────────────────────
rt_defs = {
    hA: [('Standard Single', 20.00, 1,  85, 120),
         ('Double',          30.00, 2, 130, 175),
         ('Suite',           55.00, 4, 230, 320)],
    hB: [('Standard Single', 18.00, 1,  75, 110),
         ('Double',          28.00, 2, 120, 165)],
    hC: [('Double',          32.00, 2, 115, 160),
         ('King Deluxe',     45.00, 2, 170, 235)],
    hD: [('Standard Single', 22.00, 1,  90, 125),
         ('Double',          29.00, 2, 140, 195),
         ('Suite',           60.00, 4, 265, 360)],
    hE: [('Cabin Suite',     68.00, 4, 220, 295),
         ('Standard Double', 30.00, 2, 130, 180)],
}

rt_feats = {
    'Standard Single': ['Free Wi-Fi', 'Air Conditioning'],
    'Double':          ['Free Wi-Fi', 'Air Conditioning', 'Mini-Fridge'],
    'Suite':           ['Free Wi-Fi', 'Jacuzzi', 'King Bed', 'Kitchenette'],
    'King Deluxe':     ['Free Wi-Fi', 'Mountain View', 'King Bed'],
    'Cabin Suite':     ['Free Wi-Fi', 'Fireplace', 'Hot Tub'],
    'Standard Double': ['Free Wi-Fi', 'Patio'],
}

rt_ids   = {}   # hotel -> {type_name: rtid}
room_ids = {}   # rtid  -> [rid, rid, rid]

for hid in hotel_ids:
    rt_ids[hid] = {}
    for (tname, size, cap, low, high) in rt_defs[hid]:
        cur.execute(
            "INSERT INTO ROOM_TYPE (HotelID, type_name, size_sq, capacities) VALUES (%s,%s,%s,%s) RETURNING RoomTypeID",
            (hid, tname, size, cap)
        )
        rtid = cur.fetchone()[0]
        rt_ids[hid][tname] = rtid

        for feat in rt_feats.get(tname, ['Free Wi-Fi']):
            cur.execute(
                "INSERT INTO ROOM_TYPE_FEATURE (RoomTypeID, FeatureName) VALUES (%s,%s) ON CONFLICT DO NOTHING",
                (rtid, feat)
            )

        # Each day gets its own multiplier so weekday prices also differ from each other
        day_mult = {d: round(random.uniform(0.87, 0.99), 4) for d in DAYS}
        for sid in season_ids[hid]:
            base = high if sid == season_ids[hid][0] else low
            for day in DAYS:
                if day in WEEKEND:
                    price = round(base * random.uniform(1.20, 1.35), 2)
                else:
                    price = round(base * day_mult[day], 2)
                cur.execute(
                    "INSERT INTO ROOM_PRICE (RoomTypeID, SeasonID, DayOfTheWeek, Price) VALUES (%s,%s,%s,%s)",
                    (rtid, sid, day, price)
                )

        room_ids[rtid] = []
        for r in range(1, 4):
            fl = random.randint(1, 4)
            cur.execute(
                "INSERT INTO ROOM (HotelID, RoomTypeID, room_number, floor) VALUES (%s,%s,%s,%s) RETURNING RoomID",
                (hid, rtid, f"{fl}{r:02d}", fl)
            )
            room_ids[rtid].append(cur.fetchone()[0])

# Type shortcuts
rt_singleA = rt_ids[hA]['Standard Single']
rt_doubleA = rt_ids[hA]['Double']
rt_suiteA  = rt_ids[hA]['Suite']
rt_singleB = rt_ids[hB]['Standard Single']
rt_doubleB = rt_ids[hB]['Double']
rt_doubleC = rt_ids[hC]['Double']
rt_kingC   = rt_ids[hC]['King Deluxe']
rt_doubleD = rt_ids[hD]['Double']
rt_suiteD  = rt_ids[hD]['Suite']
rt_cabinE  = rt_ids[hE]['Cabin Suite']

# ── SERVICE TYPES ─────────────────────────────────────────────
svc_names = ['Room Service', 'Spa Treatment', 'Parking', 'Minibar', 'Laundry']
svc_ids   = []
for name in svc_names:
    cur.execute("INSERT INTO SERVICE_TYPE (ServiceTypeName) VALUES (%s) RETURNING ServiceTypeID", (name,))
    svc_ids.append(cur.fetchone()[0])
SVC_ROOM, SVC_SPA, SVC_PARK, SVC_BAR, SVC_LAUNDRY = svc_ids

# ── GUESTS (10 registered) ────────────────────────────────────
# All personal data from Faker. Slots 0-2 are gold (query-critical),
# slot 3 is gold, slots 4-9 are standard.
categories = ['gold','gold','gold','gold',
              'standard','standard','standard','standard','standard','standard']
guest_ids = []
for cat in categories:
    cur.execute("""
        INSERT INTO GUEST (IdType, IdNumber, Address, HomePhone, MobilePhone, Category_name)
        VALUES (%s,%s,%s,%s,%s,%s) RETURNING GuestID
    """, (
        random.choice(['passport','drivers_license']),
        fake.bothify('??########').upper(),
        fake.address().replace('\n',', ')[:255],
        fake.phone_number()[:30],
        fake.phone_number()[:30],
        cat,
    ))
    guest_ids.append(cur.fetchone()[0])

# ── RESERVATIONS ──────────────────────────────────────────────

# ── Q1 blocker: Standard Single at Hotel A checked_in Jul 15-17 ──
cur.execute(
    "INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES (%s,%s,%s,%s) RETURNING ReservationID",
    (guest_ids[4], hA, '2025-07-10 10:00:00', 'active')
)
res_block = cur.fetchone()[0]
cur.execute(
    "INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES (%s,%s,%s,%s,%s,%s) RETURNING ReservedRoomID",
    (res_block, rt_singleA, room_ids[rt_singleA][0], date(2025,7,15), date(2025,7,17), 'checked_in')
)
rr_block = cur.fetchone()[0]
cur.execute("INSERT INTO OCCUPANTS (ReservedRoomID, Name, GuestID) VALUES (%s,%s,%s)",
            (rr_block, fake.name(), guest_ids[4]))

# ── Q2 blocker: one Double at Hotel B already checked_in on Jul 18 ──
cur.execute(
    "INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES (%s,%s,%s,%s) RETURNING ReservationID",
    (guest_ids[5], hB, '2025-07-12 11:00:00', 'active')
)
res_occ = cur.fetchone()[0]
cur.execute(
    "INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES (%s,%s,%s,%s,%s,%s) RETURNING ReservedRoomID",
    (res_occ, rt_doubleB, room_ids[rt_doubleB][0], date(2025,7,18), date(2025,7,21), 'checked_in')
)
rr_occ = cur.fetchone()[0]
cur.execute("INSERT INTO OCCUPANTS (ReservedRoomID, Name, GuestID) VALUES (%s,%s,%s)",
            (rr_occ, fake.name(), guest_ids[5]))

# ── Q2/Q3/Q4: Mrs. Smith (guest 1) — Double at Hotel B, Jul 18-20 ──
# Jul 18=Fri, Jul 19=Sat → weekend rates differ, satisfying Q3 price variation.
# Starts reserved; updated to checked_in then checked_out below.
smith_room = room_ids[rt_doubleB][1]   # room[0] already occupied

cur.execute(
    "INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES (%s,%s,%s,%s) RETURNING ReservationID",
    (guest_ids[1], hB, '2025-07-10 09:00:00', 'active')
)
res_smith = cur.fetchone()[0]
cur.execute(
    "INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES (%s,%s,%s,%s,%s,%s) RETURNING ReservedRoomID",
    (res_smith, rt_doubleB, smith_room, date(2025,7,18), date(2025,7,20), 'reserved')
)
rr_smith = cur.fetchone()[0]

# Q2: insert Mr. Smith as a new guest (not previously in the DB)
cur.execute("""
    INSERT INTO GUEST (IdType, IdNumber, Address, HomePhone, MobilePhone, Category_name)
    VALUES (%s,%s,%s,%s,%s,%s) RETURNING GuestID
""", ('drivers_license', fake.bothify('DL########').upper(),
      fake.address().replace('\n',', ')[:255],
      fake.phone_number()[:30], fake.phone_number()[:30], None))
mr_smith_id = cur.fetchone()[0]

cur.execute("UPDATE RESERVED_ROOM SET Status='checked_in' WHERE ReservedRoomID=%s", (rr_smith,))

# Q4: both occupants so query returns reserver + at least 1 occupant
cur.execute("INSERT INTO OCCUPANTS (ReservedRoomID, Name, GuestID) VALUES (%s,%s,%s)",
            (rr_smith, fake.name(), guest_ids[1]))
cur.execute("INSERT INTO OCCUPANTS (ReservedRoomID, Name, GuestID) VALUES (%s,%s,%s)",
            (rr_smith, fake.name(), mr_smith_id))

# Q3: generate bill, add service charge, check out
d_smith = disc_mult(guest_ids[1])
sid_smith = season_for(hB, date(2025,7,18))
p_fri = night_price(rt_doubleB, sid_smith, date(2025,7,18))
p_sat = night_price(rt_doubleB, sid_smith, date(2025,7,19))
room_total  = round((p_fri + p_sat) * d_smith, 2)
svc_charge  = 32.00

cur.execute(
    "INSERT INTO BILL (ReservedRoomID, Information, TotalAmount, DateGenerated, Status) VALUES (%s,%s,%s,%s,%s) RETURNING BillID",
    (rr_smith,
     f'Double: Fri ${p_fri:.2f}, Sat ${p_sat:.2f}. Gold 15% discount. Room: ${room_total:.2f}. Room service: ${svc_charge:.2f}.',
     round(room_total + svc_charge, 2), date(2025,7,20), 'paid')
)
bill_smith = cur.fetchone()[0]
cur.execute(
    "INSERT INTO Services (BillID, GuestID, ServiceTypeID, Quantity, DateTime, Price) VALUES (%s,%s,%s,%s,%s,%s)",
    (bill_smith, guest_ids[1], SVC_ROOM, 1, '2025-07-18 20:00:00', svc_charge)
)
cur.execute("UPDATE RESERVED_ROOM SET Status='checked_out' WHERE ReservedRoomID=%s", (rr_smith,))
cur.execute("UPDATE RESERVATION    SET Status='checked_out' WHERE ReservationID=%s",  (res_smith,))

# ── Q5: guest 2 — two stays at two different hotels in 2025 ──

# Stay A: Hotel A, Aug 5-7 (within High Season, multi-day)
d_g2 = disc_mult(guest_ids[2])
cur.execute(
    "INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES (%s,%s,%s,%s) RETURNING ReservationID",
    (guest_ids[2], hA, '2025-08-01 09:00:00', 'checked_out')
)
res_g2A = cur.fetchone()[0]
cur.execute(
    "INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES (%s,%s,%s,%s,%s,%s) RETURNING ReservedRoomID",
    (res_g2A, rt_doubleA, room_ids[rt_doubleA][0], date(2025,8,5), date(2025,8,7), 'checked_out')
)
rr_g2A = cur.fetchone()[0]
cur.execute("INSERT INTO OCCUPANTS (ReservedRoomID, Name, GuestID) VALUES (%s,%s,%s)",
            (rr_g2A, fake.name(), guest_ids[2]))
sid_g2A   = season_for(hA, date(2025,8,5))
total_g2A = round((night_price(rt_doubleA, sid_g2A, date(2025,8,5)) +
                   night_price(rt_doubleA, sid_g2A, date(2025,8,6))) * d_g2, 2)
cur.execute(
    "INSERT INTO BILL (ReservedRoomID, Information, TotalAmount, DateGenerated, Status) VALUES (%s,%s,%s,%s,%s) RETURNING BillID",
    (rr_g2A, 'Double 2 nights. Gold discount.', total_g2A, date(2025,8,7), 'paid')
)
bill_g2A = cur.fetchone()[0]
cur.execute("INSERT INTO Services (BillID, GuestID, ServiceTypeID, Quantity, DateTime, Price) VALUES (%s,%s,%s,%s,%s,%s)",
            (bill_g2A, guest_ids[2], SVC_PARK, 2, '2025-08-05 15:00:00', 18.00))
cur.execute("UPDATE BILL SET TotalAmount = TotalAmount + 18.00 WHERE BillID=%s", (bill_g2A,))

# Stay B: Hotel B, Sep 5-7 (within Off Season, multi-day)
cur.execute(
    "INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES (%s,%s,%s,%s) RETURNING ReservationID",
    (guest_ids[2], hB, '2025-09-01 10:00:00', 'checked_out')
)
res_g2B = cur.fetchone()[0]
cur.execute(
    "INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES (%s,%s,%s,%s,%s,%s) RETURNING ReservedRoomID",
    (res_g2B, rt_singleB, room_ids[rt_singleB][0], date(2025,9,5), date(2025,9,7), 'checked_out')
)
rr_g2B = cur.fetchone()[0]
cur.execute("INSERT INTO OCCUPANTS (ReservedRoomID, Name, GuestID) VALUES (%s,%s,%s)",
            (rr_g2B, fake.name(), guest_ids[2]))
sid_g2B   = season_for(hB, date(2025,9,5))
total_g2B = round((night_price(rt_singleB, sid_g2B, date(2025,9,5)) +
                   night_price(rt_singleB, sid_g2B, date(2025,9,6))) * d_g2, 2)
cur.execute(
    "INSERT INTO BILL (ReservedRoomID, Information, TotalAmount, DateGenerated, Status) VALUES (%s,%s,%s,%s,%s) RETURNING BillID",
    (rr_g2B, 'Standard Single 2 nights. Gold discount.', total_g2B, date(2025,9,7), 'paid')
)
bill_g2B = cur.fetchone()[0]
cur.execute("INSERT INTO Services (BillID, GuestID, ServiceTypeID, Quantity, DateTime, Price) VALUES (%s,%s,%s,%s,%s,%s)",
            (bill_g2B, guest_ids[2], SVC_BAR, 1, '2025-09-05 21:00:00', 15.00))
cur.execute("UPDATE BILL SET TotalAmount = TotalAmount + 15.00 WHERE BillID=%s", (bill_g2B,))

# ── Multiple-room-type reservation #1: guest 3, Hotel A (completed) ──
cur.execute(
    "INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES (%s,%s,%s,%s) RETURNING ReservationID",
    (guest_ids[3], hA, '2025-09-10 08:00:00', 'checked_out')
)
res_mrt1 = cur.fetchone()[0]
for rtid in [rt_doubleA, rt_suiteA]:
    cur.execute(
        "INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES (%s,%s,%s,%s,%s,%s) RETURNING ReservedRoomID",
        (res_mrt1, rtid, room_ids[rtid][1], date(2025,9,12), date(2025,9,14), 'checked_out')
    )
    rr = cur.fetchone()[0]
    cur.execute("INSERT INTO OCCUPANTS (ReservedRoomID, Name, GuestID) VALUES (%s,%s,%s)",
                (rr, fake.name(), guest_ids[3]))
    sid = season_for(hA, date(2025,9,12))
    total = round((night_price(rtid, sid, date(2025,9,12)) +
                   night_price(rtid, sid, date(2025,9,13))) * disc_mult(guest_ids[3]), 2)
    cur.execute(
        "INSERT INTO BILL (ReservedRoomID, Information, TotalAmount, DateGenerated, Status) VALUES (%s,%s,%s,%s,%s)",
        (rr, '2-night stay. Gold discount.', total, date(2025,9,14), 'paid')
    )

# ── Multiple-room-type reservation #2: guest 6, Hotel D (future) ──
cur.execute(
    "INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES (%s,%s,%s,%s) RETURNING ReservationID",
    (guest_ids[6], hD, '2026-04-20 08:00:00', 'confirmed')
)
res_mrt2 = cur.fetchone()[0]
for rtid in [rt_doubleD, rt_suiteD]:
    cur.execute(
        "INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES (%s,%s,%s,%s,%s,%s)",
        (res_mrt2, rtid, None, date(2026,5,12), date(2026,5,14), 'reserved')
    )

# ── Multiple-rooms-same-type #1: guest 7, Hotel D, 2× Double (future) ──
cur.execute(
    "INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES (%s,%s,%s,%s) RETURNING ReservationID",
    (guest_ids[7], hD, '2026-04-22 10:00:00', 'confirmed')
)
res_mst1 = cur.fetchone()[0]
for _ in range(2):
    cur.execute(
        "INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES (%s,%s,%s,%s,%s,%s)",
        (res_mst1, rt_doubleD, None, date(2026,5,16), date(2026,5,17), 'reserved')
    )

# ── Multiple-rooms-same-type #2: guest 8, Hotel C, 2× Double (future) ──
cur.execute(
    "INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES (%s,%s,%s,%s) RETURNING ReservationID",
    (guest_ids[8], hC, '2026-04-23 14:00:00', 'confirmed')
)
res_mst2 = cur.fetchone()[0]
for _ in range(2):
    cur.execute(
        "INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES (%s,%s,%s,%s,%s,%s)",
        (res_mst2, rt_doubleC, None, date(2026,5,20), date(2026,5,22), 'reserved')
    )

# ── Guest 9: simple future reservation ──
cur.execute(
    "INSERT INTO RESERVATION (GuestID, HotelID, BookingDateTime, Status) VALUES (%s,%s,%s,%s) RETURNING ReservationID",
    (guest_ids[9], hE, '2026-04-25 16:00:00', 'confirmed')
)
res_g9 = cur.fetchone()[0]
cur.execute(
    "INSERT INTO RESERVED_ROOM (ReservationID, RoomTypeID, RoomID, CheckInDate, CheckOutDate, Status) VALUES (%s,%s,%s,%s,%s,%s)",
    (res_g9, rt_cabinE, None, date(2026,5,22), date(2026,5,24), 'reserved')
)

# ── COMMIT ────────────────────────────────────────────────────
conn.commit()
print("Done.")

print("\nRow counts:")
for label, tbl in [
    ("Hotels",         "HOTEL"),
    ("Seasons",        "SEASON"),
    ("Room Types",     "ROOM_TYPE"),
    ("Rooms",          "ROOM"),
    ("Guests",         "GUEST"),
    ("Reservations",   "RESERVATION"),
    ("Reserved Rooms", "RESERVED_ROOM"),
    ("Occupants",      "OCCUPANTS"),
    ("Bills",          "BILL"),
    ("Services",       "Services"),
]:
    cur.execute(f"SELECT COUNT(*) FROM {tbl}")
    print(f"  {label+':':<16} {cur.fetchone()[0]}")

cur.close()
conn.close()

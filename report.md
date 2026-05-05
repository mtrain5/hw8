# CS374 Hotel Database Final Report
*Marcus Tran and Matthew Berggren*

## ER Model
*insert the image here*
![Entity Relational Model](./images/Entity_Relation_HW8.png)
ER model changes from HW 7:
-	changed total_price to “price” for the SERVICE_TYPE table
-	Added a “Status” string to RESERVED_ROOM table
-	Added a “Status” string to BILL table
-	Removed “Category_type” from GUEST table
-	Removed “is_guest” from OCCUPANTS table
-	Renamed date/time to “BookingDateTime” for clarity in RESERVATION
-	Added a “CAN BE A” relation between Room and Reserved_Room
-	Removed Quantity field in Reserved_Room


## Relational Model
*insert the image(s) here*
![Relational Model](./images/Relational_Model_HW8.png)
Relational Model / drop_create_tables.sql changes from HW 7:
-	changed total_price to “price” for the SERVICE_TYPE table
-	Removed “Category_type” from GUEST table
-	Removed isGuest Boolean in OCCUPANTS, replaced with a nullable GuestID reference to the GUEST table
-	Changed ServiceTypeName to not null
-	Changed Services table to all caps “SERVICES” to reflect the naming norms of the database
-	Changed DateTime to BookingDateTime for clarity in RESERVATION
-	Changed type of GuestID FK in OCCUPANT to Int instead of Boolean
-	Change type of DiscountPercent in CATEGORY from Int to decimal(5,2) to reflect percentages and make math easier when calculating the discount in the queries.
-	Added a nullable RoomID FK to RESERVED_ROOM to reference ROOM. This ensures sure you can directly connect and relate the reserved room to the specific room ID number in the database.
-	Removed the Quantity field in RESERVED_ROOM
-	Added a “Status” string to RESERVED_ROOM table so it can have values like “Checked-in” or “unreserved”


## Database creation
*Link the files here*

- Drop tables: [drop.sql](./database/drop.sql)
- Create tables: [create.sql](./database/alter.sql)
- Add constraints to tables: [alter.sql](./database/alter.sql)

*They should be in a subdirectory called database*

*Describe any changes very briefly: for example:*

We changed the scripts to match updated model shown in previous section.

## Data
*Link the files here*

- Add some data from csv files: [load.sql](./data/load.sql)
     - [room.csv](./data/room.csv)
- Add some data from using Python and faker: [generate.py](./data/generate.py)

*They should be in a subdirectory called data*

*Describe any changes very briefly: for example:*

We changed the data to facilitate the queries, as described in the following sections.  We also changed how we loaded the data for X, Y and Z to using insert statements rather than `faker`.

## Queries

### Query 1
*Link the code file(s) here from subdirectory queries*

For example:
- [workshop_leader.py](./queries/workshop_leader.py)

*Describe the queries in detail with screenshots of the data setup and the results*

### Query 2
*Link the code file(s) here from subdirectory queries*

*Describe the queries in detail with screenshots of setup and results*

### Query 3
*Link the code file(s) here from subdirectory queries*

*Describe the queries in detail with screenshots of setup and results*

### Query 4
*Link the code file(s) here from subdirectory queries*

*Describe the queries in detail with screenshots of setup and results*

### Query 5
*Link the code file(s) here from subdirectory queries*

*Describe the queries in detail with screenshots of setup and results*

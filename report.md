# CS374 Hotel Database Final Report
*your names*

## ER Model
*insert the image here*
![conference review EER](./images/ConferenceReviewEER.drawio.png)
*describe any changes since HW7*

## Relational Model
*insert the image(s) here*

- Conference Review System: ![conference review relational model](./images/ConferenceReviewRelational-mysql.png)
- madiSTEM System: ![madistem relational model - Workbench style](./images/madistem-relational.png)
- madiSTEM System (dbdiagram style): ![madistem relational model - dbdiagram style](./images/schema.png)

*Describe any changes since HW7*

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

DROP TABLE IF EXISTS SERVICES CASCADE;
DROP TABLE IF EXISTS SERVICE_TYPE CASCADE;
DROP TABLE IF EXISTS BILL CASCADE;
DROP TABLE IF EXISTS OCCUPANTS CASCADE;
DROP TABLE IF EXISTS RESERVED_ROOM CASCADE;
DROP TABLE IF EXISTS RESERVATION CASCADE;
DROP TABLE IF EXISTS GUEST CASCADE;
DROP TABLE IF EXISTS ROOM CASCADE;
DROP TABLE IF EXISTS ROOM_TYPE_FEATURE CASCADE;
DROP TABLE IF EXISTS ROOM_PRICE CASCADE;
DROP TABLE IF EXISTS ROOM_TYPE CASCADE;
DROP TABLE IF EXISTS SEASON CASCADE;
DROP TABLE IF EXISTS HOTEL_FEATURE CASCADE;
DROP TABLE IF EXISTS CATEGORY CASCADE;
DROP TABLE IF EXISTS HOTEL_PHONE CASCADE;
DROP TABLE IF EXISTS HOTEL CASCADE;

CREATE TABLE HOTEL (
    HotelID SERIAL PRIMARY KEY,
    Name    VARCHAR(100) NOT NULL,
    Address VARCHAR(255) NOT NULL
);

CREATE TABLE HOTEL_PHONE (
    HotelID     INT         NOT NULL,
    PhoneNumber VARCHAR(30) NOT NULL,
    PRIMARY KEY (HotelID, PhoneNumber)
);

CREATE TABLE CATEGORY (
    CategoryName    VARCHAR(100)  PRIMARY KEY NOT NULL,
    DiscountPercent DECIMAL(5,2)  NOT NULL
);

CREATE TABLE HOTEL_FEATURE (
    FeatureID SERIAL PRIMARY KEY,
    HotelID   INT          NOT NULL,
    Name      VARCHAR(100) NOT NULL
);

CREATE TABLE SEASON (
    SeasonID  SERIAL PRIMARY KEY,
    HotelID   INT         NOT NULL,
    Name      VARCHAR(80) NOT NULL,
    StartDate DATE        NOT NULL,
    EndDate   DATE        NOT NULL
);

CREATE TABLE ROOM_TYPE (
    RoomTypeID SERIAL PRIMARY KEY,
    HotelID    INT          NOT NULL,
    type_name  VARCHAR(80)  NOT NULL,
    size_sq    DECIMAL(6,2),
    capacities INT          NOT NULL
);

CREATE TABLE ROOM_PRICE (
    RoomTypeID   INT           NOT NULL,
    SeasonID     INT           NOT NULL,
    DayOfTheWeek VARCHAR(3)    NOT NULL,
    Price        DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (RoomTypeID, SeasonID, DayOfTheWeek)
);

CREATE TABLE ROOM_TYPE_FEATURE (
    RoomTypeID  INT         NOT NULL,
    FeatureName VARCHAR(80) NOT NULL,
    PRIMARY KEY (RoomTypeID, FeatureName)
);

CREATE TABLE ROOM (
    RoomID      SERIAL PRIMARY KEY,
    HotelID     INT         NOT NULL,
    RoomTypeID  INT         NOT NULL,
    room_number VARCHAR(20) NOT NULL,
    floor       INT         NOT NULL
);

CREATE TABLE GUEST (
    GuestID       SERIAL PRIMARY KEY,
    IdType        VARCHAR(50)  NOT NULL,
    IdNumber      VARCHAR(60)  NOT NULL,
    Address       VARCHAR(255),
    HomePhone     VARCHAR(30),
    MobilePhone   VARCHAR(30),
    Category_name VARCHAR(60)
);

CREATE TABLE RESERVATION (
    ReservationID   SERIAL PRIMARY KEY,
    GuestID         INT         NOT NULL,
    HotelID         INT         NOT NULL,
    BookingDateTime TIMESTAMP   NOT NULL,
    Status          VARCHAR(20) NOT NULL
);

CREATE TABLE RESERVED_ROOM (
    ReservedRoomID SERIAL PRIMARY KEY,
    ReservationID  INT         NOT NULL,
    RoomTypeID     INT         NOT NULL,
    RoomID         INT,
    CheckInDate    DATE        NOT NULL,
    CheckOutDate   DATE        NOT NULL,
    Status         VARCHAR(20) NOT NULL
);

CREATE TABLE OCCUPANTS (
    OccupantID     SERIAL PRIMARY KEY,
    ReservedRoomID INT          NOT NULL,
    Name           VARCHAR(150) NOT NULL,
    GuestID        INT
);

CREATE TABLE BILL (
    BillID         SERIAL PRIMARY KEY,
    ReservedRoomID INT           NOT NULL,
    Information    TEXT,
    TotalAmount    DECIMAL(10,2) NOT NULL,
    DateGenerated  DATE          NOT NULL,
    Status         VARCHAR(20)   NOT NULL
);

CREATE TABLE SERVICE_TYPE (
    ServiceTypeID   SERIAL PRIMARY KEY,
    ServiceTypeName VARCHAR(50) NOT NULL
);

CREATE TABLE SERVICES (
    ServiceID     SERIAL PRIMARY KEY,
    BillID        INT           NULL,
    GuestID       INT           NULL,
    ServiceTypeID INT           NOT NULL,
    Quantity      DECIMAL(8,2)  NOT NULL,
    DateTime      TIMESTAMP     NOT NULL,
    Price         DECIMAL(10,2) NOT NULL
);

-- index
CREATE INDEX idx_reservedroom_availability
    ON RESERVED_ROOM (Status, CheckInDate, CheckOutDate, RoomTypeID);

CREATE DATABASE Hotel
GO

USE Hotel
GO

USE Population
GO

DROP DATABASE Hotel
GO

CREATE TABLE Employees(
    employee_ID INT IDENTITY PRIMARY KEY,
    first_name NVARCHAR(20),
    last_name NVARCHAR(50),
    position NVARCHAR(20)
);
GO


CREATE TABLE Customer(

    ID INT IDENTITY PRIMARY KEY,

    first_name NVARCHAR(20),

    last_name NVARCHAR(50),

    email NVARCHAR(50),

    phone_number NVARCHAR(30),

    street_address NVARCHAR(50),

    city NVARCHAR(50),

    postal_code INT,

    country NVARCHAR(50),

    is_contact BIT NOT NULL DEFAULT 0

);
GO

CREATE TABLE creditcard(

    card_type_ID INT PRIMARY KEY,

    card_type NVARCHAR(50),

);
GO

CREATE TABLE Room(
    room_NR INT IDENTITY PRIMARY KEY,
    nr_of_beds INT,
    roomtype NVARCHAR(20),
--RUMSTYP SOM TABELL?
    balcony BIT NOT NULL
--EXTRA SÄNGAR??
);
GO

CREATE TABLE Guest_booking(
    id INT IDENTITY PRIMARY KEY,
    customer_id INT FOREIGN KEY REFERENCES Customer (ID)

)
GO

CREATE TABLE Booking(
    booking_id INT IDENTITY PRIMARY KEY,
    contact_id INT FOREIGN KEY REFERENCES Customer(ID),
    room_id INT FOREIGN KEY REFERENCES Room(room_NR),
    guest_booking_id INT FOREIGN KEY REFERENCES Guest_booking(id),
--- REFERENS TILL TABELL MED BOKANDE GÄSTER

    num_of_night INT,
    check_in_date DATETIME,
    check_out_date DATETIME,
    late_arrival_timer DATETIME,
    --TÄNKT ATT LÖSAS MED EN TRIGGER SOM BERÄKNAR LOG_CHECK_IN - CHECK_IN IF>0
    no_show BIT NOT NULL DEFAULT 0,
    employee_ref INT FOREIGN KEY REFERENCES Employees(employee_ID),
    prepaid BIT NOT NULL DEFAULT 0
);
GO


CREATE TABLE room_bill(
    amount DECIMAL,
    bill_id INT IDENTITY PRIMARY KEY,
    --total_discount NVARCHAR(10),

    payment_booking_id INT FOREIGN KEY REFERENCES Booking (booking_id)
);
GO

CREATE TABLE Rebate(
    rebate_id INT IDENTITY PRIMARY KEY,
    rebate_code NVARCHAR(30),
    rebate_amount INT
);
GO

CREATE TABLE total_booking_bill
(
    id INT IDENTITY PRIMARY KEY,
    room_bill_id INT FOREIGN KEY REFERENCES room_bill(bill_id),
    total_amount DECIMAL,
    rebate_id INT FOREIGN KEY REFERENCES Rebate(rebate_id),
    card_ID INT FOREIGN KEY REFERENCES creditcard(card_type_ID),
    card_number INT
);
GO


CREATE TABLE Messages(
    message_id INT IDENTITY PRIMARY KEY,
    customer_id INT FOREIGN KEY REFERENCES Customer(ID),
    comment NVARCHAR(500),
    employee_ref INT FOREIGN KEY REFERENCES Employees(employee_ID)

)
GO




CREATE TABLE Feedback(
    feedback_id INT IDENTITY PRIMARY KEY,
    comment NVARCHAR(500),
    score INT,
    booking INT FOREIGN KEY REFERENCES Booking(booking_id)

);
GO

CREATE TABLE check_log(
log_id INT IDENTITY PRIMARY KEY,
log_check_in DATETIME,
log_check_out DATETIME
)
GO

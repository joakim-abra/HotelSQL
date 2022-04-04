CREATE DATABASE Hotel
GO

USE Hotel
GO

CREATE TABLE Customer(

    ID INT IDENTITY PRIMARY KEY,

    first_name NVARCHAR(20),

    last_name NVARCHAR(50),

    email NVARCHAR(50),

    phone_number INT,

    is_contact BIT NOT NULL DEFAULT 0

);

CREATE TABLE payment_method(

    payment_ID INT PRIMARY KEY,

    method_name NVARCHAR(50),


);

CREATE TABLE Room(
    room_NR INT IDENTITY PRIMARY KEY,
    nr_of_beds INT,
    roomtype NVARCHAR(20),
--RUMSTYP SOM TABELL?
    balcony BIT NOT NULL
--EXTRA SÄNGAR??
);

CREATE TABLE Booking(
    booking_id INT IDENTITY PRIMARY KEY,
    contact_id INT FOREIGN KEY REFERENCES Customer(ID),
    room_id INT FOREIGN KEY REFERENCES Room(room_NR),
    guest_booking_id INT FOREIGN KEY REFERENCES Guest_booking (guest_booking_id),
--- REFERENS TILL TABELL MED BOKANDE GÄSTER

    num_of_night INT,
    check_in_date DATETIME,
    check_out_date DATETIME,
    late_arrival_timer DATETIME,
    --TÄNKT ATT LÖSAS MED EN TRIGGER SOM BERÄKNAR LOG_CHECK_IN - CHECK_IN IF>0
    no_show BIT NOT NULL DEFAULT 0,

    prepaid BIT NOT NULL DEFAULT 0
);

CREATE TABLE Guest_booking(
    id INT IDENTITY PRIMARY KEY,
    customer_id INT FOREIGN KEY REFERENCES Customer (ID)

)


CREATE TABLE total_booking_bill
(
    id INT IDENTITY PRIMARY KEY,
    room_bill_id INT FOREIGN KEY REFERENCES room_bill(bill_id),
    total_amount DECIMAL,
    rebate_id INT FOREIGN KEY REFERENCES Rebate(rebate_id)
);

CREATE TABLE room_bill(
    amount DECIMAL,
    bill_id INT IDENTITY PRIMARY KEY
    --total_discount NVARCHAR(10),

    payment_booking_id INT FOREIGN KEY REFERENCES Booking (booking_id)
);

CREATE TABLE Rebate(
    rebate_id INT IDENTITY PRIMARY KEY,
    rebate_code NVARCHAR(30),
    rebate_amount INT
);

CREATE TABLE Messages(
    message_id INT IDENTITY PRIMARY KEY,
    booking_customer_id INT FOREIGN KEY REFERENCES booking(contact_id),
    comment NVARCHAR(500),

)

CREATE TABLE Employees(
    employee_ID INT IDENTITY PRIMARY KEY,
    first_name NVARCHAR(20),
    last_name NVARCHAR(50),
    position NVARCHAR(20)
)


CREATE TABLE Feedback(
    feedback_id INT IDENTITY PRIMARY KEY,
    comment NVARCHAR(500),
    score INT (500,1),
    booking INT FOREIGN KEY REFERENCES Booking(booking_id)

);

CREATE TABLE check_log(
log_id INT IDENTITY PRIMARY KEY,
log_check_in DATETIME,
log_check_out DATETIME
)


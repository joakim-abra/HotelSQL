CREATE DATABASE Hotel
GO

USE Hotel
GO

-- USE demoday2;
-- GO

-- DROP DATABASE Hotel
-- GO

--ANSTÄLLDA
CREATE TABLE Employees(
    employee_ID INT IDENTITY PRIMARY KEY,
    first_name NVARCHAR(20),
    last_name NVARCHAR(50),
    position NVARCHAR(20),
    signature NVARCHAR(3) UNIQUE
)
GO

--GÄSTER
CREATE TABLE Customer(
    ID INT IDENTITY PRIMARY KEY,
    first_name NVARCHAR(20),
    last_name NVARCHAR(50),
    email NVARCHAR(50),
    phone_number NVARCHAR(30),
    street_address NVARCHAR(50),
    city NVARCHAR(50),
    postal_code NVARCHAR(20),
    country NVARCHAR(50),
);
GO

--BETALNINGSMETODER
CREATE TABLE payment_methods(
    method_id INT IDENTITY PRIMARY KEY,
    method_name NVARCHAR(20)
);
GO

--RUMSTYPER
CREATE TABLE Room_type(
    room_type_id INT IDENTITY PRIMARY KEY,
    name NVARCHAR(30),
    nr_of_beds INT NOT NULL DEFAULT 1,
    balcony INT NOT NULL DEFAULT 0,
    price DECIMAL NOT NULL,
    description NVARCHAR(300)
);
GO


--RUM
CREATE TABLE Room(
    room_NR INT IDENTITY PRIMARY KEY,
    room_room_type_id INT FOREIGN KEY REFERENCES Room_type(room_type_id),
    floor INT,
    room_price DECIMAL
);
GO

--BOKNINGAR
CREATE TABLE Booking(
    booking_id INT IDENTITY PRIMARY KEY,
    contact_id INT FOREIGN KEY REFERENCES Customer(ID),
--- REFERENS TILL TABELL MED BOKANDE GÄSTER
    num_of_night INT,
    check_in_date DATETIME,
    check_out_date DATETIME,
    late_arrival_timer INT,
    no_show BIT NOT NULL DEFAULT 0,
    employee_ref INT FOREIGN KEY REFERENCES Employees(employee_ID),
    prepaid BIT NOT NULL DEFAULT 0
);
GO

--GÄSTER TILL BOKNING
CREATE TABLE Guest_booking(
    id INT IDENTITY PRIMARY KEY,
    customer_id INT FOREIGN KEY REFERENCES Customer (ID),
    belongs_to_booking_id INT FOREIGN KEY REFERENCES Booking(booking_id),
);
GO

--RUM FÖR BOKNING
CREATE TABLE Rooms_booked(
    booked_rooms_id INT IDENTITY PRIMARY KEY,
    room_id INT FOREIGN KEY REFERENCES Room(room_NR),
    room_belongs_to_booking_id INT FOREIGN KEY REFERENCES Booking(booking_id),
    extra_bed INT NOT NULL DEFAULT 0,
    number_of_guests INT
);
GO

--RABATTER FÖR RUM
CREATE TABLE discount(
    discount_id INT IDENTITY PRIMARY KEY,
    discount_code NVARCHAR(30),
    discount_amount DECIMAL
);
GO

--RUMSRÄKNING
CREATE TABLE room_bill(
    amount DECIMAL,
    bill_id INT IDENTITY PRIMARY KEY,
    room_discount_id INT FOREIGN KEY REFERENCES discount (discount_id),
    booked_room_ID INT FOREIGN KEY REFERENCES rooms_booked(booked_rooms_id)
);
GO


--TOTAL RÄKNING FÖR BOKNING
CREATE TABLE total_booking_bill
(
    id INT IDENTITY PRIMARY KEY,
    total_amount DECIMAL,
    selected_payment_method INT FOREIGN KEY REFERENCES payment_methods(method_id),
    reference_number INT, -- fakturanummer, kreditkortsnummer o.s.v. Null om t.ex. kontantbetalning har valts.
    booking_id_bill INT  FOREIGN KEY REFERENCES Booking(booking_id)
);
GO

--MEDDELANDEN
CREATE TABLE Messages(
    message_id INT IDENTITY PRIMARY KEY,
    comment NVARCHAR(500),
    employee_ref INT FOREIGN KEY REFERENCES Employees(employee_ID),
    date_ DATETIME DEFAULT GETDATE()

);
GO

--RECENSIONER
CREATE TABLE Feedback(
    feedback_id INT IDENTITY PRIMARY KEY,
    reviewer NVARCHAR(50),
    comment NVARCHAR(500),
    score INT
);
GO

--INCHECKNINGAR
CREATE TABLE check_in_log(
log_id INT IDENTITY PRIMARY KEY,
booking_id INT UNIQUE FOREIGN KEY REFERENCES booking(booking_id),
log_check_in DATETIME
);
GO

CREATE DATABASE Hotel
GO

USE Hotel
GO

-- USE demoday2;
-- GO

-- DROP DATABASE Hotel
-- GO


--VIEW ALLA RUM OCH TYP

-- SELECT r.room_NR, rt.name, rt.nr_of_beds, rt.balcony, r.extra_bed FROM Room r
-- INNER JOIN Room_type rt
-- ON r.room_type_id = rt.room_type_id



CREATE TABLE Employees(
    employee_ID INT IDENTITY PRIMARY KEY,
    first_name NVARCHAR(20),
    last_name NVARCHAR(50),
    position NVARCHAR(20),
    signature NVARCHAR(20)
)
GO


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

CREATE TABLE payment_methods(
    method_id INT IDENTITY PRIMARY KEY,
    method_name NVARCHAR(20)
);
GO



-- CREATE TABLE creditcard(

--     card_type_ID INT PRIMARY KEY,

--     card_type NVARCHAR(50),

-- );
-- GO


CREATE TABLE Room_type(
    room_type_id INT IDENTITY PRIMARY KEY,
    name NVARCHAR(30),
    nr_of_beds INT NOT NULL DEFAULT 1,
    balcony INT NOT NULL DEFAULT 0,
    price DECIMAL NOT NULL,
    description NVARCHAR(300)
);
GO



CREATE TABLE Room(
    room_NR INT IDENTITY PRIMARY KEY,
    room_room_type_id INT FOREIGN KEY REFERENCES Room_type(room_type_id),
    floor INT,
    room_price DECIMAL
);
GO

/*
CREATE TABLE Booking(
    booking_id INT IDENTITY PRIMARY KEY,
    contact_id INT FOREIGN KEY REFERENCES Customer(ID),
    --room_id INT FOREIGN KEY REFERENCES Room(room_NR),
    rooms_booked_id INT FOREIGN KEY REFERENCES Rooms_booked(booked_rooms_id), 
    guest_booking_id INT FOREIGN KEY REFERENCES Guest_booking(id),
--- REFERENS TILL TABELL MED BOKANDE GÄSTER
    extra_bed INT NOT NULL DEFAULT 0,
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
*/

CREATE TABLE Booking(
    booking_id INT IDENTITY PRIMARY KEY,
    contact_id INT FOREIGN KEY REFERENCES Customer(ID),
--- REFERENS TILL TABELL MED BOKANDE GÄSTER
    num_of_night INT,
    check_in_date DATETIME,
    check_out_date DATETIME,
    late_arrival_timer INT,
    --TÄNKT ATT LÖSAS MED EN TRIGGER SOM BERÄKNAR LOG_CHECK_IN - CHECK_IN IF>0
    no_show BIT NOT NULL DEFAULT 0,
    employee_ref INT FOREIGN KEY REFERENCES Employees(employee_ID),
    prepaid BIT NOT NULL DEFAULT 0
);
GO

-- CREATE TABLE Guest_booking(
--     id INT IDENTITY PRIMARY KEY,
--     customer_id INT FOREIGN KEY REFERENCES Customer (ID),
--     belongs_to_booking_id INT 
-- );
-- GO

CREATE TABLE Guest_booking(
    id INT IDENTITY PRIMARY KEY,
    customer_id INT FOREIGN KEY REFERENCES Customer (ID),
    belongs_to_booking_id INT FOREIGN KEY REFERENCES Booking(booking_id),
);
GO

-- CREATE TABLE Rooms_booked(
--     booked_rooms_id INT IDENTITY PRIMARY KEY,
--     room_id INT FOREIGN KEY REFERENCES Room(room_NR),
--     room_belongs_to_booking_id INT,
--     number_of_guests INT
-- );
-- GO

CREATE TABLE Rooms_booked(
    booked_rooms_id INT IDENTITY PRIMARY KEY,
    room_id INT FOREIGN KEY REFERENCES Room(room_NR),
    room_belongs_to_booking_id INT FOREIGN KEY REFERENCES Booking(booking_id),
    extra_bed INT NOT NULL DEFAULT 0,
    number_of_guests INT
);
GO

CREATE TABLE discount(
    discount_id INT IDENTITY PRIMARY KEY,
    discount_code NVARCHAR(30),
    discount_amount DECIMAL
);
GO

CREATE TABLE room_bill(
    amount DECIMAL,
    bill_id INT IDENTITY PRIMARY KEY,
    room_discount_id INT FOREIGN KEY REFERENCES discount (discount_id),
    booked_room_ID INT FOREIGN KEY REFERENCES rooms_booked(booked_rooms_id)
);
GO



CREATE TABLE total_booking_bill
(
    id INT IDENTITY PRIMARY KEY,
    total_amount DECIMAL,
    selected_payment_method INT FOREIGN KEY REFERENCES payment_methods(method_id),
    reference_number INT, -- fakturanummer, kreditkortsnummer o.s.v. Null om t.ex. kontantbetalning har valts.
    booking_id_bill INT  FOREIGN KEY REFERENCES Booking(booking_id)
);
GO




CREATE TABLE Messages(
    message_id INT IDENTITY PRIMARY KEY,
    customer_id INT FOREIGN KEY REFERENCES Customer(ID),
    comment NVARCHAR(500),
    employee_ref INT FOREIGN KEY REFERENCES Employees(employee_ID),
    booking_ref INT FOREIGN KEY REFERENCES booking(booking_id),
    date_ DATETIME DEFAULT GETDATE()

);
GO


CREATE TABLE Feedback(
    feedback_id INT IDENTITY PRIMARY KEY,
    reviewer NVARCHAR(50),
    comment NVARCHAR(500),
    score INT
);
GO

CREATE TABLE check_log(
log_id INT IDENTITY PRIMARY KEY,
booking_id INT FOREIGN KEY REFERENCES booking(booking_id),
log_check_in DATETIME,
log_check_out DATETIME
);
GO

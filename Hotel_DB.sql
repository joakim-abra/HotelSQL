CREATE DATABASE Hotel
GO

USE Hotel
GO

CREATE TABLE Customer(

    ID INT IDENTITY PRIMARY KEY,

    first_name NVARCHAR(20),

    last_name NVARCHAR(50),

    email NVARCHAR(50),

    phone_number INT

);

CREATE TABLE payment(

    payment_ID INT PRIMARY KEY,

    payment_method NVARCHAR(50),

    total_amount DECIMAL,

    --total_discount NVARCHAR(10),

    customer_ID INT FOREIGN KEY REFERENCES customer(customer_ID)

);
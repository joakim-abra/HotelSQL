USE Hotel;
GO

-- PROCEDURES

-- Visar användarnas snittbetyg.
CREATE PROCEDURE display_average_rating
AS
DECLARE @average DECIMAL (5,2)
SET @average = CAST((SELECT SUM(score) FROM Feedback) AS decimal)/CAST((SELECT COUNT(score) FROM Feedback) AS decimal)
PRINT 'Hotellets medelbetyg: ' + CAST(@average AS VARCHAR(10));
GO

EXECUTE display_average_rating;
GO



-- TRIGGERS




-- VIEWS

CREATE VIEW owerview_booking AS
SELECT b.check_in_date, b.check_out_date, c.first_name, c.last_name, c.phone_number
FROM Booking AS b
LEFT JOIN Customer AS c
ON b.contact_id = c.ID
GO
-- OBS! EJ FÄRDIGA VIEWS NEDAN

-- Vilken bokning som har vilka gäster.
SELECT b.booking_id,b.contact_id, c.ID AS customer_id, c.first_name, c.last_name FROM Guest_booking gb
INNER JOIN Booking b
ON gb.belongs_to_booking_id = b.booking_id
RIGHT JOIN Customer c 
ON gb.customer_id = c.ID

-- Vilken bokning som har bokat vilka rum och av vem.
SELECT rb.room_id, rb.number_of_guests, b.booking_id, c.ID AS customer_id, c.first_name, c.last_name FROM Rooms_booked rb 
INNER JOIN Booking b 
ON rb.room_belongs_to_booking_id = b.booking_id
INNER JOIN Customer c 
ON b.contact_id = c.ID
GO


SELECT * FROM owerview_booking
GO

CREATE VIEW Clear_rum
AS
SELECT ro.room_NR,r.name, ro.nr_of_beds, b.check_out_date 
FROM Booking AS b 
INNER JOIN Rooms_booked AS r
ON b.room_id = r.booked_rooms_id
INNER JOIN Room AS ro 
ON r.room_id = ro.room_type_id
GO

SELECT * FROM Clear_rum

SELECT b.booking_id, b.num_of_night, tbb.total_amount, d.discount_code, d.discount_amount
FROM Booking AS b
INNER JOIN room_bill AS r
ON b.booking_id = r.payment_booking_id
INNER JOIN total_booking_bill AS tbb
ON r.bill_id = tbb.room_bill_id
INNER JOIN discount AS d 
ON tbb.discount_id = d.discount_id
GO
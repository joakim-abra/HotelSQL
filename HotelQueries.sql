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
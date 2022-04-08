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



CREATE PROCEDURE create_room_bill (@Room_NR INT, @discount_id INT)
AS
DECLARE @amount DECIMAL
DECLARE @booking_id INT = (SELECT rb.booked_rooms_id FROM Rooms_booked rb WHERE @Room_NR = rb.room_id)
SET @amount = (SELECT r.room_price FROM Room r WHERE @Room_NR = r.room_NR)
SET @amount = @amount - (@amount*(SELECT d.discount_amount FROM Discount d WHERE @discount_id = d.discount_id))
INSERT INTO room_bill (amount,room_discount_id,booked_room_ID) VALUES (@amount, @discount_id, @booking_id)
GO

DROP PROCEDURE create_room_bill

EXEC create_room_bill 229,2
EXEC create_room_bill 230,1

TRUNCATE TABLE room_bill

SELECT SUM(amount) FROM room_bill rb
JOIN Rooms_booked roob
ON rb.booked_room_ID = roob.booked_rooms_id
WHERE roob.room_belongs_to_booking_id = 11
GO


CREATE PROCEDURE create_total_bill_(@booking_id INT, @payment_method_id INT, @reference_number INT = NULL)
AS
INSERT INTO total_booking_bill(total_amount,
    selected_payment_method,
    reference_number,
    booking_id_bill) VALUES ((SELECT SUM(amount) FROM room_bill rb
JOIN Rooms_booked roob
ON rb.booked_room_ID = roob.booked_rooms_id
WHERE roob.room_belongs_to_booking_id = @booking_id),@payment_method_id,@reference_number,@booking_id
);

EXEC create_total_bill_ 11,3

SELECT * FROM total_booking_bill

SELECT b.booking_id Bokning, (SELECT c.first_name FROM Customer c WHERE b.contact_id = c.ID) Förnamn, (SELECT c.last_name FROM Customer c WHERE b.contact_id = c.ID) Efternamn, tbb.total_amount Summa, 
(SELECT pm.method_name FROM payment_methods pm WHERE tbb.selected_payment_method = pm.method_id) Betalningsmetod,tbb.reference_number Referensnummer FROM Booking b 
JOIN total_booking_bill tbb ON b.booking_id = tbb.booking_id_bill



SELECT * FROM Rooms_booked
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
WHERE booking_id IS NOT NULL

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


--SE VILKA GÄSTER SOM ÄR BOKADE I VILKA RUM OCH NÄR
SELECT b.booking_id, b.check_in_date, b.check_out_date, c.first_name, c.last_name, r.room_NR,r.[floor],rt.name
FROM Customer c 
JOIN Guest_booking gb ON gb.customer_id = c.ID
JOIN Booking b ON gb.id = b.guest_booking_id
JOIN Rooms_booked rb ON rb.booked_rooms_id = b.rooms_booked_id
JOIN room r ON r.room_NR = rb.room_id
JOIN Room_type rt ON rt.room_type_id = r.room_room_type_id
--WHERE b.check_out_date>GETDATE() --FÖR ATT SE VILKA SOM ÄR AKTIVA 
ORDER BY r.room_NR

SELECT * FROM booking 
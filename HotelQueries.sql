USE Hotel;
GO




-- PROCEDURES

-- Visar användarnas snittbetyg.
CREATE PROCEDURE display_feedback_and_average_rating
AS
DECLARE @counter INT
DECLARE @feedback_id INT, @reviewer NVARCHAR(50), @comment NVARCHAR(500), @score INT 
DECLARE @average DECIMAL (5,2)
SET @counter = 1
SET @average = CAST((SELECT SUM(score) FROM Feedback) AS decimal)/CAST((SELECT COUNT(score) FROM Feedback) AS decimal)
BEGIN
    PRINT 'Hotellets medelbetyg: ' + CAST(@average AS VARCHAR(10))
    PRINT '---------------'
END
WHILE (SELECT COUNT(feedback_id) FROM Feedback) - @counter >= 0
BEGIN
    SET @feedback_id = (SELECT feedback_id FROM Feedback WHERE feedback_id = @counter)
    SET @reviewer = (SELECT reviewer FROM Feedback WHERE feedback_id = @counter)
    SET @comment = (SELECT comment FROM Feedback WHERE feedback_id = @counter)
    SET @score = (SELECT score FROM Feedback WHERE feedback_id = @counter)
    PRINT CAST(@feedback_id AS VARCHAR (10)) + ' * Reviewer: ' + @reviewer + ' * Comment: ' + @comment + ' * Score: ' + CAST(@score AS NVARCHAR(10))
    PRINT '---------------'
    SET @counter = @counter + 1;
END;
GO

EXECUTE display_feedback_and_average_rating;
GO

drop PROCEDURE display_feedback_and_average_rating;
GO

-- Feedback rad 11 saknar reviewer

CREATE PROCEDURE write_review @reviewer NVARCHAR(50), @comment NVARCHAR(500), @score INT 
AS 
BEGIN TRY
    IF (@score < 1 OR @score > 5)
    PRINT 'The score has to be between 1 and 5.'
    ELSE
    INSERT INTO Feedback (reviewer, comment, score) VALUES (@reviewer, @comment, @score)
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
GO

--EXECUTE write_review @reviewer = 'namn', @comment = 'kommentar', @score = betyg 1- 5 som INT;
EXECUTE write_review @reviewer = 'A name', @comment = 'A comment', @score = 5;
GO

DROP PROCEDURE write_review;
GO

-- Tänk på att feedback_id ökar varje gång även om raden tas bort.
DELETE FROM Feedback
WHERE feedback_id = 26;
GO

select * from Feedback



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
CREATE TRIGGER late_arrival
ON check_log
FOR INSERT
AS
BEGIN
    IF ((SELECT log_check_in FROM inserted)-(SELECT check_in_date FROM booking WHERE booking_id = (SELECT i.booking_id FROM inserted i))>0)
        BEGIN
            UPDATE Booking
            SET late_arrival_timer = (DATEDIFF (hour, (SELECT log_check_in FROM inserted),(SELECT check_in_date FROM booking WHERE booking_id = (SELECT i.booking_id FROM inserted i))))
            WHERE booking_id = (SELECT i.booking_id FROM inserted i)
        END
END   
GO     

-- VIEWS

CREATE VIEW Bokings_person_och_rum
AS
SELECT c.first_name, c.last_name, ro.room_NR, b.booking_id
 FROM Customer AS c
INNER JOIN booking AS b
ON b.contact_id = c.ID
INNER JOIN Rooms_booked as r 
ON b.booking_id = r.room_belongs_to_booking_id
INNER JOIN Room AS ro 
ON r.room_id = ro.room_NR
GO

SELECT * FROM Bokings_person_och_rum
GO

CREATE VIEW owerview_booking AS
SELECT b.check_in_date, b.check_out_date, c.first_name, c.last_name, c.phone_number
FROM Booking AS b
LEFT JOIN Customer AS c
ON b.contact_id = c.ID
GO

SELECT * FROM owerview_booking
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
USE Hotel;
GO

---------------------------------------------- Konton

-- Admin
-- db_owner representerar en administratör. Om det är rätt val är oklart, då permissions är ett djupt ämne.
CREATE LOGIN hotel_admin WITH PASSWORD = 'adminPass01';
GO

CREATE USER hotel_admin FOR LOGIN hotel_admin;
GO 

ALTER ROLE db_owner
ADD MEMBER hotel_admin;
GO 

-- Personal
CREATE LOGIN hotel_staff WITH PASSWORD ='staffPass01';
GO

CREATE USER hotel_staff FOR LOGIN hotel_staff;
GO

DROP USER hotel_staff

GRANT INSERT, SELECT, UPDATE, DELETE, EXECUTE
TO hotel_staff
GO


-- Gäst
CREATE LOGIN hotel_guest WITH PASSWORD = 'guestPass01'

CREATE USER hotel_guest FOR LOGIN hotel_guest;
GO

GRANT EXECUTE ON OBJECT::display_feedback_and_average_rating TO hotel_guest; -- GRANT EXECUTE ON display_feedback_and_average_rating TO hotel_guest
GO

GRANT EXECUTE ON OBJECT::write_review TO hotel_guest; -- GRANT EXECUTE ON display_feedback_and_average_rating TO hotel_guest
GO

DROP USER hotel_admin;
DROP LOGIN hotel_admin
GO
DROP USER hotel_staff;
DROP LOGIN hotel_staff
GO
DROP USER hotel_guest;
DROP LOGIN hotel_guest
GO






/*
-- Görs inloggad som sa.
-- Skapar ett nytt inlogg för användare demouser till SERVER.
CREATE LOGIN demouser WITH PASSWORD = 'P@ssw0rd';
GO

-- Skapar en användare för aktuell DATABAS (se USE).
CREATE USER demouser1 FOR LOGIN demouser;
GO

-- Tilldelar demouser1 CRUD-funktionalitet.
GRANT CONTROL TO demouser1 

SELECT * FROM users;
*/


----------------------------------------------- PROCEDURES

-- Visar användarnas snittbetyg.
-- Eftersom IDENTITY helt plötsligt hoppar från t.ex. 20 till 1021 så fungerar inte proceduren alltid som tänkt.
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

DROP DATABASE Hotel

drop PROCEDURE display_feedback_and_average_rating;
GO

-- Feedback rad 11 saknar reviewer


-- TRY CATCH fungerar inte
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
WHERE feedback_id = 1023;
GO

select * from Feedback
GO



--SKAPAR FAKTURA FÖR ETT RUM
CREATE PROCEDURE create_room_bill (@Room_NR INT, @discount_id INT)
AS
DECLARE @amount DECIMAL
DECLARE @booking_id INT = (SELECT rb.booked_rooms_id FROM Rooms_booked rb WHERE @Room_NR = rb.room_id)
SET @amount = (SELECT r.room_price FROM Room r WHERE @Room_NR = r.room_NR)
SET @amount = @amount - (@amount*(SELECT d.discount_amount FROM Discount d WHERE @discount_id = d.discount_id))
SET @amount = @amount *(SELECT b.num_of_night FROM booking b WHERE booking_id = (SELECT rb.room_belongs_to_booking_id FROM Rooms_booked rb WHERE @Room_NR = rb.room_id))
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

SELECT * FROM Booking
WHERE booking_id = 11
GO



--SKAPAR TOTAL RÄKNING FÖR BOKNING
CREATE PROCEDURE create_total_bill_(@booking_id INT, @payment_method_id INT, @reference_number INT = NULL)
AS
DECLARE @totalsum DECIMAL = 
    (SELECT SUM(amount) FROM room_bill rb
JOIN Rooms_booked roob
ON rb.booked_room_ID = roob.booked_rooms_id
WHERE roob.room_belongs_to_booking_id = @booking_id)
--OM FÖRSENAD ANKOMST LÄGGS TILLÄGGSAVGIFT TILL om 50kr/timmen
IF((SELECT late_arrival_timer FROM booking WHERE booking_id = @booking_id)>0)
    BEGIN
        SET @totalsum = @totalsum + (50*(SELECT late_arrival_timer FROM booking WHERE booking_id = @booking_id))
    END
INSERT INTO total_booking_bill(total_amount,
    selected_payment_method,
    reference_number,
    booking_id_bill) VALUES (@totalsum,@payment_method_id,@reference_number,@booking_id
);




EXEC create_total_bill_ 11,3

SELECT * FROM total_booking_bill

SELECT * FROM Rooms_booked
GO


--PROCEDUR FÖR ATT SÄTTA NO_SHOW/"AVBOKNING" (egentligen gör att triggern som kollar rum och datum släpper igenom ny rumsbokning)
CREATE PROCEDURE SET_no_show (@booking_id INT)
AS
    BEGIN
                IF((SELECT log_check_in FROM check_in_log WHERE booking_id = @booking_id) IS NULL)
                    BEGIN
                        PRINT 'Rummen avbokas för bokningsdatumet'
                        UPDATE Booking
                        SET check_in_date = NULL, check_out_date = NULL, no_show = 1
                        WHERE booking_id = @booking_id
                    END
                ELSE
                    BEGIN
                        PRINT 'Kan inte avboka en incheckad gäst!'
                    END    
    END
GO






------------------------------------------------------------ TRIGGERS


--SKAPAR DATA FÖR LATE_ARRIVAL_TIMER I BOOKING GENOM INSERT TILL CHECK-LOG (INCHECKNING)
CREATE TRIGGER late_arrival
ON check_in_log
FOR INSERT,UPDATE, DELETE
AS
BEGIN
    IF EXISTS(SELECT * FROM inserted)
    BEGIN
    IF ((SELECT log_check_in FROM inserted)-(SELECT check_in_date FROM booking WHERE booking_id = (SELECT i.booking_id FROM inserted i))>0)
        BEGIN
            UPDATE Booking
            SET late_arrival_timer = (DATEDIFF (hour, (SELECT check_in_date FROM booking WHERE booking_id = (SELECT i.booking_id FROM inserted i)),(SELECT log_check_in FROM inserted)))
            WHERE booking_id = (SELECT i.booking_id FROM inserted i)
        END
    END
    ELSE
        BEGIN
            IF EXISTS(SELECT * FROM deleted)
            BEGIN
                UPDATE Booking
                SET late_arrival_timer = 0 WHERE booking_id = (SELECT d.booking_id FROM deleted d)
            END    
        END
END   
GO   

INSERT INTO check_log (booking_id,log_check_in) VALUES(11, '2022-04-07 15:30')
GO


--TRIGGER FÖR ATT FÖRHINDRA DUBBELBOKNING AV RUM
SELECT * FROM Booking 
GO
insert into booking (contact_id, num_of_night, check_in_date, check_out_date, late_arrival_timer, no_show, employee_ref, prepaid) values (2, 7, '2021-05-18', '2021-05-18','2023-05-23',0,9, 1);
GO

CREATE TRIGGER availability_checker 
ON Booking
FOR INSERT
AS
    IF EXISTS(
                SELECT check_in_date FROM inserted 
                WHERE check_in_date 
                BETWEEN 
                        (SELECT b.check_in_date FROM Booking b
                        INNER JOIN Rooms_booked rb
                        ON b.booking_id =  rb.room_belongs_to_booking_id
                        INNER JOIN Room r 
                        ON rb.room_id = r.room_NR
                        WHERE room_NR = 1)
                AND
                        (SELECT b.check_out_date FROM Booking b
                        INNER JOIN Rooms_booked rb
                        ON b.booking_id =  rb.room_belongs_to_booking_id
                        INNER JOIN Room r 
                        ON rb.room_id = r.room_NR
                        WHERE room_NR = 1)
            )
            BEGIN
                ROLLBACK TRANSACTION
                PRINT 'Rummet är redan bokat.' -- lägg till datum här, kanske. Eller ha ett RaiseError ... 
            END
    ELSE
        BEGIN
            --COMMIT TRANSACTION
            PRINT 'Bokning registrerad.'
        END;
GO


delete from Booking where booking_id = 16
select * from Booking
GO

drop TRIGGER availability_checker;
GO




--FUNKAR INTE
CREATE TRIGGER availability_check2
ON rooms_booked
FOR INSERT, UPDATE
AS
    BEGIN
        IF ((SELECT i.room_id FROM inserted i) IN (SELECT rb.room_id FROM Rooms_booked rb))
            BEGIN
                IF ((SELECT b.check_in_date FROM Booking b WHERE b.booking_id = (SELECT i.room_belongs_to_booking_id FROM inserted i)) BETWEEN (SELECT b2.check_in_date FROM booking b2 WHERE b2.booking_id = 
                (SELECT rb2.room_belongs_to_booking_id FROM Rooms_booked rb2 WHERE rb2.room_id IN (SELECT i.room_id FROM inserted i))) AND (SELECT b2.check_out_date FROM booking b2 WHERE b2.booking_id = 
                (SELECT rb3.room_belongs_to_booking_id FROM Rooms_booked rb3 WHERE  rb3.room_id IN (SELECT i.room_id FROM inserted i))))
                    BEGIN
                    ROLLBACK TRANSACTION
                       PRINT 'GÅR EJ ATT GENOMFÖRA DENNA BOKNING EFTERSOM ETT RUM ÄR UPPTAGET'
                    END
            END
        ELSE
            BEGIN
                COMMIT TRANSACTION
                PRINT 'RUM BOKAT'
            END    
    END
GO                        


-- SÄTTER STANDARD INCHECKNINGSTID TILL 11:00 OCH UTCHECKNINGSTID TILL 14:00.
CREATE TRIGGER check_in_out_time_default
ON booking
FOR INSERT
AS
    BEGIN
        UPDATE Booking
        SET check_in_date = DATEADD(hour, 14, check_in_date) 
        , check_out_date = DATEADD(hour, 11, check_out_date)   
        WHERE booking_id = (SELECT booking_id FROM inserted)
    END
GO


SELECT * FROM Booking WHERE booking_id = 11



SELECT b.booking_id,rb.room_id FROM booking b 
JOIN rooms_booked rb
ON b.booking_id = rb.room_belongs_to_booking_id










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
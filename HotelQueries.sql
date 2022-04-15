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

GRANT EXECUTE ON OBJECT::display_feedback_and_average_rating TO hotel_guest;
GO

GRANT EXECUTE ON OBJECT::write_review TO hotel_guest;
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



----------------------- PROCEDURES -----------------------


---Sök efter kund och, mata in datum att kontrollera på status på (för att slippa behöva lägga in/ändra om i data för incheckningar och bokningar/bokningstider)
--anges inget datum sätts det till dagens varav träffar kommer ha status utcheckade, såvida inte fler bokningar med framtida/aktuella datum skapats.
--(Kräver att klockslag efter loggad incheckning anges för kontroll för samma dag)
CREATE PROCEDURE find_customer (@search NVARCHAR(4), @dateToCheck DATETIME = NULL)
AS
    IF (@dateToCheck) IS NULL
        BEGIN
            SET @dateToCheck = GETDATE()
        END
        IF EXISTS(SELECT c.first_name, c.last_name FROM Customer c WHERE c.first_name LIKE '%'+@search+'%' OR c.last_name LIKE '%'+@search+'%')
        BEGIN
    SELECT c.first_name 'Förnamn',c.last_name 'Efternamn', r.[floor] 'Våning',r.room_NR 'Rumsnummer', b.num_of_night 'Antal nätter', b.check_out_date,cl.log_check_in ,
    CASE WHEN b.check_out_date < @dateToCheck THEN 'utcheckad'
         WHEN b.check_in_date>@dateToCheck AND @dateToCheck< (SELECT cl.log_check_in FROM check_in_log cl WHERE cl.booking_id = b.booking_id) THEN 'Ej incheckad'
         WHEN b.check_out_date> @dateToCheck AND @dateToCheck>= (SELECT cl.log_check_in FROM check_in_log cl WHERE cl.booking_id = b.booking_id) THEN 'incheckad'
    END AS status     
    FROM Customer c 
    JOIN Guest_booking gb ON gb.customer_id = c.ID
    JOIN Rooms_booked rb ON rb.room_belongs_to_booking_id = gb.belongs_to_booking_id
    JOIN Room r ON r.room_NR = rb.room_id
    JOIN Booking b ON b.booking_id = rb.room_belongs_to_booking_id
    JOIN check_in_log cl ON cl.booking_id = b.booking_id
    WHERE c.first_name LIKE '%'+@search+'%' OR c.last_name LIKE '%'+@search+'%'
    END
    ELSE 
        BEGIN
            PRINT 'Inga träffar'
        END    
GO

EXEC find_customer 'er'
GO
EXEC find_customer 'er', '2022-03-09'
GO

EXEC find_customer 'er', '2022-03-09 14:15'
GO








-- Visar hotellets snittbetyg och gästers feedback.
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
WHILE @counter <= (SELECT MAX(feedback_id) FROM Feedback)
BEGIN
    IF (SELECT feedback_id FROM Feedback WHERE feedback_id = @counter) IS NOT NULL
    BEGIN
        SET @feedback_id = (SELECT feedback_id FROM Feedback WHERE feedback_id = @counter)
        SET @reviewer = (SELECT reviewer FROM Feedback WHERE feedback_id = @counter)
        SET @comment = (SELECT comment FROM Feedback WHERE feedback_id = @counter)
        SET @score = (SELECT score FROM Feedback WHERE feedback_id = @counter)
        PRINT CAST(@feedback_id AS VARCHAR (10)) + ' * Reviewer: ' + @reviewer + ' * Comment: ' + @comment + ' * Score: ' + CAST(@score AS NVARCHAR(10))
        PRINT '---------------'
        SET @counter = @counter + 1
    END
    ELSE 
    BEGIN
        SET @counter = @counter + 1
    END
END;
GO

EXECUTE display_feedback_and_average_rating;
GO

drop PROCEDURE display_feedback_and_average_rating;
GO

-- Feedback rad 11 saknar reviewer


CREATE PROCEDURE write_review @reviewer NVARCHAR(50), @comment NVARCHAR(500), @score INT 
AS 
    IF (@score < 1 OR @score > 5)
    BEGIN
        PRINT 'The score has to be between 1 and 5.'
    END
    ELSE
    BEGIN
        INSERT INTO Feedback (reviewer, comment, score) VALUES (@reviewer, @comment, @score)
    END
GO


--EXECUTE write_review @reviewer = 'namn', @comment = 'kommentar', @score = betyg 1- 5 som INT;
EXECUTE write_review @reviewer = 'A reviewer', @comment = 'A comment', @score = 5;
GO

DROP PROCEDURE write_review;
GO

DELETE FROM Feedback
WHERE feedback_id = 1023;
GO

select * from Feedback
GO


CREATE PROCEDURE delete_review @feedback_id INT
AS
DELETE FROM Feedback WHERE feedback_id = @feedback_id;
GO

EXECUTE delete_review @feedback_id = 22;
GO

--SKAPAR FAKTURA FÖR ETT RUM
CREATE PROCEDURE create_room_bill (@Room_NR INT, @discount_id INT, @rooms_booking_id INT)
AS
DECLARE @amount DECIMAL
SET @amount = (SELECT r.room_price FROM Room r WHERE @Room_NR = r.room_NR)
SET @amount = @amount - (@amount*(SELECT d.discount_amount FROM Discount d WHERE @discount_id = d.discount_id))
SET @amount = @amount *(SELECT b.num_of_night FROM booking b WHERE booking_id = (SELECT rb.room_belongs_to_booking_id FROM Rooms_booked rb 
WHERE @Room_NR = rb.room_id AND rb.booked_rooms_id=@rooms_booking_id))
INSERT INTO room_bill (amount,room_discount_id,booked_room_ID) VALUES (@amount, @discount_id, @rooms_booking_id)
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


--INCHECKNING
CREATE PROCEDURE Check_In (@booking_id INT)
AS
    DECLARE @now DATETIME = GETDATE() 
    IF(@Now - (
    SELECT b1.check_out_date FROM booking b1 JOIN Rooms_booked rb ON b1.booking_id = rb.room_belongs_to_booking_id
    WHERE rb.room_id = ANY (SELECT rb1.room_id FROM Rooms_booked rb1 WHERE rb1.room_belongs_to_booking_id = 12) AND b1.booking_id<>@booking_id)>=0)
        BEGIN
            INSERT INTO check_in_log (booking_id, log_check_in) VALUES (
            @booking_id, @now
        )
        END 
    ELSE
        BEGIN
            PRINT 'KAN ej checka in ännu, rum ej redo'
        END    
GO    

SELECT * FROM Booking WHERE booking_id = 11
GO


----------------- TRIGGERS-----------------


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
            SET late_arrival_timer = (DATEDIFF (hour, (SELECT check_in_date FROM booking WHERE booking_id = 
                                    (SELECT i.booking_id FROM inserted i)),(SELECT log_check_in FROM inserted)))
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

INSERT INTO check_in_log (booking_id,log_check_in) VALUES (11, '2022-04-07 14:05')
GO

UPDATE check_in_log
SET log_check_in = '2022-04-07 14:05'
WHERE booking_id = 11

SELECT * FROM Booking WHERE booking_id = 11
GO

-- SÄTTER STANDARD INCHECKNINGSTID TILL 11:00 OCH UTCHECKNINGSTID TILL 14:00. (För att slippa skriva in detta)
CREATE TRIGGER check_in_out_time_default
ON booking
FOR INSERT
AS
    BEGIN
        UPDATE Booking
        SET check_in_date = DATEADD(hour, 14, check_in_date), 
            check_out_date = DATEADD(hour, 11, check_out_date)  
         WHERE booking_id = (SELECT booking_id FROM inserted)
    END
GO



--TRIGGER FÖR ATT FÖRHINDRA DUBBELBOKNING AV RUM
CREATE TRIGGER room_check
ON rooms_booked
FOR INSERT, UPDATE
AS IF EXISTS((SELECT i.room_id FROM inserted i WHERE i.room_id IN
            (SELECT rb.room_id FROM Rooms_booked rb
            JOIN booking b 
            ON b.booking_id = rb.room_belongs_to_booking_id
            WHERE b.check_out_date> (SELECT b2.check_in_date FROM Booking b2 WHERE b2.booking_id = i.room_belongs_to_booking_id) 
            AND b.booking_id <> i.room_belongs_to_booking_id)))
                BEGIN
                    ROLLBACK TRANSACTION
                    PRINT 'RUMMET ÄR UPPTAGET'
                END
GO

SELECT * FROM Rooms_booked

SELECT * FROM booking
LEFT JOIN Rooms_booked ON booking_id = room_belongs_to_booking_id
WHERE Rooms_booked.room_id = 230

insert into booking (contact_id, num_of_night, check_in_date, check_out_date, no_show, employee_ref, prepaid) values (16, 4, '2022-04-08', '2022-04-13',0, 10, 1);
insert into rooms_booked (room_id, room_belongs_to_booking_id, extra_bed,number_of_guests) values (230, 13, 0,1);
GO






------------------------------------------------------------ VIEWS

-- 1.
CREATE VIEW room_overview
AS
SELECT r.room_NR, rt.name, r.floor, rt.nr_of_beds, rt.balcony, rt.price, rt.[description] FROM Room r 
INNER JOIN Room_type rt ON R.room_room_type_id = rt.room_type_id
GO

select * from room_overview;
GO

-- 2.
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

SELECT * FROM Bokings_person_och_rum;
GO

-- 3.
CREATE view user_payment
AS
SELECT c.first_name, c.last_name, c.street_address, c.postal_code, c.city, tbb.total_amount, tbb.reference_number, pm.method_name FROM Customer c
INNER JOIN Booking b ON c.ID = b.contact_id
LEFT JOIN total_booking_bill tbb ON b.booking_id = tbb.booking_id_bill
LEFT JOIN payment_methods pm ON tbb.selected_payment_method = pm.method_id
GO

SELECT * FROM user_payment;
GO


-- 4. view med bokningar som är utchekade
CREATE VIEW owerview_done_bookings AS
SELECT b.check_in_date, b.check_out_date, c.first_name, c.last_name, c.phone_number
FROM Booking AS b
INNEr JOIN Customer AS c
ON b.contact_id = c.ID
WHERE check_out_date < GETDATE()
GO

SELECT * FROM owerview_done_bookings;
GO

-- 5.
CREATE VIEW owerview_going_bookings AS
SELECT b.check_in_date, b.check_out_date, c.first_name, c.last_name, c.phone_number
FROM Booking AS b
LEFT JOIN Customer AS c
ON b.contact_id = c.ID
WHERE check_out_date > GETDATE()
GO

SELECT * FROM owerview_going_bookings;
GO

-- 6. Vilken bokning som har vilka gäster.
CREATE VIEW guests_part_of_booking
AS
SELECT b.booking_id,b.contact_id, c.ID AS customer_id, c.first_name, c.last_name FROM Guest_booking gb
INNER JOIN Booking b
ON gb.belongs_to_booking_id = b.booking_id
INNER JOIN Customer c 
ON gb.customer_id = c.ID
WHERE booking_id IS NOT NULL;
GO

SELECT * FROM guests_part_of_booking;
GO

-- 7. Vilken bokning som har bokat vilka rum och av vem.
CREATE VIEW rooms_booked_by
AS
SELECT rb.room_id, rb.number_of_guests, b.booking_id, c.ID AS customer_id, c.first_name, c.last_name FROM Rooms_booked rb 
INNER JOIN Booking b 
ON rb.room_belongs_to_booking_id = b.booking_id
INNER JOIN Customer c 
ON b.contact_id = c.ID;
GO

SELECT * FROM rooms_booked_by;
GO



-- EJ KLAR. ORDER BY GÅR INTE I VIEW
-- 8. SE VILKA GÄSTER SOM ÄR BOKADE I VILKA RUM OCH NÄR

--SE VILKA GÄSTER SOM ÄR BOKADE I VILKA RUM OCH NÄR
CREATE VIEW active_booking AS
SELECT c.first_name Förnamn, c.last_name Efternamn, r.room_NR Rum,r.[floor] Våning,rt.name Rumstyp,b.booking_id, b.check_in_date, b.check_out_date 
FROM Customer c 
JOIN Guest_booking gb ON gb.customer_id = c.ID
JOIN Booking b ON gb.belongs_to_booking_id = b.booking_id
JOIN Rooms_booked rb ON rb.booked_rooms_id = b.booking_id
JOIN room r ON r.room_NR = rb.room_id
JOIN Room_type rt ON rt.room_type_id = r.room_room_type_id
WHERE b.check_out_date>GETDATE() AND b.check_in_date <GETDATE()
ORDER BY r.room_NR
GO

-- 9. De bokade rum som har fått rabatt.
CREATE VIEW room_with_discount
AS
SELECT r.room_NR, d.discount_code, b.booking_id FROM Booking b
INNER JOIN Rooms_booked rb
ON b.booking_id = rb.room_belongs_to_booking_id
INNER JOIN Room r 
ON rb.room_id = r.room_NR 
INNER JOIN room_bill rbi 
ON rb.booked_rooms_id = rbi.booked_room_ID
INNER JOIN discount d 
ON rbi.room_discount_id = d.discount_id
WHERE d.discount_code <> 'default';
GO

SELECT * FROM room_with_discount;
GO

-- 10. Meddelanden från vilket rum och vem som bokat.
CREATE VIEW comment_room_guest
AS
SELECT m.comment, r.room_NR, c.last_name, c.first_name FROM Messages m
INNER JOIN Booking b
ON m.booking_ref = b.booking_id
INNER JOIN Customer c 
ON b.contact_id = c.ID
INNER JOIN Rooms_booked rb
ON b.booking_id = rb.room_belongs_to_booking_id
INNER JOIN Room r 
ON rb.room_id = r.room_NR;
GO

SELECT * FROM comment_room_guest;
GO

-- 11. Vem i personalen som har tagit hand om en bokning.
CREATE VIEW booking_handled_by_which_employee
AS
SELECT b.booking_id, c.ID AS customer_id, e.last_name, e.first_name, e.[position] FROM Booking b
INNER JOIN Employees e
ON b.employee_ref = e.employee_ID
INNER JOIN Customer c 
ON b.contact_id = c.ID;
GO

SELECT * FROM booking_handled_by_which_employee;
GO

-- 12. De fem incheckningar som ligger senast i tiden.
CREATE VIEW top_5_check_in_ordered_by_latest
AS
SELECT TOP 5 (b.check_in_date), b.booking_id, c.last_name, c.first_name FROM Booking b
INNER JOIN Customer c 
ON b.booking_id = c.ID
ORDER BY b.check_in_date DESC;
GO

SELECT * FROM top_5_check_in_ordered_by_latest;
GO

-- 13. De rum och den bokning som har beställt extrasäng.
CREATE VIEW room_with_extra_bed
AS
SELECT rb.extra_bed, r.room_NR, b.booking_id FROM Rooms_booked rb
INNER JOIN Booking b 
ON rb.room_belongs_to_booking_id = b.booking_id
INNER JOIN Room r 
ON rb.room_id = r.room_NR
WHERE rb.extra_bed <> 0;
GO

SELECT * FROM room_with_extra_bed;
GO

-- 14. Rum med kommande bokning.
CREATE VIEW future_booked_room
AS
SELECT r.room_NR, b.check_in_date FROM Room r
INNER JOIN Rooms_booked rb 
ON r.room_NR = rb.room_id
INNER JOIN Booking b 
ON rb.room_belongs_to_booking_id = b.booking_id
WHERE b.check_in_date > GETDATE();
GO

select * from future_booked_room;
GO

--  15. Visar förskottsbetalda rum (BIT) och betalningsmetod
CREATE VIEW prepaid_rooms_and_payment_type
AS
SELECT r.room_NR, b.prepaid, pm.method_name FROM Room r
INNER JOIN Rooms_booked rb 
ON r.room_NR = rb.room_id
INNER JOIN Booking b 
ON rb.room_belongs_to_booking_id = b.booking_id
INNER JOIN total_booking_bill tb 
ON b.booking_id = tb.booking_id_bill
INNER JOIN payment_methods pm 
ON tb.selected_payment_method = pm.method_id
WHERE prepaid <> 0;
GO

SELECT * FROM prepaid_rooms_and_payment_type;
GO

USE Hotel;
GO

-- Testdata

-- Kör våra queries i följande ordning: Hotel_DB, HotelQueries, HotelData och sist den med testqueries.
-- Det finns kommentarer a anslutning till de olika procedurerna, vyerna och triggrarna som förklarar deras funktion.

-- Skapa ny bokning.
INSERT INTO booking (contact_id, num_of_night, check_in_date, check_out_date, no_show, employee_ref, prepaid) VALUES (6, 3, '2022-04-16', '2022-04-19',0, 2, 0);
GO

-- OBS!
-- För att nedan ska fungera måste booking_id = 12 och @rooms_booking_id = 13 stämma (@rooms_booking_id motvarar rb.booked_rooms_id).
-- Använd queryn nedan för kontroll. 
-- SELECT b.booking_id, rb.booked_rooms_id FROM booking b 
-- LEFT JOIN Rooms_booked rb 
-- ON booking_id = room_belongs_to_booking_id;
-- GO

-- Anger vilken gäst som hör till vilken bokning.
INSERT INTO guest_booking (customer_id, belongs_to_booking_id) VALUES (6, 12);
GO

-- Anger rum som bokas.
INSERT INTO rooms_booked (room_id, room_belongs_to_booking_id, extra_bed,number_of_guests) VALUES (56, 12, 0, 1);
GO


-- Procedurer

-- För att kunna checka in måste incheckningsdatum vara samma som dagens datum.
-- Det finns också begränsningar vad gäller klockslag - utcheckning vid 11 och incheckning vid 14.
-- För att kontrollera att senincheckningstillägget fungerar behöver @now i Check-In-proceduret sättas till ett tidigare datum än dagens.
EXECUTE Check_In @booking_id = 12;
GO

-- Sätter förseningsavgift.
UPDATE check_in_log SET log_check_in = '2022-04-17' where booking_id = 12

-- Skapar rumsräkning.
EXECUTE create_room_bill @Room_NR = 56, @discount_id = 4, @rooms_booking_id = 13;
GO

-- Skapar den totala räkningen.
EXECUTE create_total_bill_ @booking_id = 12, @payment_method_id = 3, @reference_number = 498763233;
GO

-- Hanterar avbokning.
EXECUTE SET_No_Show @booking_id = 11;
GO

-- Söker efter gäst. Datum är valfritt.
EXECUTE find_customer @search = 'Mc'--, date_to_check; 
GO

-- Ser vad gäster tycker om hotellet.
EXECUTE display_feedback_and_average_rating;
GO

-- Möjliggör för gäster att tycka till.
EXECUTE write_review @reviewer = 'Skurt', @comment = 'Nästan lika härlig som Göran Persson.', @score = 5;
GO


-- Vyer

SELECT * FROM room_overview;
GO

SELECT * FROM Bokings_person_och_rum;
GO

SELECT * FROM user_payment;
GO

SELECT * FROM owerview_done_bookings;
GO

SELECT * FROM owerview_going_bookings;
GO

SELECT * FROM guests_part_of_booking;
GO

SELECT * FROM rooms_booked_by;
GO

SELECT * FROM active_booking;
GO

SELECT * FROM room_with_discount;
GO

SELECT * FROM comment_room_guest;
GO

SELECT * FROM booking_handled_by_which_employee;
GO

SELECT * FROM top_5_check_in_ordered_by_latest;
GO

SELECT * FROM room_with_extra_bed;
GO

SELECT * FROM future_booked_room;
GO

SELECT * FROM prepaid_rooms_and_payment_type;
GO

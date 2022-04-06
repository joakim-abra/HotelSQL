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
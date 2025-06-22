--ASSIGNMENT 5 
--Firstly we will create the tables
CREATE TABLE SubjectAllotments (
    StudentID VARCHAR(20),
    SubjectID VARCHAR(20),
    Is_valid BIT
);
-- Create the SubjectRequest Table
CREATE TABLE SubjectRequest (
    StudentID VARCHAR(20),
    SubjectID VARCHAR(20)
);

-- Insert Initial Data into SubjectAllotments
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_valid) VALUES
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 0),
('159103036', 'PO1493', 0),
('159103036', 'PO1494', 0),
('159103036', 'PO1495', 0);

--Insert Request Data into SubjectRequest
INSERT INTO SubjectRequest (StudentID, SubjectID) VALUES
('159103036', 'PO1496');

-- Now we will create the Stored procedure
CREATE PROCEDURE UpdateSubjectAllotment
AS
BEGIN
    DECLARE @StudentID VARCHAR(20)
    DECLARE @NewSubjectID VARCHAR(20)
    DECLARE @CurrentSubjectID VARCHAR(20)

    -- Cursor to loop through all subject requests
    DECLARE request_cursor CURSOR FOR
        SELECT StudentID, SubjectID FROM SubjectRequest

    OPEN request_cursor
    FETCH NEXT FROM request_cursor INTO @StudentID, @NewSubjectID

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check current valid subject
        SELECT @CurrentSubjectID = SubjectID 
        FROM SubjectAllotments 
        WHERE StudentID = @StudentID AND Is_valid = 1

        IF @CurrentSubjectID IS NULL
        BEGIN
            -- No existing subject, just insert the new one
            INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_valid)
            VALUES (@StudentID, @NewSubjectID, 1)
        END
        ELSE IF @CurrentSubjectID <> @NewSubjectID
        BEGIN
            -- Make current subject invalid
            UPDATE SubjectAllotments
            SET Is_valid = 0
            WHERE StudentID = @StudentID AND SubjectID = @CurrentSubjectID

            -- Insert new subject as valid
            INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_valid)
            VALUES (@StudentID, @NewSubjectID, 1)
        END
        -- Else: If requested subject is same as current valid, do nothing

        FETCH NEXT FROM request_cursor INTO @StudentID, @NewSubjectID
    END

    CLOSE request_cursor
    DEALLOCATE request_cursor
END

--execute the procedure
EXEC UpdateSubjectAllotment;

--now we will view the final data
SELECT * FROM SubjectAllotments;

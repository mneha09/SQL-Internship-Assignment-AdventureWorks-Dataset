INSERT INTO StudentDetails (StudentId, StudentName, GPA) VALUES
(1, 'Arjun Tehlan', 9.2),
(2, 'Mohit Agarwal', 8.7),
(3, 'Rohit Agarwal', 7.5);
INSERT INTO SubjectDetails (SubjectId, SubjectName, MaxSeats) VALUES
(101, 'Basics of Accounting', 1),
(102, 'Basics of Political Science', 1);

INSERT INTO StudentPreference (StudentId, Preference, SubjectId) VALUES
(1, 1, 101), (1, 2, 102),
(2, 1, 102), (2, 2, 101),
(3, 1, 101), (3, 2, 102);

EXEC AllocateSubjects;

SELECT 
    sd.StudentId,
    sd.StudentName,
    ISNULL(sub.SubjectName, 'Not Allotted') AS AllottedSubject,
    sp.Preference AS AllottedPreference
FROM 
    StudentDetails sd
LEFT JOIN 
    Allotments a ON sd.StudentId = a.StudentId
LEFT JOIN 
    SubjectDetails sub ON a.SubjectId = sub.SubjectId
LEFT JOIN 
    StudentPreference sp ON sp.StudentId = sd.StudentId AND sp.SubjectId = a.SubjectId
ORDER BY 
    sd.GPA DESC;





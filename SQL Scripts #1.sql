USE SmartClinicDB;

-- 1. Patient table
CREATE TABLE Patient (
    PatientID INT UNSIGNED AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50),
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender ENUM('Male', 'Female') NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Email VARCHAR(100),
    Address VARCHAR(200),
    RegistrationDate DATE NOT NULL DEFAULT (CURRENT_DATE),

    CONSTRAINT PK_Patient
        PRIMARY KEY (PatientID),

    CONSTRAINT UQ_Patient_Phone
        UNIQUE (Phone),

    CONSTRAINT UQ_Patient_Email
        UNIQUE (Email)
);
--8 --7
--6      --1  --3

CREATE TABLE Doctor (
    DoctorID INT UNSIGNED AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50),
    LastName VARCHAR(50) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    LicenseNumber VARCHAR(50) NOT NULL,
    DoctorType ENUM(
        'General Practitioner',
        'Specialist',
        'Surgeon'
    ) NOT NULL,

    CONSTRAINT PK_Doctor
        PRIMARY KEY (DoctorID),

    CONSTRAINT UQ_Doctor_Phone
        UNIQUE (Phone),

    CONSTRAINT UQ_Doctor_Email
        UNIQUE (Email),

    CONSTRAINT UQ_Doctor_License
        UNIQUE (LicenseNumber)
);


-- 3. General practitioner subtype
CREATE TABLE General_Practitioner (
    DoctorID INT UNSIGNED,
    YearsExperience INT UNSIGNED NOT NULL,

    CONSTRAINT PK_GeneralPractitioner
        PRIMARY KEY (DoctorID),

    CONSTRAINT FK_GP_Doctor
        FOREIGN KEY (DoctorID)
        REFERENCES Doctor (DoctorID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT CHK_GP_Experience
        CHECK (YearsExperience >= 0)
);


-- 4. Specialist doctor subtype
CREATE TABLE Specialist_Doctor (
    DoctorID INT UNSIGNED,
    SubSpecialization VARCHAR(100) NOT NULL,

    CONSTRAINT PK_SpecialistDoctor
        PRIMARY KEY (DoctorID),

    CONSTRAINT FK_Specialist_Doctor
        FOREIGN KEY (DoctorID)
        REFERENCES Doctor (DoctorID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- 5. Surgeon doctor subtype
CREATE TABLE Surgeon_Doctor (
    DoctorID INT UNSIGNED,
    OperationTheater VARCHAR(100) NOT NULL,

    CONSTRAINT PK_SurgeonDoctor
        PRIMARY KEY (DoctorID),

    CONSTRAINT FK_Surgeon_Doctor
        FOREIGN KEY (DoctorID)
        REFERENCES Doctor (DoctorID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- 6. Appointment table
CREATE TABLE Appointment (
    AppointmentID INT UNSIGNED AUTO_INCREMENT,
    PatientID INT UNSIGNED NOT NULL,
    DoctorID INT UNSIGNED NOT NULL,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    Reason VARCHAR(250),
    Status ENUM(
        'Scheduled',
        'Completed',
        'Cancelled',
        'No Show'
    ) NOT NULL DEFAULT 'Scheduled',
    Notes TEXT,

    CONSTRAINT PK_Appointment
        PRIMARY KEY (AppointmentID),

    CONSTRAINT FK_Appointment_Patient
        FOREIGN KEY (PatientID)
        REFERENCES Patient (PatientID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT FK_Appointment_Doctor
        FOREIGN KEY (DoctorID)
        REFERENCES Doctor (DoctorID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT UQ_Doctor_AppointmentSlot
        UNIQUE (DoctorID, AppointmentDate, AppointmentTime)
);


-- 7. Treatment table
CREATE TABLE Treatment (
    TreatmentID INT UNSIGNED AUTO_INCREMENT,
    AppointmentID INT UNSIGNED NOT NULL,
    TreatmentName VARCHAR(100) NOT NULL,
    Diagnosis VARCHAR(250) NOT NULL,
    Description TEXT,
    TreatmentDate DATE NOT NULL,
    Cost DECIMAL(10,2) NOT NULL DEFAULT 0.00,

    CONSTRAINT PK_Treatment
        PRIMARY KEY (TreatmentID),

    CONSTRAINT FK_Treatment_Appointment
        FOREIGN KEY (AppointmentID)
        REFERENCES Appointment (AppointmentID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT CHK_Treatment_Cost
        CHECK (Cost >= 0)
);


-- 8. Prescription table
CREATE TABLE Prescription (
    PrescriptionID INT UNSIGNED AUTO_INCREMENT,
    AppointmentID INT UNSIGNED NOT NULL,
    PrescriptionDate DATE NOT NULL DEFAULT (CURRENT_DATE),
    Instructions TEXT,

    CONSTRAINT PK_Prescription
        PRIMARY KEY (PrescriptionID),

    CONSTRAINT FK_Prescription_Appointment
        FOREIGN KEY (AppointmentID)
        REFERENCES Appointment (AppointmentID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- 9. Medicine table
CREATE TABLE Medicine (
    MedicineID INT UNSIGNED AUTO_INCREMENT,
    MedicineName VARCHAR(100) NOT NULL,
    Description VARCHAR(250),
    UnitPrice DECIMAL(10,2) NOT NULL,
    StockQuantity INT UNSIGNED NOT NULL DEFAULT 0,
    ExpiryDate DATE,

    CONSTRAINT PK_Medicine
        PRIMARY KEY (MedicineID),

    CONSTRAINT UQ_Medicine_Name
        UNIQUE (MedicineName),

    CONSTRAINT CHK_Medicine_Price
        CHECK (UnitPrice >= 0)
);


-- 10. Associative entity between Prescription and Medicine
CREATE TABLE Prescription_Medicine (
    PrescriptionID INT UNSIGNED,
    MedicineID INT UNSIGNED,
    Dosage VARCHAR(50) NOT NULL,
    Frequency VARCHAR(50) NOT NULL,
    DurationDays INT UNSIGNED NOT NULL,
    Quantity INT UNSIGNED NOT NULL,

    CONSTRAINT PK_PrescriptionMedicine
        PRIMARY KEY (PrescriptionID, MedicineID),

    CONSTRAINT FK_PM_Prescription
        FOREIGN KEY (PrescriptionID)
        REFERENCES Prescription (PrescriptionID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT FK_PM_Medicine
        FOREIGN KEY (MedicineID)
        REFERENCES Medicine (MedicineID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT CHK_PM_Duration
        CHECK (DurationDays > 0),

    CONSTRAINT CHK_PM_Quantity
        CHECK (Quantity > 0)
);


-- 11. Payment table
CREATE TABLE Payment (
    PaymentID INT UNSIGNED AUTO_INCREMENT,
    AppointmentID INT UNSIGNED NOT NULL,
    PaymentDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentMethod ENUM(
        'Cash',
        'Credit Card',
        'Debit Card',
        'Bank Transfer',
        'Insurance'
    ) NOT NULL,
    PaymentStatus ENUM(
        'Pending',
        'Paid',
        'Refunded'
    ) NOT NULL DEFAULT 'Pending',
    ReferenceNumber VARCHAR(50),

    CONSTRAINT PK_Payment
        PRIMARY KEY (PaymentID),

    CONSTRAINT FK_Payment_Appointment
        FOREIGN KEY (AppointmentID)
        REFERENCES Appointment (AppointmentID)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT UQ_Payment_Reference
        UNIQUE (ReferenceNumber),

    CONSTRAINT CHK_Payment_Amount
        CHECK (Amount > 0)
);





USE SmartClinicDB;

-- =========================================================
-- 1. PATIENT: 8 records
-- =========================================================
INSERT INTO Patient
    (PatientID, FirstName, MiddleName, LastName, DateOfBirth,
     Gender, Phone, Email, Address, RegistrationDate)
VALUES
    (1, 'Ahmed', 'Mohammed', 'Alqahtani', '1990-04-15',
     'Male', '0501234567', 'ahmed.alqahtani@example.sa',
     'Al Olaya, Riyadh', '2026-01-05'),

    (2, 'Noura', 'Abdullah', 'Alharbi', '1987-09-22',
     'Female', '0512345678', 'noura.alharbi@example.sa',
     'Al Rawdah, Jeddah', '2026-01-07'),

    (3, 'Khalid', 'Saad', 'Alotaibi', '1978-02-10',
     'Male', '0523456789', 'khalid.alotaibi@example.sa',
     'Al Faisaliyah, Dammam', '2026-01-10'),

    (4, 'Reem', 'Fahad', 'Alshammari', '1995-11-03',
     'Female', '0534567890', 'reem.alshammari@example.sa',
     'Al Narjis, Riyadh', '2026-01-12'),

    (5, 'Omar', 'Ali', 'Alzahrani', '2001-06-18',
     'Male', '0545678901', 'omar.alzahrani@example.sa',
     'Al Aziziyah, Makkah', '2026-01-15'),

    (6, 'Sara', 'Hamad', 'Aldosari', '1992-08-27',
     'Female', '0556789012', 'sara.aldosari@example.sa',
     'Al Rakah, Khobar', '2026-01-18'),

    (7, 'Faisal', 'Nasser', 'Alghamdi', '1983-12-09',
     'Male', '0567890123', 'faisal.alghamdi@example.sa',
     'Al Khalidiyah, Madinah', '2026-01-20'),

    (8, 'Lama', 'Majed', 'Almutairi', '1998-03-25',
     'Female', '0578901234', 'lama.almutairi@example.sa',
     'Al Yasmin, Riyadh', '2026-01-22');


-- =========================================================
-- 2. DOCTOR: 8 records
-- =========================================================
INSERT INTO Doctor
    (DoctorID, FirstName, MiddleName, LastName, Phone,
     Email, LicenseNumber, DoctorType)
VALUES
    (1, 'Abdullah', 'Saleh', 'Alsubaie', '0581000001',
     'abdullah.alsubaie@clinic.sa', 'SCFHS-GP-1001',
     'General Practitioner'),

    (2, 'Maha', 'Ibrahim', 'Alenezi', '0581000002',
     'maha.alenezi@clinic.sa', 'SCFHS-SP-1002',
     'Specialist'),

    (3, 'Yousef', 'Ahmed', 'Alamri', '0581000003',
     'yousef.alamri@clinic.sa', 'SCFHS-SG-1003',
     'Surgeon'),

    (4, 'Hessa', 'Khalid', 'Alrasheed', '0581000004',
     'hessa.alrasheed@clinic.sa', 'SCFHS-GP-1004',
     'General Practitioner'),

    (5, 'Turki', 'Nawaf', 'Almalki', '0581000005',
     'turki.almalki@clinic.sa', 'SCFHS-SP-1005',
     'Specialist'),

    (6, 'Abeer', 'Sultan', 'Alqahtani', '0581000006',
     'abeer.alqahtani@clinic.sa', 'SCFHS-SG-1006',
     'Surgeon'),

    (7, 'Saad', 'Fahad', 'Almutairi', '0581000007',
     'saad.almutairi@clinic.sa', 'SCFHS-GP-1007',
     'General Practitioner'),

    (8, 'Rania', 'Mohammed', 'Alharbi', '0581000008',
     'rania.alharbi@clinic.sa', 'SCFHS-SP-1008',
     'Specialist');



-- =========================================================
-- 3. DOCTOR SUBTYPE TABLES
-- =========================================================
INSERT INTO General_Practitioner (DoctorID, YearsExperience)
VALUES
    (1, 12),
    (4, 8),
    (7, 15);

INSERT INTO Specialist_Doctor (DoctorID, SubSpecialization)
VALUES
    (2, 'Cardiology'),
    (5, 'Dermatology'),
    (8, 'Pediatrics');

INSERT INTO Surgeon_Doctor (DoctorID, OperationTheater)
VALUES
    (3, 'Operation Theater 1'),
    (6, 'Operation Theater 2');



-- =========================================================
-- 4. APPOINTMENT: 8 records
-- =========================================================
INSERT INTO Appointment
    (AppointmentID, PatientID, DoctorID, AppointmentDate,
     AppointmentTime, Reason, Status, Notes)
VALUES
    (1, 1, 1, '2026-02-01', '09:00:00',
     'General health examination', 'Completed',
     'Routine medical examination completed'),

    (2, 2, 2, '2026-02-01', '10:30:00',
     'Chest discomfort and fatigue', 'Completed',
     'Cardiology assessment required'),

    (3, 3, 3, '2026-02-02', '11:00:00',
     'Abdominal pain', 'Completed',
     'Patient examined for possible surgical condition'),

    (4, 4, 5, '2026-02-03', '13:00:00',
     'Skin irritation', 'Completed',
     'Skin allergy suspected'),

    (5, 5, 7, '2026-02-04', '09:30:00',
     'Fever and sore throat', 'Completed',
     'Symptoms started three days earlier'),

    (6, 6, 8, '2026-02-05', '10:00:00',
     'Child vaccination consultation', 'Completed',
     'Vaccination record reviewed'),

    (7, 7, 6, '2026-02-06', '12:00:00',
     'Knee injury', 'Completed',
     'Minor surgical procedure considered'),

    (8, 8, 4, '2026-02-07', '14:00:00',
     'Headache and dizziness', 'Completed',
     'Blood pressure and glucose tested');



-- =========================================================
-- 5. TREATMENT: 8 records
-- =========================================================
INSERT INTO Treatment
    (TreatmentID, AppointmentID, TreatmentName, Diagnosis,
     Description, TreatmentDate, Cost)
VALUES
    (1, 1, 'General Examination', 'Routine health assessment',
     'Vital signs and general physical examination',
     '2026-02-01', 200.00),

    (2, 2, 'Cardiac Assessment', 'Mild hypertension',
     'Blood pressure evaluation and ECG examination',
     '2026-02-01', 450.00),

    (3, 3, 'Abdominal Examination', 'Gallbladder inflammation',
     'Clinical examination and ultrasound referral',
     '2026-02-02', 600.00),

    (4, 4, 'Dermatology Consultation', 'Allergic dermatitis',
     'Skin examination and allergy treatment plan',
     '2026-02-03', 350.00),

    (5, 5, 'Respiratory Examination', 'Acute pharyngitis',
     'Throat examination and supportive treatment',
     '2026-02-04', 250.00),

    (6, 6, 'Vaccination Service', 'Preventive pediatric care',
     'Age-appropriate vaccination administered',
     '2026-02-05', 300.00),

    (7, 7, 'Knee Wound Treatment', 'Minor knee laceration',
     'Wound cleaning, local anaesthesia, and suturing',
     '2026-02-06', 750.00),

    (8, 8, 'Neurological Screening', 'Tension headache',
     'Basic neurological examination and pain management',
     '2026-02-07', 300.00);



-- =========================================================
-- 6. PRESCRIPTION: 8 records
-- =========================================================
INSERT INTO Prescription
    (PrescriptionID, AppointmentID, PrescriptionDate, Instructions)
VALUES
    (1, 1, '2026-02-01',
     'Take the medicine after meals when required'),

    (2, 2, '2026-02-01',
     'Take regularly and monitor blood pressure'),

    (3, 3, '2026-02-02',
     'Use until the scheduled follow-up examination'),

    (4, 4, '2026-02-03',
     'Apply the cream to the affected area'),

    (5, 5, '2026-02-04',
     'Complete the prescribed treatment period'),

    (6, 6, '2026-02-05',
     'Use fever medicine only when necessary'),

    (7, 7, '2026-02-06',
     'Take after food and keep the wound dry'),

    (8, 8, '2026-02-07',
     'Take when headache symptoms occur');



-- =========================================================
-- 7. MEDICINE: 8 records
-- =========================================================
INSERT INTO Medicine
    (MedicineID, MedicineName, Description, UnitPrice,
     StockQuantity, ExpiryDate)
VALUES
    (1, 'Paracetamol 500 mg',
     'Pain reliever and fever reducer',
     12.50, 200, '2028-06-30'),

    (2, 'Amlodipine 5 mg',
     'Medicine used to control high blood pressure',
     28.00, 120, '2028-03-31'),

    (3, 'Amoxicillin 500 mg',
     'Antibiotic used for bacterial infections',
     35.00, 100, '2027-12-31'),

    (4, 'Hydrocortisone Cream 1%',
     'Topical cream used for skin inflammation',
     22.00, 80, '2027-09-30'),

    (5, 'Ibuprofen 400 mg',
     'Anti-inflammatory medicine and pain reliever',
     18.50, 150, '2028-01-31'),

    (6, 'Omeprazole 20 mg',
     'Medicine used to reduce stomach acid',
     30.00, 110, '2028-04-30'),

    (7, 'Cetirizine 10 mg',
     'Antihistamine used for allergic symptoms',
     16.00, 130, '2027-11-30'),

    (8, 'Povidone-Iodine Solution',
     'Antiseptic solution used for wound cleaning',
     24.00, 70, '2028-02-28');



-- =========================================================
-- 8. PRESCRIPTION_MEDICINE: 10 records
-- =========================================================
INSERT INTO Prescription_Medicine
    (PrescriptionID, MedicineID, Dosage, Frequency,
     DurationDays, Quantity)
VALUES
    (1, 1, '500 mg', 'When required', 5, 10),

    (2, 2, '5 mg', 'Once daily', 30, 30),

    (3, 6, '20 mg', 'Once daily before breakfast', 14, 14),

    (3, 1, '500 mg', 'Twice daily', 5, 10),

    (4, 4, 'Thin layer', 'Twice daily', 7, 1),

    (4, 7, '10 mg', 'Once daily', 7, 7),

    (5, 3, '500 mg', 'Three times daily', 7, 21),

    (6, 1, '500 mg', 'When required', 3, 6),

    (7, 5, '400 mg', 'Twice daily after food', 5, 10),

    (8, 1, '500 mg', 'When required', 5, 10);




-- =========================================================
-- 9. PAYMENT: 8 records
-- =========================================================
INSERT INTO Payment
    (PaymentID, AppointmentID, PaymentDate, Amount,
     PaymentMethod, PaymentStatus, ReferenceNumber)
VALUES
    (1, 1, '2026-02-01 09:45:00', 200.00,
     'Cash', 'Paid', 'PAY-KSA-2026-001'),

    (2, 2, '2026-02-01 11:20:00', 450.00,
     'Credit Card', 'Paid', 'PAY-KSA-2026-002'),

    (3, 3, '2026-02-02 12:10:00', 600.00,
     'Insurance', 'Paid', 'PAY-KSA-2026-003'),

    (4, 4, '2026-02-03 13:45:00', 350.00,
     'Debit Card', 'Paid', 'PAY-KSA-2026-004'),

    (5, 5, '2026-02-04 10:15:00', 250.00,
     'Cash', 'Paid', 'PAY-KSA-2026-005'),

    (6, 6, '2026-02-05 10:50:00', 300.00,
     'Insurance', 'Paid', 'PAY-KSA-2026-006'),

    (7, 7, '2026-02-06 13:20:00', 750.00,
     'Bank Transfer', 'Paid', 'PAY-KSA-2026-007'),

    (8, 8, '2026-02-07 14:40:00', 300.00,
     'Credit Card', 'Paid', 'PAY-KSA-2026-008');


SELECT
    PatientID,
    FirstName,
    MiddleName,
    LastName,
    DateOfBirth,
    Gender,
    Phone,
    Email,
    Address,
    RegistrationDate
FROM Patient
ORDER BY LastName, FirstName;

SELECT
    AppointmentID,
    PatientID,
    DoctorID,
    AppointmentDate,
    AppointmentTime,
    Reason,
    Status
FROM Appointment
WHERE Status = 'Completed'
ORDER BY AppointmentDate, AppointmentTime;

SELECT
    a.AppointmentID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    d.DoctorType,
    a.AppointmentDate,
    a.AppointmentTime,
    a.Reason,
    a.Status
FROM Appointment AS a
INNER JOIN Patient AS p
    ON a.PatientID = p.PatientID
INNER JOIN Doctor AS d
    ON a.DoctorID = d.DoctorID
ORDER BY a.AppointmentDate, a.AppointmentTime;

SELECT
    pr.PrescriptionID,
    pr.AppointmentID,
    m.MedicineName,
    pm.Dosage,
    pm.Frequency,
    pm.DurationDays,
    pm.Quantity
FROM Prescription AS pr
INNER JOIN Prescription_Medicine AS pm
    ON pr.PrescriptionID = pm.PrescriptionID
INNER JOIN Medicine AS m
    ON pm.MedicineID = m.MedicineID
ORDER BY pr.PrescriptionID, m.MedicineName;

SELECT
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    a.AppointmentID,
    pay.PaymentID,
    pay.Amount,
    pay.PaymentMethod,
    pay.PaymentStatus
FROM Patient AS p
LEFT JOIN Appointment AS a
    ON p.PatientID = a.PatientID
LEFT JOIN Payment AS pay
    ON a.AppointmentID = pay.AppointmentID
ORDER BY p.PatientID, a.AppointmentID;

SELECT
    TreatmentID,
    AppointmentID,
    TreatmentName,
    Diagnosis,
    Cost
FROM Treatment
WHERE Cost > (
    SELECT AVG(Cost)
    FROM Treatment
)
ORDER BY Cost DESC;

SELECT
    PatientID,
    FirstName,
    LastName,
    Phone
FROM Patient
WHERE PatientID IN (
    SELECT PatientID
    FROM Appointment
    WHERE Status = 'Completed'
)
ORDER BY LastName, FirstName;

SELECT
    d.DoctorID,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    COUNT(a.AppointmentID) AS TotalAppointments
FROM Doctor AS d
LEFT JOIN Appointment AS a
    ON d.DoctorID = a.DoctorID
GROUP BY
    d.DoctorID,
    d.FirstName,
    d.LastName
ORDER BY TotalAppointments DESC;

SELECT
    PaymentMethod,
    COUNT(PaymentID) AS NumberOfPayments,
    SUM(Amount) AS TotalAmount,
    AVG(Amount) AS AverageAmount
FROM Payment
WHERE PaymentStatus = 'Paid'
GROUP BY PaymentMethod
ORDER BY TotalAmount DESC;

UPDATE Appointment
SET
    Status = 'Cancelled',
    Notes = 'Appointment status updated by clinic administration'
WHERE AppointmentID = 8;

DELETE FROM Medicine
WHERE MedicineID = 8
  AND StockQuantity = 0
  AND MedicineID NOT IN (
      SELECT MedicineID
      FROM Prescription_Medicine
  );

CREATE OR REPLACE VIEW Appointment_Summary AS
SELECT
    a.AppointmentID,
    a.AppointmentDate,
    a.AppointmentTime,
    a.Status AS AppointmentStatus,
    a.Reason,
    p.PatientID,
    CONCAT(p.FirstName, ' ', p.LastName) AS PatientName,
    p.Phone AS PatientPhone,
    d.DoctorID,
    CONCAT(d.FirstName, ' ', d.LastName) AS DoctorName,
    d.DoctorType,
    COALESCE(SUM(pay.Amount), 0.00) AS TotalPaid
FROM Appointment AS a
INNER JOIN Patient AS p
    ON a.PatientID = p.PatientID
INNER JOIN Doctor AS d
    ON a.DoctorID = d.DoctorID
LEFT JOIN Payment AS pay
    ON a.AppointmentID = pay.AppointmentID
   AND pay.PaymentStatus = 'Paid'
GROUP BY
    a.AppointmentID,
    a.AppointmentDate,
    a.AppointmentTime,
    a.Status,
    a.Reason,
    p.PatientID,
    p.FirstName,
    p.LastName,
    p.Phone,
    d.DoctorID,
    d.FirstName,
    d.LastName,
    d.DoctorType;






SELECT *
FROM Appointment_Summary
ORDER BY AppointmentDate, AppointmentTime;

DROP TRIGGER IF EXISTS TRG_Patient_Before_Insert;



DROP TRIGGER IF EXISTS TRG_Patient_Before_Insert;

DELIMITER //

CREATE TRIGGER TRG_Patient_Before_Insert
BEFORE INSERT ON Patient
FOR EACH ROW
BEGIN
    IF NEW.DateOfBirth > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Date of birth cannot be later than the current date';
    END IF;
END//

DELIMITER ;

INSERT INTO Patient
    (FirstName, LastName, DateOfBirth, Gender, Phone, RegistrationDate)
VALUES
    ('Test', 'Patient', '2030-01-01', 'Male',
     '0599999999', CURRENT_DATE);
Patient Management (Patient): Created the patient table with unique constraints on email and phone number to prevent duplicate records.

Doctor Inheritance Hierarchy (Doctor Superclass & Subtypes): Implemented an Enhanced ER (EER) model splitting doctors into a base Doctor table and three specialized sub-tables (General_Practitioner, Specialist_Doctor, Surgeon_Doctor) linked via 1:1 Foreign Keys with CASCADE rules.

Appointment System (Appointment): Built the scheduling logic using a composite UNIQUE constraint on (DoctorID, AppointmentDate, AppointmentTime) to prevent double-booking doctors.

Treatment Tracking (Treatment): Linked medical treatments directly to appointments with automated cascade deletion.

Data Integrity Constraints: Applied CHECK constraints for valid numerical ranges (experience and cost \ge 0) and ENUM data types for status tracking

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


-- 2. Doctor superclass table
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



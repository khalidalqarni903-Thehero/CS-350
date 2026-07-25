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





import ballerina/time;

// Patient information record
public type Patient record {|
    string patientId;
    string patientName;
    string patientEmail;
    string patientPhoneNumber?;
|};

// Doctor information record
public type Doctor record {|
    string doctorId?;
    string doctorName;
    string specialization?;
|};

// Hospital information record
public type Hospital record {|
    string hospitalName;
    string hospitalId?;
    string hospitalAddress?;
|};

// Main appointment record
public type Appointment record {|
    Patient patient;
    Doctor doctor;
    Hospital hospital;
    time:Utc appointmentTime;
    string appointmentId?;
    string status?;
    string notes?;
|};

// Custom error type for duplicate patient
public type DuplicatePatientError distinct error;

// Custom error type for patient operations
public type PatientError DuplicatePatientError;

// Custom error type for duplicate doctor
public type DuplicateDoctorError distinct error;

// Custom error type for doctor operations
public type DoctorError DuplicateDoctorError;

// Custom error type for duplicate hospital
public type DuplicateHospitalError distinct error;

// Custom error type for hospital operations
public type HospitalError DuplicateHospitalError;
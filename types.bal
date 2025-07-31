// Patient information record
public type Patient record {|
    string patientId?;
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


// Appointment record
public type Appointment record {|
    string appointmentId?;
    Patient patient;
    Doctor doctor;
    string hospital;
    //YYYY-MM-DD hh:mm:ss
    string appointmentTime;
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

// Custom error type for duplicate appointment
public type DuplicateAppointmentError distinct error;

// Custom error type for appointment operations
public type AppointmentError DuplicateAppointmentError;
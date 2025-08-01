import ballerina/sql;

// Define record type for patient query results
type PatientRow record {|
    string patientId?;
    string patientName;
    string patientEmail;
    string? patientPhoneNumber;
|};

// Define record type for doctor query results
type DoctorRow record {|
    int id;
    string doctorId;
    string doctorName;
    string? specialization;
|};

// Define record type for appointment query results
type AppointmentRow record {|
    string appointmentId;
    string patientId;
    string doctorId;
    string hospital;
    string appointmentTime;
    string? status;
    string? notes;
|};

//function to check if patient exists by ID
public function getPatientById(string patientId) returns PatientRow|sql:Error|() {
    sql:ParameterizedQuery selectQuery = `
        SELECT patientId, patientName, patientEmail, patientPhoneNumber
        FROM patient 
        WHERE patientId = ${patientId}
    `; 
    
    // Use queryRow() to get a single result
    PatientRow|sql:Error result = mysqlClient->queryRow(selectQuery);

    if result is sql:NoRowsError {
        // No patient found with this ID - this is not a database error
        return ();
    } else if result is sql:Error {
        // This is an actual database error (connection issues, syntax errors, etc.)
        return result;
    } else {
        // Patient exists, return the Patient record
        return result;
    }
}

// Function to check if patient exists by email
public function getPatientByEmail(string email) returns Patient|sql:Error|() {
    sql:ParameterizedQuery selectQuery = `
        SELECT patientId, patientName, patientEmail, patientPhoneNumber
        FROM patient 
        WHERE patientEmail = ${email}
    `;

    // Use query() instead of queryRow() to handle no results gracefully
    stream<PatientRow, sql:Error?> resultStream = mysqlClient->query(selectQuery);

    // Read one result from the stream
    record {| PatientRow value; |} | sql:Error? result = resultStream.next();

    if result is sql:Error {
        return result;
    } else if result is () {
        return ();
    } else {
        // Found a patient row
        PatientRow patientRow = result.value;
        return {
            patientId: patientRow.patientId,
            patientName: patientRow.patientName,
            patientEmail: patientRow.patientEmail,
            patientPhoneNumber: patientRow.patientPhoneNumber
        };
    }
}

// Reusable function to ensure patient exists - either return existing ID or create new patient
public function ensurePatientExists(Patient patient) returns string|PatientError|sql:Error {
    // First check if patient already exists by email
    Patient|sql:Error|() existingPatient = getPatientByEmail(patient.patientEmail);
    
    if existingPatient is sql:Error {
        return existingPatient;
    } else if existingPatient is Patient {
        // Patient already exists, return existing patient ID
        return existingPatient.patientId ?: "UNKNOWN";
    } else {
        // Patient doesn't exist, insert new patient
        return insertPatientRecord(patient);
    }
}

// Internal function to insert patient record into database
function insertPatientRecord(Patient patient) returns string|PatientError|sql:Error {
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO patient (
            patientId, patientName, patientEmail, patientPhoneNumber
        ) VALUES (
            ${patient.patientId}, ${patient.patientName}, ${patient.patientEmail}, ${patient.patientPhoneNumber}
        )
    `;
    
    sql:ExecutionResult|sql:Error result = mysqlClient->execute(insertQuery);
    
    if result is sql:Error {
        return result;
    } else {
        // Extract the generated ID from the execution result
        string|int? generatedId = result.lastInsertId;
        
        if generatedId is string {
            return generatedId;
        } else if generatedId is int {
            return generatedId.toString();
        } else {
            // If no ID was generated, return the provided patientId
            return patient.patientId ?: "UNKNOWN";
        }
    }
}

// Function to insert Patient into database and return the generated patient ID
// Returns clear error if patient already exists by email
public function insertPatient(Patient patient) returns string|PatientError|sql:Error {
    // First check if patient already exists by email
    Patient|sql:Error|() existingPatient = getPatientByEmail(patient.patientEmail);
    
    if existingPatient is sql:Error {
        return existingPatient;
    } else if existingPatient is Patient {
        // Patient already exists, return clear duplicate error
        string errorMessage = string `Patient with email '${patient.patientEmail}' already exists with ID: ${existingPatient.patientId ?: "UNKNOWN"}`;
        return error DuplicatePatientError(errorMessage);
    } else {
        // Patient doesn't exist, proceed with insertion
        return insertPatientRecord(patient);
    }
}

// Function to check if doctor exists by name
public function getDoctorByName(string doctorName) returns Doctor|sql:Error|() {
    sql:ParameterizedQuery selectQuery = `
        SELECT doctorId, doctorName, specialization
        FROM doctor 
        WHERE doctorName = ${doctorName}
    `;
    
    // Use query() instead of queryRow() to handle no results gracefully
    stream<DoctorRow, sql:Error?> resultStream = mysqlClient->query(selectQuery);
    
    // Check if there are any results
    record {|DoctorRow value;|}|sql:Error? result = resultStream.next();
    
    if result is sql:Error {
        return result;
    } else if result is () {
        // No doctor found with this name
        return ();
    } else {
        // Doctor exists, return the Doctor record
        DoctorRow doctorRow = result.value;
        Doctor existingDoctor = {
            doctorId: doctorRow.doctorId,
            doctorName: doctorRow.doctorName,
            specialization: doctorRow.specialization
        };
        
        // Close the stream
        check resultStream.close();
        return existingDoctor;
    }
}

// Reusable function to ensure doctor exists - either return existing ID or create new doctor
public function ensureDoctorExists(Doctor doctor) returns string|DoctorError|sql:Error {
    // First check if doctor already exists by name
    Doctor|sql:Error|() existingDoctor = getDoctorByName(doctor.doctorName);
    
    if existingDoctor is sql:Error {
        return existingDoctor;
    } else if existingDoctor is Doctor {
        // Doctor already exists, return existing doctor ID
        return existingDoctor.doctorId ?: "UNKNOWN";
    } else {
        // Doctor doesn't exist, insert new doctor
        return insertDoctorRecord(doctor);
    }
}

// Internal function to insert doctor record into database
function insertDoctorRecord(Doctor doctor) returns string|DoctorError|sql:Error {
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO doctor (
            doctorId, doctorName, specialization
        ) VALUES (
            ${doctor.doctorId}, ${doctor.doctorName}, ${doctor.specialization}
        )
    `;
    
    sql:ExecutionResult|sql:Error result = mysqlClient->execute(insertQuery);
    
    if result is sql:Error {
        return result;
    } else {
        // Extract the generated ID from the execution result
        string|int? generatedId = result.lastInsertId;
        
        if generatedId is string {
            return generatedId;
        } else if generatedId is int {
            return generatedId.toString();
        } else {
            // If no ID was generated, return the provided doctorId
            return doctor.doctorId ?: "UNKNOWN";
        }
    }
}

// Function to insert Doctor into database and return the generated doctor ID
// Returns clear error if doctor already exists by name
public function insertDoctor(Doctor doctor) returns string|DoctorError|sql:Error {
    // First check if doctor already exists by name
    Doctor|sql:Error|() existingDoctor = getDoctorByName(doctor.doctorName);
    
    if existingDoctor is sql:Error {
        return existingDoctor;
    } else if existingDoctor is Doctor {
        // Doctor already exists, return clear duplicate error
        string errorMessage = string `Doctor with name '${doctor.doctorName}' already exists with ID: ${existingDoctor.doctorId ?: "N/A"}`;
        return error DuplicateDoctorError(errorMessage);
    } else {
        // Doctor doesn't exist, proceed with insertion
        return insertDoctorRecord(doctor);
    }
}

// Function to check if appointment exists by ID
public function getAppointmentById(string appointmentId) returns AppointmentRow|sql:Error|() {
    sql:ParameterizedQuery selectQuery = `
        SELECT appointmentId, patientId, doctorId, hospital, appointmentTime, status, notes
        FROM appointment 
        WHERE appointmentId = ${appointmentId}
    `;
    
    AppointmentRow|sql:Error result = mysqlClient->queryRow(selectQuery);

    if result is sql:NoRowsError {
        // No appointment found with this ID
        return ();
    } else if result is sql:Error {
        // This is an actual database error
        return result;
    } else {
        // Appointment exists, return the Appointment record
        return result;
    }
}

// Function to insert appointment into database with duplicate checking
public function insertAppointment(Appointment appointment, string patientId, string doctorId, string hospital) returns string|AppointmentError|sql:Error {
    // Check if appointment already exists if appointmentId is provided
    if appointment.appointmentId is string {
        string appointmentId = appointment.appointmentId ?: "";
        if appointmentId != "" {
            AppointmentRow|sql:Error|() existingAppointment = getAppointmentById(appointmentId);
            
            if existingAppointment is sql:Error {
                return existingAppointment;
            } else if existingAppointment is AppointmentRow {
                // Appointment already exists, return clear duplicate error
                string errorMessage = string `Appointment with ID '${appointmentId}' already exists`;
                return error DuplicateAppointmentError(errorMessage);
            }
        }
    }
    
    // Insert appointment into database
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO appointment (
            appointmentId, patientId, doctorId, hospital,
            appointmentTime, status, notes
        ) VALUES (
            ${appointment.appointmentId}, ${patientId}, ${doctorId}, ${hospital},
            ${appointment.appointmentTime}, ${appointment.status}, ${appointment.notes}
        )
    `;
    
    sql:ExecutionResult|sql:Error result = mysqlClient->execute(insertQuery);
    
    if result is sql:Error {
        return result;
    } else {
        // Extract the generated ID from the execution result
        string|int? generatedId = result.lastInsertId;
        
        if generatedId is string {
            return generatedId;
        } else if generatedId is int {
            return generatedId.toString();
        } else {
            // If no ID was generated, return the provided appointmentId
            return appointment.appointmentId ?: "UNKNOWN";
        }
    }
}

// Function to process complete appointment creation 
public function createAppointment(Appointment appointment) returns string|AppointmentError|sql:Error {
    // Process patient using reusable function
    string|PatientError|sql:Error patientResult = ensurePatientExists(appointment.patient);
    
    // Handle all possible return types from ensurePatientExists
    if patientResult is PatientError {
        // Convert PatientError to AppointmentError
        return error DuplicateAppointmentError(patientResult.message());
    } else if patientResult is sql:Error {
        return patientResult;
    } else {
        // patientResult is string - Patient ID obtained successfully
        string patientId = patientResult;
        
        // Process doctor using reusable function
        string|DoctorError|sql:Error doctorResult = ensureDoctorExists(appointment.doctor);
        
        // Handle all possible return types from ensureDoctorExists
        if doctorResult is DoctorError {
            // Convert DoctorError to AppointmentError
            return error DuplicateAppointmentError(doctorResult.message());
        } else if doctorResult is sql:Error {
            return doctorResult;
        } else {
            // doctorResult is string - Doctor ID obtained successfully
            string doctorId = doctorResult;
            
            // Insert appointment - both patientId and doctorId are guaranteed to be strings
            return insertAppointment(appointment, patientId, doctorId, appointment.hospital);
        }
    }
}

// Function to close database connection
public function closeDatabaseConnection() returns sql:Error? {
    return mysqlClient.close();
}
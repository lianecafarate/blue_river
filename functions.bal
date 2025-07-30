import ballerina/sql;

// Define record type for patient query results
type PatientRow record {|
    int id;
    string patientId;
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

// Define record type for hospital query results
type HospitalRow record {|
    int id;
    string hospitalId;
    string hospitalName;
    string? hospitalAddress;
|};

// Function to check if patient exists by email
public function getPatientByEmail(string email) returns Patient|sql:Error|() {
    sql:ParameterizedQuery selectQuery = `
        SELECT patientId, patientName, patientEmail, patientPhoneNumber
        FROM patient 
        WHERE patientEmail = ${email}
    `;
    
    // Use query() instead of queryRow() to handle no results gracefully
    stream<PatientRow, sql:Error?> resultStream = mysqlClient->query(selectQuery);
    
    // Check if there are any results
    record {|PatientRow value;|}|sql:Error? result = resultStream.next();
    
    if result is sql:Error {
        return result;
    } else if result is () {
        // No patient found with this email
        return ();
    } else {
        // Patient exists, return the Patient record
        PatientRow patientRow = result.value;
        Patient existingPatient = {
            patientId: patientRow.patientId,
            patientName: patientRow.patientName,
            patientEmail: patientRow.patientEmail,
            patientPhoneNumber: patientRow.patientPhoneNumber
        };
        
        // Close the stream
        check resultStream.close();
        return existingPatient;
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

// Function to check if hospital exists by name
public function getHospitalByName(string hospitalName) returns Hospital|sql:Error|() {
    sql:ParameterizedQuery selectQuery = `
        SELECT hospitalId, hospitalName, hospitalAddress
        FROM hospital 
        WHERE hospitalName = ${hospitalName}
    `;
    
    // Use query() instead of queryRow() to handle no results gracefully
    stream<HospitalRow, sql:Error?> resultStream = mysqlClient->query(selectQuery);
    
    // Check if there are any results
    record {|HospitalRow value;|}|sql:Error? result = resultStream.next();
    
    if result is sql:Error {
        return result;
    } else if result is () {
        // No hospital found with this name
        return ();
    } else {
        // Hospital exists, return the Hospital record
        HospitalRow hospitalRow = result.value;
        Hospital existingHospital = {
            hospitalId: hospitalRow.hospitalId,
            hospitalName: hospitalRow.hospitalName,
            hospitalAddress: hospitalRow.hospitalAddress
        };
        
        // Close the stream
        check resultStream.close();
        return existingHospital;
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
        string errorMessage = string `Patient with email '${patient.patientEmail}' already exists with ID: ${existingPatient.patientId}`;
        return error DuplicatePatientError(errorMessage);
    }
    
    // Patient doesn't exist, proceed with insertion
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
            return patient.patientId;
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
    }
    
    // Doctor doesn't exist, proceed with insertion
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

// Function to insert Hospital into database and return the generated hospital ID
// Returns clear error if hospital already exists by name
public function insertHospital(Hospital hospital) returns string|HospitalError|sql:Error {
    // First check if hospital already exists by name
    Hospital|sql:Error|() existingHospital = getHospitalByName(hospital.hospitalName);
    
    if existingHospital is sql:Error {
        return existingHospital;
    } else if existingHospital is Hospital {
        // Hospital already exists, return clear duplicate error
        string errorMessage = string `Hospital with name '${hospital.hospitalName}' already exists with ID: ${existingHospital.hospitalId ?: "N/A"}`;
        return error DuplicateHospitalError(errorMessage);
    }
    
    // Hospital doesn't exist, proceed with insertion
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO hospital (
            hospitalId, hospitalName, hospitalAddress
        ) VALUES (
            ${hospital.hospitalId}, ${hospital.hospitalName}, ${hospital.hospitalAddress}
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
            // If no ID was generated, return the provided hospitalId
            return hospital.hospitalId ?: "UNKNOWN";
        }
    }
}

// Function to close database connection
public function closeDatabaseConnection() returns sql:Error? {
    return mysqlClient.close();
}
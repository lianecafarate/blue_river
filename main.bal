import ballerina/io;
import ballerina/sql;

public function main() returns error? {
    // ===== PATIENT TESTING =====
    io:println("\n===== Testing Patient Operations =====");
    
    // Create sample patient data
    Patient samplePatient = {
        patientId: "PAT001",
        patientName: "John Doe",
        patientEmail: "john.doe@email.com",
        patientPhoneNumber: "+1-555-0001"
    };

    // Insert sample patient into database and get the returned patient ID
    string|PatientError|sql:Error insertResult = insertPatient(samplePatient);

    if insertResult is DuplicatePatientError {
        io:println("Duplicate Patient Error: ", insertResult.message());
    } else if insertResult is sql:Error {
        io:println("Database Error inserting patient: ", insertResult.message());
    } else {
        io:println("Patient inserted successfully with ID: ", insertResult);
    }

    // Test with the same patient again to see duplicate error
    Patient duplicatePatient = {
        patientId: "PAT002", // Different ID but same email
        patientName: "John Doe Updated",
        patientEmail: "john.doe@email.com", // Same email
        patientPhoneNumber: "+1-555-0002"
    };

    string|PatientError|sql:Error duplicateResult = insertPatient(duplicatePatient);

    if duplicateResult is DuplicatePatientError {
        io:println("Duplicate Patient Error: ", duplicateResult.message());
    } else if duplicateResult is sql:Error {
        io:println("Database Error processing duplicate patient: ", duplicateResult.message());
    } else {
        io:println("Unexpected success for duplicate patient with ID: ", duplicateResult);
    }

    // Test with a completely new patient
    Patient newPatient = {
        patientId: "PAT003",
        patientName: "Jane Smith",
        patientEmail: "jane.smith@email.com", // Different email
        patientPhoneNumber: "+1-555-0003"
    };

    string|PatientError|sql:Error newResult = insertPatient(newPatient);

    if newResult is DuplicatePatientError {
        io:println("Unexpected Duplicate Patient Error: ", newResult.message());
    } else if newResult is sql:Error {
        io:println("Database Error inserting new patient: ", newResult.message());
    } else {
        io:println("New patient inserted successfully with ID: ", newResult);
    }

    // ===== DOCTOR TESTING =====
    io:println("\n===== Testing Doctor Operations =====");

    // Create sample doctor data
    Doctor sampleDoctor = {
        doctorId: "DOC001",
        doctorName: "John Smith",
        specialization: "Cardiology"
    };

    // Insert sample doctor into database and get the returned doctor ID
    string|DoctorError|sql:Error doctorInsertResult = insertDoctor(sampleDoctor);

    if doctorInsertResult is DuplicateDoctorError {
        io:println("Duplicate Doctor Error: ", doctorInsertResult.message());
    } else if doctorInsertResult is sql:Error {
        io:println("Database Error inserting doctor: ", doctorInsertResult.message());
    } else {
        io:println("Doctor inserted successfully with ID: ", doctorInsertResult);
    }

    // Test with the same doctor again to see duplicate error
    Doctor duplicateDoctor = {
        doctorId: "DOC002", // Different ID but same name
        doctorName: "John Smith", // Same name
        specialization: "General Medicine"
    };

    string|DoctorError|sql:Error doctorDuplicateResult = insertDoctor(duplicateDoctor);

    if doctorDuplicateResult is DuplicateDoctorError {
        io:println("Duplicate Doctor Error: ", doctorDuplicateResult.message());
    } else if doctorDuplicateResult is sql:Error {
        io:println("Database Error processing duplicate doctor: ", doctorDuplicateResult.message());
    } else {
        io:println("Unexpected success for duplicate doctor with ID: ", doctorDuplicateResult);
    }

    // Test with a completely new doctor
    Doctor newDoctor = {
        doctorId: "DOC003",
        doctorName: "James Johnson", // Different name
        specialization: "Neurology"
    };

    string|DoctorError|sql:Error newDoctorResult = insertDoctor(newDoctor);

    if newDoctorResult is DuplicateDoctorError {
        io:println("Unexpected Duplicate Doctor Error: ", newDoctorResult.message());
    } else if newDoctorResult is sql:Error {
        io:println("Database Error inserting new doctor: ", newDoctorResult.message());
    } else {
        io:println("New doctor inserted successfully with ID: ", newDoctorResult);
    }

    // ===== HOSPITAL TESTING =====
    io:println("\n===== Testing Hospital Operations =====");

    // Create sample hospital data
    Hospital sampleHospital = {
        hospitalId: "HOS001",
        hospitalName: "City General Hospital",
        hospitalAddress: "123 Main Street, Downtown"
    };

    // Insert sample hospital into database and get the returned hospital ID
    string|HospitalError|sql:Error hospitalInsertResult = insertHospital(sampleHospital);

    if hospitalInsertResult is DuplicateHospitalError {
        io:println("Duplicate Hospital Error: ", hospitalInsertResult.message());
    } else if hospitalInsertResult is sql:Error {
        io:println("Database Error inserting hospital: ", hospitalInsertResult.message());
    } else {
        io:println("Hospital inserted successfully with ID: ", hospitalInsertResult);
    }

    // Test with the same hospital again to see duplicate error
    Hospital duplicateHospital = {
        hospitalId: "HOS002", // Different ID but same name
        hospitalName: "City General Hospital", // Same name
        hospitalAddress: "456 Oak Avenue, Uptown"
    };

    string|HospitalError|sql:Error hospitalDuplicateResult = insertHospital(duplicateHospital);

    if hospitalDuplicateResult is DuplicateHospitalError {
        io:println("Duplicate Hospital Error: ", hospitalDuplicateResult.message());
    } else if hospitalDuplicateResult is sql:Error {
        io:println("Database Error processing duplicate hospital: ", hospitalDuplicateResult.message());
    } else {
        io:println("Unexpected success for duplicate hospital with ID: ", hospitalDuplicateResult);
    }

    // Test with a completely new hospital
    Hospital newHospital = {
        hospitalId: "HOS003",
        hospitalName: "Regional Medical Center", // Different name
        hospitalAddress: "789 Pine Street, Westside"
    };

    string|HospitalError|sql:Error newHospitalResult = insertHospital(newHospital);

    if newHospitalResult is DuplicateHospitalError {
        io:println("Unexpected Duplicate Hospital Error: ", newHospitalResult.message());
    } else if newHospitalResult is sql:Error {
        io:println("Database Error inserting new hospital: ", newHospitalResult.message());
    } else {
        io:println("New hospital inserted successfully with ID: ", newHospitalResult);
    }

    // Close database connection when done
    check closeDatabaseConnection();
}
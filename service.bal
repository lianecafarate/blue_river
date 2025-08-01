import ballerina/http;
import ballerina/sql;

// HTTP service configuration
configurable int patientServicePort = 8080;
configurable int doctorServicePort = 8081;
configurable int appointmentServicePort = 8082;

// Define response record types
type PatientResponse record {|
    string patientId;
    string patientName;
    string patientEmail;
    string patientPhoneNumber?;
|};

type DoctorResponse record {|
    string doctorId?;
    string doctorName;
    string specialization?;
|};

type AppointmentResponse record {|
    string appointmentId;
    string message;
    string status;
|};

type AppointmentDetailsResponse record {|
    string appointmentId;
    string patientId;
    string doctorId;
    string hospital;
    string appointmentTime;
    string status?;
    string notes?;
|};

type ErrorResponse record {|
    string message;
    string errorType;
    int statusCode;
|};

// ===== HTTP Service for Patient Management =====
service /patient on new http:Listener(patientServicePort) {
    // GET endpoint to retrieve patient information
    // curl "http://localhost:8080/patient?patientId=id" | jq
    resource function get .(string patientId) returns PatientResponse|http:NotFound|http:InternalServerError|error {
        PatientRow|sql:Error|() patientResult = getPatientById(patientId);

        if patientResult is PatientRow {
            PatientResponse response = {
                patientId: patientResult.patientId ?: "",
                patientName: patientResult.patientName,
                patientEmail: patientResult.patientEmail,
                patientPhoneNumber: patientResult.patientPhoneNumber
            };
            return response;
        } else if patientResult is sql:Error {
            http:InternalServerError errorResponse = {
                body: {
                    message: patientResult.message(),
                    errorType: "DatabaseError"
                }
            };
            return errorResponse;
        } else {
            http:NotFound notFoundResponse = {
                body: {
                    message: "Patient not found",
                    errorType: "NotFound"
                }
            };
            return notFoundResponse;
        }
    }

    // POST endpoint to create a new patient
    // curl -X POST http://localhost:8080/patient -H "Content-Type: application/json" -d @patient-payload.json | jq
    resource function post .(Patient patientRequest) returns PatientResponse|http:InternalServerError|error {
        Patient patient = {
            patientId: patientRequest.patientId,
            patientName: patientRequest.patientName,
            patientEmail: patientRequest.patientEmail,
            patientPhoneNumber: patientRequest.patientPhoneNumber
        };

        string|PatientError|sql:Error result = insertPatient(patient);

        if result is string {
            // Patient inserted successfully
            PatientResponse response = {
                patientId: result,
                patientName: patient.patientName,
                patientEmail: patient.patientEmail,
                patientPhoneNumber: patient.patientPhoneNumber
            };
            return response;
        } else if result is PatientError {
            // Handle patient-specific errors
            http:InternalServerError errorResponse = {
                body: {
                    message: result.message(),
                    errorType: "DuplicatePatientError"
                }
            };
            return errorResponse;
        } else {
            // Handle generic SQL errors
            http:InternalServerError errorResponse = {
                body: {
                    message: result.message(),
                    errorType: "DatabaseError"
                }
            };
            return errorResponse;
        }
    }
}

// ===== HTTP Service for Doctor Management =====
service /doctor on new http:Listener(doctorServicePort) {
    // GET endpoint to retrieve doctor information
    // curl "http://localhost:8081/doctor?doctorName=name%20lastname" | jq
    resource function get .(string doctorName) returns DoctorResponse|http:NotFound|http:InternalServerError|error {
        Doctor|sql:Error|() doctorResult = getDoctorByName(doctorName);

        if doctorResult is Doctor {
            DoctorResponse response = {
                doctorId: doctorResult.doctorId,
                doctorName: doctorResult.doctorName,
                specialization: doctorResult.specialization
            };
            return response;
        } else if doctorResult is sql:Error {
            http:InternalServerError errorResponse = {
                body: {
                    message: doctorResult.message(),
                    errorType: "DatabaseError"
                }
            };
            return errorResponse;
        } else {
            http:NotFound notFoundResponse = {
                body: {
                    message: "Doctor not found",
                    errorType: "NotFound"
                }
            };
            return notFoundResponse;
        }
    }

    // POST endpoint to create a new doctor
    // curl -X POST http://localhost:8081/doctor -H "Content-Type: application/json" -d @doctor-payload.json | jq
    resource function post .(Doctor doctorRequest) returns DoctorResponse|http:InternalServerError|error {
        Doctor doctor = {
            doctorId: doctorRequest.doctorId,
            doctorName: doctorRequest.doctorName,
            specialization: doctorRequest.specialization
        };

        string|DoctorError|sql:Error result = insertDoctor(doctor);

        if result is string {
            // Doctor inserted successfully
            DoctorResponse response = {
                doctorId: result,
                doctorName: doctor.doctorName,
                specialization: doctor.specialization
            };
            return response;
        } else if result is DoctorError {
            // Handle doctor-specific errors
            http:InternalServerError errorResponse = {
                body: {
                    message: result.message(),
                    errorType: "DuplicateDoctorError"
                }
            };
            return errorResponse;
        } else {
            // Handle generic SQL errors
            http:InternalServerError errorResponse = {
                body: {
                    message: result.message(),
                    errorType: "DatabaseError"
                }
            };
            return errorResponse;
        }
    }
}

// ===== HTTP Service for Appointment Management =====
service /appointment on new http:Listener(appointmentServicePort) {
    // POST endpoint to create a new appointment
    // curl -X POST http://localhost:8082/appointment -H "Content-Type: application/json" -d @appointment-payload.json | jq
    resource function post .(Appointment appointmentRequest) returns AppointmentResponse|http:InternalServerError|error {
        Appointment appointment = {
            patient: appointmentRequest.patient,
            doctor: appointmentRequest.doctor,
            hospital: appointmentRequest.hospital,
            appointmentTime: appointmentRequest.appointmentTime,
            appointmentId: appointmentRequest.appointmentId,
            status: appointmentRequest.status,
            notes: appointmentRequest.notes
        };

        string|AppointmentError|sql:Error result = createAppointment(appointment);

        if result is string {
            // Appointment created successfully
            AppointmentResponse successResponse = {
                appointmentId: result,
                message: "Appointment created successfully",
                status: "success"
            };
            return successResponse;
        } else if result is AppointmentError {
            // Handle appointment-specific errors
            http:InternalServerError errorResponse = {
                body: {
                    message: result.message(),
                    errorType: "AppointmentError"
                }
            };
            return errorResponse;
        } else {
            // Handle generic SQL errors
            http:InternalServerError errorResponse = {
                body: {
                    message: result.message(),
                    errorType: "DatabaseError"
                }
            };
            return errorResponse;
        }
    }

    // GET endpoint to retrieve appointment information
    // curl "http://localhost:8082/appointment?appointmentId=id" | jq
    resource function get .(string appointmentId) returns AppointmentDetailsResponse|http:NotFound|http:InternalServerError|error {
        AppointmentRow|sql:Error|() appointmentResult = getAppointmentById(appointmentId);

        if appointmentResult is AppointmentRow {
            AppointmentDetailsResponse response = {
                appointmentId: appointmentResult.appointmentId,
                patientId: appointmentResult.patientId,
                doctorId: appointmentResult.doctorId,
                hospital: appointmentResult.hospital,
                appointmentTime: appointmentResult.appointmentTime,
                status: appointmentResult.status,
                notes: appointmentResult.notes
            };
            return response;
        } else if appointmentResult is sql:Error {
            http:InternalServerError errorResponse = {
                body: {
                    message: appointmentResult.message(),
                    errorType: "DatabaseError"
                }
            };
            return errorResponse;
        } else {
            http:NotFound notFoundResponse = {
                body: {
                    message: "Appointment not found",
                    errorType: "NotFound"
                }
            };
            return notFoundResponse;
        }
    }
}
import ballerina/io;
import ballerina/sql;
import ballerina/time;

public function main() returns error? {
    // Create sample patient data
    Patient samplePatient = {
        patientId: "PAT001",
        patientName: "John Doe",
        patientEmail: "john.doe@email.com",
        patientPhoneNumber: "+1-555-0001"
    };

    // Create sample doctor data
    Doctor sampleDoctor = {
        doctorId: "DOC001",
        doctorName: "Dr. Smith",
        specialization: "General Medicine"
    };

    // Create sample hospital data
    Hospital sampleHospital = {
        hospitalName: "City General Hospital",
        hospitalId: "CGH001",
        hospitalAddress: "123 Main Street, City Center"
    };

    // Create specific appointment time using Civil time and convert to UTC
    time:Civil appointmentCivil = {
        year: 2025,
        month: 7,
        day: 29,
        hour: 10,
        minute: 30,
        second: 0.0,
        utcOffset: {hours: 0, minutes: 0}
    };
    time:Utc appointmentTime = check time:utcFromCivil(appointmentCivil);

    // Create sample appointment with new structure
    Appointment sampleAppointment = {
        appointmentId: "APT001",
        patient: samplePatient,
        doctor: sampleDoctor,
        hospital: sampleHospital,
        appointmentTime: appointmentTime,
        status: "Scheduled",
        notes: "Regular checkup"
    };

    // Insert appointment into database
    sql:ExecutionResult|sql:Error insertResult = insertAppointment(sampleAppointment);
    if insertResult is sql:Error {
        io:println("Error inserting appointment: ", insertResult.message());
    } else {
        io:println("Appointment inserted successfully. Affected rows: ", insertResult.affectedRowCount);
        
        // Display the formatted datetime using utility function
        string formattedDatetime = formatDisplayDatetime(appointmentTime);
        io:println("Appointment datetime: ", formattedDatetime);
    }

    // Retrieve appointments by patient ID
    Appointment[]|sql:Error|error appointments = getAppointmentsByPatientId("PAT001");
    if appointments is sql:Error {
        io:println("Error retrieving appointments: ", appointments.message());
    } else if appointments is error {
        io:println("Error parsing appointments: ", appointments.message());
    } else {
        io:println("Retrieved appointments: ", appointments.length());
        foreach Appointment appointment in appointments {
            io:println("Appointment ID: ", appointment.appointmentId);
            io:println("Patient: ", appointment.patient.patientName);
            io:println("Doctor: ", appointment.doctor.doctorName);
            io:println("Hospital: ", appointment.hospital.hospitalName);
            
            // Use utility function for display formatting
            string displayDatetime = formatDisplayDatetime(appointment.appointmentTime);
            io:println("Datetime: ", displayDatetime);
        }
    }

    // Create another sample appointment with different datetime
    Patient anotherPatient = {
        patientId: "PAT002",
        patientName: "Jane Smith",
        patientEmail: "jane.smith@email.com",
        patientPhoneNumber: "+1-555-0002"
    };

    Doctor anotherDoctor = {
        doctorId: "DOC002",
        doctorName: "Dr. Johnson",
        specialization: "Cardiology"
    };

    // Create another specific appointment time
    time:Civil anotherAppointmentCivil = {
        year: 2024,
        month: 12,
        day: 26,
        hour: 14,
        minute: 15,
        second: 0.0,
        utcOffset: {hours: 0, minutes: 0}
    };
    time:Utc anotherAppointmentTime = check time:utcFromCivil(anotherAppointmentCivil);

    Appointment anotherAppointment = {
        appointmentId: "APT002",
        patient: anotherPatient,
        doctor: anotherDoctor,
        hospital: sampleHospital,
        appointmentTime: anotherAppointmentTime,
        status: "Confirmed",
        notes: "Follow-up consultation"
    };

    // Insert second appointment
    sql:ExecutionResult|sql:Error anotherInsertResult = insertAppointment(anotherAppointment);
    if anotherInsertResult is sql:Error {
        io:println("Error inserting second appointment: ", anotherInsertResult.message());
    } else {
        io:println("Second appointment inserted successfully. Affected rows: ", anotherInsertResult.affectedRowCount);
    }

    // Retrieve appointments by doctor name
    Appointment[]|sql:Error|error doctorAppointments = getAppointmentsByDoctorName("Dr. Johnson");
    if doctorAppointments is sql:Error {
        io:println("Error retrieving doctor appointments: ", doctorAppointments.message());
    } else if doctorAppointments is error {
        io:println("Error parsing doctor appointments: ", doctorAppointments.message());
    } else {
        io:println("Dr. Johnson's appointments: ", doctorAppointments.length());
        foreach Appointment appointment in doctorAppointments {
            io:println("Patient: ", appointment.patient.patientName);
            io:println("Status: ", appointment.status);
            
            // Use utility function for cleaner display
            string appointmentDatetime = formatDisplayDatetime(appointment.appointmentTime);
            io:println("Appointment datetime: ", appointmentDatetime);
        }
    }

    // Test date range query
    Appointment[]|sql:Error|error rangeAppointments = getAppointmentsByDateRange("2024-12-25 00:00:00", "2024-12-26 23:59:59");
    if rangeAppointments is sql:Error {
        io:println("Error retrieving appointments by date range: ", rangeAppointments.message());
    } else if rangeAppointments is error {
        io:println("Error parsing range appointments: ", rangeAppointments.message());
    } else {
        io:println("Appointments in date range: ", rangeAppointments.length());
        foreach Appointment appointment in rangeAppointments {
            string displayDatetime = formatDisplayDatetime(appointment.appointmentTime);
            io:println("Patient: ", appointment.patient.patientName, " - Datetime: ", displayDatetime);
        }
    }

    // Close database connection when done
    check closeDatabaseConnection();
}
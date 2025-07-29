import ballerina/sql;
import ballerina/time;

// Function to insert appointment data into MySQL database
public function insertAppointment(Appointment appointment) returns sql:ExecutionResult|sql:Error {
    // Convert time:Utc to MySQL datetime format using utility function
    string appointmentDatetime = utcToMySQLDatetime(appointment.appointmentTime);
    
    // Extract patient information
    string patientId = appointment.patient.patientId;
    string patientName = appointment.patient.patientName;
    string patientEmail = appointment.patient.patientEmail;
    string? patientPhone = appointment.patient.patientPhoneNumber;
    
    // Extract doctor information
    string? doctorId = appointment.doctor.doctorId;
    string doctorName = appointment.doctor.doctorName;
    string? specialization = appointment.doctor.specialization;
    
    // Extract hospital information
    string hospitalName = appointment.hospital.hospitalName;
    string? hospitalId = appointment.hospital.hospitalId;
    string? hospitalAddress = appointment.hospital.hospitalAddress;
    
    // Insert without appointmentId if it's auto-generated
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO appointment (
            patientId, patientName, patientEmail, patientPhone,
            doctorId, doctorName, specialization,
            hospitalName, hospitalId, hospitalAddress,
            appointmentTime, status, notes
        ) VALUES (
            ${patientId}, ${patientName}, ${patientEmail}, ${patientPhone},
            ${doctorId}, ${doctorName}, ${specialization},
            ${hospitalName}, ${hospitalId}, ${hospitalAddress},
            ${appointmentDatetime}, ${appointment.status}, ${appointment.notes}
        )
    `;
    
    return mysqlClient->execute(insertQuery);
}

// Define a record type for database query results
type AppointmentRow record {|
    int id;  // Auto-generated primary key
    string patient_id;
    string patient_name;
    string patient_email;
    string? patient_phone;
    string? doctor_id;
    string doctor_name;
    string? specialization;
    string hospital_name;
    string? hospital_id;
    string? hospital_address;
    string appointment_datetime;
    string? status;
    string? notes;
|};

// Function to retrieve appointments by patient ID
public function getAppointmentsByPatientId(string patientId) returns Appointment[]|sql:Error|error {
    sql:ParameterizedQuery selectQuery = `
        SELECT id, patientId, patientName, patientEmail, patientPhone,
               doctorId, doctorName, specialization,
               hospitalName, hospitalId, hospitalAddress,
               appointmentTime, status, notes
        FROM appointment 
        WHERE patientId = ${patientId}
    `;
    
    stream<AppointmentRow, sql:Error?> resultStream = mysqlClient->query(selectQuery);
    Appointment[] appointments = [];
    
    check from AppointmentRow row in resultStream
        do {
            // Parse MySQL datetime string using utility function
            string datetimeStr = row.appointment_datetime;
            time:Utc appointmentUtc = check parseMySQLDatetime(datetimeStr);
            
            // Create nested records
            Patient patient = {
                patientId: row.patient_id,
                patientName: row.patient_name,
                patientEmail: row.patient_email,
                patientPhoneNumber: row.patient_phone
            };
            
            Doctor doctor = {
                doctorId: row.doctor_id,
                doctorName: row.doctor_name,
                specialization: row.specialization
            };
            
            Hospital hospital = {
                hospitalName: row.hospital_name,
                hospitalId: row.hospital_id,
                hospitalAddress: row.hospital_address
            };
            
            Appointment appointment = {
                appointmentId: row.id.toString(), // Convert auto-generated ID to string
                patient: patient,
                doctor: doctor,
                hospital: hospital,
                appointmentTime: appointmentUtc,
                status: row.status,
                notes: row.notes
            };
            
            appointments.push(appointment);
        };
    
    return appointments;
}

// Function to retrieve appointments by doctor name
public function getAppointmentsByDoctorName(string doctorName) returns Appointment[]|sql:Error|error {
    sql:ParameterizedQuery selectQuery = `
        SELECT appointmentId, patientId, patientName, patientEmail, patientPhone,
               doctorId, doctorName, specialization,
               hospitalName, hospitalId, hospitalAddress,
               appointmentTime, status, notes
        FROM appointment 
        WHERE doctorName = ${doctorName}
    `;
    
    stream<AppointmentRow, sql:Error?> resultStream = mysqlClient->query(selectQuery);
    Appointment[] appointments = [];
    
    check from AppointmentRow row in resultStream
        do {
            // Parse MySQL datetime string using utility function
            string datetimeStr = row.appointment_datetime;
            time:Utc appointmentUtc = check parseMySQLDatetime(datetimeStr);
            
            Patient patient = {
                patientId: row.patient_id,
                patientName: row.patient_name,
                patientEmail: row.patient_email,
                patientPhoneNumber: row.patient_phone
            };
            
            Doctor doctor = {
                doctorId: row.doctor_id,
                doctorName: row.doctor_name,
                specialization: row.specialization
            };
            
            Hospital hospital = {
                hospitalName: row.hospital_name,
                hospitalId: row.hospital_id,
                hospitalAddress: row.hospital_address
            };
            
            Appointment appointment = {
                appointmentId: row.id.toString(),
                patient: patient,
                doctor: doctor,
                hospital: hospital,
                appointmentTime: appointmentUtc,
                status: row.status,
                notes: row.notes
            };
            
            appointments.push(appointment);
        };
    
    return appointments;
}

// Function to retrieve appointments by date range
public function getAppointmentsByDateRange(string startDate, string endDate) returns Appointment[]|sql:Error|error {
    sql:ParameterizedQuery selectQuery = `
        SELECT appointmentId, patientId, patientName, patientEmail, patientPhone,
               doctorId, doctorName, specialization,
               hospitalName, hospitalId, hospitalAddress,
               appointmentTime, status, notes
        FROM appointment 
        WHERE appointmentTime BETWEEN ${startDate} AND ${endDate}
        ORDER BY appointmentTime
    `;
    
    stream<AppointmentRow, sql:Error?> resultStream = mysqlClient->query(selectQuery);
    Appointment[] appointments = [];
    
    check from AppointmentRow row in resultStream
        do {
            string datetimeStr = row.appointment_datetime;
            time:Utc appointmentUtc = check parseMySQLDatetime(datetimeStr);
            
            Patient patient = {
                patientId: row.patient_id,
                patientName: row.patient_name,
                patientEmail: row.patient_email,
                patientPhoneNumber: row.patient_phone
            };
            
            Doctor doctor = {
                doctorId: row.doctor_id,
                doctorName: row.doctor_name,
                specialization: row.specialization
            };
            
            Hospital hospital = {
                hospitalName: row.hospital_name,
                hospitalId: row.hospital_id,
                hospitalAddress: row.hospital_address
            };
            
            Appointment appointment = {
                appointmentId: row.id.toString(),
                patient: patient,
                doctor: doctor,
                hospital: hospital,
                appointmentTime: appointmentUtc,
                status: row.status,
                notes: row.notes
            };
            
            appointments.push(appointment);
        };
    
    return appointments;
}

// Function to close database connection
public function closeDatabaseConnection() returns sql:Error? {
    return mysqlClient.close();
}
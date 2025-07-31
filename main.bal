import ballerina/io;

public function main() returns error? {
    io:println("Appointment Service is starting...");
    io:println("Patient Service will be available at: http://localhost:8080/patient");
    io:println("Doctor Service will be available at: http://localhost:8081/doctor");
    io:println("Appointment Service will be available at: http://localhost:8082/appointment");
}
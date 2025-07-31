CREATE DATABASE IF NOT EXISTS blueriver;

USE blueriver;

CREATE TABLE IF NOT EXISTS patient (
   patientId VARCHAR(255) PRIMARY KEY,
   patientName VARCHAR(255) NOT NULL,
   patientEmail VARCHAR(255) NOT NULL UNIQUE,
   patientPhoneNumber VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS doctor (
   doctorId VARCHAR(255) PRIMARY KEY,
   doctorName VARCHAR(255) NOT NULL,
   specialization VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS appointment (
   appointmentId VARCHAR(255) PRIMARY KEY,
   patientId VARCHAR(255) NOT NULL,
   doctorId VARCHAR(255) NOT NULL,
   hospital VARCHAR(255) NOT NULL,
   appointmentTime DATETIME NOT NULL,
   status VARCHAR(50),
   notes TEXT,
   FOREIGN KEY (patientId) REFERENCES patient(patientId),
   FOREIGN KEY (doctorId) REFERENCES doctor(doctorId)
);
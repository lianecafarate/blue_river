// HTTP service configuration
configurable int patientServicePort = 8080;
configurable int doctorServicePort = 8081;
configurable int appointmentServicePort = 8082;

// MySQL database configuration
configurable string dbHost = "localhost";
configurable string dbUser = "root";
configurable string dbPassword = "rootpass";
configurable string dbName = "blueriver";
configurable int dbPort = 3306;

// IBM MQ configuration
configurable string queueManagerName = "QM1";
configurable string queueHost = "localhost";
configurable int queuePort = 1414;
configurable string queueChannel = "DEV.APP.SVRCONN";
configurable string queueUserID = "app";
configurable string queuePassword = "password";
configurable string queueName = "APPOINTMENT.QUEUE";
configurable decimal pollingInterval = 1.0;
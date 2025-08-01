import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerinax/ibm.ibmmq;

// MySQL client initialization
final mysql:Client mysqlClient = check new (dbHost, dbUser, dbPassword, dbName, dbPort);

// IBM MQ client initialization
final ibmmq:QueueManager queueManager = check new (
    name = queueManagerName, host = queueHost, port = queuePort, channel = queueChannel, userID = queueUserID, password = queuePassword
);
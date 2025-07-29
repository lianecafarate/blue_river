import ballerinax/mysql;
import ballerinax/mysql.driver as _;

// MySQL client initialization
final mysql:Client mysqlClient = check new (dbHost, dbUser, dbPassword, dbName, dbPort);
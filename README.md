## rt106-MySQL


This git project has the setup and initialization files for the Rt 106 MySQL database.

This database is initially used for logging messages, execution records,
user feedback on algorithms, information on connected clients, and health status of
system components.  In the future, other metadata may be stored here.

### Create the Rt106 MySQL Docker image 
To create the Rt106 MySQL Docker image, run this command:
```
docker build -t rt106/rt106-mysql --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy --build-arg no_proxy=$no_proxy .
```

### To set up MySQL in a Docker Compose file

This needs to be part of any Docker Compose file that builds the system:
```
version: '3'
services:
  mysql:
    image: rt106/rt106-mysql:latest
    ports:
    - 3306:3306
    volumes:
    - rt106-mysql-volume:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: rt106mysql
volumes:
  rt106-mysql-volume:
```

### To test the MySQL container:

(These steps are not required to build the system but can be useful for troubleshooting.)

On the machine running the MySQL Docker container, first determine the name of the database container by running 'docker ps'.  

For these examples, we will assume that name is rt106-mysql, but replace that name if it is something else.

Connect a bash session to the MySQL container:
```
docker exec -it rt106-mysql bash
```
From this bash session, log into MySQL:
```
mysql -u root -p
```
You will be prompted for a password, which is:
```
rt106mysql
```
You can see all the defined databases by typing:
```
SHOW DATABASES;
```
The above should include the rt106db database.

You should then get a "mysql>" prompt.  Type this to use the OIP database:
```
USE rt106db;
```
You should see 3 table names listed if you type:
```
SHOW TABLES;
```
Print out the contents from the OIP execution log table:
```
SELECT * FROM execution_log;
```

#### Troubleshooting

If you run the above tests and do not see the rt106db database, then at the mysql> prompt, type:
```
source /docker-entrypoint-initdb.d/rt106db.sql
```

#### Maintenance

To delete your execution list, then at the mysql> prompt, type:
```
DELETE FROM execution_log;
```

To selectively delete items from the execution, first you can query the entire list using:
```
SELECT * FROM execution_log;
```

To delete one items from the execution by ID (e.g. ID of '8'):
```
DELETE FROM execution_log WHERE ID='8';
```

To delete all items prior to a given execution by ID (e.g. before ID of '15'):
```
DELETE FROM execution_log WHERE ID<'15';
```

Items can also be deleted by time.  

NOTE: There are 3 "message_types" in execution_log:  request, response, and execution.  The execution combines information from the individual request and response.

Request messages have start_time.

Response messages have an end_time.

Execution messages have both.

NOTE:  The units of the response message end_time are off by a factor of 1000 from the other times.  This is an inconsistency that should be fixed, but for now, that needs to be taken into account in the delete statements.

```
DELETE FROM execution_log WHERE message_type='request' AND start_time<'1493740582000';
DELETE FROM execution_log WHERE message_type='execution' AND start_time<'1493740582000';
DELETE FROM execution_log WHERE message_type='response' AND end_time<'1493740582';
```

To delete the 3 messages (request, response, execution) for a given execution ID:
```
DELETE FROM execution_log WHERE JSON_EXTRACT(message_json,"$.header.executionId") = '619652c7-9751-4d05-a100-54f6c069a8d0';
```

Deleting based on other fields can be tricky, in that the request / response / execution should ideally be deleted together, but not all of these messages contain all fields.
For example, response messages do not contain analytic ID.


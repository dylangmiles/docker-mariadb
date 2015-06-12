DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.db WHERE Db LIKE 'test%';
DROP DATABASE test;
UPDATE mysql.user SET password = password('abc123') WHERE user = 'root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'172.17.42.%'
    IDENTIFIED BY 'abc123'  
    WITH GRANT OPTION;
FLUSH PRIVILEGES;
flush privileges;

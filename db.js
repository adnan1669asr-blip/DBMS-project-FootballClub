const mysql = require('mysql2');

const db = mysql.createConnection({
       host: 'localhost',
       user: 'root', 
       password: '1234', 
       database: 'footballmanagment', 
       port: 3306
});

db.connect((err) => {
    if (err) throw err;
    console.log('Connected to MySQL database');
});

module.exports = db;

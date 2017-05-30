'use strict';

const mysqlModule = require('mysql');

let host, user, password, database;

const mysql = {
  connect: () => {
    let connection = mysqlModule.createConnection( { host, user, password, database } );
    connection.connect();
    return connection;
  },
  query: (sql, values, callback) => {
    let connection = mysql.connect();
    let next = (error, results, fields) => {
      connection.end();
      callback(error, results, fields);
    };
    connection.query({sql, values}, next);
  }
};
const queries = {
  insert: (event, context, ua, callback) => mysql.query(
    "INSERT INTO `apigw` SET ?",
    {event, context, ua},
    callback
  ),
  select: callback => mysql.query(
    "SELECT * FROM `charts`",
    [],
    (error, results, fields) => {
      if (error) return callback(error, results, fields);
      callback(error, results.map(result => result.options ? JSON.parse(result.options) : {}), fields);
    }
  )
};

module.exports = details => {
  host = details.host;
  user = details.user;
  password = details.password;
  database = details.database;
  return queries;
};

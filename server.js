const express = require('express');
const app = express();
 const Sequelize = require('sequelize');

const { Pool } = require('pg')
const connectionString = 'postgres://ulgpbzcaxnbkft:be2cfa564ede47fff1b20578c0df3b8426edec6086da33da15db2b7f7b898f0d@ec2-54-246-185-161.eu-west-1.compute.amazonaws.com:5432/d1ebnbl3rm8869'
const sequelize = new Sequelize(connectionString);

const pool = new Pool({
  sequelize,
})



pool.query('SELECT NOW()', (err, res) => {
  // console.log(err, res)
  pool.end()
})

app.get('/', (req, res) => {
  res
    .status(200)
    .send('Hello server is running')
    .end();
});
 
// Start the server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`App listening on port ${PORT}`);
  console.log('Press Ctrl+C to quit.');
});
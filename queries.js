const { request } = require('express')
const { Pool } = require('pg')
const connectionString = 'postgres://ulgpbzcaxnbkft:be2cfa564ede47fff1b20578c0df3b8426edec6086da33da15db2b7f7b898f0d@ec2-54-246-185-161.eu-west-1.compute.amazonaws.com:5432/d1ebnbl3rm8869'


const pool = new Pool({
 connectionString,
 ssl: {
 rejectUnauthorized: false
 }})


const addUserToEvent = (request, response) => {
    const {userId, eventId} = request.body 
    pool.query('SELECT simbirsoft.addusertoevent($1, $2)', [userId, eventId] ,(error, results) => {
        if (error) {
            response.status(500).json(error.message)
            return
        } 
        response.status(200).json('success')
    })
}

const deleteUserFromEvent = (request, response) => {
    const {userId, eventId} = request.body
    pool.query('SELECT simbirsoft.deleteuserfromevent($1, $2)', [userId, eventId] ,(error, results) => {
        if (error) {
            response.status(500).json(error.message)
            return
        } 
        response.status(200).json('success')
    })
}

const createFeedback = (request, response) => {
    const {userId, eventId, feedbackText} = request.body
    pool.query('SELECT simbirsoft.createfeedback($1, $2, $3)', [userId, eventId, feedbackText] ,(error, results) => {
        if (error) {
            response.status(500).json(error.message)
            return
        } 
        response.status(200).json('success')
    })
}

const getAllParticipants = (request, response) => {
    const {eventId} = request.query
    pool.query('SELECT simbirsoft.getallparticipants($1)', [eventId] ,(error, results) => {
        if (error) {
            response.status(500).json(error.message)
            return
        } 
        response.status(200).json(results.rows)
    })
}

const getEvents = (request, response) => {
  const {date, cityId, directionId, participation} = request.query
  
  pool.query('SELECT simbirsoft.geteventsbyfilters($1::timestamp without time zone, $2, $3, 4)', [date, cityId, directionId, participation],  (error, results) => {
          if (error) { 
              response.status(500).json(error.message)
              return
          }
          response.status(200).json(results.rows)
      })
} 
 
const getDirection = (request, response) => {
 pool.query('SELECT simbirsoft.getdirection()', (error, results) => {
        if (error) {
            response.status(500).json(error.message)
            return

        }
        response.status(200).json(results.rows)
    })
}

const getCity = (request, response) => {
 pool.query('SELECT simbirsoft.getcity()', (error, results) => {
        if (error) {
            response.status(500).json(error.message)
            return

        }
        response.status(200).json(results.rows)
    })
}

const getEventsbyId = (request, response) => {
  const {eventId} = request.query

  pool.query('SELECT simbirsoft.geteventsbyid()',[eventId], (error, results) => {
          if (error) {
              response.status(500).json(error.message)
              return

          }
          response.status(200).json(results.rows)
      })
}

const createEvent = (request, response) => {
  const {name, date, cityId, place, description, maxCount, direction, eventHolderId} = request.body
    const thumbnail = request.file.filename || ''
    pool.query('SELECT simbirsoft.createevent($1, $2::timestamp without time zone, $3, $4, $5, $6, $7, $8, $9)',[name, date, cityId, place, description, maxCount, direction, thumbnail, eventHolderId], (error, results) => {
          if (error) {
              response.status(500).json(error.message)
              return

          }
          response.status(200).json(results.rows)
      })
}

module.exports = {
  addUserToEvent,
  deleteUserFromEvent,
  createFeedback,
  getAllParticipants,
  getCity,
  getEvents,
  getDirection,
  getEventsbyId,
  createEvent
}
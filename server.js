const express = require('express');
const app = express();
const port = 3000
const db = require('./queries')
const bodyParser = require("body-parser");
// import swaggerAutogen from 'swagger-autogen'
// const endpointsFiles = [join(_dirname, './queries.js')]

app.use(bodyParser.json())
app.use(
    bodyParser.urlencoded({
        extended: true,
    })
)

//  app.use(express.methodOverride());
app.use(bodyParser.multipart({
    uploadDir: './uploads',
    keepExtensions: true
}));
 
app.get('/getCity/', db.getCity)
//
app.get('/getEvents/', db.getEvents) 
//
app.post('/addUserToEvent/', db.addUserToEvent) 
app.delete('/deleteUserFromEvent/', db.deleteUserFromEvent) 
//
app.post('/createFeedback/', db.createFeedback) 
//
app.get('/getAllParticipants/', db.getAllParticipants) 
//
app.get('/getDirection/', db.getDirection) 
//
app.get('/getEventsbyId/', db.getEventsbyId) 
//
app.post('/upload', function(req, res){
    // Returns json of uploaded file
    res.json(req.files);
});


app.listen(port, () => {
    console.log(`App running on port ${port}.`)
})

 
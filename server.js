const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080
let fs = require('fs-extra');
const db = require('./queries')
const multer = require('multer')
const bodyParser = require("body-parser");
// import swaggerAutogen from 'swagger-autogen'
// const endpointsFiles = [join(_dirname, './queries.js')]

app.use(bodyParser.json())
app.use(
    bodyParser.urlencoded({
        extended: true,
    })
)

 
const storage  = multer.diskStorage({
    destination: function (req, file, cb) {
        let newDestination = ''
        if (req.body.eventId) {
            newDestination = `./uploads/${req.body.eventId}`;
        } else {
            newDestination = `./uploads/`;
        }

        fs.mkdirsSync(newDestination);
        cb(null, newDestination);
    }
});

const upload = multer(
    { 
        dest: 'uploads/',
        limits: {
            fieldNameSize: 100,
            fileSize: 60000000
        },
        storage: storage
    }
);
 

app.get('/', (req, res) => {
  res.send('Is working')
})

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
app.post("/uploadFiles", upload.array("files"), () =>  res.json({ message: "Successfully uploaded files" }));
 
app.post('/createEvent/',  upload.single('thumbnail'), db.createEvent
) 

app.listen(PORT, () => {
    console.log(`App running.`)
})

 
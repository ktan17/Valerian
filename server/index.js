var express = require('express');

var app = express();
app.use(express.bodyParser());

app.get('/', (req, res) => {
    res.send("Googly moogly");
})

app.post('/', (req, res) => {
    var object = req.body;
    var message = object.user_message;
    res.send({
	"success": true,
	"received_message": message
    });
})

app.listen(3000, () => {
    console.log("Listening on port 3000!");
})

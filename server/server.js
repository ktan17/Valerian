var express = require('express');

var app = express();
app.use(express.bodyParser());

app.get('/', (req, res) => {
    res.send("Googly moogly");
})

app.post('/', (req, res) => {
    var object = req.body;
    var message = object.user_message;

    var spawn = require('child_process').spawn;
    var process = spawn('python', ["./FelixMain.py", message]);

    process.stdout.on('data', (data) => {
	res.send(data);
    });
})

var port = process.env.PORT || 8080;
app.listen(port, () => {
    console.log("Listening on port 3000!");
})

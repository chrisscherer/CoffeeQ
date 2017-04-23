var express = require('express'), app = express(), port = process.env.PORT || 3000;


var bodyParser = require('body-parser')
app.use( bodyParser.json() );       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
  extended: true
})); 

app.listen(port);

console.log('todo list RESTful API server started on: ' + port);


// database stuff
var pg = require('pg');
 
// create a config to configure both pooling behavior 
// and client options 
// note: all config is optional and the environment variables 
// will be read if the config is not present 
var config = {
  user: 'coffeeq', //env var: PGUSER 
  database: 'coffeeq', //env var: PGDATABASE 
  password: 'QuincyJones', //env var: PGPASSWORD 
  host: 'localhost', // Server hosting the postgres database 
  port: 5432, //env var: PGPORT 
  max: 10, // max number of clients in the pool 
  idleTimeoutMillis: 30000, // how long a client is allowed to remain idle before being closed 
};
 
 
//this initializes a connection pool 
//it will keep idle connections open for 30 seconds 
//and set a limit of maximum 10 idle clients 
var pool = new pg.Pool(config);
 
pool.on('error', function (err, client) {
  // if an error is encountered by a client while it sits idle in the pool 
  // the pool itself will emit an error event with both the error and 
  // the client which emitted the original error 
  // this is a rare occurrence but can happen if there is a network partition 
  // between your application and the database, the database restarts, etc. 
  // and so you might want to handle it and at least log it out 
  console.error('idle client error', err.message, err.stack)
})




app.post('/v1/buy', function (req, res) {
	// TODO - call method to 
	// for (int i = 0; i < req.body.size) {
	//     insert(...)
	// }
	
	var user_id;

	pool.connect(function(err, client, done) {
	  if(err) { return console.error('error fetching client from pool', err); }

	  // client.query('SELECT $1::int AS number', ['1'], function(err, result) {
	  var query = client.query('SELECT * from users where email = $1', [req.body.email]);
	  query.on('row', function(row) {
	  	console.log(row);
	    user_id = row.id;
	    console.log("inside " + user_id);

	    if (user_id == undefined) {
		  	var query = client.query('INSERT into users values (first_name = $1, email = $2) returning id', [req.body.first_name, req.body.email]);
		  	query.on('row', function(row) {
		    	user_id = row.id;
		  	});

			console.log("if")
			// query = client.query('select * from transactions', []);
		  	query = client.query('INSERT into transactions values (buyer_id = $1::int, cafe_id = $2)', [user_id, req.body.cafe_id]);
		  	query.on('row', function(row) {
		    	console.log("row " + row);
		  	});
	  	} else {
		  	query = client.query('INSERT into transactions (buyer_id, cafe_id) values ($1::int, $2::int)', [user_id, req.body.cafe_id]);
		  	// query = client.query('select * from transactions', []);
		  	query.on('row', function(row) {
		    	console.log(row);
		  	});
	  	}

	  	console.log("buyer_id : " + user_id);
	  	query = client.query('SELECT count(*) from transactions where buyer_id = $1', [user_id]);
	  	query.on('row', function(row) {
	  		// console.log("# transactions: ")
	  		// console.log(row.count)
	  		// console.log(JSON.stringify({"success" : true, "total" : row.count}))
	  		res.send(JSON.stringify({"success" : true, "total" : row.count}));
	  	});

		//"{0}{1}".format("{1}", "{0}")
  		

	  });


	});


  	// res.send(req.body.email)
})

app.post('/v1/redeem/', function (req, res) {
	var cafe_id = req.body.cafe_id;


	res.send("{\"success\" : true}");
})
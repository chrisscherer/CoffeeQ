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
	var user_id;

	pool.connect(function(err, client, done) {
	  if(err) { return console.error('error fetching client from pool', err); }

	  var query = client.query('SELECT * from users where email = $1', [req.body.email]);
	  // console.log(query)
	  var rows = [];

	  query.on('row', function(row) {
	  	rows.push(row);
	  });
	  query.on('error', function(error) {
      	console.log(error);
       });

	  query.on('end', function(result) {
	  	if (rows.length == 0) {
	  		var query = client.query('INSERT into users (first_name, email) values ($1, $2) returning id', [req.body.first_name, req.body.email]);
		  	query.on('row', function(row) {
		    	user_id = row.id;
		  	});
			
			insertTransactions(client, user_id, req.body.cafe_id, req.body.quantity);
		}
		else {
      		user_id = rows[0].id;
      		insertTransactions(client, user_id, req.body.cafe_id, req.body.quantity);
	  	}

	  	// return the json response of success and total # of transactions for the buyer up until now
	  	query = client.query('SELECT count(*) from transactions where buyer_id = $1', [user_id]);
	  	query.on('row', function(row) {
	  		res.send(JSON.stringify({"success" : true, "total" : row.count}));
	  	});
      });

	});
})

function insertTransactions(client, user_id, cafe_id, quantity) {
	for (i = 0; i < quantity; i++) {
		var query = client.query('INSERT into transactions (buyer_id, cafe_id) values ($1::int, $2::int)', [user_id, cafe_id]);
		query.on('row', function(row) {
			console.log(row);
		});
	}
}

app.post('/v1/redeem/', function (req, res) {
	var cafe_id = req.body.cafe_id;

	pool.connect(function(err, client, done) {
	  if(err) { return console.error('error fetching client from pool', err); }

	  var rows = [];
	  var query = client.query('SELECT t.id as trans_id, * FROM transactions t left join users u on (t.buyer_id = u.id) where cafe_id = $1 and date_redeemed is null order by date_purchased limit 1', [cafe_id]);

	  query.on('row', function(row) {
	  	rows.push(row);
	  });
	  query.on('error', function(error) {
      	console.log(error);
      });

	  query.on('end', function(result) {
	  	if (rows.length == 0) {
			res.send(JSON.stringify({"success" : false, "error_message" : "no coffees available at this location"}));
		}
		else {
			email = rows[0].email;
			first_name = rows[0].first_name;
			// console.log("updating " + rows[0].trans_id);

			query = client.query('UPDATE transactions SET date_redeemed = now() where id = $1', [rows[0].trans_id]);
	  		query.on('end', function(result) {
	  			res.send(JSON.stringify({"success" : true, "patron_name" : first_name, "patron_email" : email }));
	  		});
	  	}
      });

	});
})



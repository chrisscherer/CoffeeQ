var express = require('express'), app = express(), port = process.env.PORT || 3000;

const util = require('util');

var bodyParser = require('body-parser')
app.use( bodyParser.json() );       // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
  extended: true
})); 

app.listen(port);

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
  host: 'coffeeq.c3kft858tuq1.us-west-2.rds.amazonaws.com', // Server hosting the postgres database 
  port: 5432, //env var: PGPORT 
  max: 10, // max number of clients in the pool 
  idleTimeoutMillis: 30000, // how long a client is allowed to remain idle before being closed 
};
 
 
//this initializes a connection pool 
//it will keep idle connections open for 30 seconds 
//and set a limit of maximum 10 idle clients 
var pool = new pg.Pool(config);
pool.on('error', function (err, client) {
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
			
			insertTransactions(client, user_id, req.body.cafe_id, req.body.message, req.body.quantity);
		}
		else {
      		user_id = rows[0].id;
      		insertTransactions(client, user_id, req.body.cafe_id, req.body.message, req.body.quantity);
	  	}

	  	// return the json response of success and total # of transactions for the buyer up until now
	  	query = client.query('SELECT count(*) from transactions where buyer_id = $1', [user_id]);
	  	query.on('row', function(row) {
	  		res.send(JSON.stringify({"success" : true, "total" : row.count}));
	  	});
      });

	});
})

function insertTransactions(client, user_id, cafe_id, message, quantity) {
	for (i = 0; i < quantity; i++) {
		var query = client.query('INSERT into transactions (buyer_id, cafe_id, message) values ($1::int, $2::int, $3)', [user_id, cafe_id, message]);
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
			date_purchased = rows[0].date_purchased;

			query = client.query('UPDATE transactions SET date_redeemed = now(), redeemer_message = $1, redeemer_first_name = $2, redeemer_last_name = $3 where id = $4', [req.body.message, req.body.first_name, req.body.last_name, rows[0].trans_id]);
	  		query.on('end', function(result) {
	  			if (email != undefined && email != "") {
	  				sendRedeemedEmail(email, first_name, date_purchased, req.body.first_name, req.body.message);
	  			}

	  			res.send(JSON.stringify({"success" : true, "patron_name" : first_name, "patron_email" : email }));
	  		});
	  	}
      });

	});
});

function sendRedeemedEmail(email, first_name, date_purchased, redeemer_first_name, redeemer_message) {
	var api_key = 'key-3ebbc68ff0db1c1342f1b8219e67efc6';
	var domain = 'sandbox1f014df702eb448e9f749216d621b8ea.mailgun.org';
	var mailgun = require('mailgun-js')({apiKey: api_key, domain: domain});
	 
	// var redeemer_name = "<Redeemer Name>"
	var message = "Thanks for the coffee, Bro!"

	var body = util.format("Hi %s\n\nCongrats, the coffee you purchased on date has been redeemed!\nYou are a true hero and coffee ambassador for your community.\n\n", first_name) +
	util.format("%s would like to thank you with this message:\n\n\"%s", redeemer_first_name, redeemer_message) +
	"\"\n\nLet’s inspire others to pay it forward by sharing your good deed.\nLinks to social media including location of purchase for publicity.\n\n" +
	"A simple act of kindness over a cup of coffee allows us to help those we may otherwise ignore, and brings together a community from all walks of life.\n\n" +
	"Please keep being the inspiration we need!\n" +
	"Sincerely,\n" +
	"CoffeeQ Team"

	console.log(body)

	var data = {
	  from: 'CoffeeQ <info@qdcoffee.co>',
	  to: util.format("%s <%s>", first_name, email),
	  subject: 'Someone Redeemed your Coffee!',
	  text: body
	};
	 
	mailgun.messages().send(data, function (error, body) {
	  console.log(body);
	});
};

app.get('/v1/cafe/:cafe_id', function(req, res) {
	var cafe_id = req.params.cafe_id;

	pool.connect(function(err, client, done) {
	  if(err) { return console.error('error fetching client from pool', err); }

	  var rows = [];
	  var query = client.query('select c.*, count(t.id) from cafes c left join transactions t on (c.id = t.cafe_id) where c.id = $1 group by c.id', [cafe_id]);

	  query.on('row', function(row) {
	  	rows.push(row);
	  });
	  query.on('error', function(error) {
      	console.log(error);
      });

	  query.on('end', function(result) {
	  	console.log("in end")
	  	if (rows.length == 0) {
			res.send(JSON.stringify({"success" : false, "error_message" : "this cafe doesn't exist!"}));
		}
		else {
			res.send(JSON.stringify({"success" : true, "name" : rows[0].name, "address" : rows[0].address, "count": rows[0].count}));
		}
	  })
	})
})






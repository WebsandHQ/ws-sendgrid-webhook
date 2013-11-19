# Get marketing events from an event queue and save them to a database.

# The databases are:

"""
CREATE USER testuser WITH ENCRYPTED PASSWORD 'password';
CREATE DATABASE test_events WITH ENCODING 'UTF-8' OWNER "testuser";
GRANT ALL PRIVILEGES ON DATABASE test_events TO testuser;
\connect test_events
BEGIN;
CREATE TABLE "sendgrid_sendgridevent" (
    "id" serial NOT NULL PRIMARY KEY,
    "email" varchar(254) NOT NULL,
    "event" varchar(100) NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    "rxed_json" text NOT NULL
);
CREATE TABLE "sendgrid_sendgridmarketingevent" (
    "id" serial NOT NULL PRIMARY KEY,
    "email" varchar(254) NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    "id_newsletter" varchar(20) NOT NULL,
    "event" varchar(100) NOT NULL,
    "rxed_json" text NOT NULL
);
CREATE INDEX "sendgrid_sendgridevent_email" ON "sendgrid_sendgridevent" ("email");
CREATE INDEX "sendgrid_sendgridevent_email_like" ON "sendgrid_sendgridevent" ("email" varchar_pattern_ops);
CREATE INDEX "sendgrid_sendgridmarketingevent_email" ON "sendgrid_sendgridmarketingevent" ("email");
CREATE INDEX "sendgrid_sendgridmarketingevent_email_like" ON "sendgrid_sendgridmarketingevent" ("email" varchar_pattern_ops);
CREATE INDEX "sendgrid_sendgridmarketingevent_id_newsletter" ON "sendgrid_sendgridmarketingevent" ("id_newsletter");
CREATE INDEX "sendgrid_sendgridmarketingevent_id_newsletter_like" ON "sendgrid_sendgridmarketingevent" ("id_newsletter" varchar_pattern_ops);
COMMIT;
"""
import pika
import logging
import json
import psycopg2
import datetime

logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.CRITICAL)

try:
    import config
except Exception as e:
    config = {}
    print e
    print "Using local config"

DATABASE = getattr(config, 'DATABASE', "test_events")
USER = getattr(config, 'USER', "testuser")
PASSWORD = getattr(config, 'PASSWORD', "password")
QUEUE = getattr(config, 'QUEUE', 'webhook_demo')
EXCHANGE = getattr(config, 'EXCHANGE', 'webhook')
ROUTING_KEY = getattr(config, 'ROUTING_KEY', 'webhook_demo')

NEWSLETTER_TABLE = 'sendgrid_sendgridmarketingevent'
TRANSACTION_TABLE = 'sendgrid_sendgridevent'

# Create a global channel variable to hold our channel object in
channel = None


# Step #2
def on_connected(connection):
    """Called when we are fully connected to RabbitMQ"""
    # Open a channel
    connection.channel(on_channel_open)


# Step #3
def on_channel_open(new_channel):
    """Called when our channel has opened"""
    global channel
    channel = new_channel
    channel.queue_declare(queue=QUEUE, durable=True, exclusive=False, auto_delete=False, callback=on_queue_declared)


# Step #4
def on_queue_declared(frame):
    """Called when RabbitMQ has told us our Queue has been declared, frame is the response from RabbitMQ"""
    channel.queue_bind(queue=QUEUE, exchange=EXCHANGE, routing_key=ROUTING_KEY, callback=on_queue_bound)


# Step #5
def on_queue_bound(frame):
    """Called when RabbitMQ has told us our Queue has been bound to the Exchange"""
    channel.basic_consume(handle_delivery, queue=QUEUE)


# Step #6
def handle_delivery(channel, method, header, body):
    """
    Called when we receive a message from RabbitMQ
    """
    process_sendgrid_body(body)
    channel.basic_ack(method.delivery_tag)


def process_sendgrid_body(body):
    try:
        events = json.loads(body)
    except:
        print "Couldn't process the body! "
        print body
        return
    db_con = None
    cur = None
    try:
        db_con = psycopg2.connect(
            host='localhost',
            database=DATABASE,
            user=USER,
            password=PASSWORD)
        cur = db_con.cursor()
        for event in events:
            add_to_database(cur, event)
        db_con.commit()
        cur.close()
        db_con.close()
    except psycopg2.DatabaseError as e:
        print "Database Error: {0}".format(e)
        if db_con:
            db_con.rollback()
    except Exception as e:
        print "Other error: {0}".format(e)
    finally:
        cur = None
        db_con = None


def add_to_database(cur, data):
    try:
        data['newsletter']
        add_to_newsletter_table(cur, data)
    except KeyError:
        add_to_transaction_table(cur, data)
    except Exception:
        raise


def add_to_newsletter_table(cur, data):
    event = data['event']
    email = data['email']
    timestamp = datetime.datetime.utcfromtimestamp(data['timestamp'])
    newsletter_id = data['newsletter']['newsletter_id']
    query = "INSERT INTO {0} (event, email, timestamp, id_newsletter, rxed_json) VALUES ( %s, %s, %s, %s, %s)".format(NEWSLETTER_TABLE)
    cur.execute(query, (event, email, timestamp, newsletter_id, json.dumps(data)))


def add_to_transaction_table(cur, data):
    event = data['event']
    email = data['email']
    timestamp = datetime.datetime.utcfromtimestamp(data['timestamp'])
    query = "INSERT INTO {0} (event, email, timestamp, rxed_json) VALUES ( %s, %s, %s, %s)".format(TRANSACTION_TABLE)
    cur.execute(query, (event, email, timestamp, json.dumps(data)))


# Step #1: Connect to RabbitMQ using the default parameters (i.e. localhost, guest, port 5672)
parameters = pika.ConnectionParameters()
connection = pika.SelectConnection(parameters, on_connected)

try:
    # Loop so we can communicate with RabbitMQ
    connection.ioloop.start()
except KeyboardInterrupt:
    # Gracefully close the connection
    connection.close()
    # Loop until we're fully closed, will stop on its own
    connection.ioloop.start()

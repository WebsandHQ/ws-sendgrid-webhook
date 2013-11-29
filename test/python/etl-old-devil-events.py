# Convert and load the old devil events format into the current (as of 29/11/12)
# events format for devilware

# The devil_events databases are:

"""
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
"""
# the sendgrid events database looks like:

"""
CREATE TABLE sendgrid_sendgridevent_new
(
  id serial NOT NULL,
  uuid character varying(36),
  id_newsletter character varying(20),
  email character varying(254) NOT NULL,
  event character varying(100) NOT NULL,
  "timestamp" timestamp with time zone NOT NULL,
  rxed_json text NOT NULL,
  CONSTRAINT sendgrid_sendgridevent_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

"""

# so this file pulls all the events from these two tables and pushes them into
# the new table

import psycopg2
import datetime
import os

DATABASE_HOST = os.environ.get('PYTHON_DB_HOST', 'localhost')
DATABASE_PORT = int(os.environ.get('PYTHON_DB_PORT', 5432))
DATABASE_OLD_EVENTS = os.environ.get('PYTHON_OLD_DBNAME', "test_events")
DATABASE_NEW_EVENTS = os.environ.get('PYTHON_NEW_DBNAME', "new_events")
USER = os.environ['PYTHON_DB_USER']
PASSWORD = os.environ['PYTHON_DB_PASSWORD']

NEWSLETTER_TABLE = 'sendgrid_sendgridmarketingevent'
TRANSACTION_TABLE = 'sendgrid_sendgridevent'

NEW_SENDGRIDEVENT_TABLE = 'sendgrid_sendgridevent'


def read_write_db():
    db_read_con = psycopg2.connect(
        host=DATABASE_HOST,
        database=DATABASE_OLD_EVENTS,
        port=DATABASE_PORT,
        user=USER,
        password=PASSWORD)
    db_read_cur = db_read_con.cursor()

    db_write_con = psycopg2.connect(
        host=DATABASE_HOST,
        database=DATABASE_NEW_EVENTS,
        port=DATABASE_PORT,
        user=USER,
        password=PASSWORD)
    db_write_cur = db_write_con.cursor()

    # Now read the normal sendgrid events and write them to the table
    read1_query = (
        'SELECT null, "email", "event", "timestamp", "rxed_json" FROM {0}'
        .format(TRANSACTION_TABLE))
    read2_query = (
        'SELECT "id_newsletter", "email", "event", "timestamp", "rxed_json" FROM {0}'
        .format(NEWSLETTER_TABLE))
    write_query = (
        'INSERT INTO {0} ("id_newsletter", "email", "event",'
        ' "timestamp", "rxed_json") VALUES(%s, %s, %s, %s, %s)'
        .format(NEW_SENDGRIDEVENT_TABLE))

    count = 0
    try:
        for query in (read1_query, read2_query):
            db_read_cur.execute(query)
            for record in db_read_cur:
                count += 1
                print record
                db_write_cur.execute(write_query, record)
        db_write_con.commit()
        db_write_cur.close()
        db_read_cur.close()
    except psycopg2.DatabaseError as e:
        print "Database Error: {0}".format(e)
        return
        if db_write_con:
            db_write_con.rollback()
    except Exception as e:
        print "Other error: {0}".format(e)
    finally:
        db_read_cur = None
        db_read_con = None
        db_write_cur = None
        db_write_con = None
    print "total read: {0}".format(count)


if __name__ == '__main__':
    read_write_db()

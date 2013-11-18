# basic blocking test.
import pika
import json

connection = pika.BlockingConnection()
channel = connection.channel()
method_frame, header_frame, body = channel.basic_get('webhook_demo')
if method_frame:
    print method_frame
    print header_frame.content_type
    print body
    print type(body)
    print json.loads(body)
    channel.basic_ack(method_frame.delivery_tag)
else:
    print "No message returned."

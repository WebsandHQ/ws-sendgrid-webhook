import pika

import logging
logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.CRITICAL)

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
    channel.queue_declare(queue="webhook_demo", durable=True, exclusive=False, auto_delete=False, callback=on_queue_declared)

# Step #4
def on_queue_declared(frame):
    """Called when RabbitMQ has told us our Queue has been declared, frame is the response from RabbitMQ"""
    channel.queue_bind(queue="webhook_demo", exchange='webhook', routing_key='webhook_demo', callback=on_queue_bound)

# Step #5
def on_queue_bound(frame):
	"""Called when RabbitMQ has told us our Queue has been bound to the Exchange"""
	channel.basic_consume(handle_delivery, queue='webhook_demo')

# Step #6
def handle_delivery(channel, method, header, body):
    """Called when we receive a message from RabbitMQ"""
    print "handle_delivery"
    print channel
    print method
    print header
    print body
    print
    # pause for 10 seconds.
    import time
    time.sleep(10)
    channel.basic_ack(method.delivery_tag)

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

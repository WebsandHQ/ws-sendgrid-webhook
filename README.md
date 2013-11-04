# Sendgrid URL Webhook receiver.

This accepts SendGrid URL webhook calls (with Basic Auth) and chucks them on to
the configured Celery Queue via the appropriate broker (which will be RabbitMQ).

This is used to take the spikiness out of SendGrid URL webhook calls and ensure
that we can handle the load if lots of people open the same email at the same
time.

This single instance can handle webhook URL calls for multiple instances.
The idea is that the webhook has the form:

https://sendgridurlhook.websandhq.co.uk/[appname]

This will then send the data to the appropriate the celery queue as part of the
configuration.

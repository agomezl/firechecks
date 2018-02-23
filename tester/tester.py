#!/usr/bin/env python3

import sys
import os
import pika
import sh
from sh import bash
import requests


MQ_HOST = os.getenv('MQ_HOST', 'localhost')
COURSE  = os.getenv('COURSE_NAME', 'testLab')
LABN    = int(os.getenv('LAB_NUMBER','1'))

# Connect to rabbit
connection = pika.BlockingConnection(pika.ConnectionParameters(MQ_HOST))
channel = connection.channel()

# Declare queues

lab_queue='%s-lab%i' % (COURSE,LABN)

channel.queue_declare(queue=lab_queue)

def callback(ch, method, properties, body):
    test     = bash.bake(_err_to_out=True,_ok_code=range(0,256),\
                         _timeout=300)
    values   = body.decode('ascii').split('|')
    fileUrl  = values[0]
    callback = values[1]

    print('[*] processing file=%s with callback=%s...'%(fileUrl,callback))
    try:
        run      = test('lab%i/lab%i.sh' % (LABN,LABN), fileUrl)
        out      = run.stdout.decode('ascii')[2:]
        code     = run.exit_code
    except sh.SignalException_SIGKILL:
        out  = "The program ran out of time"
        code = 1

    outcome  = 'pass' if code == 0 else 'fail'

    print('==SUCCESS==' if code == 0 else '==FAILURE==')
    print('With output:')
    print(out)

    r = requests.post(fileUrl,params={'status' : outcome},data=out)
    print("Got response with code=%s from callback with content=%s'" % (r.status_code,r.text))


channel.basic_consume(callback,
                      queue=lab_queue,
                      no_ack=True)

print(' [*] Waiting for messages. To exit press CTRL+C')
channel.start_consuming()

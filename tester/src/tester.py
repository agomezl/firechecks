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

lab_queue='%s-lab%i' % (COURSE,LABN)
lab_file='./%s-lab%i.out' % (COURSE,LABN)

def callback(ch, method, properties, body):
    test     = bash.bake(_err_to_out=True,_ok_code=range(0,256),\
                         _out=lab_file, _timeout=120)
    values   = body.decode('ascii').split('|')
    fileUrl  = values[0]
    callback = values[1]

    timeout = False

    print('[*] processing file=%s with callback=%s...'%(fileUrl,callback))
    try:
        run      = test('./lab%i.sh' % LABN, fileUrl)
        #out      = run.stdout.decode('utf-8')
        code     = run.exit_code
    except sh.TimeoutException:
        timeout = True
        code = 1

    outcome  = 'pass' if code == 0 else 'fail'

    print('==SUCCESS==' if code == 0 else '==FAILURE==')
    print('With output:')

    # Gets the output
    with open(lab_file,'rb') as out_file:
        out = out_file.read().decode('utf-8')

        if timeout:
            out +="\n===\n [*] The program ran out of time"

        print(out)

    try:
        r = requests.post(callback,params={'status' : outcome},data=out.encode('utf-8'))
        print("Got response with code=%s from callback with content=%s'" % (r.status_code,r.text))
    except Exception as e:
        print("Some error ocurred while try to send the response")
        print(e)

while True:
    # Connect to rabbit
    connection = pika.BlockingConnection(pika.ConnectionParameters(MQ_HOST))
    channel = connection.channel()
    # Declare queues
    channel.queue_declare(queue=lab_queue)
    channel.basic_qos(prefetch_count=1)

    try:
        channel.basic_consume(queue=lab_queue,
                              auto_ack=True,
                              on_message_callback=callback)
        print(' [*] Waiting for messages. To exit press CTRL+C')
        channel.start_consuming()
    except pika.exceptions.ConnectionClosed:
        print("Trying to re-connect")
        connection.close()

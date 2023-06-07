import logging
import json
import urllib3

http = urllib3.PoolManager()

def lambda_handler(event, context):
    logging.info('retreives current bitcoin exchange rates')

    try:
        response = http.request('GET', 'https://api.coindesk.com/v1/bpi/currentprice.json')

        return {
            "statusCode": 200,
            "isBase64Encoded": False,
            "headers": {"Content-Type": "application/json"},
            "body": response.data
        }

    except:
        pass

    data = "invalid response from coindesk api"

    return {
        "statusCode": 503,
        "isBase64Encoded": False,
        "headers": {"Content-Type": "application/json"},
        "body": data
    }
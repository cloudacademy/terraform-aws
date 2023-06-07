import logging
import json
    
def lambda_handler(event, context):
    logging.info('Python HTTP trigger function processed a request.')
    msg = "Terrarform + Azure Function Apps = 👍👍👍👍"

    try:
        name = event["queryStringParameters"]['name']
        if not name:
            try:
                req_body = json.parse(event.body)
            except ValueError:
                pass
            else:
                name = req_body.get('name')

        if name:
            return {
                "statusCode": 200,
                "isBase64Encoded": 'false',
                "headers": {"Content-Type": "application/json"},
                "body": f"\n{msg}\n{name} was here!!\n\n"
            }
    except:
        pass
    
    return {
        "statusCode": 200,
        "isBase64Encoded": 'false',
        "headers": {"Content-Type": "application/json"},
        "body": f"\n{msg}\n\n"
    }

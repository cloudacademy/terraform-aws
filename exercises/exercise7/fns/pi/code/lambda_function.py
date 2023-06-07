import logging

def lambda_handler(event, context):
    logging.info('calculates pi to n decimal places...')

    try:
        num = event["queryStringParameters"]['num']

        if num:
            digits = [str(n) for n in list(pi_digits(int(num)))]
            pi = "%s.%s\n" % (digits.pop(0), "".join(digits))
            return {
                "statusCode": 200,
                "isBase64Encoded": 'false',
                "headers": {"Content-Type": "application/json"},
                "body": f"\n{pi}\n\n"
            }
    except:
        pass
    
    return {
        "statusCode": 200,
        "isBase64Encoded": 'false',
        "headers": {"Content-Type": "application/json"},
        "body": f"\n{0}\n\n"
    }

def pi_digits(x):
    k,a,b,a1,b1 = 2,4,1,12,4
    while x > 0:
        p,q,k = k * k, 2 * k + 1, k + 1
        a,b,a1,b1 = a1, b1, p*a + q*a1, p*b + q*b1
        d,d1 = a/b, a1/b1
        while d == d1 and x > 0:
            yield int(d)
            x -= 1
            a,a1 = 10*(a % b), 10*(a1 % b1)
            d,d1 = a/b, a1/b1
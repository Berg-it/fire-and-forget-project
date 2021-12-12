import logging
import json 
import os
import boto3
import time

logger = logging.getLogger()
logger.setLevel(logging.INFO)
table_name = os.environ.get('dynamodb_table')
dynamodb = boto3.resource('dynamodb')
s3_client = boto3.client('s3')
table = dynamodb.Table(table_name)
bucket_name = os.environ.get('report_bucket_id')


def lambda_handler(event, context):

    logger.info('Event: %s', event)

    for record in event['Records']:
        if 'aws:dynamodb' == record['eventSource'] \
            and 'INSERT' == record['eventName']    \
            and 'NEW_IMAGE' == record['dynamodb']['StreamViewType']:
                logger.info("-----")
                new_item = record['dynamodb']['NewImage']
                logger.info(new_item)
                id = new_item['Id']['S']
                logger.info("id value equal to "+id)

                time.sleep(10) # Sleep for 10 seconds, simulate that our report will generated on 10 sec
                
                path = id+'-'+'report.json'
                data_set = {"key1": [1, 2, 3], "key2": [4, 5, 6]}
                json_dump = json.dumps(data_set)

                s3_client.put_object(
                        ACL='private',
                        ContentType='application/json',
                        Key=path,
                        Body=json_dump,
                        Bucket=bucket_name
                    )

                response = table.update_item(
                        Key={'Id': id},
                        UpdateExpression="set report_status=:st",
                        ExpressionAttributeValues={':st': 'completed'},
                        ReturnValues="UPDATED_NEW"
                    )                    


    response = {
        "statusCode": 200,
        "headers": {},
        "body": json.dumps({"ho": "ha"})
    }
    return response
import boto3
import os

# ============================================================
# Lambda: Stop EC2 instance on schedule
# Region: us-east-1 (adjust if needed)
# Trigger: EventBridge rule (cron)
# ============================================================

# ===== Required IAM Policy =====
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "ec2:StopInstances",
#         "ec2:DescribeInstances"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#       "Resource": "*"
#     }
#   ]
# }

# ===== Environment Variables =====
# INSTANCE_ID = i-xxxxxxxxxxxxxxxxx

ec2 = boto3.client("ec2")

def lambda_handler(event, context):
    instance_id = os.environ["INSTANCE_ID"]

    try:
        print(f"Stopping EC2 instance: {instance_id}")
        ec2.stop_instances(InstanceIds=[instance_id])
        return {"status": "stopped", "instance_id": instance_id}
    except Exception as e:
        print(f"[ERROR] {e}")
        return {"status": "error", "message": str(e)}

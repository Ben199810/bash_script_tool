#!/bin/bash

# 列出所有 EC2 实例的状态
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' --output table
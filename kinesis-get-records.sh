#!/usr/bin/env bash

if [ $# -lt 1 ]
then
    echo "usage: $0 stream-name"
    exit 1
fi

STREAM_NAME=$1

STREAM_DESC=`aws kinesis describe-stream --stream-name ${STREAM_NAME}`
SHARD_ID=`echo $STREAM_DESC | \
    jq -r .StreamDescription.Shards[0].ShardId`
START_NUM=`echo $STREAM_DESC | \
    jq -r .StreamDescription.Shards[0].SequenceNumberRange.StartingSequenceNumber`
echo "Shard ID: ${SHARD_ID}"
echo "Starting Sequence Number: ${START_NUM}"

SHARD_ITERATOR=`aws kinesis get-shard-iterator --stream-name ${STREAM_NAME} \
    --shard-id ${SHARD_ID} --shard-iterator AT_SEQUENCE_NUMBER \
    --starting-sequence-number ${START_NUM} | \
    jq -r .ShardIterator`
echo ${SHARD_ITERATOR}

aws kinesis get-records \
    --shard-iterator ${SHARD_ITERATOR}

#!/bin/bash

cd evaluation || exit

CHECKPOINT_NAME="meditron-7b"
BENCHMARK="head_qa"
SHOTS=0
COT=0
SC_COT=0
MULTI_SEED=0
BACKEND="vllm"
WANDB=1
BATCH_SIZE=4

HELP_STR="[--checkpoint=$CHECKPOINT_NAME] [--benchmark=$BENCHMARK] [--help]"

help () {
	echo "Usage: $0 <vllm> $HELP_STR"
}

if [[ $# = 1 ]] && [[ $1 = "-h" ]] || [[ $1 = "--help" ]]; then
	help
	exit 0
fi

while getopts c:b:s:r:e:m:t:d: flag
do
    case "${flag}" in
        c) CHECKPOINT_NAME=${OPTARG};;
        b) BENCHMARK=${OPTARG};;
        s) SHOTS=${OPTARG};;
        r) COT=${OPTARG};;
        e) BACKEND=${OPTARG};;
        m) MULTI_SEED=${OPTARG};;
        t) SC_COT=${OPTARG};;
        d) BATCH_SIZE=${OPTARG};;
    esac
done

# THE FIX: Point directly to the Hugging Face repo instead of a dead local path
#CHECKPOINT="epfl-llm/meditron-7b"
CHECKPOINT="TheBloke/meditron-7B-AWQ"

echo
echo "Running inference pipeline"
echo "Checkpoint name: $CHECKPOINT_NAME"
echo "Checkpoint: $CHECKPOINT"
echo "Benchmark: $BENCHMARK"
echo "Backend: $BACKEND"
echo "Shots: $SHOTS"
echo "COT: $COT"
echo "Multi seed: $MULTI_SEED"
echo "SC COT: $SC_COT"
echo "BATCH_SIZE: $BATCH_SIZE"
echo

COMMON_ARGS="--checkpoint $CHECKPOINT \
    --checkpoint_name ${CHECKPOINT_NAME} \
    --benchmark $BENCHMARK \
    --shots $SHOTS \
    --batch_size $BATCH_SIZE"
    
ACC_ARGS="--checkpoint $CHECKPOINT_NAME \
    --benchmark $BENCHMARK \
    --shots $SHOTS"

if [[ $COT = 1 ]]; then
    echo "COT Prompting"
   COMMON_ARGS="$COMMON_ARGS --cot"
fi

if [[ $MULTI_SEED = 1 ]]; then
    echo "In-context with Multi Seed"
    COMMON_ARGS="$COMMON_ARGS --multi_seed"
    ACC_ARGS="$ACC_ARGS --multi_seed"
fi

if [[ $SC_COT = 1 ]]; then
    echo "SC-COT Prompting"
    COMMON_ARGS="$COMMON_ARGS --sc_cot"
    ACC_ARGS="$ACC_ARGS --sc_cot"
fi

if [[ $WANDB = 1 ]]; then
    echo "WANDB Log Enabled"
    ACC_ARGS="$ACC_ARGS --wandb"
fi

echo python inference.py $COMMON_ARGS
python inference.py $COMMON_ARGS

# THE SAFETY NET: Only run evaluate.py if inference.py succeeds
if [ $? -eq 0 ]; then
    python evaluate.py $ACC_ARGS
else
    echo "Inference failed. Skipping evaluation."
    exit 1
fi
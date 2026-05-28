#!/bin/bash

cd evaluation || exit

# ARGUMENT REFERENCE:
# -c: Model name
# -b: Benchmark/Dataset
# -s: In-context learning shots number (default is 0)
# -r: CoT prompting (0: disabled, 1: enabled)
# -e: Inference backend (currently support vllm only)
# -m: In-context learning with multiple seeds (0: disabled, 1: enabled)
# -t: Self-consistency CoT prompting (0: disabled, 1: enabled)
# -d: Batch size for inference per GPU (Set to 4 for T4 16GB)

./inference_pipeline.sh \
    -c "meditron-7b" \
    -b "head_qa" \
    -s 0 \
    -r 0 \
    -e vllm \
    -m 0 \
    -t 0 \
    -d 4
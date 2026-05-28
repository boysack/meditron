#!/bin/bash

./inference_pipeline.sh
    -c "meditron-7b"
    -b "head_qa"
    -s 0        #(in-context learning shots number, default is zero)
    -r 0        #(cot prompting; 0: disabled, 1: enabled)
    -e vllm     #(inference backend, currently support vllm only)
    -m 0        #(in-context learning with multiple seeds; 0: disabled, 1: enabled)
    -t 0        #(self-consistency cot prompting; 0: disabled, 1: enabled)
    -d 32       #(setting batch_size 32 for inference per gpu)
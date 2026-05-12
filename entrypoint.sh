#!/bin/bash

hailomz compile --ckpt best.onnx --hw-arch hailo8l --calib-path calibration_imgs/ --yaml yolov8s_custom.yaml --model-script yolov8s_custom.alls --classes 5

mkdir -p /workspace/results

# Move everything that ISN'T one of your original source files
# We use an extended glob to ignore your specific protected files
shopt -s extglob
mv !("Dockerfile"|"best.onnx"|"hailo_dataflow_compiler-3.30.0-py3-none-linux_x86_64.whl"|"results"|"README.md"|"calibration_imgs"|"hailort-4.20.0-cp310-cp310-linux_x86_64.whl"|"yolov8s_custom.alls"|"additional-requirements.md"|"constraints.txt"|"hailort_4.20.0_amd64.deb"|"yolov8s_custom.yaml"|"backup"|"entrypoint.sh"|"jaxlib-0.4.13-cp310-cp310-manylinux2014_x86_64.whl"|"yolov8s_nms_config.json") /workspace/results/ 2>/dev/null
echo "Compilation finished. Generated files moved to /onnx-to-hef-yolov8/results"

#add y/n prompt to benchmark model and write to /results 
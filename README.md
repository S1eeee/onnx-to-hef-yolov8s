# Hailo ONNX to HEF Converter

This docker image can be used to convert an ONNX exported **yolov8s model** to Hailo's **HEF format**.
This docker image might work for other yolo model versions with some modifications, but yolov8 is the priority

## Pre-requisites

- Docker
- ONNX exported model (only yolov8s)
- Calibration images (from your training data)
- Project intallation binaries from Hailo. For more details, see [additional-requirements](additional-requirements.txt)

## Usage

### 1. Train Model and Export

Train your model with Ultralytics and [export](https://docs.ultralytics.com/modes/export/#why-choose-yolov8s-export-mode) it to ONNX format.

```bash
yolo export model=/path/to/trained/best.pt imgsz=640 format=onnx opset=11
```

For reference see:
- https://docs.ultralytics.com/modes/export/#why-choose-yolov8s-export-mode
- https://github.com/hailo-ai/hailo_model_zoo/blob/master/training/yolov8/README.rst

See this repo for an automated, complementary training container meant to work with this one: 



### 2. Build the docker image

```bash
docker build -t hailo_converter .
```

### 4. Prepare model and calibration images 

Place the **ONNX model** and **calibration images folder** in the repository root.

> [!NOTE] 
> The calibration set should be real images that are a subset of the training dataset.
> They should be diverse and representative of the dataset. Max 64 images are used.

Obtaining these calibration images can be easily taken from your training images, but you might find it difficult to select up to 64 images representative of your dataset. If this is the case, you can try [This Script](/calibration_imgs/calibration-gathering.sh)

### 5. Run the docker image

Ensure that the current directory is where the ONNX model and calibration images are placed.

> [!IMPORTANT]
> They need to be named **EXACTLY** `best.onnx` and `calibration_imgs`.

```bash
sudo docker run -v $(pwd):/workspace --ipc=host hailo_converter:latest
```

This command does not use your system's graphic card(s), if you have the requirements to use a GPU, you can alternatively run the following command:

```bash
sudo docker run -v $(pwd):/workspace --gpus all --ipc=host hailo_converter:latest
```
If your user account is in the docker usegroup, you do not need sudo at the start of either command

Running either command will run the following command inside the docker container:

```bash
hailomz compile --ckpt best.onnx --hw-arch hailo8l --calib-path calibration_imgs/ --yaml yolov8s_custom.yaml --model-script yolov8s_custom.alls --classes 5
```

Depending on your exact model goals, you might want to go into the [Dockerfile](Dockerfile) and change some fields, for example, if you have a different number of classes. Another thing you might want to change are your env variables (low priority it seems). 

As for adjusting the ```hailomz compile``` command, for example, if you have different needs, such as a different number of classes, you can check out [entrypoint.sh](entrypoint.sh) 

> [!NOTE]
> The `Using deprecated NumPy API` warning at the beginning can be ignored it seems.

> [!NOTE]  
> The compilation can take a considerable amount of time, likely more if not using a GPU, though I am unsure as to exactly how much longer it can take

Once successful, the HEF model will be saved in ```onnx-to-hef-yolov8/results``` The rest of the files in ```/results``` are safe to delete/move elsewhere. 
It does not seem like this directory needs to be empty in order for this to work, but I'd recommend that you empty it out after every run.


### In a Nutshell:

1. Clone repo:

    ```
    git clone https://github.com/S1eeee/onnx-to-hef-yolov8"
    ```

2. Find Necessary Binaries

    See [this](additional-requirements.md) for details
    Then place them in the root of the cloned repo

3. Place your ```best.onnx``` and your ```calibration_imgs``` in the root of the cloned repo

    See above, [calibration-gathering](/calibration_imgs/readme.md) for details

4. Open a terminal and ```cd``` to the root of the project. Once in, run one of the following:

    ```bash
sudo docker run -v $(pwd):/workspace --ipc=host hailo_converter:latest
```

This command does not use your system's graphic card(s), if you have the requirements to use a GPU, you can alternatively run the following command:

```bash
sudo docker run -v $(pwd):/workspace --gpus all --ipc=host hailo_converter:latest
```

5. Let docker work

    Let it do its thing, it will output text to the terminal, and if all goes well, your onnx will turn into a hef

6. Once done, visit [results](/results/) to recover your compiled hef
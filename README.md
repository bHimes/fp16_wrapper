# fp16_wrapper

Buffer your fp16 MRC files in memory and then view with your favorite software.

```bash
$ fp16_wrapper [imod, chimera, tdisp ....] [my_fp16.mrc]
```

## Installation

- Clone the repository:
```
git clone https://github.com/bHimes/fp16_wrapper.git
or
git clone git@github.com:bHimes/fp16_wrapper.git
```

## Setup

This convenience script does a few things:
- makes sure you have the python3 module [mrcfile](https://pypi.org/project/mrcfile/) installed.
    - if not you it will install it (optionally in a virtual environement)

```{warning}
For now it just assumes you have numpy. If you select to install in the venv, numpy will also be installed.
```
```
cd fp16_wrapper
./fp16_wrapper_setup.sh
```

This should output a test script to make sure everything is working. This will be run automatically to make sure you can read/write a fp16 file to /tmp
```
./fp16_wrapper_test.py
```
If this passes, two files will be created:
- fp16_wrapper
- fp16_wrapper.py

You should get an outpout like this in the terminal:
```
Converting to float32
Successfully converted to used mrcfile to write a float16 to float32 stored in /tmp (memory)
You can now call the program /groups/himesb/git/fp16_wrapper/fp16_wrapper [name of viz software, e.g. imod] [file name of fp16 mrc]
```

## Usage

You pass the name of the software you want to use to view the file, and the name of the (fp16) file you want to view.
- it is assumed the software is on your path (i.e. imod, chimera, tdisp or whaterver)
- it is assumed that the software can read fp32 MRC files



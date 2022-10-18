#!/home/himesb/miniconda3/envs/cryoAI/bin/python3


import mrcfile
import numpy as np
from sys import argv
import os.path as OP

#TODO: no error or exception handling, but could easily be added

def main(argv):
    
    # read in and convert to float32
    with mrcfile.open(argv[1]) as mrc:
        new_name = OP.splitext(argv[1])[0] + "_fp16.mrc"
        print(new_name)
        with mrcfile.new(new_name, overwrite=True) as mrc2:
            mrc2.set_data(mrc.data.astype(np.float16))
            mrc2.close()       

if __name__ == "__main__":
    main(argv[:])


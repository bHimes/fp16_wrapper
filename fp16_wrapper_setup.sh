#!/bin/bash

# name for virtual env for mrcfile install if desired. Note: this is in .gitignore
VIRTUAL_ENV_NAME=.fp16_wrapper
USING_VENV=0

# TODO: need a check on numpy presence as well

# check to see that we have python3
python_3=$(which python3)

if [[ $? -ne 0 ]] ; then

    # Okay, it wasn't python3, let's check to see python works
    python_3=$(which python)
    if [[ $? -ne 0 ]] ; then
        echo "python not found on your system, what fresh hell is this?"
        exit 1
    else
        # Okay, found python, is it version 3 somethings?
        if [[ $($python_3 --version | awk 'gsub("\."," "){print $2}') -ne 3 ]] ; then
            echo "python3 not found as python, please install python3"
            exit 1
        fi
    fi 

    # Okay, we have python3, let's use it
fi

echo "Found python3 at $python_3"

# check to see that we have pip3
pip_3=$(which pip3)
if [[ $? -ne 0 ]] ; then
    echo "pip3 not found on your system, what fresh hell is this?"
    exit 1
fi

# See if mrcfile happens to already exist
if [[ ! $(pip3 list | grep mrcfile) ]] ; then 
    echo "mrcfile not found on your system."
    echo -e "\nWould you like to install mrcfile: ? (y/n)"
    read answer
    if [[ $answer == "y" ]] ; then
        echo "Would you like to install mrcfile in a virtualenv? (y/n)"
        read answer
        if [[ $answer == "y" ]] ; then
            # no error handling here, should check on venv
            echo "Installing mrcfile in virtualenv"
            $python_3 -m ${VIRTUAL_ENV_NAME}
            source ${VIRTUAL_ENV_NAME}/bin/activate
            echo "Activating the venv with command : source $(pwd)/bin/activate"
            echo "Deactivate with command : deactivate"
            source venv/bin/activate
            pip3 install mrcfile numpy
            USING_VENV=1
        else
            echo "Installing mrcfile"
            pip3 install mrcfile
        fi
    else
        echo "Please install mrcfile before continuing"
        exit 1
    fi
fi

rm -f /tmp/fp16_wrapper_tofp32.mrc

# Okay we should be setup, so let's run the test to make sure.
if [[ $USING_VENV -eq 1 ]] ; then source $(pwd)/bin/activate ; fi

{
echo '#!'"${python_3}"
echo ""
echo ""
echo "#Automagic test script to test fp16_wrapper_setup"
echo ""
echo "import mrcfile"
echo "import numpy as np"
echo ""
echo "with mrcfile.new(\"/tmp/fp16_wrapper.mrc\", data=None, compression=None, overwrite=True) as mrc:"
echo "    mrc.set_data(np.zeros((5, 5), dtype=np.float16))"
echo "    mrc.data[1:4,1:4] = 10"
echo "    print(\"made test data {}\".format(mrc.data))"
echo "    mrc.close()"
echo ""
echo "# now read it back in and convert to float32"
echo "with mrcfile.open(\"/tmp/fp16_wrapper.mrc\") as mrc:"
echo "    print(\"read test data {}\".format(mrc.data))"
echo "    print(\"Converting to float32\")"
echo "    with mrcfile.new(\"/tmp/fp16_wrapper_tofp32.mrc\", overwrite=True) as mrc2:"
echo "        mrc2.set_data(mrc.data.astype(np.float32))"
echo "        mrc2.close()"
echo ""
echo "    mrc.close()"
} > .fp16_wrapper_test.py

chmod a+x .fp16_wrapper_test.py
./.fp16_wrapper_test.py

# Now see if the file is written out
if [[ -f /tmp/fp16_wrapper_tofp32.mrc ]] ; then
    echo "Successfully converted to used mrcfile to write a float16 to float32 stored in /tmp (memory)"
    echo "You can now call the program $(pwd)/fp16_wrapper [name of viz software, e.g. imod] [file name of fp16 mrc]"
else
    echo "Failed to write out test file"
    echo "As of now, the setup script is not checking that you have numpy installed, please confirm this."
    echo "You can examine the test script at $(pwd)/.fp16_wrapper_test.py"
    exit 1
fi

{
echo '#!'"/bin/bash"
echo ""
echo ""
# If a virtual env was created with fp16_wrapper_setup.sh, activate it
if [[ $USING_VENV -eq 1 ]] ; then 
    echo "source $(pwd)/bin/activate"
else
    echo '#'"it looks like no venv was use in setup, not activating anything."
fi
echo ""
echo '#'"check that the viualization software is on the path."
echo "viz_software=\$(which \$1)"
echo "if [[ \$? -ne 0 ]] ; then echo \"visulaization software (\$1) not found on your system\" ; exit 1 ; fi"
echo ""
echo '#'"check that the fp16 mrc file is on the path."
echo "if [[ ! -f \$2 ]] ; then echo \"fp16 mrc file (\$2) not found on your system\" ; exit 1 ; fi"
echo ""
echo "$(pwd)/fp16_wrapper.py \$1 \$2"

} > ./fp16_wrapper

chmod a+x ./fp16_wrapper

{
echo '#!'"${python_3}"
echo ""
echo ""
echo "import mrcfile"
echo "import numpy as np"
echo "import sys, subprocess"
echo ""
echo '#'"TODO: no error or exception handling, but could easily be added"
echo ""
echo "def main(argv, fp32_name):"
echo "    "
echo "    # read in and convert to float32"
echo "    with mrcfile.open(argv[1]) as mrc:"
echo "        print(\"Converting to float32\")"
echo "        with mrcfile.new(fp32_name, overwrite=True) as mrc2:"
echo "            mrc2.set_data(mrc.data.astype(np.float32))"
echo "            mrc2.close()"
echo ""
echo "    subprocess.call([argv[0], fp32_name, \"shell=True\"])"
echo ""
echo "if __name__ == \"__main__\":"
echo "    fp32_name = \"/tmp/fp16_wrapper_tofp32.mrc\""
echo "    main(sys.argv[1:], fp32_name)"
echo '   #'" Since imod goes to the background we need to manually clean up the file, else it is deleted"
echo '   #'"    subprocess.call([\"rm\", \"-f\", fp32_name, \"shell=True\"])"
} > ./fp16_wrapper.py

chmod a+x ./fp16_wrapper.py

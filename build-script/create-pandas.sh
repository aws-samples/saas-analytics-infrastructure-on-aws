#!/usr/bin/env bash

scriptDir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo ""
echo "Creating Pandas Zip..."
cd $scriptDir/..
mkdir temp
cd temp
curl https://files.pythonhosted.org/packages/da/4a/a0c8d3ba8d875a25578bcb3032b6ac9b2db3d016b0a762ab41e1a13f3b52/pandas-1.5.0-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl -o pandas.whl
curl https://files.pythonhosted.org/packages/d6/e2/bed33bdbf513cd6d3fcb4377792ef1b8aad941da542a191e1e2a98c6621f/numpy-1.23.3-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl -o numpy.whl
curl https://files.pythonhosted.org/packages/d5/50/54451e88e3da4616286029a3a17fc377de817f66a0f50e1faaee90161724/pytz-2022.2.1-py2.py3-none-any.whl -o pytz.whl
curl https://files.pythonhosted.org/packages/40/46/505f0dd53c14096f01922bf93a7abb4e40e29a06f858abbaa791e6954324/PyJWT-2.6.0-py3-none-any.whl -o pyjwt.whl
mkdir python
unzip pandas.whl -d ./python
unzip numpy.whl -d ./python
unzip pytz.whl -d ./python
unzip pyjwt.whl -d ./python
zip -r python.zip ./python
cp python.zip ../iac/templates/components/initialization
cd ..
rm -r temp
echo "Finished Creating Pandas Zip"
echo ""

# Tirocinio_Classificazione_Cagliata_public

## Installation

### Enviroment and packages

Python and MATLAB are required to run the project, and needs to be installed in PATH(Python Needs to be able to be called form "python" command, and also MATLAB from matlab command).
Support is limited to Windows, but could be easily ported to other platforms.Used Python version is 3.11.3
Used MATLAB version is R2023a
but versions higher than those shouldn't cause problems.

Its needed to install this MATLAB packages to run the project:

- "Computer Vision Toolbox" by MathWorks
- "Deep Learning HDL Toolbox" by MathWorks
- "Deep Learning Toolbox" by MathWorks
- "Deep Learning Toolbox Model for AlexNet Network" by MathWorks Deep Learning Toolbox Team 
- "Deep Learning ToolboxTM Model for DarkNet-19 Network" by MathWorks Deep Learning Toolbox Team 
- "Deep Learning ToolboxTM Model for DarkNet-53 Network" by MathWorks Deep Learning Toolbox Team 
- "Deep Learning Toolbox Model for DenseNet-201 Network" by MathWorks Deep Learning Toolbox Team 
- "Deep Learning ToolboxTM Model for EfficientNet-b0 Network" by MathWorks Deep Learning Toolbox Team 
- "Deep Learning Toolbox Model for GoogLeNet Network" by MathWorks Deep Learning Toolbox Team 
- "Deep Learning Toolbox Model for Inception-ResNet-v2 Network" by MathWorks Deep Learning Toolbox Team
- "Deep Learning Toolbox Model for Inception-v3 Network" by MathWorks Deep Learning Toolbox Team 
- "Deep Learning Toolbox Model for MobileNet-v2 Network" by MathWorks Deep Learning Toolbox Team
- "Deep Learning ToolboxTM Model for NASNet-Large Network" by MathWorks Deep Learning Toolbox Team
- "Deep Learning ToolboxTM Model for NASNet-Mobile Network" by MathWorks Deep Learning Toolbox Team
- "Deep Learning Toolbox Model for ResNet-101 Network" by MathWorks Deep Learning Toolbox Team
- "Deep Learning Toolbox Model for ResNet-18 Network" by MathWorks Deep Learning Toolbox Team
- "Deep Learning Toolbox Model for ResNet-50 Network" by MathWorks Deep Learning Toolbox Team
- "Deep Learning ToolboxTM Model for ShuffleNet Network" by MathWorks Deep Learning Toolbox Team
- "Deep Learning Toolbox Model for VGG-16 Network" by MathWorks Deep Learning Toolbox Team
- "Deep Learning Toolbox Model for VGG-19 Network" by MathWorks Deep Learning Toolbox Team
- "Deep Learning ToolboxTM Model for Xception Network" by MathWorks Deep Learning Toolbox Team
- "Image Processing Toolbox" by MathWorks
- "Statistics and Machine Learning Toolbox" by MathWorks

### Optional

To run the mutual information test equivalence between matlab and scipy implementation you need to install scipy and numpy, otherwise the test is skipped and its just normally used the matlab version.
The test results are saved in "./test/mutual_info_*.txt" files and are the mutual information scores obtained from matlab and scikit algorithms on alexnet extracted features given a filter and a set.
The files contain and index with associated mutual information score, that seems to be equal to up to the fifth decimal (this may be caused by differencies in random generation and machine number precision in both languages, the rest of digits are similar in terms of absolute values).

## Run Locally

Clone the project

```bash
  git clone https://link-to-project
```

Go to the project directory, and then put the "1_Processed" folder in the root of the project, directory should be like this.

```
  ./Utils
  ...
  ./OtherUtils
  ./1_Processed
```

Edit the first 2 lines of the script "./test_extractors.bat" in the root of the project to use your desired set and filter to test (Below the defalut example)
```
  set testset=10
  set filter=Enhanced
```
Save the bat and then run it.
Parsed results of the iteraction will be stored in "./results" directory, raw results instead are stored in the root of the project.



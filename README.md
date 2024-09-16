
# Tirocinio_Classificazione_Cagliata_public

## Installation

### Enviroment and packages

Python and MATLAB are required to run the project, and needs to be installed in PATH(Python Needs to be able to be called form "python" command, and also MATLAB from matlab command).
Support is limited to Windows, but could be easily ported to other platforms.Used Python version is 3.11.3
Used MATLAB version is R2024a
but versions higher than those shouldn't cause problems.

Its needed to install some MATLAB packages to run the project, and from a new MATLAB installation, one can run the powershell script "setup.ps1"(As Administrator) to install requiered packages:

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

To run the mutual information test equivalence between matlab and scipy implementation you need to install scipy,numpy and sklearn. otherwise the test is skipped and its just normally used the matlab version.
The test results are saved in "./test/mutual_info_*.txt" files and are the mutual information scores obtained from matlab and scikit algorithms on alexnet extracted features given a filter and a set.
The files contain and index with associated mutual information score, that seems to be equal to up to the fifth decimal (this may be caused by differencies in random generation and machine number precision in both languages, the rest of digits are similar in terms of absolute values).

## Run Locally

Clone the project

```bash
  git clone https://github.com/LoreBadTime/Tirocinio_Classificazione_Cagliata_public
```

Go to the project directory, and then put the "1_Processed" folder in the root of the project,the root directory should be like this.

```
  ./Utils
  ...
  ./OtherUtils
  ./1_Processed
```
### Important Note

To make the reports automatic some ".bat" files are used, be sure that when using thuse files the terminal/cmd is in the project root, NOT from vscode integrated terminal

### Set Report Generation

Edit the first 2 lines of the script "./test_extractors.bat" in the root of the project to use your desired set and filter to test (Below the default example)
```
  set testset=10
  set filter=Enhanced
```
Save the bat and then run it,(or replace the value to take directly the input if you want to use it as cmd interface).
Parsed results of the iteraction will be stored in "./results" directory, raw results instead are stored in the "./raw" folder.

### Tsne Report Generation

Just start the file "tsne_extractor.bat"

### Intra-Set Ensemble Experiment

Edit the first line of the script "./ensemble_in_set.bat" in the root of the project to use your desired set to test (Below the default example)
```
  set testset=10
```
Save the bat and then run it,(or replace the value to take directly the input if you want to use it as cmd interface).

During processing two subsets will be created from the starting set, consisting on few images (by default 12 in total) from that set. At the end of the run a .jpg file will appear in "./results", consisting of the predictions of the chosen set using few images from it.

### Inter-Set Ensemble Experiment

Just start script "./ensemble_excl.bat" in the root of the project. During processing two subsets will be created from the starting set,at the end of the running test few graphs will appear in "./results" that contains the predictions on sets 4,5,6,9,10,11,12,14 with only using in training few images from set number 15 and the set number 13 for filtering the ensemble.
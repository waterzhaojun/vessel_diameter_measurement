bvfiles: extract folder paths based on animal, date, run.

We use Scanbox as our 2P recording system. It create a sbx file to store the data from one or two pmt channels. After recording, we need to convert the sbx file to Tif. Check how’s your experiment. You can do alignment but it is not necessary. 

We use MatLab function diameter.m to calculate the diameter changes. This function will load the Tif file and produce a reference image by using max value (After calculation it will be saved to the same folder named ref.jpg). You need to draw a roi by counterclockwise sequence. In short, mark the left point, then the right side, then the second right side, then the left side, then the first point as an end. The roi should be as vertical to the vessel as possible. Once roi is defined, the function will rotate the image and calculate the mean vertically, then calculate the diameter by findEdge.m function, which calculate maximum and minimum values of the two sides after smoothing, and find the point below 50% of this difference as the edge of the vessel.

The function of diameter.m will create a result.mat file to store diameter changes and a ref.jpg file to store the reference for roi. 

After the diameter analysis, run set_vessel_type.m to set each roi's vessel type. If you want to edit redefined roi, just run the code again.

## 12/2/2020
I am thinking maybe seperate the analysis to different steps will be better. One step error wont' let you run the whole process again. And it is easier to debug each step. The steps are designed as below:

1. check 3D structure (if it is optune). find the best layers. Use optsbx2tif_3d for this step.
2. extract matrix by using diameter_prepare_mx. By default it will produce a 1hz or less than 1hz sample mov.
3. build reference and mask by diameter_build_refmask. 
4. use set_scanrate to set bv scanrate for each layer's result. You can pass this step if you just rerun the analysis.
5. analyze result.roi by diameter_analysis.
6. use diameter_baseline to calculate this trial's bv baseline. This step need you already identified running situation. It will use rest station to calculate baseline.
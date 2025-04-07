# Step Finder

This is a standalone MATLAB app for single-molecule time series analysis. The user imports laboratory single-molecule fluorescence data and the step-finder estimates the number and characteristics of photobleaching events.


### Installing the app:
1. Download the Chiara_Step_Finder_v01.mlappinstall file.
2. Open MATLAB.
3. Click on the Apps tab at the top.
4. Click on Install app and select the downloaded Chiara_Step_Finder_v01.mlappinstall file. Click install.
5. Once the app is successfully installed, the app will be found under "My apps" in MATALAB's Apps tab. It will be named "Chiara_Step_Finder_v01". 

### Running the app and importing the data:
1. Once the app has been installed, click on it and a new window will open. This will look like the attached screenshot.
2. Begin by specifying the units of time and data to be used (these are set to be sec and adu by default but can be edited).
4. Click the import time series button to import your raw data. Accepted extensions are .csv, .xlsx, .txt. This file should contain two columns with headers w_n and t_n containing the raw measurements and time data respectively. If the time data is not provided, set t_n = 1, 2, 3,... .
5. After importing the data, you should see it plotted on the "results" panel on the right.

### Editing the temporal and detector settings and initializing MCMC chain:
1. The max number of steps is set to 25 by default which is usually sufficient for most applications involving ~10 steps of less. However, for cases with many more expected steps, this value should be increased. This does affects the computational time needed, so generally very large values (unless necessary) are not advised. 
2. The min and max step time values will automatically populate based on the imported data (but can be edited if needed). 
3. Enter the exposure time, offset, variance, and gain values used to collect the data.
4. Select the type of camera used from the excess noise factor drop-down menu. 
5. Click the initialize MCMC button.

### Running MCMC:
1. Enter the desired MCMC batch size (this is how many iterations to run every time the expand MCMC button is clicked). The suggested size is 100, but can be adjusted.
2. Select the type of progress report you would like to see while the MCMC runs. The default is set to none to make things run a bit faster. 
3. Click on the expand MCMC button. A log posterior plot will appear at the top of the result panel and histograms for the total number of steps and background samples will appear at the bottom. Moreover, the MAP signal will appear on the same plot as the data. This may take a few seconds, so wait for the plots to update before clicking the expand MCMC button again. 
4. Continue to click on the expand MCMC button to extend the MCMC chain. You can track convergence by looking at the log posterior plot. 
5. Click the Export MCMC button to export the MCMC chain, if desired.

### Interpreting results + Visualizing additional results:
1. The main info you are interested in is the total number of steps. For this, you should be looking at the histogram on the bottom left corner of the results panel which can provide info regarding both the number of steps with the highest probability and the uncertainty of this value.  
2. The MAP signal also provides information regarding the steps locations, and intensities with the highest probability. Click the get signal traces button to get a plot of the measurements, MAP signal, and stimuli. 
3. Click the get plot matrix button to get histograms for all sampled time steps, intensity steps, and background as well as scatter plots that showcase correlations between variables. 

### Using the reset button
Click the reset button to start over. You can click this button at any point.

## Example Data Set
An example data set is provided (demo_flourescence_data.txt). To analyze this data set use the following settings: units of time = sec, units of data = adu, max # of steps = 25, exposure period = 0.1, offset = 4350, variance = 1940, gain = 0.64, camera type: EMCCD. 

<!-- ## Contact
If you have any questions, contact us: <br>
Chiara Mattamira - cmattami@vols.utk.edu <br>
Ioannis Sgouralis - isgoural@utk.edu <br>  -->




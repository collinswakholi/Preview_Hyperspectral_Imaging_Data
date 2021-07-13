# Preview_Hyperspectral_Imaging_Data

This is a Simple GUI (MATLAB guide) app to load, preview, perform PCA and save spectral data from Hyperspectral images

**Dependencies**
1. This app was developed in MATLAB 2019b
2. It depends on MATLAB GUIDE, Image processing Toolbox, and the Statistics and Machine Learning Toolbox.

**How to Run app**
- Download this repository
- unzip the contents to specified folder
- Change current working directory to the specified folder 
- Run command "Display_Data_GUI" to run the app GUI

The app is able to load any ENVI-format (i.e in ".bil", ".dat", ".file", or "img" format) Hyperspectral Imaging (HSI) data from any directory. 
The loading of the ENVI format HSI data was inherited from Link-dev's ENVI_reanAndWrite (https://github.com/Link-dev/ENVI_readAndWrite) repository.

You can specify a waveband of the HSI data to be displayed in main plot window. 
You can select any portion of the image to preview the spectral data behind each of the selected pixels. 
Plot spectral data of multiple points in the image to unveil spectral similarities or disparities with in you HSI data (see screenshots below).

![Screenshot 2021-07-14 001113](https://user-images.githubusercontent.com/49397327/125479710-763d24fc-12c7-48ad-99b5-c11ad043f130.png)

![Screenshot 2021-07-14 001213](https://user-images.githubusercontent.com/49397327/125479974-27385dc6-2e22-4f0e-8c9b-dd0334ef533b.png)



Further more, You can a PCA analysis on the HSI data and return PCA images which can further reveal clear sources of variance in the HSI data (see screenshot below).
![Screenshot 2021-07-14 001312](https://user-images.githubusercontent.com/49397327/125480542-e4a84c2a-2950-4b56-958a-54579be0b292.png)

Finally, you can save spectral data of specied points in the HSI data in .txt format to folder of your choice.

Hopefully this is helpful to any one seeking to have a quick understanding of his HSI data.

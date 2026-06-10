// Process the output of the ilastik pixel classifier (amoeba_detector.ilp) to use in AmoePy
//============================================================================================

// 1- Open ilastik output images as an image stack
inputDir = getDir("Choose input Directory"); //directory containing the ilastik output images
File.openSequence(inputDir);
stackTitle = getInfo("window.title");
outputDir = inputDir + ".." + File.separator + stackTitle + "_postProcessed" + File.separator;

// 2- Threshold prediction images at 0.5 probability
// 	Since ilastik outputs 8-bit images, this equals setting a min threshold of 128.
setThreshold(128, 255, "raw");
run("Convert to Mask", "background=Dark black");

// 3- Run a 'Close' EDM operation to smooth cell masks, fill small holes and remove small particles
run("Options...", "iterations=2 count=4 black do=Close stack");

// 4- Save porcessed output as image sequence for processing with AmoePy
if (!File.exists(outputDir)){
	File.makeDirectory(outputDir);
}
run("Image Sequence... ", "select=[" + outputDir + "] dir=[" + outputDir + "] format=TIFF name=" + stackTitle);
close();
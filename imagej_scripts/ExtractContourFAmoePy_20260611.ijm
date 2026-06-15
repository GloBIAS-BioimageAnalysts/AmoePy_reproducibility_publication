// Extract contour coordinates from binary masks for AmoePy
// Version: 2026-06-11
// 
// Updates:
// - Added image selection dialog
// - Added user-configurable export settings
// - Added contour coordinate export log message
// - Added image existence check

// Output:
// - contour_um.txt containing resampled contour coordinates in micrometers

if (nImages < 1) {
    exit("Please open an image first.");
}

Imgs = getList("image.titles");

Dialog.createNonBlocking("Contour Extraction Settings");
Dialog.addDirectory("Coordinate File Output Folder", "");
Dialog.addChoice("Select Image", Imgs, Imgs[0]);
Dialog.addNumber("Resample Points", 400);
Dialog.addNumber("Start Time (s)", 0.00000, 5, 6, "sec");;
Dialog.addNumber("Frame Interval (s)", 4, 2, 5, "sec");;;
Dialog.addNumber("Pixels per Millimeter", 3372);;;;
Dialog.show();

CurrentImg = Dialog.getChoice();
ResultPath = Dialog.getString();//Folder to save the coordinate file
ResamplePN = Dialog.getNumber();;//virtual marker number
timeStamp = Dialog.getNumber();;
duration = Dialog.getNumber();;;//time interval
pixPermm = Dialog.getNumber();;;;//pixwl size

savePath = ResultPath +File.separator + "contour_um.txt";

selectWindow(CurrentImg);
run("Select None");
roiManager("reset");

run("Analyze Particles...", "add stack");
header = "# time_0 & X_0,0 & Y_0,0 & X_0,1 & Y_0,1 & X_0,2 & ... //" +
          " time_1 & X_1,0 & Y_1,0 & X_1,1 & Y_1,1 & X_1,2 & ... // ...;" +
          "  Units: \\$s, \\\\mu m\\$, (Seconds, Mikrometer)";        
allText = header +"\n";


for (f = 1; f <= nSlices; f++) {
    setSlice(f);
    info = ""+ d2s(timeStamp,6) ;
    roiManager("select", f-1);
	getSelectionCoordinates(xps, yps);
	oriPN = xps.length;
	AccuPeri = newArray(oriPN+1);
	AccuPeri[0] = 0;
	RePxs = newArray(ResamplePN);
	RePys = newArray(ResamplePN);
	for(i=0; i < oriPN; i++){
		j = (i+1) % oriPN;
		dx = xps[j] - xps[i];
		dy = yps[j] - yps[i];
		Dis =  sqrt(dx*dx+dy*dy);
		AccuPeri[i+1] = Dis + AccuPeri[i];
		}
		
	step = AccuPeri[oriPN] / ResamplePN;
	seg = 0;
	for (k=0; k < ResamplePN; k++){
		targetAcc = step * k;
	
		while(seg < oriPN-1 && AccuPeri[seg + 1] < targetAcc){
			seg++;
			}
			next = (seg+1) % oriPN;
			DifPeri = AccuPeri[seg+1] - AccuPeri[seg];
			
			if(DifPeri ==0){
				t =0;}
				
			else {
				t = (targetAcc - AccuPeri[seg]) / DifPeri ;
			}
			RePxs[k] = xps[seg] + t * (xps[next] - xps[seg]);
			RePys[k] = yps[seg] + t * (yps[next] - yps[seg]);
			RePxs_um = RePxs[k] / pixPermm *1000;
			RePys_um = RePys[k] / pixPermm *1000;
			info += " " + RePxs_um + " " +RePys_um;	
			//info += " " + RePxs[k] + " " +RePys[k];
		
		}
	timeStamp += duration;	
	allText = allText + info + "\n";
}
File.saveString(allText, savePath);
IJ.log("Contour coordinates exported successfully: " + savePath);
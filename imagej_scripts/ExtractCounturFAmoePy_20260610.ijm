ResultPath = "E:/NTUCM/Publication/20250731_Reproduction of AmoePy/Analysis and Result/4_Extract contour from ilastik/Fig2";//Folder to save the coordinate file
savePath = ResultPath +File.separator + "countur_um.txt";
roiManager("reset");
run("Analyze Particles...", "add stack");
ResamplePN = 400;//virtual marker number
timeStamp = 0.00000;
pixPermm = 3372;//pixwl size
duration = 4;//time interval
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
			RePxs_um = RePxs[k] / pixPermmm *1000;
			RePys_um = RePys[k] / pixPermmm *1000;
			info += " " + RePxs_um + " " +RePys_um;	
			//info += " " + RePxs[k] + " " +RePys[k];
		
		}
	timeStampmp += duration;	
	allText = allText + info + "\n";
}
File.saveString(allText, savePath);


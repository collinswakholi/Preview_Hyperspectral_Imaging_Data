function Data = load_my_data(Data_dir,samples, lines,bands)

[fid2,msg2] = fopen(Data_dir,'r');
[NormalData2, count2]= fread(fid2, [samples, lines*bands], 'uint16');
fclose(fid2);

Data = zeros(samples, lines, bands);
BandImage = zeros(samples, lines);

for ib = 1:bands
    for il = 1:lines
         BandImage(:,lines-il+1) = NormalData2(:,(il-1)*bands + ib);
    end
     Data(:,:,ib) = BandImage;
end
function [samples, lines, bands, wavelength] = get_my_hdr_info(hdr_dir)

fid=fopen(hdr_dir, 'r');
c2=textscan(fid, '%s %s %s');
fclose(fid);

% samples = str2double(char(c2{3}(3)));
% lines = str2double(char(c2{3}(4)));
% bands = str2double(char(c2{3}(5)));

% find samples lines bands
samples_idx = contains(c2{1,1},'samples');
lines_idx = contains(c2{1,1},'lines');
bands_idx = contains(c2{1,1},'bands');

samples = str2double(char(c2{3}(samples_idx)));
lines = str2double(char(c2{3}(lines_idx)));
bands = str2double(char(c2{3}(bands_idx)));

% find wavelength idx
wavelength_idx = find(endsWith(c2{1,1},'wavelength'));
top = cellfun(@str2num, c2{1,3}(wavelength_idx));
wv = [c2{1,1}((wavelength_idx+1):end),...
    c2{1,2}((wavelength_idx+1):end),...
    c2{1,3}((wavelength_idx+1):end)];
sz = size(wv);
wv = reshape(wv',sz(1)*sz(2),1);
wv = wv(~any(cellfun('isempty', wv), 2), :);
wv = cellfun(@str2num, wv);

wavelength = [top;wv];
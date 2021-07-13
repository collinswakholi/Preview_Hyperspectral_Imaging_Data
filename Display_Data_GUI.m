function varargout = Display_Data_GUI(varargin)
% DISPLAY_DATA_GUI MATLAB code for Display_Data_GUI.fig
%      DISPLAY_DATA_GUI, by itself, creates a new DISPLAY_DATA_GUI or raises the existing
%      singleton*.
%
%      H = DISPLAY_DATA_GUI returns the handle to a new DISPLAY_DATA_GUI or the handle to
%      the existing singleton*.
%
%      DISPLAY_DATA_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DISPLAY_DATA_GUI.M with the given input arguments.
%
%      DISPLAY_DATA_GUI('Property','Value',...) creates a new DISPLAY_DATA_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Display_Data_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Display_Data_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Display_Data_GUI

% Last Modified by GUIDE v2.5 13-Jul-2021 16:05:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Display_Data_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Display_Data_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Display_Data_GUI is made visible.
function Display_Data_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Display_Data_GUI (see VARARGIN)
global pre_band ncomps prev_option sel_option sav_option data_corr preview_comp
global m_pca color_mat color_mat_tr get_wave removeBK

pre_band = 950;
ncomps = 30;
prev_option = 1;
sel_option = 1;
sav_option = 1;
data_corr = 0;
preview_comp = 1;
m_pca = 0;
get_wave = 2;
removeBK = 0;

color_mat = [1, 0, 0;...
    0, 1, 0;...
    0, 0, 1;...
    1, 0.4, 0;...
    1, 0, 1;...
    0, 1, 1;...
    0, 0, 0;...
    1, 1, 0];

color_mat_tr = [1, 0.7, 0.7;...
    0.7, 1, 0.7;...
    0.65, 0.65, 1;...
    1, 0.85, 0.75;...
    1, 0.8, 1;...
    0.7, 1, 1;...
    0.65, 0.65, 0.65;...
    1, 1, 0.65];
% Choose default command line output for Display_Data_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Display_Data_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Display_Data_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_data.
function load_data_Callback(hObject, eventdata, handles)
% hObject    handle to load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Name Data wavelength pre_band Old_data samples lines bands iz im get_wave bb

im = 0;
iz = 0;
cla(handles.axes_image_preview)
cla(handles.axes_plot)
handles.text7.Visible = 0;

[ff,dd] = uigetfile({'*.dat;*.file;*.bil;*.img;'}, ...
   'Select Data File');
if ~(ff==0)
    nnm = strsplit(ff,'.');
    Name = nnm{1,end-1};
    all_files = dir(dd);
    All_Names = {all_files.name};
    
    idx_all = contains(All_Names,Name);
    idx_hdr = contains(All_Names,'.hdr');
    Idx_hdr = and(idx_all,idx_hdr);
    
    hdr_ff = All_Names{1,Idx_hdr};
    Data_dir = [dd,ff];
    hdr_dir = [dd,hdr_ff];

    % load hdr and data
    if get_wave == 1
        [samples, lines, bands] = get_my_hdr_info(hdr_dir);
    else
        [samples, lines, bands, wavelength] = get_my_hdr_info(hdr_dir);
    end
    
    if length(wavelength)~= bands
        answer = questdlg('Adjust & match Bands with wavelength?', ...
                'Wavelength not matching # bands', ...
                'Yes','No','No');
        if strcmp(answer, 'Yes')
            wavelength = [wavelength(1):((wavelength(end)-wavelength(1))/bands): wavelength(end)];
        else
            
        end
    end
    Data = load_my_data(Data_dir,samples, lines,bands);
    Old_data = Data;

    %save('wave.mat','wavelength')

    wv_min = num2str(round(min(wavelength),1));
    wv_max = num2str(round(max(wavelength),1));

    [~,bb] = min(abs(wavelength-pre_band));

    imshow(Data(:,:,bb),[], 'Parent', handles.axes_image_preview)
    handles.wv_limits.String = [wv_min,' - ',wv_max,'nm'];
    handles.wavelength_val.String = num2str(pre_band);
    drawnow;
else
    errordlg('Please load the data again','Error!!!');
    Data =[];
end


% --- Executes on button press in exit_button.
function exit_button_Callback(hObject, eventdata, handles)
% hObject    handle to exit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global iz im
iz = 0;
im = 0; 
close Display_Data_GUI

% --- Executes on selection change in preview_option.
function preview_option_Callback(hObject, eventdata, handles)
% hObject    handle to preview_option (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global prev_option Data ncomps wavelength pre_band Coeff Explained Scores samples lines bands
global preview_comp m_pca iz im bb

im = 0;
iz = 0;
cla(handles.axes_image_preview)
cla(handles.axes_plot)

hold(handles.axes_plot,'off');
hold(handles.axes_image_preview,'off');

handles.text7.Visible = 1;
prev_option = get(hObject,'Value');

if prev_option==1
    [~,bb] = min(abs(wavelength-pre_band));

    imshow(Data(:,:,bb),[], 'Parent', handles.axes_image_preview)
    handles.band_name.String = 'Wavelength (nm)';
    handles.wavelength_val.String = num2str(pre_band);
    handles.text3.String = 'Band Image';
    handles.spectra_plot.String = 'Spectra Plot';
    
    % enable data selection
    handles.data_selection.Enable = 'on';
    drawnow;
    
    try
        dummy = zeros(size(wavelength));
        plot(wavelength,dummy,'r', 'LineWidth',1.5,...
            'Parent', handles.axes_plot)
        set(handles.axes_plot,'XGrid','on','YGrid','on', 'XDir','normal');% 'reverse'
        axis(handles.axes_plot,[round(0.95*min(wavelength)) round(1.05*max(wavelength))...
            -1 1]);
    end
    
else
    handles.data_selection.Enable = 'off';
    
    if m_pca == 0
        f = msgbox('Computing PCA...','Please wait');
        r_data = reshape(Data, samples*lines, bands);
        [coeff,score,~,~,explained] = pca(r_data);
        r_scores = reshape(score,samples,lines, bands);
        Coeff = coeff(:,1:ncomps);
        Scores = r_scores(:,:,1:ncomps);
        Exp = round(100*explained/sum(explained),4);
        Explained = Exp(1:ncomps);
        m_pca = 1;
        try
            close(f)
        end
    end
    
    imshow(Scores(:,:,preview_comp),[], 'Parent', handles.axes_image_preview)
    colormap('jet')
    drawnow;
    
    plot(wavelength,Coeff(:,preview_comp),'b', 'LineWidth',2,...
        'Parent', handles.axes_plot)
    set(handles.axes_plot,'XGrid','on','YGrid','on', 'XDir','normal');% 'reverse'
    handles.axes_plot.XLim = [round(0.95*min(wavelength)) round(1.05*max(wavelength))];
        
    handles.band_name.String = 'PC Component';
    handles.wavelength_val.String = num2str(preview_comp);
    handles.text3.String = 'PCA_Image';
    handles.spectra_plot.String = 'Loading Plot';
    drawnow
end
% Hints: contents = cellstr(get(hObject,'String')) returns preview_option contents as cell array
%        contents{get(hObject,'Value')} returns selected item from preview_option



function wavelength_val_Callback(hObject, eventdata, handles)
% hObject    handle to wavelength_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global prev_option pre_band Data wavelength Scores Coeff preview_comp bb

hold(handles.axes_plot,'off');
hold(handles.axes_image_preview,'off');

if prev_option==1
    pre_band = str2double(get(hObject,'String'));
    [~,bb] = min(abs(wavelength-pre_band));
    wavee = round(wavelength(bb),1);
    handles.wavelength_val.String = num2str(wavee);

    imshow(Data(:,:,bb),[], 'Parent', handles.axes_image_preview)
    
    handles.text3.String = 'Band Image';
    handles.spectra_plot.String = 'Spectra Plot';
    
else
    preview_comp = str2double(get(hObject,'String'));
    if preview_comp>size(Scores,3)
        preview_comp = size(Scores,3);
        handles.wavelength_val.String = num2str(preview_comp);
        drawnow;
    end
    imshow(Scores(:,:,preview_comp),[], 'Parent', handles.axes_image_preview)
    colormap('jet')
    drawnow;
    
    plot(wavelength,Coeff(:,preview_comp),'b', 'LineWidth',2,...
        'Parent', handles.axes_plot)
    set(handles.axes_plot,'XGrid','on','YGrid','on', 'XDir','normal');% 'reverse'
    handles.axes_plot.XLim = [round(0.95*min(wavelength)) round(1.05*max(wavelength))];
    
    handles.wavelength_val.String = num2str(preview_comp);
    handles.text3.String = 'PCA_Image';
    handles.spectra_plot.String = 'Loading Plot';
    
end
drawnow
% Hints: get(hObject,'String') returns contents of wavelength_val as text
%        str2double(get(hObject,'String')) returns contents of wavelength_val as a double


% --- Executes during object creation, after setting all properties.
function wavelength_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wavelength_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function data_correction_Callback(hObject, eventdata, handles)
% hObject    handle to data_correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global data_corr Data Old_data samples bands wavelength pre_band

if data_corr == 0
    handles.data_correction.Checked = 'On';
    data_corr = 1;
else
    handles.data_correction.Checked = 'Off';
    data_corr = 0;
    Data = Old_data;
end

if data_corr == 1
    % load white
    [ff,dd] = uigetfile({'*.dat;*.file;*.bil;*.img;'}, ...
       'Select White Reference File');
    if ~(ff==0)
        h = msgbox('Processing White Reference', 'Please wait...');

        nnm = strsplit(ff,'.');
        Name = nnm{1,end-1};

        all_files = dir(dd);
        All_Names = {all_files.name};

        idx_all = contains(All_Names,Name);
        idx_hdr = contains(All_Names,'.hdr');
        Idx_hdr = and(idx_all,idx_hdr);

        hdr_ff = All_Names{1,Idx_hdr};
        Data_dir = [dd,ff];
        hdr_dir = [dd,hdr_ff];

        [wsamples, wlines, bands] = get_my_hdr_info(hdr_dir);
        wData = load_my_data(Data_dir,wsamples, wlines,bands);

        res_wData = reshape(wData,wsamples, wlines*bands);
        mean_wData = reshape(mean(res_wData,1),wlines, bands);
        W_data = [];
        for iw = 1:samples
            W_data(iw,:,:) = mean_wData;
        end
        close(h);
    else
        warndlg('No white reference with such name found', 'Warning!!!');
    end

    % load Dark
    
    [ff,dd] = uigetfile({'*.dat;*.file;*.bil;*.img;'}, ...
       'Select Dark Reference File');
    
    if ~(ff==0)
        h = msgbox('Processing Dark Reference', 'Please wait...');
        
        nnm = strsplit(ff,'.');
        Name = nnm{1,end-1};

        all_files = dir(dd);
        All_Names = {all_files.name};

        idx_all = contains(All_Names,Name);
        idx_hdr = contains(All_Names,'.hdr');
        Idx_hdr = and(idx_all,idx_hdr);

        hdr_ff = All_Names{1,Idx_hdr};
        Data_dir = [dd,ff];
        hdr_dir = [dd,hdr_ff];

        [dsamples, dlines, bands] = get_my_hdr_info(hdr_dir);
        dData = load_my_data(Data_dir,dsamples, dlines, bands);

        res_dData = reshape(dData,dsamples, dlines*bands);
        mean_dData = reshape(mean(res_dData,1),dlines, bands);

        D_data = [];
        for iw = 1:samples
            D_data(iw,:,:) = mean_dData;
        end
        close(h);
    
    else
        warndlg('No Dark reference with such name found', 'Warning!!!');
    end

    % correct data
    if ~(ff==0)
        Data = (Data-D_data)./(W_data-D_data+0.5);
    end
else
    Data = Old_data;
end

[~,bb] = min(abs(wavelength-pre_band));
imshow(Data(:,:,bb),[], 'Parent', handles.axes_image_preview)
drawnow;
h = msgbox('Data correction completed', 'Done');


% --- Executes on selection change in data_selection.
function data_selection_Callback(hObject, eventdata, handles)
% hObject    handle to data_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sel_option count Pos mean_dt Data_plot plot_data poly r_data Data
global samples lines bands hhs

sel_option = get(hObject,'Value');

Pos = [];
poly = [];
mean_dt = [];
Data_plot = [];
plot_data = [];
hhs = {};
count = 0;
r_data = reshape(Data, samples*lines, bands);

plot_new_spectr_Callback(hObject, eventdata, handles)

% Hints: contents = cellstr(get(hObject,'String')) returns data_selection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from data_selection


% --- Executes during object creation, after setting all properties.
function data_selection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clear_spectra.
function clear_spectra_Callback(hObject, eventdata, handles)
% hObject    handle to clear_spectra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data plot_data wavelength pre_band count iz im Poly Pos

count = 0;
iz = 0;
im = 0;
plot_data = [];
Poly = {};
Pos = {};

hold(handles.axes_plot,'off');
hold(handles.axes_image_preview,'off');

cla(handles.axes_plot)
cla(handles.axes_image_preview,'reset')

[~,bb] = min(abs(wavelength-pre_band));

imshow(Data(:,:,bb),[], 'Parent', handles.axes_image_preview)
colormap('gray')

try
    dummy = zeros(size(wavelength));
    plot(wavelength,dummy,'b', 'LineWidth',1.5,...
        'Parent', handles.axes_plot)
    set(handles.axes_plot,'XGrid','on','YGrid','on', 'XDir','normal');% 'reverse'
    axis(handles.axes_plot,[round(0.95*min(wavelength)) round(1.05*max(wavelength))...
        -1 1]);
end
handles.plot_new_spectr.String = 'Plot New';



% --- Executes on button press in save_spectra.
function save_spectra_Callback(hObject, eventdata, handles)
% hObject    handle to save_spectra (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plot_data sav_option wavelength

my_dir = uigetdir;
x_in = inputdlg('Please enter name');

try
    if sav_option == 1
        writematrix((plot_data.mean)',[my_dir,'\',x_in{1,1}]);
    else
        len = length(plot_data.all);
        for ii = 1:len
            writematrix((plot_data.all{ii,1})',[my_dir,'\s_',num2str(ii),x_in{1,1}]);
        end
    end
    writematrix(wavelength',[my_dir,'\Wavelength_',x_in{1,1}]);
    hd = msgbox('Data Saved',' Sucess...');
    tic;
catch
    hd = errordlg('Failed to Save Data',' Error!!!');
    tic;
end
t = toc;
cc = 1;
while cc>0
    t = toc;
    if t>5
        close(hd);
        break;
    end
end


% --- Executes on selection change in saving_option.
function saving_option_Callback(hObject, eventdata, handles)
% hObject    handle to saving_option (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global sav_option
sav_option = get(hObject,'Value');
% Hints: contents = cellstr(get(hObject,'String')) returns saving_option contents as cell array
%        contents{get(hObject,'Value')} returns selected item from saving_option


% --- Executes during object creation, after setting all properties.
function saving_option_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saving_option (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function band_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to band_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in plot_new_spectr.
function plot_new_spectr_Callback(hObject, eventdata, handles)
% hObject    handle to plot_new_spectr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data sz color_mat color_mat_tr count plot_data sel_option
global bands wavelength pre_band iz im hh data_plot
global Pos mean_dt Data_plot poly r_data Poly last_poly


[~,bb] = min(abs(wavelength-pre_band));
   
handles.band_name.String = 'Wavelength (nm)';
handles.wavelength_val.String = num2str(pre_band);
handles.text3.String = 'Band Image';
handles.spectra_plot.String = 'Spectra Plot';
drawnow;

hold(handles.axes_plot,'off');
hold(handles.axes_image_preview,'off');

imshow(Data(:,:,bb),[], 'Parent', handles.axes_image_preview)
drawnow;

sz = size(Data);

count = count+1;
handles.plot_new_spectr.String = ['Plot New(',num2str(count),')'];

if count>0 && count<=8

    if sel_option == 1
        
        if count==1
            pos2 = [];
            pos = round(0.5*([sz(1),sz(2)]));
        else
            pos2 = Pos(count-1,:);
            pos = Pos(count-1,:);
        end

        % iterative plot
        iz = 1;

            try
                while iz>0             
                    roi = drawpoint(handles.axes_image_preview,'Color',color_mat(count,:));
                    pos2 = round(roi.Position);
                    delete(roi)

                    if ~isequal(pos,pos2)
                        pos = pos2;
                        spec = reshape((Data(pos(2),pos(1),:)),bands,1);
                        Pos(count,:) = pos;
                        mean_dt(:,count) = spec;
                        plot_data.mean = mean_dt;
                        plot_data.pos = Pos;

                        try
                            plt.XData = [];
                            plt.YData = [];
                        end

                        hold(handles.axes_image_preview,'off');
                        for ss = 1:count
                            hold(handles.axes_image_preview,'on');
                            plt = scatter(Pos(ss,1),Pos(ss,2),50,color_mat(ss,:),'filled','Parent', handles.axes_image_preview);
                        end
                        
                        hold(handles.axes_plot,'off');
                        for pp = 1:count
                            plot(wavelength, mean_dt(:,pp), 'LineWidth',1.5,...
                                'Color',color_mat(pp,:), 'Parent', handles.axes_plot)
                            set(handles.axes_plot,'XGrid','on','YGrid','on', 'XDir','normal');% 'reverse'
                            handles.axes_plot.XLim = [round(0.95*min(wavelength)) round(1.02*max(wavelength))];
                            hold(handles.axes_plot,'on');
                        end

                        drawnow
                    end

                end
    %             hold(handles.axes_plot,'on');
            end
            
    elseif sel_option==2

            iz = 0;
            im = 1;
            tf = 1;
            pp1 = {};
            pp2 = {};
            hh = {};
            
            if count ==1
                last_poly = poly;
            end

            try
                while im > 0
                    try
                        hh{im} = drawfreehand(handles.axes_image_preview,'Color',color_mat(count,:));
                        poly = hh{im}.Position;
                        tf = isequal(poly,last_poly);
                        Poly{count} = poly;
                    end

                    if tf==0 % plot only if selection changes
                        try
                            delete(ppy{im-1});
                            hh{im-1}.Visible = 'off';
                            pp1{im-1}.XData = [];
                            pp2{im-1}.XData = [];
                        end

                        ROI = poly2mask(poly(:,1),poly(:,2),sz(1),sz(2));
                        idx = find(ROI==1);
                        data_plot = r_data(idx,:);
                        mean_data_plot = mean(data_plot);
                        mean_dt(:,count) = mean_data_plot;
                        Data_plot{count,1} = data_plot;
                        plot_data.mean = mean_dt;
                        plot_data.all = Data_plot;
                        
                        if count>1
                            for ix = 1:count-1
                                hold(handles.axes_image_preview,'on');
                                images.roi.Polygon(handles.axes_image_preview,'Position',Poly{ix},...
                                    'Color',color_mat(ix,:));
                            end
                        end
                        % selected plot
                        ppy{im} = images.roi.Polygon(handles.axes_image_preview,'Position',Poly{count},...
                                'Color',color_mat(count,:));
                                

                        for pp = 1:count
                            % all spectra plot
                            pp1{im} = plot(wavelength,Data_plot{pp,1},'Color',color_mat_tr(pp,:), 'LineWidth',0.5,...
                                    'Parent', handles.axes_plot);
                                    hold(handles.axes_plot,'on')

                            % mean spectra plot
                            pp2{im} = plot(wavelength, mean_dt(:,pp), 'LineWidth',2,'Color',color_mat(pp,:),...
                                    'Parent', handles.axes_plot);    
                                    set(handles.axes_plot,'XGrid','on','YGrid','on', 'XDir','normal');% 'reverse'
                                    handles.axes_plot.XLim = [round(0.95*min(wavelength)) round(1.02*max(wavelength))];
                                    hold(handles.axes_plot,'on')
                        end
                        hold(handles.axes_plot,'off')
                        hold(handles.axes_image_preview,'off')
                        
                        last_poly = poly;

                        im = im+1;
                        drawnow;
                    end
                end
            end
    %         save('plot_data.mat','plot_data');
    end
    
else
    warndlg('Maximum Selection Exceeded','Stop!!!')
    
end



% --- Executes during object creation, after setting all properties.
function preview_option_CreateFcn(hObject, eventdata, handles)
% hObject    handle to preview_option (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function load_wv_file_Callback(hObject, eventdata, handles)
% hObject    handle to load_wv_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function load_wave_file_Callback(hObject, eventdata, handles)
% hObject    handle to load_wave_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global get_wave wavelength

get_wave = 1;
handles.load_wave_hdr.Checked = 'Off';
handles.load_wave_file.Checked = 'On';

[ff,dd] = uigetfile({'*.xlsx;*.xls;*.txt;*.csv'}, ...
   'Select wavelength File');
wavelength = readmatrix([dd,ff]);
sz = size(wavelength);

if sz(1)<sz(2)
    wavelength = wavelength';
end

% --------------------------------------------------------------------
function load_wave_hdr_Callback(hObject, eventdata, handles)
% hObject    handle to load_wave_hdr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global get_wave

handles.load_wave_file.Checked = 'Off';
handles.load_wave_hdr.Checked = 'On';
get_wave = 2;


% --- Executes on button press in check_BR.
function check_BR_Callback(hObject, eventdata, handles)
% hObject    handle to check_BR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data thre_value removeBK bb Im_bin BKData
removeBK = get(hObject,'Value');
BKData = Data;
if removeBK
    % enable button and threshold field
    handles.text10.Enable = 'on';
    handles.threshold_edit.Enable = 'on';
    handles.apply_threshold.Enable = 'on';
    
    thre_value = 0.5;
    Im = mat2gray(Data(:,:,bb));
    Im_bin = Im>thre_value;
    imshow(Im_bin, 'Parent', handles.axes_image_preview);
    handles.threshold_edit.String = num2str(thre_value);
    drawnow;
else
    % disable button and threshold field
    handles.text10.Enable = 'off';
    handles.threshold_edit.Enable = 'off';
    handles.apply_threshold.Enable = 'off';
    Data = BKData;
    imshow(Data(:,:,bb),[], 'Parent', handles.axes_image_preview);
    drawnow;
end
% Hint: get(hObject,'Value') returns toggle state of check_BR


% --- Executes on button press in apply_threshold.
function apply_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to apply_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Data bb Im_bin

h = msgbox('Applying mask...', 'Please wait!!!');

for i = 1:size(Data,3)
    Data(:,:,i) = Data(:,:,i).*Im_bin;
end
Im = Data(:,:,bb);
imshow(Im, [], 'Parent', handles.axes_image_preview);
drawnow;

close(h);

% --- Executes during object creation, after setting all properties.
function threshold_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function threshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold_edit as text
%        str2double(get(hObject,'String')) returns contents of threshold_edit as a double
global Data thre_value bb Im_bin

thre_value = str2double(get(hObject,'String'));
Im = mat2gray(Data(:,:,bb));
Im_bin = Im>thre_value;
imshow(Im_bin, 'Parent', handles.axes_image_preview);
handles.threshold_edit.String = num2str(thre_value);
drawnow;

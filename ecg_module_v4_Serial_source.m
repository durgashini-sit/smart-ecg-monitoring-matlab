classdef ecg_module_v4_Serial < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        TabGroup                       matlab.ui.container.TabGroup
        COMPortDetectionTab            matlab.ui.container.Tab
        StatusEditField                matlab.ui.control.EditField
        StatusEditFieldLabel           matlab.ui.control.Label
        ORLabel                        matlab.ui.control.Label
        RegisterandUpdateButton        matlab.ui.control.Button
        STEP2BLabel                    matlab.ui.control.Label
        STEP2ALabel                    matlab.ui.control.Label
        STEP1Label                     matlab.ui.control.Label
        DeviceIDEditField              matlab.ui.control.EditField
        DeviceIDEditFieldLabel         matlab.ui.control.Label
        AutoDetectButton               matlab.ui.control.Button
        COMPortDetectedEditField       matlab.ui.control.EditField
        COMPortDetectedEditFieldLabel  matlab.ui.control.Label
        ForFirstTimeInitialisationwithMATLABDesignerAppLabel  matlab.ui.control.Label
        NameField                      matlab.ui.control.EditField
        DeviceNameLabel                matlab.ui.control.Label
        SelectDeviceLabel              matlab.ui.control.Label
        ScanCOMPortButton              matlab.ui.control.Button
        UITable                        matlab.ui.control.Table
        SignalAcquisitionTab           matlab.ui.container.Tab
        IferroroccursControlCinCommandWindorandreAcuireSignalagainLabel  matlab.ui.control.Label
        COMPortTextArea                matlab.ui.control.TextArea
        COMPortTextAreaLabel           matlab.ui.control.Label
        StatusTextArea                 matlab.ui.control.TextArea
        StatusTextAreaLabel            matlab.ui.control.Label
        AcquireSignalButton            matlab.ui.control.Button
        UIAxes                         matlab.ui.control.UIAxes
        OriginalSignalTab              matlab.ui.container.Tab
        SamplingFrequencyEditField     matlab.ui.control.NumericEditField
        SamplingFrequencyEditFieldLabel  matlab.ui.control.Label
        ConvertButton                  matlab.ui.control.Button
        LoadFileButton                 matlab.ui.control.Button
        UIAxes3                        matlab.ui.control.UIAxes
        UIAxes2                        matlab.ui.control.UIAxes
        GraphsTab                      matlab.ui.container.Tab
        TabGroup2                      matlab.ui.container.TabGroup
        FFTTab                         matlab.ui.container.Tab
        PlotButton_3                   matlab.ui.control.Button
        NoiseInfusionButtonGroup       matlab.ui.container.ButtonGroup
        WithNoiseInputButton           matlab.ui.control.RadioButton
        NoNoiseInputButton             matlab.ui.control.RadioButton
        LowPassFilterTab               matlab.ui.container.Tab
        LowPassFreqEditField           matlab.ui.control.NumericEditField
        LowPassFreqEditFieldLabel      matlab.ui.control.Label
        PlotButton_2                   matlab.ui.control.Button
        HighPassFilterTab_2            matlab.ui.container.Tab
        HighPassFreqEditField          matlab.ui.control.NumericEditField
        HighPassFreqEditFieldLabel     matlab.ui.control.Label
        PlotButton                     matlab.ui.control.Button
        PeakTab                        matlab.ui.container.Tab
        HeartRatebpmEditField          matlab.ui.control.NumericEditField
        HeartRatebpmEditFieldLabel     matlab.ui.control.Label
        PeakDetectedEditField          matlab.ui.control.NumericEditField
        PeakDetectedEditFieldLabel     matlab.ui.control.Label
        ThresholdEditField             matlab.ui.control.NumericEditField
        ThresholdEditFieldLabel        matlab.ui.control.Label
        DetectButton                   matlab.ui.control.Button
        UIAxes4                        matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        %****************************************************
        %Properties for Bluetooth Connectivity. Do not remove
        DeviceName % Description
%         DeviceChannel
        selectedCell 
        devlist
        portdetect=[]
        deviceID
        data_original
        x_time
        s_FreqSamp
        
%         device
        %*****************************************************


    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: ScanCOMPortButton
        function ScanCOMPortButtonPushed(app, event)
%             clear app.device
            app.UITable.Data = [];
            app.NameField.Placeholder=("XXX");
            app.devlist = serialportlist';
%             app.devlist = bluetoothlist;
            app.UITable.Data = app.devlist;
        
        end

        % Cell selection callback: UITable
        function UITableCellSelection(app, event)
            app.selectedCell = event.Indices;
            app.DeviceName=app.UITable.Data{app.selectedCell(1,1),app.selectedCell(1,2)}
%             app.DeviceChannel=app.UITable.Data{app.selectedCell(3,1),app.selectedCell(3,2)}
            app.NameField.Placeholder=app.DeviceName;
            app.COMPortTextArea.Placeholder=app.DeviceName;
            app.deviceID=app.DeviceIDEditField.Value;
%             app.ChannelField.Placeholder=num2str(app.DeviceChannel);
        end

        % Callback function: AcquireSignalButton, NameField
        function ConnecttoECGDeviceButtonPushed(app, event)
            



            %*****************************************************
            %*****Constant and Initialization*********************

            count =0;
            CountSecond=0;
            TotalTime=15;
            noofbtyes=0; %for every second of data
            data=[]; %Store block of data
            ZeroReadCount=0;
            
            FrameIncorrect=[]; %Not in use
            FrameCorrect=[]; %Store extracted data
            FrameIncorrectCount=1;
            ErrorXStart=0;
            ErrorXEnd=0;
            % NextX=1;
            
            FrameNoErrorData=zeros(5120,1);
            RawDataArray=zeros(5120,1);
            FrameCorrectCount=1;
            FrameNoErrorCount=1;
            data2dump=[];
            
            Gain=128;
            bitresolution=16/65536;
            checksum_right=1;
            checksum_wrong=0;


            %****************************************************

            clc;
            pause(2);
            app.StatusTextArea.Placeholder=("Connecting to COM Port Device");
%             devicelocal=app.portdetect.Port;
            app.portdetect=serialport(app.DeviceName, 57600);
            %****************************************************
        
            for countdown=0:3
                fprintf("Countdown : %d\n",3-countdown);
                string2display = strcat("Countdown: ", num2str(3-countdown));
                app.StatusTextArea.Placeholder=(string2display);
                pause(1);
            end

%             data2dump=read(devicelocal,devicelocal.NumBytesAvailable);
            data2dump=read(app.portdetect,app.portdetect.NumBytesAvailable,"uint8");

            while CountSecond < TotalTime
                pause(1); %Wait for a second
                noofbtyes = app.portdetect.NumBytesAvailable; %Check for no of bytes in buffer
                
                if noofbtyes > 0 
                    count = noofbtyes + count; %Total byte count accumulator
                    data = [data read(app.portdetect,app.portdetect.NumBytesAvailable,"uint8")]; %Append byte to existing data set 
                    CountSecond=CountSecond+1; 
                    disp(CountSecond); 
                    string2display = strcat(num2str(CountSecond)," Seconds of 15 Seconds");
                    app.StatusTextArea.Placeholder=(string2display);
                
                elseif noofbtyes == 0 %if no byte is available, device has hanged. Disconnect
                    ZeroReadCount=ZeroReadCount+1;
                    disp("ZeroReadCount");
                    if ZeroReadCount ==1
                        disp(count);
                        app.portdetect=[];
                        disp("Error: Zero Byte Available. Please restart.");
                        app.StatusTextArea.Placeholder=("Error: Zero Byte Available. Please restart.");
                        break
                    end
                end
            end
            app.portdetect=[];

            if CountSecond == TotalTime
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Post Processing
                %Determine the starting packet of data 
                for Startx=1:25
                    if data(Startx) == 170 && data(Startx+1) ==170
                        start=Startx;
            %             NextX=Startx;
                        x=Startx;
                %         fprintf("Startx: %d\n",Startx);
                        break;
                    end
                
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                while x <= count %
                    if x+7<=count % && NextX==x %Ensure next 8 bytes does not exceed the data size and to commence at the new data packet
                        if data(x)==170 && data(x+1)==170 && data(x+2)==4  %Check for 1st 3 bytes: 170 170 PLength
                            FrameCorrect = [FrameCorrect;data(x:x+1+1+data(x+2)+1)]; %Append to Array including checksum
            %                 NextX=x+1+1+data(x+2)+1+1; %Next packet frame location
                            x=x+1+1+data(x+2)+1+1;
                %             fprintf("FrameCorrect NextX: %d\n",NextX);
                
                        else  %If the 1st three bytes do not match, isolate the non correct data  
            %                 fprintf("ErrorXStart: %d\n",x);
                            ErrorXStart=x;
                            
                            while (data(x)~=170 || data(x+1)~=170 || data(x+2)~=4) && x+2<=count
                                x=x+1;
            %                     disp(x);
                            end
                            ErrorXEnd=x-1;
            %                 fprintf("ErrorXEnd: %d\n",ErrorXEnd);
                            FrameIncorrect = data(ErrorXStart:ErrorXEnd);
                            FrameIncorrectCount=FrameIncorrectCount+1;
                        end
                    else
                        break;
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for FrameCorrectCount=1:length(FrameCorrect)  %Data integreity check with checksum
                    CheckSum=dec2hex(FrameCorrect(FrameCorrectCount,8));
                    sum_dec=sum(FrameCorrect(FrameCorrectCount,4:7));
                    sum_dec_AND=255-bitand(sum_dec, 255); %Masking to extract the lower 8bit with 1st compliment
                    sum_dec_AND_hex=dec2hex(sum_dec_AND);
                    
                    if (CheckSum==sum_dec_AND_hex)
                        %%%%%%%%%%%%%%%%%%%%%%%%%    
                        raw_data=(FrameCorrect(FrameCorrectCount,6)*256)+FrameCorrect(FrameCorrectCount,7);
                        
                        if raw_data>32768
                            com_data=(raw_data-65536);
                            original_data=com_data*bitresolution/Gain;
                    %                         disp('Negative')
                    
                        else
                            com_data=(raw_data);
                            original_data=com_data*bitresolution/Gain;
                    %                         disp('Positive')
                        end
                        FrameNoErrorData(checksum_right,1)=com_data;

                        if checksum_right==5120
%                             plot(FrameNoErrorData);
                            RawDataArray=FrameNoErrorData;
                            plot(app.UIAxes,RawDataArray(:,1));

                            [c tf] = clock;
                            filename=strcat(app.deviceID,'_',int2str(c(1)),int2str(c(2)),int2str(c(3)),'_',int2str(c(4)),'_',int2str(c(5)),'_',int2str(c(6)));
                            trytry=strcat(filename,".mat");
                            save (trytry,'RawDataArray');
                            disp('Data has been saved as .mat file');
                            app.StatusTextArea.Placeholder=('Data has been saved as .mat file');

                            break;
            
                        end
                        checksum_right=checksum_right+1;
                    else
                        checksum_wrong = checksum_wrong+1;
                    end
                end
                
                if checksum_right<5120
                    disp("Error: Not enought data. Restart again");
                    app.StatusTextArea.Placeholder=("Error: Not enought data. Restart again");
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                checksum_right=0;
            end
            

        end

        % Button pushed function: AutoDetectButton
        function AutoDetectButtonPushed(app, event)
            app.portdetect=[];
            app.deviceID=app.DeviceIDEditField.Value;
            clc;
            PortList=serialportlist;
            
            for x=1:length(PortList)
                try
                    portnumber=PortList(x);
                    app.StatusEditField.Placeholder=(strcat("Testing: ",portnumber));
                    app.portdetect=serialport(portnumber, 57600);
                    pause(1);
                catch
                    fprintf("%s is not available\n", portnumber);
                    app.StatusEditField.Placeholder=(strcat(portnumber, " is not available"));
                    continue;
                end
                
                NBytes=app.portdetect.NumBytesAvailable;
            
                if NBytes > 0
                    portname=app.portdetect.Port;
                    app.DeviceName=portname;
                    app.COMPortDetectedEditField.Placeholder=app.DeviceName;
                    app.COMPortTextArea.Placeholder=app.DeviceName;
                    app.StatusEditField.Placeholder=(strcat(portnumber, " is selected"));
%                     deviceobject=[];
                    app.portdetect=[];
                    break
                else
%                 deviceobject=[];
                    app.portdetect=[];
                end

            end   
            app.StatusEditField.Placeholder=("COM Port Testing is completed.");



        end

        % Button pushed function: RegisterandUpdateButton
        function RegisterandUpdateButtonPushed(app, event)
            app.deviceID=app.DeviceIDEditField.Value;
        end

        % Callback function
        function LoadFileButtonPushed(app, event)

        end

        % Callback function
        function ConvertButtonPushed(app, event)
            %Save data for sharing
            app.s_FreqSamp=app.SamplingFrequencyEditField.Value

            %Find Sampling Period
            samplingperiod=1/app.SamplingFrequencyEditField.Value;

            % Get Sample Size
            samplelength=app.data_original;

            % Define x-axis in time,'-1' because starting from zero
            app.x_time = [0:samplingperiod:(length(samplelength)-1)*samplingperiod];
            plot(app.UIAxes3,app.x_time, app.data_original);
        end

        % Button pushed function: PlotButton
        function PlotButtonPushed(app, event)
            X=app.data_original;
            Fs=app.s_FreqSamp;
            yLP=lowpass(X,1,Fs)
            
            
            yHP=highpass(yLP,app.HighPassFreqEditField.Value,Fs)
            plot(app.UIAxes4,app.x_time, yHP);
        end

        % Button pushed function: PlotButton_2
        function PlotButton_2Pushed(app, event)
            X=app.data_original;
            Fs=app.s_FreqSamp;
            yLP=lowpass(X,app.LowPassFreqEditField.Value,Fs)
            plot(app.UIAxes4,app.x_time, yLP);
        end

        % Button pushed function: DetectButton
        function DetectButtonPushed(app, event)
        X=app.data_original;
        Fs=app.s_FreqSamp;
        yLP=lowpass(X,app.LowPassFreqEditField.Value,Fs)
        B=yLP;
        yHP=highpass(B,app.HighPassFreqEditField.Value,Fs)
            
        plot(app.UIAxes4,app.x_time,yHP)
        [pks,locs]= findpeaks(yHP,app.x_time,'MinPeakHeight',app.ThresholdEditField.Value)
        app.PeakDetectedEditField.Placeholder = string(length(pks));
        hold(app.UIAxes4,"on")

        %Plot maker with inverted triangle
        plot(app.UIAxes4,locs',pks,'v')
        hold(app.UIAxes4,"off")

        %determine the interval between peaks
        peakInterval = diff(locs);
        

        %find the mean of intervals and convert to beat per minute using reciprocal
        %can opt for median ranking
        heartrate = int8(1/(mean(peakInterval))*60);
        app.HeartRatebpmEditField.Placeholder = string(heartrate);
        end

        % Button pushed function: PlotButton_3
        function PlotButton_3Pushed(app, event)
            X=app.data_original;
            L=length(X);
            Fs=app.s_FreqSamp;
            T = 1/Fs; % Sampling period
            t = (0:L-1)*T; % Time vector

            %Add artificial noise to original signal
            if app.WithNoiseInputButton.Value == true
            S = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t);
            X = X + S + 2*randn(size(t));
            end

            %Fourier transforming process using power spectrum
            Y = fft(X);
            P2 = abs(Y/L);
            P1 = P2(1:L/2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            f = Fs*(0:(L/2))/L;
            plot(app.UIAxes4,f, P1);
        end

        % Button pushed function: LoadFileButton
        function LoadFileButtonPushed2(app, event)
            [file,path] = uigetfile('*.mat')
            %Output is a struct name
            temp=load(file); %Output is a struct name
            data=temp.RawDataArray; %Share data across methods
            app.data_original=data;%Extract the struct field
            plot(app.UIAxes2,data);
        end

        % Button pushed function: ConvertButton
        function ConvertButtonPushed2(app, event)
             %Save data for sharing
            app.s_FreqSamp=app.SamplingFrequencyEditField.Value

            %Find Sampling Period
            samplingperiod=1/app.SamplingFrequencyEditField.Value;

            % Get Sample Size
            samplelength=app.data_original;

            % Define x-axis in time,'-1' because starting from zero
            app.x_time = [0:samplingperiod:(length(samplelength)-1)*samplingperiod];
            plot(app.UIAxes3,app.x_time, app.data_original);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Theme = 'light';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 1 640 480];

            % Create COMPortDetectionTab
            app.COMPortDetectionTab = uitab(app.TabGroup);
            app.COMPortDetectionTab.Title = 'COM Port Detection';

            % Create UITable
            app.UITable = uitable(app.COMPortDetectionTab);
            app.UITable.ColumnName = {'COM Port Listing'};
            app.UITable.RowName = {};
            app.UITable.SelectionType = 'row';
            app.UITable.CellSelectionCallback = createCallbackFcn(app, @UITableCellSelection, true);
            app.UITable.Multiselect = 'off';
            app.UITable.Position = [387 130 121 201];

            % Create ScanCOMPortButton
            app.ScanCOMPortButton = uibutton(app.COMPortDetectionTab, 'push');
            app.ScanCOMPortButton.ButtonPushedFcn = createCallbackFcn(app, @ScanCOMPortButtonPushed, true);
            app.ScanCOMPortButton.FontSize = 14;
            app.ScanCOMPortButton.FontWeight = 'bold';
            app.ScanCOMPortButton.FontColor = [1 0 0];
            app.ScanCOMPortButton.Position = [113 294 117 24];
            app.ScanCOMPortButton.Text = 'Scan COM Port';

            % Create SelectDeviceLabel
            app.SelectDeviceLabel = uilabel(app.COMPortDetectionTab);
            app.SelectDeviceLabel.Position = [283 257 79 22];
            app.SelectDeviceLabel.Text = 'Select Device';

            % Create DeviceNameLabel
            app.DeviceNameLabel = uilabel(app.COMPortDetectionTab);
            app.DeviceNameLabel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.DeviceNameLabel.HorizontalAlignment = 'right';
            app.DeviceNameLabel.Position = [170 226 59 22];
            app.DeviceNameLabel.Text = 'COM Port';

            % Create NameField
            app.NameField = uieditfield(app.COMPortDetectionTab, 'text');
            app.NameField.ValueChangedFcn = createCallbackFcn(app, @ConnecttoECGDeviceButtonPushed, true);
            app.NameField.BackgroundColor = [0.9412 0.9412 0.9412];
            app.NameField.Placeholder = 'XXX';
            app.NameField.Position = [244 226 118 22];

            % Create ForFirstTimeInitialisationwithMATLABDesignerAppLabel
            app.ForFirstTimeInitialisationwithMATLABDesignerAppLabel = uilabel(app.COMPortDetectionTab);
            app.ForFirstTimeInitialisationwithMATLABDesignerAppLabel.Position = [45 406 300 22];
            app.ForFirstTimeInitialisationwithMATLABDesignerAppLabel.Text = 'For First Time Initialisation with MATLAB Designer App';

            % Create COMPortDetectedEditFieldLabel
            app.COMPortDetectedEditFieldLabel = uilabel(app.COMPortDetectionTab);
            app.COMPortDetectedEditFieldLabel.HorizontalAlignment = 'right';
            app.COMPortDetectedEditFieldLabel.Position = [283 66 110 22];
            app.COMPortDetectedEditFieldLabel.Text = 'COM Port Detected';

            % Create COMPortDetectedEditField
            app.COMPortDetectedEditField = uieditfield(app.COMPortDetectionTab, 'text');
            app.COMPortDetectedEditField.HorizontalAlignment = 'center';
            app.COMPortDetectedEditField.FontSize = 14;
            app.COMPortDetectedEditField.FontWeight = 'bold';
            app.COMPortDetectedEditField.FontColor = [1 0 0];
            app.COMPortDetectedEditField.BackgroundColor = [0.902 0.902 0.902];
            app.COMPortDetectedEditField.Position = [408 66 100 22];

            % Create AutoDetectButton
            app.AutoDetectButton = uibutton(app.COMPortDetectionTab, 'push');
            app.AutoDetectButton.ButtonPushedFcn = createCallbackFcn(app, @AutoDetectButtonPushed, true);
            app.AutoDetectButton.FontSize = 16;
            app.AutoDetectButton.FontWeight = 'bold';
            app.AutoDetectButton.FontColor = [1 0 0];
            app.AutoDetectButton.Position = [123 64 143 27];
            app.AutoDetectButton.Text = 'Auto Detect';

            % Create DeviceIDEditFieldLabel
            app.DeviceIDEditFieldLabel = uilabel(app.COMPortDetectionTab);
            app.DeviceIDEditFieldLabel.HorizontalAlignment = 'right';
            app.DeviceIDEditFieldLabel.Position = [275 364 58 22];
            app.DeviceIDEditFieldLabel.Text = 'Device ID';

            % Create DeviceIDEditField
            app.DeviceIDEditField = uieditfield(app.COMPortDetectionTab, 'text');
            app.DeviceIDEditField.HorizontalAlignment = 'center';
            app.DeviceIDEditField.Position = [348 364 100 22];
            app.DeviceIDEditField.Value = 'SHA-XX';

            % Create STEP1Label
            app.STEP1Label = uilabel(app.COMPortDetectionTab);
            app.STEP1Label.FontWeight = 'bold';
            app.STEP1Label.Position = [45 364 66 22];
            app.STEP1Label.Text = 'STEP 1';

            % Create STEP2ALabel
            app.STEP2ALabel = uilabel(app.COMPortDetectionTab);
            app.STEP2ALabel.FontWeight = 'bold';
            app.STEP2ALabel.Position = [45 296 66 22];
            app.STEP2ALabel.Text = 'STEP 2A';

            % Create STEP2BLabel
            app.STEP2BLabel = uilabel(app.COMPortDetectionTab);
            app.STEP2BLabel.FontWeight = 'bold';
            app.STEP2BLabel.Position = [48 66 66 22];
            app.STEP2BLabel.Text = 'STEP 2B';

            % Create RegisterandUpdateButton
            app.RegisterandUpdateButton = uibutton(app.COMPortDetectionTab, 'push');
            app.RegisterandUpdateButton.ButtonPushedFcn = createCallbackFcn(app, @RegisterandUpdateButtonPushed, true);
            app.RegisterandUpdateButton.FontSize = 14;
            app.RegisterandUpdateButton.FontWeight = 'bold';
            app.RegisterandUpdateButton.FontColor = [1 0 0];
            app.RegisterandUpdateButton.Position = [110 363 152 24];
            app.RegisterandUpdateButton.Text = 'Register and Update';

            % Create ORLabel
            app.ORLabel = uilabel(app.COMPortDetectionTab);
            app.ORLabel.HorizontalAlignment = 'center';
            app.ORLabel.FontSize = 16;
            app.ORLabel.FontWeight = 'bold';
            app.ORLabel.FontColor = [1 0 0];
            app.ORLabel.Position = [50 184 29 22];
            app.ORLabel.Text = 'OR';

            % Create StatusEditFieldLabel
            app.StatusEditFieldLabel = uilabel(app.COMPortDetectionTab);
            app.StatusEditFieldLabel.HorizontalAlignment = 'right';
            app.StatusEditFieldLabel.Position = [123 17 39 22];
            app.StatusEditFieldLabel.Text = 'Status';

            % Create StatusEditField
            app.StatusEditField = uieditfield(app.COMPortDetectionTab, 'text');
            app.StatusEditField.BackgroundColor = [0.8 0.8 0.8];
            app.StatusEditField.Position = [177 17 315 22];

            % Create SignalAcquisitionTab
            app.SignalAcquisitionTab = uitab(app.TabGroup);
            app.SignalAcquisitionTab.Title = 'Signal Acquisition';

            % Create UIAxes
            app.UIAxes = uiaxes(app.SignalAcquisitionTab);
            title(app.UIAxes, 'Acquired Signal')
            xlabel(app.UIAxes, 'Samples')
            ylabel(app.UIAxes, {'ECG (Digital Value)'; ''})
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [22 3 595 306];

            % Create AcquireSignalButton
            app.AcquireSignalButton = uibutton(app.SignalAcquisitionTab, 'push');
            app.AcquireSignalButton.ButtonPushedFcn = createCallbackFcn(app, @ConnecttoECGDeviceButtonPushed, true);
            app.AcquireSignalButton.Position = [45 354 151 22];
            app.AcquireSignalButton.Text = 'Acquire Signal';

            % Create StatusTextAreaLabel
            app.StatusTextAreaLabel = uilabel(app.SignalAcquisitionTab);
            app.StatusTextAreaLabel.HorizontalAlignment = 'right';
            app.StatusTextAreaLabel.Position = [229 353 39 22];
            app.StatusTextAreaLabel.Text = 'Status';

            % Create StatusTextArea
            app.StatusTextArea = uitextarea(app.SignalAcquisitionTab);
            app.StatusTextArea.Position = [283 353 302 24];

            % Create COMPortTextAreaLabel
            app.COMPortTextAreaLabel = uilabel(app.SignalAcquisitionTab);
            app.COMPortTextAreaLabel.BackgroundColor = [0.902 0.902 0.902];
            app.COMPortTextAreaLabel.HorizontalAlignment = 'right';
            app.COMPortTextAreaLabel.Position = [78 406 59 22];
            app.COMPortTextAreaLabel.Text = 'COM Port';

            % Create COMPortTextArea
            app.COMPortTextArea = uitextarea(app.SignalAcquisitionTab);
            app.COMPortTextArea.HorizontalAlignment = 'center';
            app.COMPortTextArea.BackgroundColor = [0.902 0.902 0.902];
            app.COMPortTextArea.Position = [152 406 150 23];

            % Create IferroroccursControlCinCommandWindorandreAcuireSignalagainLabel
            app.IferroroccursControlCinCommandWindorandreAcuireSignalagainLabel = uilabel(app.SignalAcquisitionTab);
            app.IferroroccursControlCinCommandWindorandreAcuireSignalagainLabel.HorizontalAlignment = 'center';
            app.IferroroccursControlCinCommandWindorandreAcuireSignalagainLabel.FontSize = 16;
            app.IferroroccursControlCinCommandWindorandreAcuireSignalagainLabel.FontWeight = 'bold';
            app.IferroroccursControlCinCommandWindorandreAcuireSignalagainLabel.FontColor = [0.6353 0.0784 0.1843];
            app.IferroroccursControlCinCommandWindorandreAcuireSignalagainLabel.Position = [11 308 617 38];
            app.IferroroccursControlCinCommandWindorandreAcuireSignalagainLabel.Text = 'If Error shows, run "Acquire Signal" again. ';

            % Create OriginalSignalTab
            app.OriginalSignalTab = uitab(app.TabGroup);
            app.OriginalSignalTab.Title = 'Original Signal';

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.OriginalSignalTab);
            title(app.UIAxes2, 'Signal')
            xlabel(app.UIAxes2, 'Samples')
            ylabel(app.UIAxes2, 'EGC')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.Position = [104 270 408 169];

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.OriginalSignalTab);
            title(app.UIAxes3, 'Signal in TIme')
            xlabel(app.UIAxes3, 'Time(s)')
            ylabel(app.UIAxes3, 'EGC')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.Position = [101 59 414 164];

            % Create LoadFileButton
            app.LoadFileButton = uibutton(app.OriginalSignalTab, 'push');
            app.LoadFileButton.ButtonPushedFcn = createCallbackFcn(app, @LoadFileButtonPushed2, true);
            app.LoadFileButton.Position = [273 234 100 23];
            app.LoadFileButton.Text = 'Load File';

            % Create ConvertButton
            app.ConvertButton = uibutton(app.OriginalSignalTab, 'push');
            app.ConvertButton.ButtonPushedFcn = createCallbackFcn(app, @ConvertButtonPushed2, true);
            app.ConvertButton.Position = [336 23 68 23];
            app.ConvertButton.Text = 'Convert';

            % Create SamplingFrequencyEditFieldLabel
            app.SamplingFrequencyEditFieldLabel = uilabel(app.OriginalSignalTab);
            app.SamplingFrequencyEditFieldLabel.HorizontalAlignment = 'right';
            app.SamplingFrequencyEditFieldLabel.Position = [158 23 115 22];
            app.SamplingFrequencyEditFieldLabel.Text = 'Sampling Frequency';

            % Create SamplingFrequencyEditField
            app.SamplingFrequencyEditField = uieditfield(app.OriginalSignalTab, 'numeric');
            app.SamplingFrequencyEditField.HorizontalAlignment = 'center';
            app.SamplingFrequencyEditField.Position = [288 23 39 22];
            app.SamplingFrequencyEditField.Value = 512;

            % Create GraphsTab
            app.GraphsTab = uitab(app.TabGroup);
            app.GraphsTab.Title = 'Graphs';

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.GraphsTab);
            title(app.UIAxes4, 'Output')
            xlabel(app.UIAxes4, 'Time(s)')
            ylabel(app.UIAxes4, 'EGC')
            zlabel(app.UIAxes4, 'Z')
            app.UIAxes4.Position = [25 247 578 197];

            % Create TabGroup2
            app.TabGroup2 = uitabgroup(app.GraphsTab);
            app.TabGroup2.Position = [27 53 576 174];

            % Create FFTTab
            app.FFTTab = uitab(app.TabGroup2);
            app.FFTTab.Title = 'FFT';

            % Create NoiseInfusionButtonGroup
            app.NoiseInfusionButtonGroup = uibuttongroup(app.FFTTab);
            app.NoiseInfusionButtonGroup.Title = 'Noise Infusion';
            app.NoiseInfusionButtonGroup.Position = [37 58 194 77];

            % Create NoNoiseInputButton
            app.NoNoiseInputButton = uiradiobutton(app.NoiseInfusionButtonGroup);
            app.NoNoiseInputButton.Text = 'No Noise Input';
            app.NoNoiseInputButton.Position = [11 31 101 22];
            app.NoNoiseInputButton.Value = true;

            % Create WithNoiseInputButton
            app.WithNoiseInputButton = uiradiobutton(app.NoiseInfusionButtonGroup);
            app.WithNoiseInputButton.Text = 'With Noise Input';
            app.WithNoiseInputButton.Position = [11 9 110 22];

            % Create PlotButton_3
            app.PlotButton_3 = uibutton(app.FFTTab, 'push');
            app.PlotButton_3.ButtonPushedFcn = createCallbackFcn(app, @PlotButton_3Pushed, true);
            app.PlotButton_3.Position = [71 10 100 23];
            app.PlotButton_3.Text = 'Plot';

            % Create LowPassFilterTab
            app.LowPassFilterTab = uitab(app.TabGroup2);
            app.LowPassFilterTab.Title = 'Low Pass Filter';

            % Create PlotButton_2
            app.PlotButton_2 = uibutton(app.LowPassFilterTab, 'push');
            app.PlotButton_2.ButtonPushedFcn = createCallbackFcn(app, @PlotButton_2Pushed, true);
            app.PlotButton_2.Position = [71 68 100 23];
            app.PlotButton_2.Text = 'Plot';

            % Create LowPassFreqEditFieldLabel
            app.LowPassFreqEditFieldLabel = uilabel(app.LowPassFilterTab);
            app.LowPassFreqEditFieldLabel.HorizontalAlignment = 'right';
            app.LowPassFreqEditFieldLabel.Position = [45 98 85 22];
            app.LowPassFreqEditFieldLabel.Text = 'Low Pass Freq';

            % Create LowPassFreqEditField
            app.LowPassFreqEditField = uieditfield(app.LowPassFilterTab, 'numeric');
            app.LowPassFreqEditField.HorizontalAlignment = 'center';
            app.LowPassFreqEditField.Position = [145 98 51 22];
            app.LowPassFreqEditField.Value = 1;

            % Create HighPassFilterTab_2
            app.HighPassFilterTab_2 = uitab(app.TabGroup2);
            app.HighPassFilterTab_2.Title = 'High Pass Filter';

            % Create PlotButton
            app.PlotButton = uibutton(app.HighPassFilterTab_2, 'push');
            app.PlotButton.ButtonPushedFcn = createCallbackFcn(app, @PlotButtonPushed, true);
            app.PlotButton.Position = [71 55 100 23];
            app.PlotButton.Text = 'Plot';

            % Create HighPassFreqEditFieldLabel
            app.HighPassFreqEditFieldLabel = uilabel(app.HighPassFilterTab_2);
            app.HighPassFreqEditFieldLabel.HorizontalAlignment = 'right';
            app.HighPassFreqEditFieldLabel.Position = [42 85 88 22];
            app.HighPassFreqEditFieldLabel.Text = 'High Pass Freq';

            % Create HighPassFreqEditField
            app.HighPassFreqEditField = uieditfield(app.HighPassFilterTab_2, 'numeric');
            app.HighPassFreqEditField.HorizontalAlignment = 'center';
            app.HighPassFreqEditField.Position = [145 85 51 22];
            app.HighPassFreqEditField.Value = 5;

            % Create PeakTab
            app.PeakTab = uitab(app.TabGroup2);
            app.PeakTab.Title = 'Peak';

            % Create DetectButton
            app.DetectButton = uibutton(app.PeakTab, 'push');
            app.DetectButton.ButtonPushedFcn = createCallbackFcn(app, @DetectButtonPushed, true);
            app.DetectButton.Position = [88 10 100 23];
            app.DetectButton.Text = 'Detect';

            % Create ThresholdEditFieldLabel
            app.ThresholdEditFieldLabel = uilabel(app.PeakTab);
            app.ThresholdEditFieldLabel.HorizontalAlignment = 'right';
            app.ThresholdEditFieldLabel.Position = [64 114 58 22];
            app.ThresholdEditFieldLabel.Text = 'Threshold';

            % Create ThresholdEditField
            app.ThresholdEditField = uieditfield(app.PeakTab, 'numeric');
            app.ThresholdEditField.HorizontalAlignment = 'center';
            app.ThresholdEditField.Position = [137 114 100 22];
            app.ThresholdEditField.Value = 0.7;

            % Create PeakDetectedEditFieldLabel
            app.PeakDetectedEditFieldLabel = uilabel(app.PeakTab);
            app.PeakDetectedEditFieldLabel.HorizontalAlignment = 'right';
            app.PeakDetectedEditFieldLabel.Position = [38 81 84 22];
            app.PeakDetectedEditFieldLabel.Text = 'Peak Detected';

            % Create PeakDetectedEditField
            app.PeakDetectedEditField = uieditfield(app.PeakTab, 'numeric');
            app.PeakDetectedEditField.AllowEmpty = 'on';
            app.PeakDetectedEditField.Editable = 'off';
            app.PeakDetectedEditField.HorizontalAlignment = 'center';
            app.PeakDetectedEditField.Position = [137 81 100 22];
            app.PeakDetectedEditField.Value = [];

            % Create HeartRatebpmEditFieldLabel
            app.HeartRatebpmEditFieldLabel = uilabel(app.PeakTab);
            app.HeartRatebpmEditFieldLabel.HorizontalAlignment = 'right';
            app.HeartRatebpmEditFieldLabel.Position = [31 46 98 22];
            app.HeartRatebpmEditFieldLabel.Text = 'Heart Rate (bpm)';

            % Create HeartRatebpmEditField
            app.HeartRatebpmEditField = uieditfield(app.PeakTab, 'numeric');
            app.HeartRatebpmEditField.AllowEmpty = 'on';
            app.HeartRatebpmEditField.Editable = 'off';
            app.HeartRatebpmEditField.HorizontalAlignment = 'center';
            app.HeartRatebpmEditField.Position = [137 46 100 22];
            app.HeartRatebpmEditField.Value = [];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ecg_module_v4_Serial

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
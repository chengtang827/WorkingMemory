function CreateConfigurationLevels
clear
curr_folder = pwd;
spl = strsplit(curr_folder,'/');
filename = sprintf('%s_%s_1_Spiketrains.mat',spl{5},spl{6});
if exist(filename)
    a = dir('session*');
    if exist(a.name)
        m = load(filename);
        s = fieldnames(m);
        cd(a.name)
        for i_array = 1:4
            mkdir(sprintf('array%02d',i_array));
        end
        for i_unit = 1:length(s)
            cell_spl = strsplit(s{i_unit},{'g','c'});
            if str2num(cell_spl{2}) < 33
                cd('array01')
                if ~exist(sprintf('channel%03d',str2num(cell_spl{2})))
                    mkdir(sprintf('channel%03d',str2num(cell_spl{2})))
                    cell_spl2 = strsplit(cell_spl{3},'s');
                    cd(sprintf('channel%03d',str2num(cell_spl{2})))
                    if ~exist(sprintf('cell%02d',str2num(cell_spl2{1})))
                        mkdir(sprintf('cell%02d',str2num(cell_spl2{1})))
                        cd(sprintf('cell%02d',str2num(cell_spl2{1})))
                        timestamps = getfield(m,s{i_unit});
                        save('unit.mat','timestamps');
                        cd ..
                    end
                    cd ..
                else
                    cell_spl2 = strsplit(cell_spl{3},'s');
                    cd(sprintf('channel%03d',str2num(cell_spl{2})))
                    if ~exist(sprintf('cell%02d',str2num(cell_spl2{1})))
                        mkdir(sprintf('cell%02d',str2num(cell_spl2{1})))
                        cd(sprintf('cell%02d',str2num(cell_spl2{1})))
                        timestamps = getfield(m,s{i_unit});
                        save('unit.mat','timestamps');
                        cd ..
                    end
                    cd ..
                end
                cd ..
            elseif str2num(cell_spl{2}) > 32 && str2num(cell_spl{2}) < 65
                cd('array02')
                if ~exist(sprintf('channel%03d',str2num(cell_spl{2})-32))
                    mkdir(sprintf('channel%03d',str2num(cell_spl{2})-32))
                    cell_spl2 = strsplit(cell_spl{3},'s');
                    cd(sprintf('channel%03d',str2num(cell_spl{2})-32))
                    if ~exist(sprintf('cell%02d',str2num(cell_spl2{1})))
                        mkdir(sprintf('cell%02d',str2num(cell_spl2{1})))
                        cd(sprintf('cell%02d',str2num(cell_spl2{1})))
                        timestamps = getfield(m,s{i_unit});
                        save('unit.mat','timestamps');
                        cd ..
                    end
                    cd ..
                else
                    cell_spl2 = strsplit(cell_spl{3},'s');
                    cd(sprintf('channel%03d',str2num(cell_spl{2})-32))
                    if ~exist(sprintf('cell%02d',str2num(cell_spl2{1})))
                        mkdir(sprintf('cell%02d',str2num(cell_spl2{1})))
                        cd(sprintf('cell%02d',str2num(cell_spl2{1})))
                        timestamps = getfield(m,s{i_unit});
                        save('unit.mat','timestamps');
                        cd ..
                    end
                    cd ..
                end
                cd ..
            elseif str2num(cell_spl{2}) > 64 && str2num(cell_spl{2}) < 97
                cd('array03')
                if ~exist(sprintf('channel%03d',str2num(cell_spl{2})-64))
                    mkdir(sprintf('channel%03d',str2num(cell_spl{2})-64))
                    cell_spl2 = strsplit(cell_spl{3},'s');
                    cd(sprintf('channel%03d',str2num(cell_spl{2})-64))
                    if ~exist(sprintf('cell%02d',str2num(cell_spl2{1})))
                        mkdir(sprintf('cell%02d',str2num(cell_spl2{1})))
                        cd(sprintf('cell%02d',str2num(cell_spl2{1})))
                        timestamps = getfield(m,s{i_unit});
                        save('unit.mat','timestamps');
                        cd ..
                    end
                    cd ..
                else
                    cell_spl2 = strsplit(cell_spl{3},'s');
                    cd(sprintf('channel%03d',str2num(cell_spl{2})-64))
                    if ~exist(sprintf('cell%02d',str2num(cell_spl2{1})))
                        mkdir(sprintf('cell%02d',str2num(cell_spl2{1})))
                        cd(sprintf('cell%02d',str2num(cell_spl2{1})))
                        timestamps = getfield(m,s{i_unit});
                        save('unit.mat','timestamps');
                        cd ..
                    end
                    cd ..
                end
                cd ..
            elseif str2num(cell_spl{2}) > 96 && str2num(cell_spl{2}) < 129
                cd('array04')
                if ~exist(sprintf('channel%03d',str2num(cell_spl{2})-96))
                    mkdir(sprintf('channel%03d',str2num(cell_spl{2})-96))
                    cell_spl2 = strsplit(cell_spl{3},'s');
                    cd(sprintf('channel%03d',str2num(cell_spl{2})-96))
                    if ~exist(sprintf('cell%02d',str2num(cell_spl2{1})))
                        mkdir(sprintf('cell%02d',str2num(cell_spl2{1})))
                        cd(sprintf('cell%02d',str2num(cell_spl2{1})))
                        timestamps = getfield(m,s{i_unit});
                        save('unit.mat','timestamps');
                        cd ..
                    end
                    cd ..
                else
                    cell_spl2 = strsplit(cell_spl{3},'s');
                    cd(sprintf('channel%03d',str2num(cell_spl{2})-96))
                    if ~exist(sprintf('cell%02d',str2num(cell_spl2{1})))
                        mkdir(sprintf('cell%02d',str2num(cell_spl2{1})))
                        cd(sprintf('cell%02d',str2num(cell_spl2{1})))
                        timestamps = getfield(m,s{i_unit});
                        save('unit.mat','timestamps');
                        cd ..
                    end
                    cd ..
                end
                cd ..
            elseif str2num(cell_spl{2}) > 128 && str2num(cell_spl{2}) < 161
                cd('array05')
                if ~exist(sprintf('channel%03d',str2num(cell_spl{2})-96))
                    mkdir(sprintf('channel%03d',str2num(cell_spl{2})-96))
                    cell_spl2 = strsplit(cell_spl{3},'s');
                    cd(sprintf('channel%03d',str2num(cell_spl{2})-96))
                    if ~exist(sprintf('cell%02d',str2num(cell_spl2{1})))
                        mkdir(sprintf('cell%02d',str2num(cell_spl2{1})))
                        cd(sprintf('cell%02d',str2num(cell_spl2{1})))
                        timestamps = getfield(m,s{i_unit});
                        save('unit.mat','timestamps');
                        cd ..
                    end
                    cd ..
                else
                    cell_spl2 = strsplit(cell_spl{3},'s');
                    cd(sprintf('channel%03d',str2num(cell_spl{2})-96))
                    if ~exist(sprintf('cell%02d',str2num(cell_spl2{1})))
                        mkdir(sprintf('cell%02d',str2num(cell_spl2{1})))
                        cd(sprintf('cell%02d',str2num(cell_spl2{1})))
                        timestamps = getfield(m,s{i_unit});
                        save('unit.mat','timestamps');
                        cd ..
                    end
                    cd ..
                end
                cd ..
            elseif str2num(cell_spl{2}) > 160 && str2num(cell_spl{2}) < 193
                cd('array06')
                if ~exist(sprintf('channel%03d',str2num(cell_spl{2})-96))
                    mkdir(sprintf('channel%03d',str2num(cell_spl{2})-96))
                    cell_spl2 = strsplit(cell_spl{3},'s');
                    cd(sprintf('channel%03d',str2num(cell_spl{2})-96))
                    if ~exist(sprintf('cell%02d',str2num(cell_spl2{1})))
                        mkdir(sprintf('cell%02d',str2num(cell_spl2{1})))
                        cd(sprintf('cell%02d',str2num(cell_spl2{1})))
                        timestamps = getfield(m,s{i_unit});
                        save('unit.mat','timestamps');
                        cd ..
                    end
                    cd ..
                else
                    cell_spl2 = strsplit(cell_spl{3},'s');
                    cd(sprintf('channel%03d',str2num(cell_spl{2})-96))
                    if ~exist(sprintf('cell%02d',str2num(cell_spl2{1})))
                        mkdir(sprintf('cell%02d',str2num(cell_spl2{1})))
                        cd(sprintf('cell%02d',str2num(cell_spl2{1})))
                        timestamps = getfield(m,s{i_unit});
                        save('unit.mat','timestamps');
                        cd ..
                    end
                    cd ..
                end
                cd ..
            elseif str2num(cell_spl{2}) > 192 && str2num(cell_spl{2}) < 225
                cd('array07')
                if ~exist(sprintf('channel%03d',str2num(cell_spl{2})-96))
                    mkdir(sprintf('channel%03d',str2num(cell_spl{2})-96))
                    cell_spl2 = strsplit(cell_spl{3},'s');
                    cd(sprintf('channel%03d',str2num(cell_spl{2})-96))
                    if ~exist(sprintf('cell%02d',str2num(cell_spl2{1})))
                        mkdir(sprintf('cell%02d',str2num(cell_spl2{1})))
                        cd(sprintf('cell%02d',str2num(cell_spl2{1})))
                        timestamps = getfield(m,s{i_unit});
                        save('unit.mat','timestamps');
                        cd ..
                    end
                    cd ..
                else
                    cell_spl2 = strsplit(cell_spl{3},'s');
                    cd(sprintf('channel%03d',str2num(cell_spl{2})-96))
                    if ~exist(sprintf('cell%02d',str2num(cell_spl2{1})))
                        mkdir(sprintf('cell%02d',str2num(cell_spl2{1})))
                        cd(sprintf('cell%02d',str2num(cell_spl2{1})))
                        timestamps = getfield(m,s{i_unit});
                        save('unit.mat','timestamps');
                        cd ..
                    end
                    cd ..
                end
                cd ..
            else
               cd('array08')
               if ~exist(sprintf('channel%03d',str2num(cell_spl{2})-96))
                   mkdir(sprintf('channel%03d',str2num(cell_spl{2})-96))
                   cell_spl2 = strsplit(cell_spl{3},'s');
                   cd(sprintf('channel%03d',str2num(cell_spl{2})-96))
                   if ~exist(sprintf('cell%02d',str2num(cell_spl2{1})))
                       mkdir(sprintf('cell%02d',str2num(cell_spl2{1})))
                       cd(sprintf('cell%02d',str2num(cell_spl2{1})))
                       timestamps = getfield(m,s{i_unit});
                       save('unit.mat','timestamps');
                       cd ..
                   end
                   cd ..
               else
                  cell_spl2 = strsplit(cell_spl{3},'s');
                   cd(sprintf('channel%03d',str2num(cell_spl{2})-96))
                   if ~exist(sprintf('cell%02d',str2num(cell_spl2{1})))
                       mkdir(sprintf('cell%02d',str2num(cell_spl2{1})))
                       cd(sprintf('cell%02d',str2num(cell_spl2{1})))
                       timestamps = getfield(m,s{i_unit});
                       save('unit.mat','timestamps');
                       cd ..
                   end
                   cd .. 
               end
               cd ..
            end
            
        end
    else
        mkdir('session01')
    end
end
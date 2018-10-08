% This code could convert a simplify3D generated Gcode to autocad readible
% script
%% open and read the file
clear;
m = 1;
d = fopen('t9x.g'); %the file name you opened

while ~feof(d)
  tline = fgetl(d);
  A(m).data = tline;
  m = m+1;
end
fclose(d);

%% Preallocate B to a cell array
C =struct2table(A);
C=table2array(C); 
C = C(~cellfun(@isempty, C));

%% find string layer 1
layer2_char='; layer 2';
for i=1:length(C)
tf = strncmpi(layer2_char,C(i),9);
    if tf == 1
        break
    end 
end
inner_line=i+3; %dunno if 6 is constant

outperi_char='; outer perimeter';
for i=inner_line:length(C)
tf = strncmpi(outperi_char,C(i),9);
    if tf == 1
        break
    end 
end
outer_line=i;

infill_char='; infill';
for i=outer_line:length(C)
tf = strncmpi(infill_char,C(i),9);
    if tf == 1
        break
    end 
end
infill_line=i;

layer3_char='; layer 3, ';
for i=infill_line:length(C)
tf = strncmpi(layer3_char,C(i),11);
    if tf == 1
        break
    end 
end
layer3_line=i;

%% generate the first line
clear layer2_char outperi_char infill_char layer3_char A m
fid = fopen('outputs.txt','w'); %open the file for writing
fprintf(fid, 'LINE\r\n'); %start with LINE
%% write the inner perimeter
g_code=C(inner_line+1:inner_line+1);
D = regexp(g_code, ' ', 'split');
%remove X and Y
for i=1:length(D)
    x_pos=strtok( D{i}(2),string('X'));
    y_pos=strtok( D{i}(3),string('Y'));
    file_content(i,:)=strcat(x_pos,',',y_pos,'\r\n'); 
    fprintf(fid, char(file_content(i,:))); %write to the file
end
    
g_code=C(inner_line+4:outer_line-1);
D = regexp(g_code, ' ', 'split');
%remove X and Y
for i=1:length(D)
    x_pos=strtok( D{i}(2),string('X'));
    y_pos=strtok( D{i}(3),string('Y'));
    file_content(i,:)=strcat(x_pos,',',y_pos,'\r\n'); 
    fprintf(fid, char(file_content(i,:))); %write to the file
end

%% write the outer perimeter

g_code=C(outer_line+1:infill_line-2);
D = regexp(g_code, ' ', 'split');
%remove X and Y
for i=1:length(D)
    x_pos=strtok( D{i}(2),string('X'));
    y_pos=strtok( D{i}(3),string('Y'));
    file_content(i,:)=strcat(x_pos,',',y_pos,'\r\n'); 
    fprintf(fid, char(file_content(i,:))); %write to the file
end

%% write the next infill
g_code=C(infill_line+1:layer3_line-2);
D = regexp(g_code, ' ', 'split');
%remove X and Y
for i=1:length(D)
    x_pos=strtok( D{i}(2),string('X'));
    y_pos=strtok( D{i}(3),string('Y'));
    file_content(i,:)=strcat(x_pos,',',y_pos,'\r\n'); 
    fprintf(fid, char(file_content(i,:))); %write to the file
end
%%
fprintf(fid, 'C'); %end with C
fclose(fid);
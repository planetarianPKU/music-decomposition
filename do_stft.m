clear all;
filepath="little star.mp3";
[x fs]=audioread(filepath);
x=x(:,1);%to make it single
T=length(x)/fs;%total seconds
cut=T/T;%cut rate
wave_cut=x(1:cut*length(x));
rate=5;%downsample rate
wave_use=downsample(wave_cut,rate);

%need to be adjusted,in general, nfft should bigger than nwin.
nwin = 2^10;%each time step cut length
nlap = nwin-10;%jump length
wind = kaiser(nwin,17);%windows type
nfft = 2^11;%signal length to do fft
upper=10*log10(max(wave_use)/(4*1000));%Threshold to pick signal
%spectrogram(wave,wind,nlap,nfft,fs/rate,'MinThreshold',1.2*upper,'yaxis');
[~,f_total,t_total,p_total] =spectrogram(wave_use,wind,nlap,nfft,fs/rate,'MinThreshold',3*upper,'yaxis');

penval=0.00;%The penalty for the frequency change of each linear frequency, the larger the value, the less likely the frequency is to change
nfb=10;%Remove the number of bits of the signal near the maximum
%Tracking linear frequency signals
[fridge,~,lr] = tfridge(p_total,f_total,penval,'NumRidges',3,'NumFrequencyBins',nfb);
p_used=p_total(lr);
dt=(t_total(end)-t_total(1))/(length(t_total)-1);


figure()
set(gcf,'unit','normalized','position',[0,0,1,1]);
out = VideoWriter('little star_120.avi');
FrameRate=120;
out.FrameRate=FrameRate;
open(out);
%save video
jump=1/(FrameRate*dt);
winsec=5;
for j=1:jump:floor(length(t_total))
    starttag=t_total(floor(j))*(fs/rate);
    if (j+winsec/dt>length(t_total))
        wave=wave_use(starttag:end);
        time= 0:rate/fs:winsec*length(wave)/(winsec*(fs/rate))-rate/fs;
        p_slice=p_used(j:end,:);
        t_slice=t_total(j:end);
        fridge_slice=fridge(j:end,:);
    else
        step=winsec/dt;
        wave=wave_use(starttag:starttag+winsec*(fs/rate)-1);
        time=0:rate/fs:winsec-rate/fs;
        p_slice=p_used(j:j+step,:);
        t_slice=t_total(j:j+step);
        fridge_slice=fridge(j:j+step,:);
    end
    subplot(4,1,1)
    plot(time,wave);
    xlim([0,5]);
    ylim([-0.7 0.7]);
    subplot(4,1,[2,3,4])
    plot3(t_slice,fridge_slice,p_slice,'o','LineWidth',0.5,'color','red','MarkerSize',1);
    lst=[28:1:61];
    for i = 1:length(lst)
        hold on;plot3(t_slice,440*2^((lst(i)-49)/12)*ones(size(t_slice)),1e-5*ones(size(t_slice)),'--','LineWidth',0.5,'color','blue');
        txt = [num2str(lst(i)) ' \rightarrow'];text(min(t_slice)+1+3*mod(i,12)/12,440*2^((lst(i)-49)/12),txt,'HorizontalAlignment','right');
    end
    hold off
    ylim([120 1e3])
    view(0,70);
    zlim([1e-6 max(max(abs(p_slice)))])
    xlim([min(t_slice),max(t_slice)]);
    set(gca,'ztick',[])
    set(gca,'ytick',[])
    F=getframe(gcf);
 
    writeVideo(out, F);
end
close(out)

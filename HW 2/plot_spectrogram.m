function plot_spectrogram(spect,time,freq)

imagesc([time(1) time(end)]*1000,[1 length(freq)],spect)
yinds = get(gca,'YTick');
set(gca,'YTickLabel',round(freq(yinds)/1000,1))
set(gca,'YDir','normal')
xlabel('Time (ms)')
ylabel('Frequency (kHz)')
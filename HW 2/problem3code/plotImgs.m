function plotImgs(imgs)
% plot images from a stretched out form

origSize = [1024, 1536];

for col = 1:3
    figure(col)
    currImg = imgs(:, col);
    toPlot = reshape( currImg, origSize);
    imshow( toPlot,[])
end


end


function weights = learnWeights(imgData)
% learns the weights by maximizing the kurtosis
    weights = [0;0;0];
    for i =1:3
        wCurr =  gradDescent( imgData, weights)
        weights(:,i) = wCurr;
    end

end

function weights = gradDescent( imgPixels, ortho )
% runs gradient descent on the demixing coefficients in order to find one
% of the outputs
    weights = randn(3, 1);
    
    for i=1:30
        weights = wUpdate( weights, imgPixels, ortho ); 
    end
    
end

function wOut = wUpdate(win, imgPixels, ortho)
    % orthonormalize
    w = win - ortho * ortho' * win;
    w = w / norm(w);

    g = mean(  (imgPixels*w).^3 .* imgPixels, 1 ); % gradient of kurtosis
    wOut = w + 0.5 * g';
    
    % orthonormalize on both ends
    wOut = wOut - ortho * ortho' * wOut;
    wOut = wOut / norm(wOut);
    
end



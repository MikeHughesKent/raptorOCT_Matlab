% save_volume
% Mike Hughes
% Writes an OCT volume to a multipage TIF file. Assumes volume is (depth, x,y).

function save_volume(volume, filename)

    for iFrame = 1:size(volume,3)
        if iFrame == 1
            imwrite(volume(:,:,iFrame) ./max(volume(:)), filename);
        else
            imwrite(volume(:,:,iFrame) ./max(volume(:)), filename, 'WriteMode', 'Append');
        end
    end

end
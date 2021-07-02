% save_volume_16bit
% Mike Hughes
% Writes an OCT volume to a 16 bit multipage TIF file. Assumes volume is (depth, x,y).

function save_volume_16bit(volume, filename)

    volume2 =  uint16(2^16 * volume / max(volume(:)));
    for iFrame = 1:size(volume,3)
        if iFrame == 1
            imwrite(volume2(:,:,iFrame) , filename);
        else
            imwrite(volume2(:,:,iFrame) , filename, 'WriteMode', 'Append');
        end
    end
    

end
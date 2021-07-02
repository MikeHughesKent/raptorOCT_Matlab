% Alterantive to normxcorr2, code by gnovice, allowing more flexibility
% in performing normalised cross correlation.
%
% Profile: https://stackoverflow.com/users/52738/gnovice
% Taken from: https://stackoverflow.com/questions/9145107/an-elegant-way-to-get-the-output-of-normxcorr2-in-a-manner-similar-to-conv2
function I = normxcorr2e(template, im, shape)

  if (nargin == 2) || strcmp(shape,'full')
      I = normxcorr2(template, im);
      return
  end

  switch shape
      case 'same'
          pad = floor(size(template)./2);
          center = size(im);
      case 'valid'
          pad = size(template) - 1;
          center = size(im) - pad;
      otherwise
          throw(Mexception('normxcorr2e:BadInput',...
              'SHAPE must be ''full'', ''same'', or ''valid''.'));
  end

  I = normxcorr2(template, im);
  I = I([false(1,pad(1)) true(1,center(1))], ...
        [false(1,pad(2)) true(1,center(2))]);

end
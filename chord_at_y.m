function c = chord_at_y(p, y)
% CHORD_AT_Y  Returns chord length at spanwise station(s) y.
%
%   c = chord_at_y(p, y)
%
%   Linear taper from root to tip.
%   y is measured from the fuselage side (y=0 at root, y=semi_span at tip).
%
%   Inputs:
%       p  - parameter struct from wing_params()
%       y  - spanwise coordinate(s) [m], scalar or vector
%
%   Output:
%       c  - chord length(s) [m], same size as y

eta = y / p.semi_span;                      % Normalised span fraction [0,1]
c   = p.c_root * (1 - (1 - p.lambda) * eta);

end

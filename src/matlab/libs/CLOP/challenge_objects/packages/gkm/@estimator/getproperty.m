function value = getproperty(e, property)
%
% GETPROPERTY - retrieve a named property of an estimator
%
%    VALUE = GETPROPERTY(ESTIMATOR,'PROPERTY') returns the value of the
%    named PROPERTY of an object implementing a performance ESTIMATOR.

%
% File        : @estimator/getproperty.m
%
% Date        : Friday 24th August 2007
%
% Author      : Dr Gavin C. Cawley
%
% Description : Retrieve a named property of a performance estimation object. 
%
% History     : 24/08/2007 - v1.00
%
% Copyright   : (c) Dr Gavin C. Cawley, August 2007.
%
%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
%

if strcmp(property, 'criterion')

   value = e.criterion;

elseif strcmp(property, 'type')

   value = e.type;

else

   value = getproperty(c.object);

end

% bye bye...


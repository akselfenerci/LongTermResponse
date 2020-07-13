if verLessThan('matlab','8.0')
    doc;
elseif verLessThan('matlab','8.5')
    doc -classic;
else
    web([fileparts(which('CODES.install')) '/+doc/html/CODES.html'])
end
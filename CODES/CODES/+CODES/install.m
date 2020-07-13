CODES.common.disp_box('CODES toolbox installation')
disp('1 - Installing LIBSVM, requires properly setup mex routine')
cd(fileparts(which('CODES.install')))
if exist('install/libsvm_temp','dir')
    rmdir('install/libsvm_temp','s');
end
copyfile('install/libsvm-3.17','install/libsvm_temp')
try
	run('install/libsvm_temp/matlab/make.m');
	svm_for_test=CODES.fit.svm([1;2],[1;-1]);
	clear svm_for_test
catch
	warning(['It seems something went wrong while mexing LIBSVM.' char(10) 'Do you have a properly set up <a href="http://www.mathworks.com/support/compilers/R2015a/index.html">C++ compiler</a>?' char(10) 'Otherwise, you can still use the CODES implementation of <a href="' fileparts(which('CODES.install')) '/+doc/html/svm.html#training">svm</a> by setting ''solver'' to ''dual''.'])
end
if exist('+fit/+libsvm','dir')
    rmdir('+fit/+libsvm','s');
end
copyfile('install/libsvm_temp/matlab','+fit/+libsvm')
copyfile('install/sigma2gamma.m','+fit/+libsvm/sigma2gamma.m')
rmdir('install/libsvm_temp','s')
disp('2 - Creating searchable help files')
builddocsearchdb([fileparts(which('CODES.install')) '/+doc/html'])
disp('3 - Opening the help (using "CODES.doc")')
disp('    Then select "CODES Toolbox"')
CODES.doc
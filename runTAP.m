function runTAP

import matlab.unittest.TestSuite;
import matlab.unittest.TestRunner;
import matlab.unittest.plugins.TAPPlugin;
import matlab.unittest.plugins.ToFile;

try
    % Create the suite and runner
    addpath(project_paths)
    suite = TestSuite.fromFolder('tests');
    runner = TestRunner.withTextOutput;

    % Add the TAPPlugin directed to a file in the Jenkins workspace
    tapFile = fullfile(getenv('WORKSPACE'), 'testResults.tap');
    runner.addPlugin(TAPPlugin.producingOriginalFormat(ToFile(tapFile)));
    
    runner.run(suite); 
catch e;
    disp(e.getReport);
    if not(usejava('desktop'))
        exit(1);
    end
end;
if not(usejava('desktop'))
    exit force;
end


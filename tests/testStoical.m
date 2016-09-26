classdef testStoical < matlab.unittest.TestCase
    
    methods(TestMethodTeardown)
        function close_all_simulink_models(testCase)
            bdclose all;
        end
    end
    
    methods(Test)
        
        function testModelContainsOnlyOneParameter( testCase )
            testCase.injectInputStub({'foo bar'});
            
            STOICAL_MODEL = 'househeat_single_param_issue';
            load_system(fullfile('models', STOICAL_MODEL));
            stoical.prepare.activate.Parameters
        end
        
        function testSetParameterInLinkedModels(testCase)
            testCase.injectInputStub({'0', '0', '0', '0', '0', '0'});
            
            STOICAL_MODEL = 'model_with_library_links';
            load_system(fullfile(STOICAL_MODEL));
            
            % prepare model
            stoical.prepare.disableLinks(STOICAL_MODEL, {'library'});
            stoical.prepare.all;
            
            %% run model
            STOICAL = stoical.Aggregations.getLabeledObjDataFromModelWorkspace(STOICAL_MODEL);
            
            stoical.VariantSubsystems.interface.setActiveVariant('#Controller','PI-controller',STOICAL);
            
            % Stimulus
            stoical.Parameters.setParameterValue('#Stimulus#Amplitude',num2str(1),STOICAL);
            % Controller
            stoical.Parameters.setParameterValue('#Controller#P',num2str(1),STOICAL);
            stoical.Parameters.setParameterValue('#Controller#I',num2str(1),STOICAL);
            % System
            stoical.Parameters.setParameterValue('#System#SystemGain',num2str(1),STOICAL);
            stoical.Parameters.setParameterValue('#System#w0',num2str(1.6),STOICAL);
            stoical.Parameters.setParameterValue('#System#damp',num2str(50),STOICAL);
            
            evalc([STOICAL.SignalSaveOptions.ReturnWorkspaceOutputsName ' = sim(STOICAL_MODEL);']);
            
            % check output
        end
    end
    
    methods(Access=private)
        function injectInputStub(testCase, answer)
            import matlab.unittest.fixtures.PathFixture;
            
            % Use the PathFixture to temporarily add the folder to the path
            % and restore it when the test method completes
            p = mfilename('fullpath');
            p = fileparts(p);
            testCase.applyFixture(PathFixture(fullfile(p, 'overloads')));
            inputdlg('','','','','', answer)
        end
    end
end


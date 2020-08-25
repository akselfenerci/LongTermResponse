%% test daceFit

loaded = load(fullfile('+dace', 'data1.mat'));
samples = loaded.S;
responses = loaded.Y;


theta = [10 10]; lob = [1e-1 1e-1]; upb = [20 20];
% make the model by calling dacefit
[dmodel, perf] = dace.dacefit(samples, responses, ...
  @dace.regpoly0, @dace.corrgauss, theta, lob, upb)

y = dace.predictor(samples, dmodel);

max(abs(y - responses))

%% test edsd.KrigingDace with same data
krigingModel = edsd.KrigingDace(samples, responses);

y2 = krigingModel.evaluate(samples);
max(abs(y2 - responses))

[v,ii] = max(abs(krigingModel.evaluate(krigingModel.samples) - krigingModel.responses))
max(abs(y2 - responses))


%% test edsd.KrigingDace with random data
domain = edsd.Box(2);
nS = 2000;
samples = domain.cvtSamples(nS);
responses = rand(nS,1);


% theta = [10 10]; 
% lob = [1e-1 1e-1]; 
lob = 0.01 * [1 1]; 
upb = [2 2];
err = Inf;
errTol = 1e-9;
while err > errTol
  theta= (lob + upb) / 2;
  % make the model by calling dacefit
  [dmodel, perf] = dace.dacefit(samples, responses, ...
    @dace.regpoly0, @dace.corrgauss, theta, lob, upb)
  
  y = dace.predictor(samples, dmodel);
  
  err = max(abs(y - responses))
  
  if err > errTol
    lob = 2 * lob;
    if ~all(upb > 2 * lob)
      upb = 2 * upb;
    end
  end
  
end
    

%%


krigingModel = edsd.KrigingDace(samples, responses);





y2 = krigingModel.evaluate(samples);

max(abs(y2 - responses))

[v,ii] = max(abs(krigingModel.evaluate(krigingModel.samples) - krigingModel.responses))
max(abs(y2 - responses))


theta = [10 10]; lob = [1e-1 1e-1]; upb = [20 20];
% make the model by calling dacefit
[dmodel, perf] = dace.dacefit(samples, responses, ...
  @dace.regpoly0, @dace.corrgauss, theta, lob, upb)

y = dace.predictor(samples, dmodel);

max(abs(y - responses))
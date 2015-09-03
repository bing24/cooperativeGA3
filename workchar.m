clear all;
close all;

tic

load shou
gaConfig.mutationProbability=0;
optimizor.mapMatrix=map.matrix;
optimizor.count=1;
optimizor.iteration=[];
% for agent_number = 1:number_of_spicies
%         % population(agent_number)= InitializePopulation(map, gaConfig);

%         Evaluating(population(agent_number),map,gaConfig);
% end

% shuffle the best individual from previous optimization

for i= 1:number_of_spicies
  % population(i).gene_length=30;
  % save the best individual from previous optimization
  lastBest=nonzeros(population(i).chromo(:,optimizor.bestIndividualIndex));
  lastBestLength=length(lastBest);
  % clear the old generation
  population(i).chromo=zeros(lastBestLength*2+4,gaConfig.PopulationSize);
  for j= 1:gaConfig.PopulationSize
    % generate random slots for numbers
    % lastBestIndex=sort(randperm(population(i).gene_length-1,lastBestLength)+1);

    % population(i).chromo(lastBestIndex,j)=lastBest;

    
    battery=4;
    record=[];

    for kk=1:lastBestLength
    record=[record;lastBest(kk)];
    battery=battery-1;
    charge=rand>0.8;
      if battery==0
        charge=1;
      end
      if battery >= lastBestLength-kk
        charge=0;
      end
      if charge ==1
        zz=4-battery;
        battery=4;
        record=cat(1,record,zeros(zz,1));
         
      end
    b(kk)=battery;
    end
    population(i).record_length(j)=length(record);
    population(i).chromo(1:length(record),j)=record;
  end
end

%cooperative part
% figure
% contour(map.matrix,1,'black','linewidth',5)
% hold on
% plot(map.mission_location(:,1),map.mission_location(:,2),'.')
generation=100;
for i=1:generation
    
  for agent_number = 1:number_of_spicies
      % population(agent_number)= InitializePopulation(map, gaConfig);
      Evaluating(population(agent_number),map,gaConfig);
  end
    EvaluatingAll(optimizor,population,map,gaConfig,chargers,randIndexes);
  for agent_number = 1:number_of_spicies
    population(agent_number).fitness=optimizor.fitness;
    population(agent_number).bestIndividualIndex=optimizor.bestIndividualIndex;
  end
  for agent_number = 1:number_of_spicies
    Selecting(population(agent_number),gaConfig,0.5);
  end
    % Mutate
    randIndexes = ceil(rand(1,gaConfig.numberOfReplications).*gaConfig.PopulationSize);
  for agent_number = 1:number_of_spicies
    Mutating(population(agent_number),gaConfig,randIndexes)
  end
  plotall(optimizor,population,chargers,gaConfig)
  drawnow
end
 for agent_number = 1:number_of_spicies
      % population(agent_number)= InitializePopulation(map, gaConfig);
      Evaluating(population(agent_number),map,gaConfig);
  end

plotall(optimizor,population,chargers,gaConfig)
toc
% obj=population;

obj=optimizor;

a=chargers(1);
b=population(1);


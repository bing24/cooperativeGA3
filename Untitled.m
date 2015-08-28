clear all;
close all;

load shou
%cooperative part
figure
contour(map.matrix,1,'black','linewidth',5)
hold on
plot(map.mission_location(:,1),map.mission_location(:,2),'.')
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

Evaluating(population(agent_number),map,gaConfig);
plotall(optimizor,population,chargers,gaConfig)
toc
% obj=population;

obj=optimizor;
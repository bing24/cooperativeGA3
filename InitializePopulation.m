classdef InitializePopulation < handle
    
    properties
        color
        cover
        charging_index
        charging_locationx
        charging_locationy
        chromo
        chromo_index
        currentx
        currenty
        % chromo_locationx
        % chromo_locationy
        chromo_number
        xbordermax=14;
        xbordermin=1;
        ybordermax=11;
        ybordermin=1;
        fitness
        minimumFitness
        bestIndividualIndex
        newPopulation
        gene_length=30;
        start_point=14;
        end_point=124;
        initialx
        initialy
        charging_ratio=0.5;
        charging_enough
        nodes_dis_charging;
        max_speed_charging=8;
        judger;
        agent_number=5;
        cost_dis;
        cost_dis_charging;
        figure_handle
        battery_life=4;
        record_length;
    end
    
    methods
        
        function population = InitializePopulation(map, gaConfig)
            population.chromo_number=population.gene_length;
            
            % population.chromo=round(4*rand(population.gene_length,gaConfig.PopulationSize));
            
            
            for j= 1: gaConfig.PopulationSize
                for i = 1: population.gene_length
                    if population.charging_ratio <= rand
                        population.chromo(i,j)=0;
                    else
                        population.chromo(i,j)=ceil(4*rand);
                    end
                end
            end
           
        end % function


        function addchromo(obj, number_of_chromos_to_add,chromos)
            if nargin==1
                number_of_chromos_to_add=1;
            end
            for i=1:number_of_chromos_to_add
                obj.chromo=[obj.chromo, chromo(chromos)];
                
            end
        end % function

        function  Evaluating (obj,map,gaConfig)

            % Clear memory from last iteration
            obj.charging_index=zeros(obj.gene_length,gaConfig.PopulationSize);
            obj.charging_locationx=[];
            obj.charging_locationy=[];
            obj.nodes_dis_charging=[];
            obj.judger=[];
            obj.cover=[];
            obj.charging_enough=[];
            % Generate locations for working robots and charging robots
            for j=1:gaConfig.PopulationSize
                obj.currentx(1,j)=obj.initialx;
                obj.currenty(1,j)=obj.initialy;
                for i=2:size(obj.chromo,1)
    
                    if obj.chromo(i-1,j)==1
                        obj.currentx(i,j)=obj.currentx(i-1,j);
                        obj.currenty(i,j)=obj.currenty(i-1,j)+1;
                        
                    elseif obj.chromo(i-1,j)==2
                       
                        obj.currentx(i,j)=obj.currentx(i-1,j)-1;
                        obj.currenty(i,j)=obj.currenty(i-1,j);
                        
                    elseif obj.chromo(i-1,j)==3
                        
                        obj.currentx(i,j)=obj.currentx(i-1,j);
                        obj.currenty(i,j)=obj.currenty(i-1,j)-1;
                        
                    elseif obj.chromo(i-1,j)==4
                        
                        obj.currentx(i,j)=obj.currentx(i-1,j)+1;
                        obj.currenty(i,j)=obj.currenty(i-1,j);
                        
                    elseif obj.chromo(i-1,j)==0
                        obj.currentx(i,j)=obj.currentx(i-1,j);
                        obj.currenty(i,j)=obj.currenty(i-1,j);
                    end
                end
            end
            
            % Charging robots locations
            for j=1:gaConfig.PopulationSize
                count=1;
                ff=1;
                while sum(obj.chromo(1:ff,j))~=sum(obj.chromo(:,j))
                    ff=ff+1;
                end
                for i=1:ff               
                    if obj.chromo(i,j)==0 && obj.chromo(i-1,j)~=0
                        obj.charging_locationx(count,j)=obj.currentx(i,j);
                        obj.charging_locationy(count,j)=obj.currenty(i,j);
                        count=count+1;
                    end
                end
            end
            
            obj.cost_dis=[];
            % Calculate Euclidean between each nodes
            for j= 1: gaConfig.PopulationSize
                for i= 1: obj.chromo_number
                    if isempty(find(map.location_matrix(:,1)==obj.currentx(i,j) & map.location_matrix(:,2)==obj.currenty(i,j)))
                        obj.chromo_index(i,j)=0;
                    else
                        obj.chromo_index(i,j)=find(map.location_matrix(:,1)==obj.currentx(i,j) & map.location_matrix(:,2)==obj.currenty(i,j));
                    end
                    if obj.chromo(i,j)==0
                        obj.charging_index(i,j)=obj.chromo_index(i,j);
                    end
                end
                % chromo_charging=[chromo_charging;obj.chromo(end)];
                % Cost function (distance)
                
                obj.cost_dis(j)=length(nonzeros(obj.chromo(:,j)));
                
                
                
      
            end
            
        end % function
    
        function Selecting (obj,gaConfig,tournamentSelectionParameter)
            obj.newPopulation=obj.chromo;
            for i = 1:gaConfig.TournamentSize:gaConfig.PopulationSize
                
                % iSelected = TournamentSelect( fitnessValues, tournamentSelectionParameter, tournamentSize)
                %select 'tournamentSize' candidates for tournament
                candidates = 1 + fix(rand(1,gaConfig.TournamentSize)*gaConfig.PopulationSize);
                candidateFitnesses = obj.fitness(candidates);
                [~, sortedIndexes] = sort(candidateFitnesses,1,'descend');
                selectionProbabilityMatrix = tournamentSelectionParameter*((1-tournamentSelectionParameter).^(0:gaConfig.TournamentSize-2)');
                r = rand;
                iSelected = candidates(sortedIndexes(r>selectionProbabilityMatrix));
                if isempty(iSelected)
                    iSelected = candidates(sortedIndexes(end));
                else
                    iSelected = iSelected(1);
                end
                
                %% TOURNAMENT SELECTION
                
                chromosome1 = obj.chromo(:,iSelected);
                candidates = 1 + fix(rand(1,gaConfig.TournamentSize)*gaConfig.PopulationSize);
                candidateFitnesses = obj.fitness(candidates);
                [~, sortedIndexes] = sort(candidateFitnesses,2,'descend');
                selectionProbabilityMatrix = tournamentSelectionParameter*((1-tournamentSelectionParameter).^(0:gaConfig.TournamentSize-2)');
                r = rand;
                iSelected = candidates(sortedIndexes(r>selectionProbabilityMatrix));
                if isempty(iSelected)
                    iSelected = candidates(sortedIndexes(end));
                else
                    iSelected = iSelected(1);
                end
                chromosome2 = obj.chromo(:,iSelected);
                
                %% CROSS-OVER
                r = rand;
                if ( r < gaConfig.CrossoverRate)
                    
                    n=ceil(rand(size(obj.chromo,1)));
                    newChromosomePair=zeros(size(obj.chromo,1),2);
                    newChromosomePair(1:n,1)=chromosome1(1:n);
                    newChromosomePair(n:end,1)=chromosome2(n:end);
                    newChromosomePair(1:n,2)=chromosome2(1:n);
                    newChromosomePair(n:end,2)=chromosome1(n:end);
                    
                    obj.newPopulation(:,i) = newChromosomePair(:,1);
                    obj.newPopulation(:,i+1) = newChromosomePair(:,2);
                else
                    obj.newPopulation(:,i) = chromosome1;
                    obj.newPopulation(:,i+1) = chromosome2;
                end
                
            end
        end
        
        function Ploting(obj)
            if ishandle(obj.figure_handle)
                delete(obj.figure_handle)
            end
            % hold off
            obj.figure_handle=plot(obj.currentx(:,obj.bestIndividualIndex),obj.currenty(:,obj.bestIndividualIndex),'Color',obj.color,'linewidth',3);
            % hold on
%             contour(map.matrix,1,'black','linewidth',5)
            title(obj.minimumFitness)

        end
        
        function Mutating(obj,gaConfig,randIndexes)
            indexes = rand(size(obj.chromo))<gaConfig.mutationProbability;                 % Index for Mutations
            
            temp=round(4*rand(size(obj.chromo,1),gaConfig.PopulationSize));
            
            %fix the starting point finishing point 
            % indexes(1,:)=0;
            % indexes(end,:)=0;
            
            obj.newPopulation(indexes) =temp(indexes);
            
            % = tempPopulation(indexes)*-1+1;                     % Bit Flip Occurs
            %% PRESERVATION OF PREVIOUS BEST SOLUTION
            bestChromosome =obj.chromo(:,obj.bestIndividualIndex);
            
            
            obj.newPopulation(:,randIndexes) = repmat(bestChromosome,1,gaConfig.numberOfReplications);
            obj.chromo=obj.newPopulation;
            
        end %end function

        function SetColor(obj,color)
            obj.color=color;
        end
        
        function SetInitial(obj,xy)
            obj.initialx=xy(1);
            obj.initialy=xy(2);
        end
    end % method
    
end % classdef
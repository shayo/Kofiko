function [g_strctPlexon] = fnUpdatePolarPlot(varargin)
global g_strctPlexon g_strctPTB
	 
		% Sloppy for now

	

		polarRadius = range([g_strctPTB.m_afPolarRect(2),g_strctPTB.m_afPolarRect(4)])/2; % Should always be a square, so we can use x or y. Using y here
		centerOfCircle = [range([g_strctPTB.m_afPolarRect(1),g_strctPTB.m_afPolarRect(3)])/2 + g_strctPTB.m_afPolarRect(1),...
						   range([g_strctPTB.m_afPolarRect(2),g_strctPTB.m_afPolarRect(4)])/2 + g_strctPTB.m_afPolarRect(2)];
		% Normalize the radius to the highest spike count

		%normalizedRadius = polarRadius/max(g_strctPlexon.m_afConditionSpikes);
		% Weighted Average the latest trial into the condition
		

		% Setup array for polar plotting

		numConditions = numel(fields(g_strctPlexon.m_afConditionSpikes));
		g_strctPlexon.m_afPolarPlottingArray  = zeros(numConditions,2); 

        maximums = zeros(numConditions,1);
		for i = 1:numConditions
			
			cond = ['condition',num2str(i)];
			maximums(i) = mean(sum([g_strctPlexon.m_afConditionSpikes.(cond)(g_strctPlexon.m_afConditionSpikes.(cond)(:,2) == 1)],2));
        end
        %maximums(isnan(maximums)) = 0;
            %maximums(maximums == NaN) = 0;
        normMax = max(maximums);
            
		normalizedSpikes = zeros(numConditions,1);
		for i = 1:numConditions
            if isnan(normMax)
                normalizedSpikes(i) = 0;
            else
                normalizedSpikes(i) = maximums(i)/normMax;
            end
		   rotAngle = (i/numConditions) * 2 * pi;
		  % g_strctPlexon.m_afPolarArray(i,1) =  
		   [g_strctPlexon.m_afPolarPlottingArray(i,1), g_strctPlexon.m_afPolarPlottingArray(i,2)] = fnRotateAroundPoint(centerOfCircle(1) ,centerOfCircle(2) + (normalizedSpikes(i) * polarRadius) ,...
                                                                    centerOfCircle(1), centerOfCircle(2), rotAngle);
		   %PolarArray(i,3) = 
			
			%PolarArray(i,2) = normalizedSpikes(i);
		end
	%disp(g_strctPlexon.m_afPolarPlottingArray)
	%disp(normalizedSpikes)
	
return;





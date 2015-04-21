function fnPlotPolarGrid(rmin,rmax, rticks,bPrintText)

        hold on;
        tc = [0,0,0];
        cax = gca;
        ls = '--';
        th = 0 : pi / 50 : 2 * pi;
        xunit = cos(th);
        yunit = sin(th);
        % now really force points on x/y axes to lie on them exactly
        inds = 1 : (length(th) - 1) / 4 : length(th);
        xunit(inds(2 : 2 : 4)) = zeros(2, 1);
        yunit(inds(1 : 2 : 5)) = zeros(3, 1);
        % plot background if necessary
            patch('XData', xunit * rmax, 'YData', yunit * rmax, ...
                'EdgeColor', tc, 'FaceColor', get(cax, 'Color'), ...
                'HandleVisibility', 'off', 'Parent', cax);
       
        % draw radial circles
        c82 = cos(82 * pi / 180);
        s82 = sin(82 * pi / 180);
        rinc = (rmax - rmin) / rticks;
        for i = (rmin + rinc) : rinc : rmax
            hhh = line(xunit * i, yunit * i, 'LineStyle', ls, 'Color', tc, 'LineWidth', 1, ...
                'HandleVisibility', 'off', 'Parent', cax);
            if bPrintText
                
           if rmax > 1
               text((i + rinc / 20) * c82, (i + rinc / 20) * s82, ['  ' num2str(round(i))], 'VerticalAlignment', 'bottom', 'HandleVisibility', 'off', 'Parent', cax);
           else
                text((i + rinc / 20) * c82, (i + rinc / 20) * s82, ['  ' num2str(i)], 'VerticalAlignment', 'bottom', 'HandleVisibility', 'off', 'Parent', cax);
           end
            end
        end
        set(hhh, 'LineStyle', '-'); % Make outer circle solid
        
        % plot spokes
        th = [0,pi/4,pi/2,3*pi/4];
        cst = cos(th);
        snt = sin(th);
        cs = [-cst; cst];
        sn = [-snt; snt];
        line(rmax * cs, rmax * sn, 'LineStyle', ls, 'Color', tc, 'LineWidth', 1, ...
            'HandleVisibility', 'off', 'Parent', cax);
        
        if 0
        % annotate spokes in degrees
        
        rt = 1.1 * rmax;

        for i = 1 : length(th)
            text(rt * cst(i), rt * snt(i), int2str(i * 30),...
                'HorizontalAlignment', 'center', ...
                'HandleVisibility', 'off', 'Parent', cax);
            if i == length(th)
                loc = int2str(0);
            else
                loc = int2str(180 + i * 30);
            end
            text(-rt * cst(i), -rt * snt(i), loc, 'HorizontalAlignment', 'center', ...
                'HandleVisibility', 'off', 'Parent', cax);
        end
        end
        axis equal;
        axis off
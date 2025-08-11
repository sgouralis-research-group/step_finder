function Gim = chainer_visualize(Gim,chain)

chain_B = sum(chain.b,1);
chain_B(~chain.i) = nan;

% chain_b = repmat(1:chain.params.M,chain.length,1);
% chain_b(~chain.b) = nan;

chain_t = chain.t'; % reshape
chain_t(~chain.b') = nan;


%% init
if isempty(Gim)

    num = 5;
    mum = 3;

    chain_i = double(chain.i(1)) + chain.stride*(0:chain.length-1)';
    i_lim = [max(chain_i(1),0.1*chain_i(end)) chain_i(end)+1];

    figure(10)
    set(gcf,'windowstyle','docked')
    clf

    tiledlayout(num,mum,'TileSpacing','compact')

    
    % --- Sample ----------------------------------------------------------
    ax_W = nexttile(0*mum+1,[num mum-1]);

    Gim.u = line(ax_W,chain.params.t,nan(chain.params.N,1),'marker','.','color','c');
    Gim_W = line(ax_W,chain.params.t,chain.params.W,'marker','.','color','k','linestyle','none');
    Gim_p = xline(ax_W,[chain.params.t_prior_min,chain.params.t_prior_max],':k');
    Gim.T = xline(ax_W,nan(1,chain.params.M));

    xlim(ax_W,[chain.params.t_min chain.params.t_max])
    ylabel(ax_W,['stimulus (',chain.params.units_stim,')'])
    xlabel(ax_W,['time (',chain.params.units_time,')'])

    title(ax_W,'MCMC sample')
    title(ax_W,{'MCMC sample',['(N=',num2str(chain.params.N),', M=',num2str(chain.params.M), ')']})

    legend(ax_W,[Gim.u;Gim_W;Gim_p(1)],'stimuli','data','prior','box','off')


    % --- MCMC ------------------------------------------------------------
    ax_P = nexttile(1*mum,[1 1]);
    ax_B = nexttile(2*mum,[1 1]);
    ax_t = nexttile(3*mum,[3 1]);

    ax_P.YAxisLocation = 'Right';
    ax_B.YAxisLocation = 'Right';
    ax_t.YAxisLocation = 'Right';

    ax_P.XLim = i_lim;
    ax_B.XLim = i_lim;
    ax_t.XLim = i_lim;

    ax_B.YLim = [0,chain.params.M+1];

    title(ax_P,{'MCMC chain',['(stride=',num2str(chain.stride),')']})

    xlabel(ax_t, 'MCMC iteration (i)')

    ax_P.YGrid = 'on';
    ax_B.YGrid = 'on';
    ax_t.YGrid = 'on';

    ylabel(ax_P, 'logP_{post} (nat)'  )
    ylabel(ax_B, 'B'  )
    ylabel(ax_t,['t^{active}_{stp} (',chain.params.units_time,')'] )

    if ~isempty( chain.ledger )
        xline(ax_P,chain.ledger(end,1));
        xline(ax_B,chain.ledger(end,1));
        xline(ax_t,chain.ledger(end,1));
    end

    yline(ax_B,chain.params.M,':k')
    yline(ax_t,[chain.params.t_prior_min,chain.params.t_prior_max],':k')

    Gim.P = line(ax_P,chain_i,nan(chain.length,             1),'marker','.','Color',Gim.u.Color);
    Gim.B = line(ax_B,chain_i,nan(chain.length,             1),'marker','.','Color',Gim.u.Color);
    Gim.t = line(ax_t,chain_i,nan(chain.length,chain.params.M),'marker','.');


    % --- ground ----------------------------------------------------------

    if isfield( chain.params,'ground' ) && isscalar(chain.params.ground.t)
        yline(ax_B,length(chain.params.t),'g')
        yline(ax_t,chain.params.ground.t ,'g')
    end


    % --- ------ ----------------------------------------------------------
    for m=1:chain.params.M
        Gim.T(m).Color = Gim.t(m).Color;
    end

end % init



Gim.u.YData = chain.sample.u;

Gim.P.YData = sum(chain.P)+chain.L;
Gim.B.YData = chain_B;

for m=1:chain.params.M
    Gim.t(m).YData = chain_t(:,m);
    if chain.sample.b(m)
        Gim.T(m).Value = chain.sample.t(m);
    else
        Gim.T(m).Value = nan;
    end        
end


drawnow


end % visualize

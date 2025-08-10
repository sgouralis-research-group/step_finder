function chain = chainer_main(chain_init,d_length,opts,flag_status,flag_visual)

tic_id = tic;

% initialize the seed or use seed for last expansion
if isempty(chain_init)
    rng('shuffle');
else
    rng(chain_init.random);
end


% init chain --------------------------------------------------------------
if d_length == 0

    % MCMC
    chain.params = chainer_init_params(opts);

    chain.length = 1;
    chain.stride = 1;
    chain.ledger = nan(0,2); % total wall time without Initialization
    chain.sizeGB = nan;      % current chain memory size
    chain.record = [];       % acceptance rates
    chain.sample = [];

    chain.sample = chainer_init_sample(chain.params);
    
    % history
    chain.i = cast( chain.sample.i, 'uint64' );
    chain.P = cast( chain.sample.P, 'double' );
    chain.L = cast( chain.sample.L, 'double' );
    chain.C = cast( chain.sample.C, 'single' );
    chain.h = cast( chain.sample.h, 'single' );
    chain.t = cast( chain.sample.t, 'single' );
    chain.b = cast( chain.sample.b, 'logical');
    
    if flag_status
        disp('CHAINER: chain initiated')
    end

    

% expand chain ------------------------------------------------------------
elseif d_length > 0

    chain.params = chain_init.params;
    chain.length = chain_init.length + d_length;
    chain.stride = chain_init.stride;
    chain.ledger = chain_init.ledger;
    chain.sizeGB = nan;
    chain.record = chain_init.record;
    chain.sample = chain_init.sample;
    
    chain.i = cat( 2 , chain_init.i , zeros( 1              , d_length , 'like',chain_init.i ) );
    chain.P = cat( 2 , chain_init.P ,   nan( get_log_priors , d_length , 'like',chain_init.P ) );
    chain.L = cat( 2 , chain_init.L ,   nan( 1              , d_length , 'like',chain_init.L ) );
    chain.C = cat( 2 , chain_init.C ,   nan( 1              , d_length , 'like',chain_init.C ) );
    chain.h = cat( 2 , chain_init.h ,   nan( chain.params.M , d_length , 'like',chain_init.h ) );
    chain.t = cat( 2 , chain_init.t ,   nan( chain.params.M , d_length , 'like',chain_init.t ) );
    chain.b = cat( 2 , chain_init.b , false( chain.params.M , d_length , 'like',chain_init.b ) );
    
    if flag_visual
        Gim = chainer_visualize([],chain);
    end
    
    %---------------------------- expand chain
    r = chain_init.length+1;
    while r <= chain.length
        
        chain.sample = sampler_update(chain.sample,chain.params);
        
        if mod(chain.sample.i,chain.stride) == 0
            
            chain.i(  r) = chain.sample.i;
            chain.P(:,r) = chain.sample.P;
            chain.L(  r) = chain.sample.L;
            chain.C(  r) = chain.sample.C;
            chain.h(:,r) = chain.sample.h;
            chain.t(:,r) = chain.sample.t;
            chain.b(:,r) = chain.sample.b;
            
            if flag_visual
                chainer_visualize(Gim,chain);
            end
            
            if flag_status
                disp([  'i = ', num2str(chain.sample.i,'%d'), ...
                     ' - B = ', num2str(sum(chain.sample.b),'%d'), ...
                     ' - acc = ', ...
                                num2str( chain.sample.rec(1,:)./chain.sample.rec(2,:)  * 100 ,'%#6.2f') , ' %', ...
                     ])
            end
            
            r = r+1;
        end
    end    

    if flag_status
        disp('CHAINER: chain expanded')
    end


% reduce chain ------------------------------------------------------------
elseif d_length < 0

    d_length = min(-d_length,chain_init.length);

    chain.params = chain_init.params;
    chain.length = d_length;
    chain.stride = nan;
    chain.ledger = chain_init.ledger;
    chain.sizeGB = nan;
    chain.record = chain_init.record;
    chain.sample = chain_init.sample;
    
    ind = mod(chain_init.length,d_length)+(floor(chain_init.length/d_length)*(1:d_length));

    chain.i = chain_init.i(  ind);
    chain.P = chain_init.P(:,ind);
    chain.L = chain_init.L(  ind);
    chain.C = chain_init.C(  ind);
    chain.h = chain_init.h(:,ind);
    chain.t = chain_init.t(:,ind);
    chain.b = chain_init.b(:,ind);
    
    chain.stride = double(chain.i(2)-chain.i(1));
    
    if flag_status
        disp('CHAINER: chain reduced')
    end
    
    
% reset chain -------------------------------------------------------------
elseif isempty(d_length)

    chain = chain_init;
    
    chain.record = [chain.record; [ chain.sample.i , chain.sample.rec(1,:)./chain.sample.rec(2,:) , nan , chain.sample.rec(3,:)./chain.sample.rec(1,:) ] ];

    chain.sample.rec(1,:) = 0;
    chain.sample.rec(2,:) = realmin;
    chain.sample.rec(3,:) = realmin;

    if flag_status
        disp('CHAINER: chain reset')
    end
    
end



% store the seed for future expansion
chain.random = rng();


%% book-keeping
chain.sizeGB = get_sizeGB(chain);               % mem size

% ledger
wall_time = toc(tic_id);
chain.ledger = [chain.ledger; double(chain.i(end)), wall_time];

if flag_status
    disp(['( wall time = ',num2str(wall_time),' s, overall wall time = ',num2str(sum(chain.ledger(:,2))),' s )'])
end



end


%% auxiliary functions

function sizeGB = get_sizeGB(chain)
    sizeGB = whos( inputname(1) );
    sizeGB = sizeGB.bytes/1024^3;
end



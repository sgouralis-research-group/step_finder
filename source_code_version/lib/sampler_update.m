function sample = sampler_update(sample, params)

sample.i = sample.i + 1;

%% Most advanced sampler
for tag = randperm(3)
    switch tag
        case 1 % Update c and h jointly
            [sample.C, sample.h, sample.u, sample.L, sample.rec(:,tag)] = ...
                sampler_update_c_h_combined_mess( ...
                    sample.C, sample.h, sample.u, sample.L, sample.rec(:,tag), ...
                    sample.t, sample.b, params);

        case 2 % Update t with slice sampler
            [sample.t, sample.u, sample.L, sample.rec(:,tag)] = ...
                sampler_update_t_slice_sampler( ...
                    sample.t, sample.u, sample.L, sample.rec(:,tag), ...
                    sample.C, sample.h, sample.b, params);

        case 3 % Update b and h jointly
            [sample.b, sample.h, sample.C, sample.u, sample.L, sample.rec(:,tag)] = ...
                sampler_update_b_h_c_jointly( ...
                    sample.b, sample.h, sample.C, sample.u, sample.L, sample.rec(:,tag), ...
                    sample.t, params);
        otherwise
            error('Unknown sampler update tag: %d', tag);
    end
end

%% Update priors 
sample.P = get_log_priors(sample.C, sample.h, sample.t, sample.b, params);

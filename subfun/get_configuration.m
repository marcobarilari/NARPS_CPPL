function cfg = get_configuration(all_GLMs, opt, iGLM)       

        cfg.HPF = opt.HPF(all_GLMs(iGLM,5));
        cfg.RT_correction = opt.RT_correction(all_GLMs(iGLM,7));
        cfg.block_type = opt.block_type{all_GLMs(iGLM,8)};
        cfg.time_der = opt.time_der(all_GLMs(iGLM,9));
        cfg.mvt = opt.mvt(all_GLMs(iGLM,10));
        
        if isfield(opt, 'prefix')
            cfg.prefix = opt.prefix;
        end
        
end


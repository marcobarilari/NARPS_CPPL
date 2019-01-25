function cfg = get_configuration(all_GLMs, opt, iGLM)       

        cfg.HPF = opt.HPF(all_GLMs(iGLM,1));
        cfg.RT_correction = opt.RT_correction(all_GLMs(iGLM,2));
        cfg.design = opt.design{all_GLMs(iGLM,3)};
        cfg.time_der = opt.time_der(all_GLMs(iGLM,4));
        cfg.mvt = opt.mvt(all_GLMs(iGLM,5));
        
        if isfield(opt, 'prefix')
            cfg.prefix = opt.prefix;
        end
        
end


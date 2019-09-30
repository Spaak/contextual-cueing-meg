import pickle
import gzip
import time

import numpy as np
import scipy as sp
import scipy.io as sio

import pymc3 as pm
import theano
import theano.tensor as tt

import matplotlib.pyplot as plt


rootdir = '/project/3018029.07'


def load_traces(model_type, detrend_blockwise=False, do_wait=False):
    # load sampler results
    # do_wait indicates whether to wait until all results are available, or to
    # raise an exception in case a file is not found.
    filepattern = 'scratch/{}_trace_sub{:02d}_detrend_blockwise={}.pkl.gz'
    nsub = 36
    alltrace = []
    allmodel = []
    has_all_data = False
    while True:
        try:
            for k in range(nsub):
                with gzip.open(filepattern.format(model_type, k, detrend_blockwise)) as f:
                    results = pickle.load(f)
                    alltrace.append(results[0])
                    allmodel.append(results[1])
            break
        except FileNotFoundError:
            if do_wait:
                time.sleep(0.5)
            else:
                raise
    
    return alltrace, allmodel


def fetch_data():
    # load the data
    matdat = sio.loadmat(rootdir + '/processed/combined/matlab/all-rt-dat-for-modelling.mat',
        squeeze_me=True)
    
    allrts = list(matdat['allrts'])
    allcond = [x.astype('bool') for x in matdat['allcond']]
    allinds = list(matdat['allinds'])
    
    return allrts, allcond, allinds


def preproc_rts(rts, trialindex, detrend_blockwise=False, conds=None):
    logrts = np.log10(rts)
    if detrend_blockwise:
        blockindex = np.floor(trialindex / 40)
        blockindex[blockindex == 22] = 21
        # compute mean(mean(new RTs), mean(old RTs)) per block to alleviate
        # concern that later blocks have more New than Old trials (but equal
        # numbers in early blocks)
        blockmeans = np.zeros_like(logrts)
        for b in range(22):
            blockmeans[blockindex==b] = np.mean((
                np.mean(logrts[(blockindex==b) & conds]),
                np.mean(logrts[(blockindex==b) & (~conds)])))
        
        # now use the per-trial expanded blockmeans as the dependent variable
        # in the detrending
        coefs = np.polyfit(trialindex, blockmeans, deg=1)
    else:
        coefs = np.polyfit(trialindex, logrts, deg=1)

    residuals = logrts - (coefs[1]+trialindex*coefs[0])
    return residuals, logrts, coefs


def sample_and_save_subj(sub_id, model_type='sp', detrend_blockwise=False):
    print('subject index: {}'.format(sub_id))
    
    allrts, allcond, allinds = fetch_data()
    resid, logrts, coefs = preproc_rts(allrts[sub_id], allinds[sub_id],
        detrend_blockwise=detrend_blockwise, conds=allcond[sub_id])
    
    if model_type == 'sp':
        trace, model = do_sampling_switchpoint(resid, allinds[sub_id], allcond[sub_id])
    elif model_type == 'nosp':
        trace, model = do_sampling_noswitchpoint(resid, allinds[sub_id], allcond[sub_id])
    elif model_type == 'linear':
        trace, model = do_sampling_linearramp(resid, allinds[sub_id], allcond[sub_id])
    elif model_type == 'blocklinear':
        trace, model = do_sampling_blockwiselinearramp(resid, allinds[sub_id], allcond[sub_id])
    elif model_type == 'noctxcue':
        trace, model = do_sampling_noctxcue(resid, allinds[sub_id], allcond[sub_id])
    elif model_type == 'quadratic':
        trace, model = do_sampling_quadratic(resid, allinds[sub_id], allcond[sub_id])
    
    with model:
        pm.traceplot(trace)
        plt.savefig('plots/{}_trace_sub{:02d}_detrend_blockwise={}.png'.format(model_type, sub_id, detrend_blockwise))
        plt.close('all')
        
        ppc = pm.sample_posterior_predictive(trace, samples=1000)
        ppc_plot(allrts[sub_id], allinds[sub_id], allcond[sub_id], ppc)
        plt.savefig('plots/{}_ppc_sub{:02d}_detrend_blockwise={}.png'.format(model_type, sub_id, detrend_blockwise))
        plt.close('all')
        
        with gzip.open('scratch/{}_trace_sub{:02d}_detrend_blockwise={}.pkl.gz'.format(model_type, sub_id, detrend_blockwise), 'wb') as f:
            pickle.dump((trace, model), f)


def do_sampling_switchpoint(rt_residuals, trialindex, conds):
    # use empirical mean (ignoring condition or time point) as center of prior
    mu_obs = np.mean(rt_residuals)
    sd_obs = np.std(rt_residuals)
    
    model = pm.Model()
    with model:
        # RTs before switchpoint all come from same distribution
        mu_before = pm.Normal('mu_before', mu=mu_obs, sd=sd_obs*2, testval=mu_obs)
        
        # RTs after switchpoint come from normal distribution where mean depends on
        # condition
        mu_after_old_benefit = pm.Normal('mu_after_old_benefit', mu=mu_obs, sd=sd_obs*2, testval=mu_obs)
        mu_after = pm.math.switch(conds, mu_before-mu_after_old_benefit, mu_before)
        
        switchpoint = pm.DiscreteUniform('switchpoint', lower=0, upper=22,
            testval=5)
        
        mu = pm.math.switch(trialindex > switchpoint*40, mu_after, mu_before)
        
        sigma = pm.HalfNormal('sigma', sd=sd_obs*2, testval=sd_obs*2)
        
        rt_modelled = pm.Normal('rt_modelled', mu=mu, sd=sigma, observed=rt_residuals)
        
        step = pm.Metropolis()
        
        trace = pm.sample(40000, step=step, start=model.test_point, chains=4,
            cores=4)
    
    return trace[20000::5], model


def do_sampling_noswitchpoint(rt_residuals, trialindex, conds):
    # use empirical mean (ignoring condition or time point) as center of prior
    mu_obs = np.mean(rt_residuals)
    sd_obs = np.std(rt_residuals)
    
    model = pm.Model()
    with model:
        mu_new =  pm.Normal('mu_new', mu=mu_obs, sd=sd_obs*2, testval=mu_obs)
        mu_old_benefit =  pm.Normal('mu_old_benefit', mu=mu_obs, sd=sd_obs*2, testval=mu_obs)
        sigma = pm.HalfNormal('sigma', sd=sd_obs*2, testval=sd_obs*2)
        
        mu = pm.math.switch(conds, mu_new-mu_old_benefit, mu_new)
        
        rt_modelled = pm.Normal('rt_modelled', mu=mu, sd=sigma, observed=rt_residuals)
        
        step = pm.Metropolis()
        
        trace = pm.sample(40000, step=step, start=model.test_point, chains=4,
            cores=4)
    
    return trace[20000::5], model


def do_sampling_noctxcue(rt_residuals, trialindex, conds):
    # use empirical mean (ignoring condition or time point) as center of prior
    mu_obs = np.mean(rt_residuals)
    sd_obs = np.std(rt_residuals)
    
    model = pm.Model()
    with model:
        mu =  pm.Normal('mu', mu=mu_obs, sd=sd_obs*2, testval=mu_obs)
        sigma = pm.HalfNormal('sigma', sd=sd_obs*2, testval=sd_obs*2)
        
        rt_modelled = pm.Normal('rt_modelled', mu=mu, sd=sigma, observed=rt_residuals)
        
        step = pm.Metropolis()
        
        trace = pm.sample(40000, step=step, start=model.test_point, chains=4,
            cores=4)
    
    return trace[20000::5], model


def do_sampling_linearramp(rt_residuals, trialindex, conds):
    # use empirical mean (ignoring condition or time point) as center of prior
    mu_obs = np.mean(rt_residuals)
    sd_obs = np.std(rt_residuals)
    
    model = pm.Model()
    with model:
        mu_new =  pm.Normal('mu_new', mu=mu_obs, sd=sd_obs*2, testval=mu_obs)
        mu_old_benefit =  pm.Normal('mu_old_benefit', mu=mu_obs, sd=sd_obs*2, testval=mu_obs)
        mu_ramp_old_benefit =  pm.Normal('mu_ramp_old_benefit', mu=mu_obs, sd=sd_obs*2, testval=mu_obs)
        
        sigma = pm.HalfNormal('sigma', sd=sd_obs*2, testval=sd_obs*2)
        
        mu = pm.math.switch(conds, mu_new-mu_old_benefit-trialindex*mu_ramp_old_benefit, mu_new)
        
        rt_modelled = pm.Normal('rt_modelled', mu=mu, sd=sigma, observed=rt_residuals)
        
        step = pm.Metropolis()
        
        trace = pm.sample(40000, step=step, start=model.test_point, chains=4,
            cores=4)
    
    return trace[20000::5], model
    

def do_sampling_quadratic(rt_residuals, trialindex, conds):
    # use empirical mean (ignoring condition or time point) as center of prior
    mu_obs = np.mean(rt_residuals)
    sd_obs = np.std(rt_residuals)

    model = pm.Model()
    with model:
        mu_new =  pm.Normal('mu_new', mu=mu_obs, sd=sd_obs*2, testval=mu_obs)
        mu_old_benefit =  pm.Normal('mu_old_benefit', mu=mu_obs, sd=sd_obs*2, testval=mu_obs)
        mu_ramp_old_benefit =  pm.Normal('mu_ramp_old_benefit', mu=mu_obs, sd=sd_obs*2, testval=mu_obs)
        
        mu_ramp_quadratic_old_benefit = pm.Normal('mu_ramp_quadratic_old_benefit',
            mu=mu_obs, sd=sd_obs*2)

        sigma = pm.HalfNormal('sigma', sd=sd_obs*2, testval=sd_obs*2)

        mu = pm.math.switch(conds, (mu_new-mu_old_benefit-trialindex*mu_ramp_old_benefit-
            trialindex**2*mu_ramp_quadratic_old_benefit), mu_new)

        rt_modelled = pm.Normal('rt_modelled', mu=mu, sd=sigma, observed=rt_residuals)

        step = pm.Metropolis()

        trace = pm.sample(40000, step=step, start=model.test_point, chains=4,
            cores=4)

    return trace[20000::5], model


def do_sampling_blockwiselinearramp(rt_residuals, trialindex, conds):
    # use empirical mean (ignoring condition or time point) as center of prior
    mu_obs = np.mean(rt_residuals)
    sd_obs = np.std(rt_residuals)
    
    trialindex = np.floor(trialindex / 40)
    
    model = pm.Model()
    with model:
        mu_new =  pm.Normal('mu_new', mu=mu_obs, sd=sd_obs*2, testval=mu_obs)
        mu_old_benefit =  pm.Normal('mu_old_benefit', mu=mu_obs, sd=sd_obs*2, testval=mu_obs)
        mu_ramp_old_benefit =  pm.Normal('mu_ramp_old_benefit', mu=mu_obs, sd=sd_obs*2, testval=mu_obs)
        
        sigma = pm.HalfNormal('sigma', sd=sd_obs*2, testval=sd_obs*2)
        
        mu = pm.math.switch(conds, mu_new-mu_old_benefit-trialindex*mu_ramp_old_benefit, mu_new)
        
        rt_modelled = pm.Normal('rt_modelled', mu=mu, sd=sigma, observed=rt_residuals)
        
        step = pm.Metropolis()
        
        trace = pm.sample(40000, step=step, start=model.test_point, chains=4,
            cores=4)
    
    return trace[20000::5], model
    

def ppc_plot(rts, trialindex, conds, ppc):
    fig, ax = plt.subplots(nrows=2, ncols=1, sharex=True)
    resid, logrts, coefs = preproc_rts(rts, trialindex)
    
    def _do_plot(ax, rt_pred, data):
        ax.fill_between(trialindex[conds], rt_pred[0, conds], rt_pred[4, conds],
            facecolor='r', alpha=0.1, label='95% PPC CI Old')
        ax.fill_between(trialindex[~conds], rt_pred[0, ~conds], rt_pred[4, ~conds],
            facecolor='g', alpha=0.1, label='95% PPC CI New')
        ax.fill_between(trialindex[conds], rt_pred[1, conds], rt_pred[3, conds],
            facecolor='r', alpha=0.25, label='50% PPC CI Old')
        ax.fill_between(trialindex[~conds], rt_pred[1, ~conds], rt_pred[3, ~conds],
            facecolor='g', alpha=0.25, label='50% PPC CI New')
        ax.plot(trialindex[conds], rt_pred[2, conds], 'r', label='PPC median Old')
        ax.plot(trialindex[~conds], rt_pred[2, ~conds], 'g', label='PPC median New')
        
        # plot actual data
        ax.plot(trialindex[conds], data[conds], 'r.', label='Observed Old')
        ax.plot(trialindex[~conds], data[~conds], 'g.', label='Observed New')
    
    # plot quantiles of posterior predictive
    rt_pred = np.quantile(ppc['rt_modelled'], [0.025, 0.25, 0.5, 0.75, 0.975], axis=0)
    _do_plot(ax[0], rt_pred, resid) 
    ax[0].set_ylabel('RT residual after linear detrend')
    ax[0].legend()
    
    # also transform to RT in seconds
    rt_pred = 10**(rt_pred + (coefs[1]+trialindex*coefs[0]))
    _do_plot(ax[1], rt_pred, rts) 
    ax[1].set_ylabel('RT (s)')
    ax[1].legend()
    
    ax[1].set_xlabel('Trial')

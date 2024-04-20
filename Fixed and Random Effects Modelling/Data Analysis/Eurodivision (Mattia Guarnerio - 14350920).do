*****************************************
** Fixed and Random Effects Modelling (2023) **
** Euro(di)vision (Mattia Guarnerio - 14350920) *********
*****************************************

************************************************************************************************

** -- General settings -- ** 
	clear // Cleaning data and value labels from memory
	clear matrix // Eliminating all matrices from memory
	set more off // Telling Stata to run the commands continuously without worrying about the capacity of the results window to display the results
	set seed 20082013 // Specifying the initial value of the random-number seed used by the random-number functions
	cap log close // Automatically closing the log file when there is a dofile error of some sort
	set scheme s2mono // Setting the graphics scheme to be used
	
** -- Setting paths -- **
	global path "C:\Users\Mattia aka Mario\Desktop\UvA\First Year\Fixed and Random Effects Modelling (T. van der Meer)\Final Paper"
	
** -- Loading the dataset -- **
	use "C:\Users\Mattia aka Mario\Desktop\UvA\First Year\Fixed and Random Effects Modelling (T. van der Meer)\Final Paper\ESS469.dta", clear
	
************************************************************************************************

** -- Visual Exploration of the Outcome Variable (European Union: European unification go further or gone too far - i.e., euftf) -- **

// I want the reader to be able to visualise the variation of the outcome variable at Levels 1, 2, and 3, to support their understanding of the empty model's interpretation

// Level-1 (individuals)
hist euftf, percent col("0 204 204") xlabel(0(2)10) ylabel(0(5)32, angle(0))width(.3) ytitle("Percent of respondents") xtitle ("Support for further EU integration")

// Level-2 (surveys nested within countries, time-variant)

// Wave 4
hist euftf if cntry_wave < 412, percent by(cntry_wave_char) col("0 204 204") xlabel(0(2)10) ylabel(0(15)32, angle(0)) width(.3) ytitle("Percent of respondents") xtitle ("Support for further EU integration") name(W4n1, replace)

hist euftf if cntry_wave >= 412 & cntry_wave < 600, percent by(cntry_wave_char) col("0 204 204") xlabel(0(2)10) ylabel(0(15)32, angle(0)) width(.3) ytitle("Percent of respondents") xtitle ("Support for further EU integration") name(W4n2, replace)

// Wave 6
hist euftf if cntry_wave >= 601 & cntry_wave < 612, percent by(cntry_wave_char) col("0 204 204") xlabel(0(2)10) ylabel(0(15)32, angle(0)) width(.3) ytitle("Percent of respondents") xtitle ("Support for further EU integration") name(W6n1, replace)

hist euftf if cntry_wave >= 612 & cntry_wave < 900, percent by(cntry_wave_char) col("0 204 204") xlabel(0(2)10) ylabel(0(15)32, angle(0)) width(.3) ytitle("Percent of respondents") xtitle ("Support for further EU integration") name(W6n2, replace)

// Wave 9
hist euftf if cntry_wave >= 901 & cntry_wave < 912, percent by(cntry_wave_char) col("0 204 204") xlabel(0(2)10) ylabel(0(15)32, angle(0)) width(.3) ytitle("Percent of respondents") xtitle ("Support for further EU integration") name(W9n1, replace)

hist euftf if cntry_wave >= 912, percent by(cntry_wave_char) col("0 204 204") xlabel(0(2)10) ylabel(0(15)32, angle(0)) width(.3) ytitle("Percent of respondents") xtitle ("Support for further EU integration") name(W9n2, replace)

/// I finally combine the six graphs so to intuitively show the time-varying country distributions
graph combine W4n1 W6n1 W9n1, rows(2) cols(2)

graph combine W4n2 W6n2 W9n2, rows(2) cols(2)

// Level-3 (countries, time-invariant)
hist euftf if cntry_num < 13, percent by(cntry) col("0 204 204") xlabel(0(2)10) ylabel(0(5)32, angle(0)) xtitle("Percent of respondents") ytitle("Support for further integration") width(.3) name(n1, replace)

hist euftf if cntry_num >= 13, percent by(cntry) col("0 204 204") xlabel(0(2)10) ylabel(0(5)32, angle(0)) xtitle("Percent of respondents") ytitle("Support for further integration") width(.3) name(n2, replace)

// I finally combine the two graphs
graph combine n1 n2, cols(2)

************************************************************************************************

** -- The Empty Model -- **

mixed euftf, ml dfmethod(residual) var // Fitting the simplest model
est store A // Saving the estimates in the "A" object

mixed euftf || cntry: || cntry_wave: , ml dfmethod(residual) var // Fitting the empty model with random country-deviations from the mean
est store B // Saving the estimates in the "B" object

lrtest A B // Testing for improvement in model fit
est clear // Clearing the stored estimates

/// It seems that the multilevel model's fit is preferrable from a likelihood-ratio perspective!

// I calculate the VPC / ICC
estat icc

// 2,860% of total variation is at the time-invariant country level
// 5,966% of the total remaining variation after accounting for time-invariant country-level differences is at the time-variant - i.e., survey - country level

************************************************************************************************

** -- Random Intercept Within-Between Framework -- **

/// I now estimate the random intercept model, including all the Level-1, Level-2, and Level-3 predictors. I specify surveys as Level-2 clusters, and countries as Level-3 clusters, and that I wish to run a restricted maximum likelihood estimation of the variances.

/// I estimate the t instead of the z test statistic, but it is important to note that p-values for inference at Level-2 and Level-3 must be computed by hand with the correct degrees of freedom, with the m - l - 1 heuristic provided by Elff et al. (2021).

/// I do not include cross-level interactions in the random intercept specification, because Heisig and Schaeffer (2018) have demonstrated that multilevel models involving cross-level interactions should always allow for random slopes on the lower-level components of those interactions. Failure to do so will result in severely anti-conservative statistical inference.

mixed euftf lrscale_m female agea_m eduyrs_m cntry_lrscale_diff gdp_z_diff cpi_diff cntry_lrscale gdp_z cpi || cntry: || cntry_wave: , reml dfmethod(residual) var

est store riwb // I store the estimates in the "riwb" object

/// I do not check whether the random intercept model yields a better fit than the empty model with no covariates, for two reasons. First, in Stata the likelihood-ratio test cannot be ran on nested models estimated with the REML method, because for the test to work they should have the same fixed part. Second, the decision to fit the random intercept model is purely theory-driven, so taking decisions on a likelihood-ratio test would not make any substantive sense. 

estat icc // I get the Intra-Class Correlation from the post-estimation command "estat"

/// When allowing for random intercepts, 2,931% of the total remaining variation is at the time-invariant country level
// When allowing for random intercepts, 5,324% of the total remaining variation after accounting for time-invariant country-level differences is at the time-variant - i.e., survey - country level

/// I now proceed to calculate the robust p-values by hand. 

/// Level-2, survey - i.e., country (time-variant) - with 66 - 3 - 1 = 62 degrees of freedom.

/// Time-variant divergence from time-invariant mean of placement on left right scale at the country level - i.e., time-variant, within-country effect
display ttail(62, 3.49) * 2 // 0.001

/// Level-3, country (time-invariant) - with 23 - 3 - 1 = 19 degrees of freedom.

/// Average placement on left right scale at the country level (time-invariant) - i.e., time-invariant, between-country effect
display ttail(19, 1.80) * 2 // 0.088

/// The robust p-value estimations do not change the interpretation I would have given had I employed the standard anti-conservative inferential statistics, but they aid me in more confidently corroborating the null hypothesis regarding the between-country, time-invariant effect.

************************************************************************************************

** -- Random Slopes Within-Between Model Selection -- **

/// From a theoretical perspective, it makes no sense not to let the slope for the main Level-2 independent variable - i.e., "cntry_lrscale_diff", the time-variant, within-country effect - vary among Level-3 units - i.e., countries. My hypotheses are based on a theoretical framework that involves the impact of national proxies so it is logical that I expect the time-variant, within-country effects to be different for each country.

/// Moreover, the same applies for the individual-level left-to-right political positioning - i.e., "lrscale_m" - because even if it is a control variable, I have a substantive interest in its interaction effect with the main Level-2, and Level-3 dependent variables. Heisig and Schaeffer (2018) have demonstrated that multilevel models involving cross-level interactions should always allow for random slopes on the lower-level components of those interactions. Failure to do so will result in severely anti-conservative statistical inference.

/// On the other hand, I have no strong theoretical expectations in favour or against letting the other control variables at Level-1 and Level-2 vary at Level-2 and Level-3. Nevertheless, I separately test for the model fit achieved with their inclusion as random slopes, following Hox et al.'s (2010) recommendations. 

/// I decide a priori to indicate an unstructured covariance matrix, because I have strong theoretical reasons - related to the cue-taking and benchmarking approaches - to expect that each pair of observations within a cluster - be it a survey, or a country (time-invariant) - has a distinct correlation. In short, national cues change as the political context mutates over time - especially in the space of 4, or even 6 years - and are country-dependent by definition.

/// Although it would be intuitive to just fit the most flexible models, illustrative analyses of ESS data carried out by Heisig, Schaeffer, and Giesecke (2017) indicate that maximally flexible mixed-effects model do not perform well in my real-life setting, and are also likely not to achieve convergence. Therefore, I need to balance parsimony and flexibility, adopting a more data-driven approach.

/// Level-1 at Level-2

foreach var of varlist female agea_m eduyrs_m {
	
	/// At each step of the loop, I estimate a mixed-effects regression model of the outcome variable "euftf", letting the slopes of given Level-1 predictor vary between Level-2 clusters (surveys).
	
	/// The "cov(unstructured)" option specifies the estimation assumption that each pair of observations within a cluster has a distinct correlation, resulting in a fully unconstrained covariance matrix.
	
	/// The "reml" option indicates that restricted maximum likelihood estimation is employed, and the "var" option requests variance components estimates. I specify a maximum number of 20 iterations because if the singular inclusion of the given random slopes already causes computational problems, I will not include it in the final formulation, as it would certainly cause convergence problems.
	
	mixed euftf lrscale_m female agea_m eduyrs_m cntry_lrscale_diff gdp_z_diff cpi_diff cntry_lrscale gdp_z cpi || cntry: lrscale_m cntry_lrscale_diff, cov(unstructured) || cntry_wave: lrscale_m `var', cov(unstructured) iter(20) reml dfmethod(residual) var
	
	/// I save the results of the mixed-effects regression in a temporary object named after the given variable being tested.
	est store `var'
	}

foreach var of varlist female {
	
	lrtest riwb `var' // I only test the models that achieved convergence
	}

foreach var of varlist female agea_m eduyrs_m {
	drop _est_`var' // I drop the estimates from the mixed-effects regression to keep the environment clean	
	}
	
/// The models allowing for random slopes for "agea_m" and "eduyrs_m" at Level-2 did not converge. Thus, the only model I keep in consideration is the one allowing for random slopes for "female" at Level-2.

/// Level-1 at Level-3

foreach var of varlist female agea_m eduyrs_m {
	
	/// At each step of the loop, I estimate a mixed-effects regression model of the outcome variable "euftf", letting the slopes of given Level-1 predictor vary between Level-3 clusters (countries, time-invariant).
	
	/// The "cov(unstructured)" option specifies the estimation assumption that each pair of observations within a cluster has a distinct correlation, resulting in a fully unconstrained covariance matrix.
	
	/// The "reml" option indicates that restricted maximum likelihood estimation is employed, and the "var" option requests variance components estimates. I specify a maximum number of 20 iterations because if the singular inclusion of the given random slopes already causes computational problems, I will not include it in the final formulation, as it would certainly cause convergence problems.
	
	mixed euftf lrscale_m female agea_m eduyrs_m cntry_lrscale_diff gdp_z_diff cpi_diff cntry_lrscale gdp_z cpi || cntry: lrscale_m cntry_lrscale_diff `var', cov(unstructured) || cntry_wave: lrscale_m, cov(unstructured) iter(20) reml dfmethod(residual) var
	
	/// I save the results of the mixed-effects regression in a temporary object named after the given variable being tested.
	est store `var'
	}
	
foreach var of varlist female agea_m eduyrs_m {
	
	drop _est_`var' // I drop the estimates from the mixed-effects regression to keep the environment clean	
	}
	
/// The model allowing for random slopes for "female" at Level-2 did converge, but Stata was not able to compute standard errors for Level-2 and Level-3 variances and covariances. The other specification did not converge. Thus, I discard all the options for further Level-1 random slopes at Level-3.
	
/// Level-2 at Level-3

foreach var of varlist gdp_z_diff cpi_diff {
	
		/// At each step of the loop, I estimate a mixed-effects regression model of the outcome variable "euftf", letting the slopes of given Level-2 predictor vary between Level-3 clusters (countries, time-invariant).
	
	/// The "cov(unstructured)" option specifies the estimation assumption that each pair of observations within a cluster has a distinct correlation, resulting in a fully unconstrained covariance matrix.
	
	/// The "reml" option indicates that restricted maximum likelihood estimation is employed, and the "var" option requests variance components estimates. I specify a maximum number of 20 iterations because if the singular inclusion of the given random slopes already causes computational problems, I will not include it in the final formulation, as it would certainly cause convergence problems.
	
	mixed euftf lrscale_m female agea_m eduyrs_m cntry_lrscale_diff gdp_z_diff cpi_diff cntry_lrscale gdp_z cpi || cntry: lrscale_m cntry_lrscale_diff `var', cov(unstructured) || cntry_wave: lrscale_m, cov(unstructured) iter(20) reml dfmethod(residual) var
	
	/// I save the results of the mixed-effects regression in a temporary object named after the given variable being tested.
	est store `var'
	}

foreach var of varlist gdp_z_diff cpi_diff {
	
	drop _est_`var' // I drop the estimates from the mixed-effects regression to keep the environment clean	
	}
	
/// The model allowing for random slopes for "cpi_diff" at Level-2 did converge, but Stata was not able to compute standard errors for Level-2 and Level-3 variances and covariances. The other specification did not converge. Thus, I discard all the options for further Level-2 random slopes at Level-3.
	
/// In the end, the only addition that I could make in terms of model flexibility would be letting the slopes for the respondent's gender (Level-1) vary for each survey (Level-2). I decide against doing this, since I experienced several convergence problems. I prioritise model stability and interpretability, focusing on the fixed effects and key random effects that align with the research questions and theoretical framework of my study.

************************************************************************************************

** -- Random Slopes Within-Between Framework -- **

/// I now compute the random intercepts and random slopes within-between model, letting the slopes of the chosen Level-1 and Level-2 predictors - i.e., "lrscale_m", "cntry_lrscale_diff" - vary between Level-2 (surveys) and Level-3 (countries, time-invariant).

mixed euftf lrscale_m female agea_m eduyrs_m cntry_lrscale_diff gdp_z_diff cpi_diff cntry_lrscale gdp_z cpi || cntry: lrscale_m cntry_lrscale_diff, cov(unstructured) || cntry_wave: lrscale_m, cov(unstructured) reml dfmethod(residual) var

est store rswb // I store the estimates from this random intercept and random slopes within-between model in the "rswb" object

lrtest riwb rswb // I run a likelihood ratio test comparing the fit of the RIWB against the RSWB model

drop _est_riwb _est_rswb // I drop the estimates from the mixed-effects regressions to keep the environment clean	

/// Even if the null hypothesis is not on the boundary of the parameter space, and the naïve p-value is conservative, the latter is extremely close to zero, so it seems that the RSWB model's fit is preferrable from a likelihood-ratio perspective.

/// I do not base my decision of including cross-level interactions on the random slope variances at Level-1 for "lrscale_m", but on my research question and my hypotheses, following a purely theory-driven approach. I thus specify cross-level interactions among the time-variant, within-country, and the time-invariant, between-country effects of living in a left- or right-wing country, and the individual (Level-1) measure of left-to-right political positioning.

mixed euftf lrscale_m female agea_m eduyrs_m within_lr_int between_lr_int cntry_lrscale_diff gdp_z_diff cpi_diff cntry_lrscale gdp_z cpi || cntry: lrscale_m cntry_lrscale_diff, cov(unstructured) || cntry_wave: lrscale_m, cov(unstructured) reml dfmethod(residual) var

/// It does not make much sense to re-estimate the ICCs at Level-2 and 3, since they would be functions of the random slopes, and thus uninformative and hard to interpret due to the mathematical nature of the independent variables.

/// I now proceed to calculate the robust p-values by hand. 

/// Level-2, survey - i.e., country (time-variant) - with 66 - 3 - 1 = 62 degrees of freedom.

/// Time-variant divergence from time-invariant mean of placement on left right scale at the country level - i.e., time-variant, within-country effect
display ttail(62, 2.84) * 2 // 0.006

/// Level-3, country (time-invariant) - with 23 - 3 - 1 = 19 degrees of freedom.

/// Average placement on left right scale at the country level (time-invariant) - i.e., time-invariant, between-country effect
display ttail(19, 1.83) * 2 // 0.083

/// The robust p-value estimations do not change the interpretation I would have given had I employed the standard anti-conservative inferential statistics, but they aid me in more confidently corroborating the null hypothesis regarding the between-country, time-invariant effect.

/// It is important to note that I need not apply the degrees of freedom adjustment to the interaction effects, since they vary at Level-1 being a product of a Level-1 variable, and there are more than enough observations to make a safe inference.

/// I now want to visualise the random slopes for the time-variant, within-country effect.

predict u0 u1 u2 u3 u4, reffects // First, I store the predicted values of the random effects - i.e., the random intercepts and slopes

predict u0se u1se u2se u3se u4se, reses // Then, I save the comparative standard errors in corresponding objects

sort u1 // I sort the predicted values of the random effects for the time-variant, within-country effect in ascending order

egen pickone = tag(cntry) // I tag all the first observations of unique country, time-invariant (Level-3) values

gen u1rank = sum(pickone) // I generate the "u1rank" variable, which is equal to the cumulative sum of the binary variable "pickone" that indicates whether each observation is the first observation for a particular value of "u1"

/// I now call the serrbar command to create a caterpillar plot of the estimated random slope values and their comparative standard errors

serrbar u1 u1se u1rank if pickone == 1, col("255 127 80") scale(1.96) yline(0) mvopts(mlabel(cntry) mlabpos(12) mlabgap(3) col("0 204 204")) xlab("") ylab(-5(1)5) ytitle("Random Slope Value") xtitle ("Country") title("Time-variant within-country Random Slopes")

/// Although the significant Level-2 within-country effect indicates a consistently negative pattern across the countries - i.e., living in an increasingly right-wing country really does decrease support for further European integration, even when controlling for the individual-level political positioning - the large confidence intervals of the effects for the country-specific, time-variant effects suggest that interpretations and inferences regarding national contexts would not be reliable.

/// Additional data - i.e., a larger sample size at Level-3 - could help provide better information, but this requirement cannot be satisfied neither under the current circumstances - i.e., there is insufficient data for the EU member countries that I excluded a priori - nor in general - i.e., in the best possible scenario, with all the EU member countries being surveyed, the Level-3 clusters would be 28.

drop u0 u1 u2 u3 u4 u0se u1se u2se u3se u4se pickone u1rank // I drop all post-estimations and auxiliary variables to keep the environment clean

************************************************************************************************

** -- Robustness Checks -- **

/// I now turn to the execution of several robustness checks, to verify my findings. First, I check whether restricting the number of Level-3 clusters - i.e., countries, time-invariant - to avoid having missing data at Level 2 leads to markedly different results. The countries that have missing data at Level-2 are Croatia, Italy, and Latvia.

/// I generate a dummy variable taking the value of 1 for Croatian, Italian, and Latvian respondents, following van der Meer et al.'s (2010) methodological recommendations.

gen missing_l2 = (cntry == "HR" | cntry == "IT" | cntry == "LV")

mixed euftf lrscale_m female agea_m eduyrs_m within_lr_int between_lr_int cntry_lrscale_diff gdp_z_diff cpi_diff cntry_lrscale gdp_z cpi missing_l2 || cntry: lrscale_m cntry_lrscale_diff, cov(unstructured) || cntry_wave: lrscale_m, cov(unstructured) reml dfmethod(residual) var

/// I now proceed to re-calculate the robust p-values by hand. 

/// Level-2, survey - i.e., country (time-variant) - with 66 - 3 - 1 = 62 degrees of freedom.

/// Time-variant divergence from time-invariant mean of placement on left right scale at the country level - i.e., time-variant, within-country effect
display ttail(62, 2.86) * 2 // 0.006

/// Level-3, country (time-invariant) - with 23 - 4 - 1 = 18 degrees of freedom.

/// Average placement on left right scale at the country level (time-invariant) - i.e., time-invariant, between-country effect
display ttail(18, 1.58) * 2 // 0.132

/// The conclusions I reached within the best model within the analysis - i.e., the random-slopes within-between framework - are robust to the more restrictive assumption of no missing data at Level-2.

drop missing_l2 // I drop the country-specific dummy to keep the environment clean

/// Influential cases

/// I now want to check whether the results of the random-slopes, within-between model are robust to clusters of influential surveys, or countries. Thus, I assess the DFBETAs diagnostics for the interaction effects, and the main Level-2 and Level-3 variables.

/// In my specific case, bivariate scatterplots would be hard to interpret since the main outcome variable, euftf, is not continuous. The best tool to reach my goal is the mltcooksd ado. Since it is based on xtmixed, I cannot get the Student's t-test statistics. However, this does not impact my robustness check, since I am looking for influential cases, and not carrying out statistical inference.

/// The biggest issue is that mltcooksd does not support three-level models, and there is no easy fix to get around this problem. Moreover, when trying to only take the Level-3 (country, time-invariant) clustering and random slopes into account, the command just refuses to run, yielding a conformability error, likely because the estimation is too complex. Instead of not carrying out the robustness check at all, the best I can do is to find influential surveys by specifying surveys (Level-2) as the sole upper-level units in the random-slopes specification. Additionally, I separately examine Level-3 outliers within the random-intercept framework, to facilitate model convergency.

/// Level-2 outliers

xtmixed euftf lrscale_m female agea_m eduyrs_m within_lr_int between_lr_int cntry_lrscale_diff gdp_z_diff cpi_diff cntry_lrscale gdp_z cpi || cntry_wave_char: lrscale_m, cov(unstructured) reml var

mltcooksd, fixed random counter graph

/// I specify options for printing fixed and random effects separately, providing an ETA because the command takes very long to run, and producing a DFBETAs graph as an output.

drop mltl2idstr // I drop this Level-2 identifier variable produced by the mltcooksd command.

/// Influential surveys are defined as those Level-2 clusters that exhibit a DFBETAs below or above the negative or positive cutoffs.

/// Influential surveys for the time-variant, within-country interaction effect are: Italy (2012, 2018), Czech Republic (2012), Estonia (2008), Cyprus (2018), and Denmark (2018)

/// Influential surveys for the time-variant, within-country effect are: Bulgaria (2008), Czech Republic (2012), and Croatia (2008)

/// Influential surveys for the time-invariant, between-country interaction effect are: Poland (2012, 2018), Spain (2018), Germany (2018), and Latvia (2018)

/// Influential surveys for the time-invariant, between-country effect are: Latvia (2008), and Poland (2008, 2012)

/// In the end, for the overall robustness check I should factor out the influence of the following surveys: Bulgaria (2008), Croatia (2008), Czech Republic (2012), Cyprus (2018), Estonia (2008), Denmark (2018), Germany (2018), Italy (2012, 2018), Latvia (2008, 2018), Poland (2008, 2012, 2018), and Spain (2018), for a grand total of 15 out of 66 surveys.

/// I carry out repeated runs, as recommended by van der Meer et al. (2010). First, I only factor out the influential surveys for the time-variant, within-country effects. Second, I do the same solely for the time-invariant, between-country effects. Finally, I include all the influential surveys.

/// I generate the corresponding dummy variables, which take the value of 1 for different influential surveys, following van der Meer et al.'s (2010) methodological recommendations.

/// Within-effects
gen outliers_within = (cntry_wave_char == "BG 2008" | cntry_wave_char == "HR 2008" | cntry_wave_char == "CZ 2012" | cntry_wave_char == "CY 2018" | cntry_wave_char == "EE 2008" | cntry_wave_char == "DK 2018" | cntry_wave_char == "IT 2012" | cntry_wave_char == "IT 2018")

/// Between-effects
gen outliers_between = (cntry_wave_char == "DE 2018" | cntry_wave_char == "LV 2008" | cntry_wave_char == "LV 2018" | cntry == "PL" | cntry_wave_char == "ES 2018")

/// Running the robustness checks

/// Within-effects
mixed euftf lrscale_m female agea_m eduyrs_m within_lr_int between_lr_int cntry_lrscale_diff gdp_z_diff cpi_diff cntry_lrscale gdp_z cpi outliers_within || cntry: lrscale_m cntry_lrscale_diff, cov(unstructured) || cntry_wave: lrscale_m, cov(unstructured) reml dfmethod(residual) var

/// I now proceed to re-calculate the robust p-value by hand. 

/// Level-2, survey - i.e., country (time-variant) - with 66 - 4 - 1 = 61 degrees of freedom.

/// Time-variant divergence from time-invariant mean of placement on left right scale at the country level - i.e., time-variant, within-country effect
display ttail(61, 2.68) * 2 // 0.009

/// The findings illustrated within the random-slopes within-between framework that concern within-effects are robust, and are not driven by influential surveys.

/// Between-effects
mixed euftf lrscale_m female agea_m eduyrs_m within_lr_int between_lr_int cntry_lrscale_diff gdp_z_diff cpi_diff cntry_lrscale gdp_z cpi outliers_between || cntry: lrscale_m cntry_lrscale_diff, cov(unstructured) || cntry_wave: lrscale_m, cov(unstructured) reml dfmethod(residual) var

/// I now proceed to re-calculate the robust p-value by hand. 

/// Level-3, country (time-invariant) - with 23 - 3 - 1 = 19 degrees of freedom.

/// Average placement on left right scale at the country level (time-invariant) - i.e., time-invariant, between-country effect
display ttail(19, 2.05) * 2 // 0.054

/// The findings illustrated within the random-slopes within-between framework that concern between-effects are robust, and are not driven by influential surveys.

/// Overall
mixed euftf lrscale_m female agea_m eduyrs_m within_lr_int between_lr_int cntry_lrscale_diff gdp_z_diff cpi_diff cntry_lrscale gdp_z cpi outliers_within outliers_between || cntry: lrscale_m cntry_lrscale_diff, cov(unstructured) || cntry_wave: lrscale_m, cov(unstructured) reml dfmethod(residual) var

/// I now proceed to re-calculate the robust p-values by hand. 

/// Level-2, survey - i.e., country (time-variant) - with 66 - 5 - 1 = 60 degrees of freedom.

/// Time-variant divergence from time-invariant mean of placement on left right scale at the country level - i.e., time-variant, within-country effect
display ttail(60, 2.49) * 2 // 0.016

/// Level-3, country (time-invariant) - with 23 - 3 - 1 = 19 degrees of freedom.

/// Average placement on left right scale at the country level (time-invariant) - i.e., time-invariant, between-country effect
display ttail(19, 2.19) * 2 // 0.041

/// The findings illustrated within the random-slopes within-between framework that concern within-effects are robust, and are not driven by influential surveys, but the ones regarding between-effects are not robust. In particular, when factoring out the impact of all influential surveys, the time-invariant, between-country effect becomes significant.

/// This leads me to the conclusion that H1 cannot be fully disconfirmed, and that it should be tested with better model specifications, more potent hardware, and more refined data.

drop outliers_within outliers_between // I drop the auxiliary dummies to keep the environment clean

/// Level-3 outliers

/// I search for Level-3 outliers within the random-intercept framework, but this time I include interactions in the fixed part of the equation. Although multilevel models involving cross-level interactions that do not allow for random slopes on the lower-level interaction components result in severely anti-conservative confidence intervals, my specific focus is not statistical inference.

xtmixed euftf lrscale_m female agea_m eduyrs_m within_lr_int between_lr_int cntry_lrscale_diff gdp_z_diff cpi_diff cntry_lrscale gdp_z cpi || cntry: , reml var

mltcooksd, fixed random counter graph

/// I specify options for printing fixed and random effects separately, providing an ETA, and producing a DFBETAs graph as an output.

drop mltl2idstr // I drop this Level-2 identifier variable produced by the mltcooksd command.

/// Influential countries are defined as those Level-3 clusters that exhibit a DFBETAs below or above the negative or positive cutoffs.

/// There are no influential countries for the time-variant, within-country interaction effect.

/// Influential countries for the time-variant, within-country effect are: Bulgaria, and Croatia.

/// Influential countries for the time-invariant, between-country interaction effect are: Latvia, and Poland.

/// Influential countries for the time-invariant, between-country effect are: Czech Republic, and Poland.

/// In the end, for the overall robustness check I should factor out the influence of the following countries: Bulgaria, Croatia, Czech Republic, Latvia, and Poland, for a grand total of 5 out of 23 countries.

/// I carry out repeated runs, as recommended by van der Meer et al. (2010). First, I only factor out the influential countries for the time-variant, within-country effects. Second, I do the same solely for the time-invariant, between-country effects. Finally, I include all the influential countries.

/// I generate the corresponding dummy variables, which take the value of 1 for different influential countries, following van der Meer et al.'s (2010) methodological recommendations.

/// Within-effects
gen outliers_within = (cntry == "BG" | cntry_wave_char == "HR")

/// Between-effects
gen outliers_between = (cntry == "CZ" | cntry == "LV" | cntry == "PL")

/// Running the robustness checks

/// Within-effects
mixed euftf lrscale_m female agea_m eduyrs_m within_lr_int between_lr_int cntry_lrscale_diff gdp_z_diff cpi_diff cntry_lrscale gdp_z cpi outliers_within || cntry: lrscale_m cntry_lrscale_diff, cov(unstructured) || cntry_wave: lrscale_m, cov(unstructured) reml dfmethod(residual) var

/// I now proceed to re-calculate the robust p-value by hand. 

/// Level-2, survey - i.e., country (time-variant) - with 66 - 3 - 1 = 62 degrees of freedom.

/// Time-variant divergence from time-invariant mean of placement on left right scale at the country level - i.e., time-variant, within-country effect
display ttail(62, 3.07) * 2 // 0.003

/// The findings illustrated within the random-slopes within-between framework that concern within-effects are robust, and are not driven by influential countries.

/// Between-effects
mixed euftf lrscale_m female agea_m eduyrs_m within_lr_int between_lr_int cntry_lrscale_diff gdp_z_diff cpi_diff cntry_lrscale gdp_z cpi outliers_between || cntry: lrscale_m cntry_lrscale_diff, cov(unstructured) || cntry_wave: lrscale_m, cov(unstructured) reml dfmethod(residual) var

/// I now proceed to re-calculate the robust p-value by hand. 

/// Level-3, country (time-invariant) - with 23 - 4 - 1 = 18 degrees of freedom.

/// Average placement on left right scale at the country level (time-invariant) - i.e., time-invariant, between-country effect
display ttail(18, 1.51) * 2 // 0.148

/// The findings illustrated within the random-slopes within-between framework that concern between-effects are robust, and are not driven by influential countries.

/// Overall
mixed euftf lrscale_m female agea_m eduyrs_m within_lr_int between_lr_int cntry_lrscale_diff gdp_z_diff cpi_diff cntry_lrscale gdp_z cpi outliers_within outliers_between || cntry: lrscale_m cntry_lrscale_diff, cov(unstructured) || cntry_wave: lrscale_m, cov(unstructured) reml dfmethod(residual) var

/// I now proceed to re-calculate the robust p-values by hand. 

/// Level-2, survey - i.e., country (time-variant) - with 66 - 3 - 1 = 62 degrees of freedom.

/// Time-variant divergence from time-invariant mean of placement on left right scale at the country level - i.e., time-variant, within-country effect
display ttail(62, 3.06) * 2 // 0.003

/// Level-3, country (time-invariant) - with 23 - 5 - 1 = 17 degrees of freedom.

/// Average placement on left right scale at the country level (time-invariant) - i.e., time-invariant, between-country effect
display ttail(17, 1.98) * 2 // 0.064

/// The findings illustrated within the random-slopes within-between framework that concern within- and between-effects are robust, and are not driven by influential countries. 

drop outliers_within outliers_between // I drop the auxiliary dummies to keep the environment clean
